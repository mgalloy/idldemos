;+
; Set the viewplace_rect of the IDLgrView and refresh the graphics display.
;
; @param vp {in}{required}{type=fltarr(4)} viewplane_rect for the IDLgrView
;-
pro mgtilejp2::setvp, vp
    compile_opt strictarr

    self.oview->setProperty, viewplane_rect=vp
    self->refresh    
end


;+
; Move view of image.
;
; @param loc {in}{required}{type=lonarr(2)} location of lower-left corner of 
;        image to move to
;-
pro mgtilejp2::move, loc
    compile_opt strictarr

    self.curLoc = loc 
    vp = [loc, self.windowDims * self.zoomFactor] 
    self->setvp, vp
end


;+
; Zoom in/out by an increment. 
;
; @param incLevel {in}{required}{type=integer} amount to increment zoom level
;-
pro mgtilejp2::zoom, incLevel
    compile_opt strictarr

    self.zoomLevel += incLevel
     
    dims = self.windowDims * self.zoomFactor
    self.zoomFactor = 2.0^self.zoomLevel 
    self.curLoc += (dims - self.windowDims * self.zoomFactor) / 2.0
     
    vp = [self.curLoc, self.windowDims * self.zoomFactor]
    self->setvp, vp
end


;+
; Refresh the graphics display, including loading any new tile 
; data if necessary.
;-
pro mgtilejp2::refresh
    compile_opt strictarr
     
    oimage = self.oview->getByName('model/image')
    reqTiles $
       = self.owindow->queryRequiredTiles(self.oview, $
                                               oimage, $
                                               count=nTiles)
    if (nTiles gt 0) then widget_control, /hourglass

    for t = 0L, nTiles - 1L do begin 
        subrect = [reqTiles[t].x, reqTiles[t].y, $
                   reqTiles[t].width, reqTiles[t].height]

        level = reqTiles[t].level
        scale = ishft(1, level)  ; scale = 2^level
        subrect *= scale
         
        ojp2 = obj_new('IDLffJPEG2000', self.jp2filename, $
                       persistent=0) 
        tileData = ojp2->getData(region=subrect, $
                                 discard_levels=level, $
                                 order=1)
        obj_destroy, ojp2
        
        oimage->setTileData, reqTiles[t], tileData, no_free=0
    endfor

    self.owindow->draw, self.oview

    widget_control, hourglass=0
end


;+
; Handles draw events.
;
; @param event {in}{required}{type=structure} draw event
;-
pro mgtilejp2::draw, event
    compile_opt strictarr

    case event.type of
       0 : begin                ; press event
          self.buttonsDown or= event.press   
          if (event.press and 1B) then begin
             self.pressLoc = self.curLoc + [event.x, event.y] * self.zoomFactor
          endif
       end
       1 : self.buttonsDown and= not event.release       ; release event
       2 : begin                                         ; motion event
          if (self.buttonsDown and 1B) then begin   
             self.curLoc = self.pressLoc - [event.x, event.y] * self.zoomFactor
             vp = [self.curLoc, self.windowDims * self.zoomFactor]
             self.oview->setProperty, viewplane_rect=vp
             self->refresh
          endif
       end
       3 :                                 ; scroll event
       4 : self.owindow->draw, self.oview  ; expose event
       5 :                                 ; ASCII key event
       6 : begin                           ; non-ASCII key event
          if (event.release ne 0) then return
          winSize = self.windowDims * self.zoomFactor
          case event.key of 
             5 : begin          ; left
                loc = self.curLoc + [- winSize[0] / 8, 0]
                self->move, loc
             end
             6 : begin          ; right
                loc =  self.curLoc + [winSize[0] / 8, 0] 
                self->move, loc
             end
             7 : begin          ; up
                loc =  self.curLoc + [0, winSize[1] / 8] 
                self->move, loc
             end
             8 : begin          ; down
                loc = self.curLoc + [0, - winSize[1] / 8]
                self->move, loc
             end
             9 : self->zoom, 1     ; page up
             10 : self->zoom, -1   ; page down
             11 : begin                         ; home
                self.curLoc = [0L, 0L]
                self.zoomLevel = 0L
                self.zoomFactor = 2.0^self.zoomLevel 
                self->setvp, [self.curLoc, self.windowDims]
             end
             else :
          endcase
       end
       7 : begin                ; wheel event
          self->zoom, event.clicks
       end
    endcase
 end


;+
; Handle resize events.
;
; @param event {in}{required}{type=structure} resize event
;-
pro mgtilejp2::resize, event
    compile_opt strictarr

    tlbG = widget_info(event.top, /geometry)
    draw = widget_info(event.top, find_by_uname='draw')

    self.windowDims = [event.x - 2 * tlbG.xpad, event.y - 2 * tlbG.ypad]
    widget_control, draw, $
                    xsize=self.windowDims[0], $
                    ysize=self.windowDims[1]

    ; fix up object graphics hierarchy
    vp = [self.curLoc, self.windowDims * self.zoomFactor]
    self->setvp, vp
