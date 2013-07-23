;+
; Do the output. 
;
; @returns 1 for success, 0 otherwise
; @param oPlotData {in}{required}{type=object} data object
;-
function mgitwritesparkline::setData, oPlotData
    compile_opt strictarr

    filename = self->getFilename()
    if (filename eq '') then return, 0

    if (~obj_valid(oPlotData)) then begin 
        self->errorMessage, ['Invalid plot data object'], title='Error', severity=2
        return, 0
    endif

    odata = oPlotData->getByType('IDLVECTOR', count=nplots)
    if (nplots eq 0) then begin 
        self->errorMessage, ['Invalid data provided to file writer'], title='Error', /severity
    endif

    odata = odata[0]
    result = odata->getData(y)

    if (result eq 0) then begin 
        self->errorMessage, ['Error retrieving plot data'], title='Error', severity=2
    endif
     
    mg_sparkline, filename, y, xsize=self.width, ysize=self.height, $ 
                  color=self.color, $ 
                  background=keyword_set(self.transparent_background) ? undefined : self.background, $
                  band_color=keyword_set(self.use_range_band) ? self.band_color : undefined, $
                  endpoint_color=self.endpoint_color

    return, 1B
end


;+
; Set properties of the object.
;
; @keyword width {in}{optional}{type=integer} width in pixels of the output
; @keyword height {in}{optional}{type=integer} height in pixels of the output
; @keyword color {in}{optional}{type=bytarr(3)} color of the plot
; @keyword transparent_background {in}{optional}{type=boolean} set if a 
;          transparent background should be used
; @keyword background {in}{optional}{type=bytarr(3)} background color (if not 
;          transparent)
; @keyword use_range_band {in}{optional}{type=boolean} set if a range band should
;          be used
; @keyword band_color {in}{optional}{type=bytarr(3)} color of the range band
; @keyword endpoint_color {in}{optional}{type=bytarr(3)} color of the endpoint
;-
pro mgitwritesparkline::setProperty, width=width, height=height, color=color, $
                                     transparent_background=transparent_background, $
                                     background=background, $
                                     use_range_band=use_range_band, $
                                     band_color=band_color, $
                                     endpoint_color=endpoint_color, $
                                     _ref_extra=e
    compile_opt strictarr

    if (n_elements(width) gt 0) then self.width = width
    if (n_elements(height) gt 0) then self.height = height
    if (n_elements(color) gt 0) then self.color = color
    if (n_elements(transparent_background) gt 0) then begin
        self.transparent_background = transparent_background
        self->setPropertyAttribute, 'background', sensitive=~transparent_background
    endif
    if (n_elements(background) gt 0) then self.background = background
    if (n_elements(use_range_band) gt 0) then begin
        self.use_range_band = use_range_band
        self->setPropertyAttribute, 'band_color', sensitive=use_range_band
    endif
    if (n_elements(band_color) gt 0) then self.band_color = band_color
    if (n_elements(endpoint_color) gt 0) then self.endpoint_color = endpoint_color

    if (n_elements(e) gt 0) then self->IDLitWriter::setProperty, _extra=e
end


;+
; Get properties of the object.
;
; @keyword width {out}{optional}{type=integer} width in pixels of the output
; @keyword height {out}{optional}{type=integer} height in pixels of the output
; @keyword color {out}{optional}{type=bytarr(3)} color of the plot
; @keyword transparent_background {out}{optional}{type=booolean} set if a 
;          transparent background should be used
; @keyword background {out}{optional}{type=background(3)} background color (if
;          not transparent)
; @keyword use_range_band {out}{optional}{type=boolean} set if a range band 
;          should be used
; @keyword band_color {out}{optional}{type=bytarr(3)} color of the range band
; @keyword endpoint_color {out}{optional}{type=bytarr(3)} color of the endpoint
;-
pro mgitwritesparkline::getProperty, width=width, height=height, color=color, $
                                     transparent_background=transparent_background, $
                                     background=background, $
                                     use_range_band=use_range_band, $
                                     band_color=band_color, $
                                     endpoint_color=endpoint_color, $
                                     _ref_extra=e
    compile_opt strictarr

    if (arg_present(width)) then width = self.width
    if (arg_present(height)) then height = self.height
    if (arg_present(color)) then color = self.color
    if (arg_present(transparent_background)) then begin
        transparent_background = self.transparent_background
    endif
    if (arg_present(background)) then background = self.background
    if (arg_present(use_range_band)) then use_range_band = self.use_range_band
    if (arg_present(band_color)) then band_color = self.band_color
    if (arg_present(endpoint_color)) then endpoint_color = self.endpoint_color

    if (n_elements(e) gt 0) then self->IDLitWriter::getProperty, _extrta=e
end


;+
; Free resources.
;-
pro mgitwritesparkline::cleanup
    compile_opt strictarr

    self->IDLitWriter::cleanup
end


;+
; Initialize MGitWriteSparkline object.
;
; @returns 1 for success, 0 otherwise
; @keyword _ref_extra {in}{optional}{type=keyword} keywords of IDLitWriter::init
;-
function mgitwritesparkline::init, _ref_extra=e
    compile_opt strictarr
     
    if (~self->IDLitWriter::init('png', type='IDLVECTOR', name='PNG of sparkline', $ 
                                 description='PNG representation of a sparkline', $
                                 _extra=e)) then return, 0B

    self->registerProperty, 'width', name='Width', $
                            description='Width in pixels of output image', /integer
    self->registerProperty, 'height', name='Height', $ 
                            description='Height in pixels of output image', /integer

    self.width = 100
    self.height = 12

    self->registerProperty, 'color', name='Color', $
                            description='Color of the plot', /color
    self->registerProperty, 'transparent_background', name='Transparent background', $
                            description='Use a transparent background', /boolean
    self->registerProperty, 'background', name='Background', $
                            description='Background color of the plot', /color, sensitive=0
    self->registerProperty, 'use_range_band', name='Use range band', $ 
                            description='Use range band', /boolean
    self->registerProperty, 'band_color', name='Band color', $
                            description='Color of the range band', /color, sensitive=0
    self->registerProperty, 'endpoint_color', name='Endpoint color', $
                            description='Color of the endpoint', /color

    self.color = [0B, 0B, 0B]
    self.transparent_background = 1B
    self.background = [255B, 255B, 255B]
    self.use_range_band = 0B
    self.band_color = [204B, 204B, 255B]
    self.endpoint_color = [255B, 0B, 0B]

    return, 1B
end


;+
; Define instance variables.

; @file_comments A FileWriter for the iTools system to create PNG sparkline 
;                files from plot data (IDLVECTOR data).
; @field width width in pixels of the output
; @field height height in pixels of the output
; @field color color of the plot
; @field transparent_background set if a transparent background should be used
; @field background background color (if not transparent)
; @field use_range_band set if a range band should be used
; @field band_color color of the range band
; @field endpoint_color color of the endpoint
;-
pro mgitwritesparkline__define
    compile_opt strictarr
    
    define = { mgitwritesparkline, inherits IDLitWriter, $
               width: 0L, $
               height: 0L, $
               color: bytarr(3), $
               transparent_background: 0B, $
               background: bytarr(3), $
               use_range_band: 0B, $
               band_color: bytarr(3), $
               endpoint_color: bytarr(3) $
             }
end
