;+
; Set the viewplace_rect of the IDLgrView and refresh the graphics display.
;
; @param pstate {in}{required}{type=pointer} pointer to widget data structure
; @param vp {in}{required}{type=fltarr(4)} viewplane_rect for the IDLgrView
;-
pro mg_tilejp2_setvp, pstate, vp
    compile_opt strictarr

    (*pstate).oview->setProperty, viewplane_rect=vp
    mg_tilejp2_refresh, pstate    
end


;+
; Move view of image.
;
; @param pstate {in}{required}{type=pointer} pointer to widget data structure
; @param loc {in}{required}{type=lonarr(2)} location of lower-left corner of 
;        image to move to
;-
pro mg_tilejp2_move, pstate, loc
    compile_opt strictarr

    (*pstate).curLoc = loc 
    vp = [loc, (*pstate).windowDims * (*pstate).zoomFactor] 
    mg_tilejp2_setvp, pstate, vp
end


;+
; Zoom in/out by an increment. 
;
; @param pstate {in}{required}{type=pointer} pointer to widget data structure
; @param incLevel {in}{required}{type=integer} amount to increment zoom level
;-
pro mg_tilejp2_zoom, pstate, incLevel
    compile_opt strictarr

    (*pstate).zoomLevel += incLevel
     
    dims = (*pstate).windowDims * (*pstate).zoomFactor
    (*pstate).zoomFactor = 2.0^(*pstate).zoomLevel 
    (*pstate).curLoc += (dims - (*pstate).windowDims * (*pstate).zoomFactor) / 2.0
     
    vp = [(*pstate).curLoc, (*pstate).windowDims * (*pstate).zoomFactor]
    mg_tilejp2_setvp, pstate, vp
end


;+
; Refresh the graphics display, including loading any new tile 
; data if necessary.
;
; @param pstate {in}{required}{type=pointer} pointer to widget 
;        data structure
;-
pro mg_tilejp2_refresh, pstate
    compile_opt strictarr
     
    oimage = (*pstate).oview->getByName('model/image')
    reqTiles $
       = (*pstate).owindow->queryRequiredTiles((*pstate).oview, $
                                               oimage, $
                                               count=nTiles)
    if (nTiles gt 0) then widget_control, /hourglass

    for t = 0L, nTiles - 1L do begin 
        subrect = [reqTiles[t].x, reqTiles[t].y, $
                   reqTiles[t].width, reqTiles[t].height]

        level = reqTiles[t].level
        scale = ishft(1, level)  ; scale = 2^level
        subrect *= scale
         
        ojp2 = obj_new('IDLffJPEG2000', (*pstate).jp2filename, $
                       persistent=0) 
        tileData = ojp2->getData(region=subrect, $
                                 discard_levels=level, $
                                 order=1)
        obj_destroy, ojp2
        
        oimage->setTileData, reqTiles[t], tileData, no_free=0
    endfor

    (*pstate).owindow->draw, (*pstate).oview

    widget_control, hourglass=0
end


;+
; Handles draw events.
;
; @param event {in}{required}{type=structure} draw event
;-
pro mg_tilejp2_draw, event
    compile_opt strictarr

    widget_control, event.top, get_uvalue=pstate

    case event.type of
       0 : begin                ; press event
          (*pstate).buttonsDown or= event.press   
          if (event.press and 1B) then begin
             (*pstate).pressLoc = (*pstate).curLoc + [event.x, event.y] * (*pstate).zoomFactor
          endif
       end
       1 : (*pstate).buttonsDown and= not event.release  ; release event
       2 : begin                                         ; motion event
          if ((*pstate).buttonsDown and 1B) then begin   
             (*pstate).curLoc = (*pstate).pressLoc - [event.x, event.y] * (*pstate).zoomFactor
             vp = [(*pstate).curLoc, (*pstate).windowDims * (*pstate).zoomFactor]
             (*pstate).oview->setProperty, viewplane_rect=vp
             mg_tilejp2_refresh, pstate
          endif
       end
       3 :                                            ; scroll event
       4 : (*pstate).owindow->draw, (*pstate).oview   ; expose event
       5 :                                            ; ASCII key event
       6 : begin                                      ; non-ASCII key event
          if (event.release ne 0) then return
          winSize = (*pstate).windowDims * (*pstate).zoomFactor
          case event.key of 
             5 : begin          ; left
                loc = (*pstate).curLoc + [- winSize[0] / 8, 0]
                mg_tilejp2_move, pstate, loc
             end
             6 : begin          ; right
                loc =  (*pstate).curLoc + [winSize[0] / 8, 0] 
                mg_tilejp2_move, pstate, loc
             end
             7 : begin          ; up
                loc =  (*pstate).curLoc + [0, winSize[1] / 8] 
                mg_tilejp2_move, pstate, loc
             end
             8 : begin          ; down
                loc = (*pstate).curLoc + [0, - winSize[1] / 8]
                mg_tilejp2_move, pstate, loc
             end
             9 : mg_tilejp2_zoom, pstate, 1     ; page up
             10 : mg_tilejp2_zoom, pstate, -1   ; page down
             11 : begin                         ; home
                (*pstate).curLoc = [0L, 0L]
                (*pstate).zoomLevel = 0L
                (*pstate).zoomFactor = 2.0^(*pstate).zoomLevel 
                mg_tilejp2_setvp, pstate, [(*pstate).curLoc, (*pstate).windowDims]
             end
             else :
          endcase
       end
       7 : begin                ; wheel event
          mg_tilejp2_zoom, pstate, event.clicks
       end
    endcase
 end


