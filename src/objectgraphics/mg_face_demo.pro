;+
; Use MGgrChernoffFace as a plot symbol.
;
; @keyword random {in}{optional}{type=boolean} set to plot a random data set
;-
pro mg_face_demo, random=random
    compile_opt strictarr

    oview = obj_new('IDLgrView')

    omodel = obj_new('IDLgrModel')
    oview->add, omodel
     
    if (~keyword_set(random)) then begin
        n = 3L
        osymbols = objarr(n)
        ofaces = objarr(n)
        
        head_eccentricities = [0.25, 0.5, 0.75]   
        nose_lengths = [1.0, 0.5, 0.5]           
        mouth_sizes = [1.0, 1.0, 1.0]           
        mouth_shapes = [0.0, 0.5, 1.0]          
        eye_sizes = [1.0, 1.0, 1.0]             
        eye_eccentricities = [0.0, 0.5, 1.0]    
        eye_spacings = [0.0, 0.5, 1.0]          
        pupil_sizes = [0.2, 0.5, 0.7]           
        eyebrow_slants = [0.0, 0.5, 1.0]        
    
        x = [0.1, 0.3, 0.5] 
        y = [0.5, 0.5, 0.5] 
    endif else begin
        n = 20L
        osymbols = objarr(n)
        ofaces = objarr(n)
        
        head_eccentricities = randomu(seed, n)  
        nose_lengths = randomu(seed, n) 
        mouth_sizes = randomu(seed, n)
        mouth_shapes = randomu(seed, n)
        eye_sizes = randomu(seed, n)
        eye_eccentricities = randomu(seed, n)
        eye_spacings = randomu(seed, n)
        pupil_sizes = randomu(seed, n)
        eyebrow_slants = randomu(seed, n)
        
        x = randomu(seed, n)
        y = randomu(seed, n)
    endelse
    
    for i = 0L, n - 1L do begin 
        ofaces[i] = obj_new('MGgrChernoffFace', thick=2.0, $
                            head_eccentricity=head_eccentricities[i], $
                            nose_length=nose_lengths[i], $
                            mouth_size=mouth_sizes[i], $
                            mouth_shape=mouth_shapes[i], $
                            eye_size=eye_sizes[i], $
                            eye_eccentricity=eye_eccentricities[i], $
                            eye_spacing=eye_spacings[i], $
                            pupil_size=pupil_sizes[i], $
                            eyebrow_slant=eyebrow_slants[i])
        osymbols[i] = obj_new('IDLgrSymbol', ofaces[i], size=0.065)
    endfor
     
    oplot = obj_new('IDLgrPlot', x, y, symbol=osymbols, linestyle=6)
    omodel->add, oplot

    xc = norm_coord([0, 1])
    xc[0] -= 0.5
    oplot->setProperty, xcoord_conv=xc, ycoord_conv=xc

    owindow = obj_new('IDLgrWindow', dimensions=[900, 900])

    owindow->draw, oview
    obj_destroy, [oview, ofaces, osymbols]
end
