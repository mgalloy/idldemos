;+
; Example of creating and controlling an iTool from the command line. This demo
; creates an iVolume tool and creates some isosurfaces within it.
;-
pro mg_isosurfaces_demo
    compile_opt strictarr

    ; Use the head data set in the IDL distribution for an example volume data set.
    ; It consists of 57 images each 80 by 100 byte valued.
    f = filepath('head.dat', subdir=['examples', 'data'])
    openr, lun, f, /get_lun
    vol = bytarr(80, 100, 57)
    readu, lun, vol
    free_lun, lun

    ; these are the isosurface values to use
    isovalues = [10, 20, 30]

    ; start up iVolume
    ivolume, vol
    
    ; get the object reference for the iVolume tool
    id = itGetCurrent(tool=otool)

    ; get volume vizualization object identifier/reference
    vol_id  = otool->findIdentifiers('*DATA SPACE/VOLUME*', /visualizations)  
    ovol = otool->getByIdentifier(vol_id)                                         
    
    ; hide the volume so the isosurfaces shows up better
    ovol->setProperty, render_extents=0                                          
    ovol->setProperty, hide=1                                                       

    ; get the isosurface operation
    iso_op_id = otool->findIdentifiers('*ISOSURFACE*', /operations)            
    oIsoOp = otool->getByIdentifier(iso_op_id)                       
    oIsoOp->setProperty, show_execution_ui=0         
                       
    ; create the isosurfaces
    for i = 0, n_elements(isovalues) - 1 do begin
        oIsoOp->setProperty, _isovalue0=isovalues[i]                     
        result = otool->doAction(iso_op_id)     
        otool->commitActions
        ovol->select
    endfor

    ; get identifiers for the isosurfaces
    isosurface_ids = otool->findIdentifiers('*DATA SPACE/ISOSURFACE*', /visualizations) 

    ; change properties of the isosurfaces
    for i = 0, n_elements(isovalues) - 1 do begin
        oIsosurface = otool->getByIdentifier(isosurface_ids[i]) 
        color = [255, 100, 100] * (- i / (n_elements(isovalues) - 1.0) + 1.0)
        oIsosurface->setProperty, source_color=1, $ 
                                  fill_color=color, $
                                  transparency=70
        otool->refreshCurrentWindow
        itPropertyReport, otool, isosurface_ids[i]
    endfor
end
