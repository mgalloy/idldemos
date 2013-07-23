;+
; Handles all events.
;
; @param event {in}{required}{type=structure} all events structures
;-
pro mg_3dwidget_demo_events, event
    compile_opt strictarr

    widget_control, event.top, get_uvalue=pstate
    uname = widget_info(event.id, /uname)

    case uname of
        'tlb' :
        'draw' : begin 
            update = (*pstate).otrack->update(event, transform=rot)
            if (update) then begin
                (*pstate).omodel->getProperty, transform=trans
                (*pstate).omodel->setProperty, transform=trans # rot
                (*pstate).owindow->draw, (*pstate).oview
            endif
        end
    endcase
end


;+
; Cleanup program resources.
;
; @param tlb {in}{required}{type=long} widget ID of the top-level base
;-
pro mg_3dwidget_demo_cleanup, tlb
    compile_opt strictarr

    widget_control, tlb, get_uvalue=pstate

    obj_destroy, [(*pstate).oview, (*pstate).otrack]
    ptr_free, pstate
end


;+
; Demonstrates using MGgrWindow3D in a widget program.
;-
pro mg_3dwidget_demo
    compile_opt strictarr

    ; get data
    filename = filepath('elevbin.dat', subdir=['examples', 'data'])
    data = bytarr(64, 64)
    openr, lun, filename, /get_lun
    readu, lun, data
    free_lun, lun

    ; create object graphics hierarchy
    oview = obj_new('IDLgrView', color=[127, 127, 127])

    omodel = obj_new('IDLgrModel')
    oview->add, omodel
    
    olight = obj_new('IDLgrLight', type=2, location=[-1, -1, 1])
    omodel->add, olight
    
    osurface = obj_new('IDLgrSurface', data, style=2, color=[0, 255, 0])
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

    ; create widget hierarchy
    tlb = widget_base(title='3D widget demo', /column, /tlb_size_events, $
                      uname='tlb')
    draw = widget_draw(tlb, xsize=400, ysize=400, graphics_level=2, $
                       /motion_events, /button_events, $
                       classname='MGgrWindow3D', uname='draw')

    widget_control, tlb, /realize
    widget_control, draw, get_value=owindow

    owindow->draw, oview
    otrack = obj_new('Trackball', [200, 200], 200)

    state = { oview : oview, $
              owindow : owindow, $
              otrack : otrack, $
              omodel : omodel, $
              draw : draw $
            }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    xmanager, 'mg_3dwidget_demo', tlb, /no_block, $
              event_handler='mg_3dwidget_demo_events', $
              cleanup='mg_3dwidget_demo_cleanup'
end
