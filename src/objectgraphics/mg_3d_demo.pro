;+
; Demo of using MGgrWindow3D to make anaglyphs.
;-
pro mg_3d_demo
    compile_opt strictarr

    filename = filepath('elevbin.dat', subdir=['examples', 'data'])
    data = bytarr(64, 64)
    openr, lun, filename, /get_lun
    readu, lun, data
    free_lun, lun

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
    
    owindow = obj_new('MGgrWindow3d', eye_separation=3)
    owindow->draw, oview
    
    obj_destroy, oview
end
