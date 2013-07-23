;+
; Handle all events for the program.
;
; @param event {in}{required}{type=structure} event from any widget in the 
;        program
;-
pro mg_timer_demo_event, event
    compile_opt strictarr

    widget_control, event.top, get_uvalue=pstate
    uname = widget_info(event.id, /uname)

    case uname of
        'rotate' : begin
            (*pstate).t = 0L
            (*pstate).stop = 0B
            timer = widget_info(event.top, find_by_uname='timer')
            widget_control, timer, timer=(*pstate).time
        end

        'stop' : (*pstate).stop = 1B

        'timer' : begin
            if ((*pstate).stop) then return
            if (++(*pstate).t gt 360) then return
            omodel = (*pstate).oview->getByName('model')
            omodel->rotate, [0, 1, 0], 1
            (*pstate).owindow->draw, (*pstate).oview
            widget_control, event.id, timer=(*pstate).time
        end

        'draw' : begin
            update = (*pstate).otrack->update(event, transform=rot)
            if (update) then begin
                omodel = (*pstate).oview->getByName('model')
                omodel->getProperty, transform=trans
                omodel->setProperty, transform=trans # rot
                (*pstate).owindow->draw, (*pstate).oview
            endif
        end
    endcase
end


;+
; Free resources.
;
; @param tlb {in}{required}{type=long} widget ID for the top-level base
;-
pro mg_timer_demo_cleanup, tlb
    compile_opt strictarr

    widget_control, tlb, get_uvalue=pstate

    obj_destroy, [(*pstate).oview, (*pstate).otrack]
    ptr_free, pstate
end


;+
; Simple program to demonstrate the use of a timer event to rotate an object
; graphics surface while still allowing interaction.
;-
pro mg_timer_demo
    compile_opt strictarr

    ; create widget hierarchy
    tlb = widget_base(title='Timer demo', /column)

    toolbar = widget_base(tlb, /row, space=0)
    bitmaps = ['resource', 'bitmaps'] 
    rotate = widget_button(toolbar, $  
                           value=filepath('rotate.bmp', subdir=bitmaps),  $
                           /bitmap, $
                           tooltip='Rotate', uname='rotate') 
    stop = widget_button(toolbar, $ 
                         value=filepath('stop.bmp', subdir=bitmaps),  $
                         /bitmap, $
                         tooltip='Stop', uname='stop')
    timer = widget_base(toolbar, uname='timer')

    draw = widget_draw(tlb, xsize=400, ysize=400, uname='draw', $
                       /motion_events, /button_events, $
                       graphics_level=2)

    widget_control, tlb, /realize
    widget_control, draw, get_value=owindow

    ; create object graphics hierarchy
    oview = obj_new('IDLgrView', color=[127, 127, 127])
    
    olightmodel = obj_new('IDLgrModel')
    oview->add, olightmodel

    olight = obj_new('IDLgrLight', type=2, location=[-1, +1, +1])
    olightmodel->add, olight

    omodel = obj_new('IDLgrModel', name='model')
    oview->add, omodel
    
    osurface = obj_new('IDLgrSurface', hanning(20, 20), $
                       name='surface', style=2, $
                       color=[255, 0, 0], bottom=[100, 0, 0])
    omodel->add, osurface

    osurface->getProperty, xrange=xr, yrange=yr, zrange=zr
    xc = norm_coord(xr)
    yc = norm_coord(yr)
    zc = norm_coord(zr)
    xc[0] -= 0.5
    yc[0] -= 0.5
    zc[0] -= 0.5 
    osurface->setProperty, xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc

    omodel->rotate, [1, 0, 0], -90
    omodel->rotate, [0, 1, 0], 30
    omodel->rotate, [1, 0, 0], 30

    owindow->draw, oview

    otrack = obj_new('Trackball', [200, 200], 200)

    state = { oview: oview, $
              owindow: owindow, $
              otrack: otrack, $
              time: 0.1, $
              t: 0L, $
              stop: 1B $
            }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    xmanager, 'mg_timer_demo', tlb, /no_block, $
              event_handler='mg_timer_demo_event', $
              cleanup='mg_timer_demo_cleanup'
end