;+
; Handle resize events.
;
; @param event {in}{required}{type=structure} resize event
;-
pro mg_tilejp2_resize, event
    compile_opt strictarr

    widget_control, event.top, get_uvalue=pstate

    tlbG = widget_info(event.top, /geometry)
    draw = widget_info(event.top, find_by_uname='draw')

    (*pstate).windowDims = [event.x - 2 * tlbG.xpad, event.y - 2 * tlbG.ypad]
    widget_control, draw, $
                    xsize=(*pstate).windowDims[0], $
                    ysize=(*pstate).windowDims[1]

    ; fix up object graphics hierarchy
    vp = [(*pstate).curLoc, (*pstate).windowDims * (*pstate).zoomFactor]
    mg_tilejp2_setvp, pstate, vp
end


;+
; Handles all the events of our widget program.
;
; @param event {in}{required}{type=structure} event structure from any widget 
;        in our hierarchy that generates events
;-
pro mg_tilejp2_event, event
    compile_opt strictarr

    uname = widget_info(event.id, /uname)

    case uname of
        'tlb'  : mg_tilejp2_resize, event
        'draw' : mg_tilejp2_draw, event
    endcase
end


;+
; Cleanup resources when XMANAGER shuts down our widget program.
;
; @param tlb {in}{required}{type=long} widget ID of the top-level base
;-
pro mg_tilejp2_cleanup, tlb
    compile_opt strictarr

    widget_control, tlb, get_uvalue=pstate

    obj_destroy, (*pstate).oview
    ptr_free, pstate
end


;+
; Widget creation/initialization routine for JPEG2000 tile viewer.
;
; @file_comments Simple JPEG2000 viewer which uses tiling capability of 
;                IDLgrImage. Click and drag or use arrows to scroll, 
;                Page Up and Page Down to zoom in/out.
; @requires IDL 6.2
; @param jp2filename {in}{optional}{type=str} filename of a JPEG2000 file
; @categories object graphics, tiling, widgets
; @author Michael Galloy, 2006
;-
pro mg_tilejp2, jp2filename
    compile_opt strictarr
    on_error, 2

    ijp2filename = (n_elements(jp2filename) eq 0) ? 'ohare.jp2' : jp2filename

    if (~file_test(ijp2filename)) then begin
        message, 'JPEG2000 file not found'
    endif

    ojp2 = obj_new('IDLffJPEG2000', ijp2filename)
    ojp2->getProperty, dimensions=imageDims, tile_dimensions=jp2TileDims
    obj_destroy, ojp2

    windowDims = [500, 500]

    ; create widget hierarchy
    tlb = widget_base(title='JPEG2000 tile viewer', /column, /tlb_size_events, $
                      uname='tlb', xpad=0, ypad=0) 
    draw = widget_draw(tlb, xsize=windowDims[0], ysize=windowDims[1], $
                       uname='draw', graphics_level=2, $ $
                       /button_events, /motion_events, /wheel_events, $
                       keyboard_events=2)
    
    widget_control, tlb, /realize
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
    state = { owindow : owindow, $
              oview : oview, $
              windowDims : windowDims, $
              buttonsDown : 0B, $
              curLoc : [0L, 0L], $
              pressLoc : [0L, 0L], $
              zoomLevel : 0L, $
              zoomFactor : 1.0, $
              jp2filename : ijp2filename $
            }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    ; initialize the graphics display
    mg_tilejp2_refresh, pstate

    ; start up events
    xmanager, 'mg_tilejp2', tlb, /no_block, $
              event_handler='mg_tilejp2_event', $
              cleanup='mg_tilejp2_cleanup'
end