end


;+
; Handles all the events of our widget program.
;
; @param event {in}{required}{type=structure} event structure from any widget 
;        in our hierarchy that generates events
;-
pro mgtilejp2::handleEvents, event
    compile_opt strictarr

    uname = widget_info(event.id, /uname)

    case uname of
        'tlb'  : self->resize, event
        'draw' : self->draw, event
    endcase
end


;+
; Cleanup resources when XMANAGER shuts down our widget program.
;-
pro mgtilejp2::cleanup
    compile_opt strictarr

    self->mgobjectwidget::cleanup
    obj_destroy, self.oview
end


;+
; Called when the widget program is being destroyed.
;
; @param tlb {in}{required}{type=long} widget ID for the top-level base
;-
pro mgtilejp2::cleanupWidgets, tlb
    compile_opt strictarr

    obj_destroy, self
end


;+
; Widget creation/initialization routine for JPEG2000 tile viewer.
;
; @file_comments Simple JPEG2000 viewer which uses tiling capability of 
;                IDLgrImage. Click and drag or use arrows to scroll, 
;                Page Up and Page Down to zoom in/out.
; @requires IDL 6.2
; @param jp2filename {in}{optional}{type=str} filename of a JPEG2000 file
; @categories object graphics, tiling, object widgets
; @author Michael Galloy, 2006
;-
function mgtilejp2::init, jp2filename
    compile_opt strictarr
    on_error, 2

    if (~self->mgobjectwidget::init(name='mgtilejp2')) then return, 0B

    ijp2filename = (n_elements(jp2filename) eq 0) ? 'ohare.jp2' : jp2filename

    if (~file_test(ijp2filename)) then begin
        message, 'JPEG2000 file not found'
    endif

    ojp2 = obj_new('IDLffJPEG2000', ijp2filename)
    ojp2->getProperty, dimensions=imageDims, tile_dimensions=jp2TileDims
    obj_destroy, ojp2

    windowDims = [500, 500]

    ; create widget hierarchy
    self.tlb = widget_base(title='JPEG2000 tile viewer', /column, $
                           /tlb_size_events, $
                           uname='tlb', xpad=0, ypad=0, uvalue=self) 
    draw = widget_draw(self.tlb, xsize=windowDims[0], ysize=windowDims[1], $
                       uname='draw', graphics_level=2, $ $
                       /button_events, /motion_events, /wheel_events, $
                       keyboard_events=2)
    
    widget_control, self.tlb, /realize
    widget_control, draw, /input_focus
    widget_control, draw, get_value=owindow

    ; create object graphics hierarchy
    oview = obj_new('IDLgrView', name='view', color=[0, 0, 0], $ 
                    viewplane_rect=[0, 0, windowDims[0], windowDims[1]])

    omodel = obj_new('IDLgrModel', name='model')
    oview->add, omodel

    oimage = obj_new('IDLgrImage', name='image', $
                     order=1, $
                     /tiling, $
                     tile_show_boundaries=0, $
                     tile_level_mode=1, $  ; automatic mode for image pyramid
                     tiled_image_dimensions=imageDims, $
                     tile_dimensions=jp2TileDims)
    omodel->add, oimage

    ; setup data for event handlers
    self.owindow = owindow
    self.oview = oview
    self.windowDims = windowDims
    self.buttonsDown = 0B
    self.curLoc = [0L, 0L]
    self.pressLoc = [0L, 0L]
    self.zoomLevel = 0L
    self.zoomFactor = 1.0
    self.jp2filename = ijp2filename 
            
    ; initialize the graphics display
    self->refresh

    self->startXManager

    return, 1B
end


;+
; Define member variables (these used to be the fields of the state variable).
;
; @file_comments Object widget version of the JPEG 2000 tiling demo.
;
; @field owindow graphics window object reference
; @field oview IDLgrView object reference 
; @field windowDims size of the window
; @field buttonsDown bitmask of the mouse buttons currently pressed
; @field curLoc current location of the displayed image section
; @field pressLoc location of the current mouse press
; @field zoomLevel level of zooming: 0 for full resolution, >0 for zooming in,
;        <0 for zooming in (thumbnails)
; @field zoomFactor 2^zoomLevel
; @field jp2filename JPEG 2000 filename
;-
pro mgtilejp2__define
    compile_opt strictarr

    define = { mgtilejp2, inherits mgwidobjectwidget, $
               owindow : obj_new(), $
               oview : obj_new(), $
               windowDims : lonarr(2), $
               buttonsDown : 0B, $
               curLoc : lonarr(2), $
               pressLoc : lonarr(2), $
               zoomLevel : 0L, $
               zoomFactor : 0.0, $
               jp2filename : '' $
             }
end

