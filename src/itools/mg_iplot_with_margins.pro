;+
; Wrapper routine for iPlot which handles margins for the plot also.
;   
; @param x {in}{required}{type=1D numeric array}
;        x-coordinates of data if y param is passed or y-coordinates of data
;        if only x is passed
; @param y {in}{optional}{type=1D numeric array}
;        y-coordinates of data
; @keyword xmargin {in}{optional}{type=fltarr(2)}{default=[0.1, 0.1]}
;          size of left and right margins in window normal units
; @keyword ymargin {in}{optional}{type=fltarr(2)}{default=[0.1, 0.1]}
;          size of bottom and top margins in window normal units
; @keyword _extra {in}{optional}{type=keywords}
;          keywords to iPlot
;-
pro mg_iplot_with_margins, x, y, xmargin=xmargin, ymargin=ymargin, _extra=e
  compile_opt strictarr
  
  myXMargin = n_elements(xmargin) eq 0 ? [0.1, 0.1] : xmargin
  myYMargin = n_elements(ymargin) eq 0 ? [0.1, 0.1] : ymargin
  
  case n_params() of
  0 : iplot, _strict_extra=e
  1 : iplot, x, _strict_extra=e
  2 : iplot, x, y, _strict_extra=e
  endcase 
  toolID = itGetCurrent(tool=oTool)
    
  visIds = oTool->findIdentifiers('*', /visualization)
  visLayerId = strmid(visIds[0], 0, strpos(visIds[0], '/', /reverse_search))
  oVisLayer = oTool->getByIdentifier(visLayerId)
  
  
  xsize = 1.4 / (1.0 - myXMargin[0] - myXMargin[1])
  ysize = 0.98 / (1.0 - myYMargin[0] - myYMargin[1])
  xstart = - myXMargin[0] * xsize - 1.4 / 2
  ystart = - myYMargin[0] * ysize - 0.98 / 2
  
  oVisLayer->setProperty, viewplane_rect=[xstart, ystart, xsize, ysize]
end
