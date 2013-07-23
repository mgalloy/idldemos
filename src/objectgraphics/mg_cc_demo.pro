;+
; Example of using [XYZ]COORD_CONV properties to scale graphics atoms into the 
; view volume.
;-
pro mg_cc_demo
  compile_opt strictarr

  ; Create very simple object graphics hierarchy
  
  ; the view is responsible for the coordinate system; the default is -1 to +1 
  ; every direction
  oview = obj_new('IDLgrView')
  
  ; the model is responsible for holding the transformation matrix i.e. rotating,
  ; translating, and scaling
  omodel = obj_new('IDLgrModel')
  oview->add, omodel
  
  ; the atom is responsible for both the data and the display properties of the 
  ; data
  osurface = obj_new('IDLgrSurface', hanning(20, 20), style=2, $
                     color=[255, 0, 0], bottom=[100, 0, 0])
  omodel->add, osurface
  
  ; add a light so we can see better
  olightmodel = obj_new('IDLgrModel')
  oview->add, olightmodel
  olight = obj_new('IDLgrLight', type=2, location=[1, 1, 1])
  olightmodel->add, olight
  
  ; Using the [XYZ]COORD_CONV properties to scale surfaces into view volume.
  ; Here the display is not isotropic, instead each dimensions range is scaled 
  ; to take up the same amount of view display space (-0.6 to +0.6). If you 
  ; wanted an isotropic display, you would calculate one coordinate conversion
  ; function and use it for XCOORD_CONV, YCOORD_CONV, and ZCOORD_CONV.
  osurface->getProperty, xrange=xr, yrange=yr, zrange=zr
  xc = mg_linear_function(xr, [-0.6, 0.6])
  yc = mg_linear_function(yr, [-0.6, 0.6])
  zc = mg_linear_function(zr, [-0.6, 0.6])
  osurface->setProperty, xcoord_conv=xc, ycoord_conv=yc, zcoord_conv=zc

  ; rotate so we can see it better
  omodel->rotate, [1, 0, 0], -90
  omodel->rotate, [0, 1, 0], 30
  omodel->rotate, [1, 0, 0], 30

  ; now display it
  owindow = obj_new('IDLgrWindow', dimensions=[400, 400])
  owindow->draw, oview
  
  ; don't forget to cleanup; the window is destroyed when the user closes it
  obj_destroy, oview
end
