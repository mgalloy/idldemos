;+
; Get properties of the operation. The itools must be able to get properties
; of your operation (and parents' properties), so be sure to pass along keywords
; to IDLitDataOperation::getProperty.
;
; @keyword clip {out}{optional}{type=float} slope limit of histogram
; @keyword top {out}{optional}{type=byte} maximum value of the scaled output array
; @keyword nregions {out}{optional}{type=long} size of the overlapped tiles as a 
;          fraction image size
; @keyword _ref_extra {out}{optional}{type=keywords} keywords of 
;          IDLitDataOperation
;-
pro mgitopadapthistequal::getProperty, clip=clip, nregions=nregions, top=top, $
                                     _ref_extra=e
    compile_opt strictarr

    if (arg_present(clip)) then clip = self.clip
    if (arg_present(nregions)) then nregions = self.nregions
    if (arg_present(top)) then top = self.top
     
    if (n_elements(e) gt 0) then begin
        self->IDLitDataOperation::getProperty, _extra=e
    endif
end


;+
; Set properties of the operation. The itools must be able to set properties
; of your operation (and parents' properties), so be sure to pass along keywords
; to IDLitDataOperation::setProperty.
;
; @keyword clip {in}{optional}{type=float} slope limit of histogram
; @keyword top {in}{optional}{type=byte} maximum value of the scaled output array
; @keyword nregions {in}{optional}{type=long} size of the overlapped tiles as a 
;          fraction image size
; @keyword _ref_extra {in}{optional}{type=keywords} keywords of 
;          IDLitDataOperation
;-
pro mgitopadapthistequal::setProperty, clip=clip, nregions=nregions, top=top, $
                                     _ref_extra=e
    compile_opt strictarr

    if (n_elements(clip) gt 0) then self.clip = clip
    if (n_elements(nregions) gt 0) then self.nregions = nregions
    if (n_elements(top) gt 0) then self.top = top

    if (n_elements(e) gt 0) then begin
        self->IDLitDataOperation::setProperty, _extra=e
    endif
end


;+
; This method is called to present a GUI for the user to modify properties, see 
; a preview, etc. before the operation is executed. 
;
; @returns 1 for success, 0 for failure
;-
function mgitopadapthistequal::doExecuteUI
    compile_opt strictarr

    otool = self->getTool()
    if (~otool) then return, 0L
    
    ; Documented predefined choices for services are: 'PropertySheet' or 
    ; 'OperationPreview'. You can also write your own UI service.
    return, otool->doUIService('OperationPreview', self) 
end


;+
; This is the method that actually does the operation.
;
; @returns 1 for success, 0 for failure.
; @param data {in}{out}{required}{type=2D array} modify this variable to do the
;        operation; it's a 2D array because of the TYPES keyword in the call to
;        IDLitDataOperation::init.
;-
function mgitopadapthistequal::execute, data
    compile_opt strictarr
     
    data = adapt_hist_equal(bytscl(data), $
                            clip=self.clip, $
                            nregions=self.nregions, $
                            top=self.top)

    return, 1L
end


;+
; Free resources of the object.
;-
pro mgitopadapthistequal::cleanup
    compile_opt strictarr

    ; Just call the parent's cleanup method.
    self->idlitdataoperation::cleanup
end



;+
; Jobs for the init method:
;   1) call the parent's init method (you MUST pass along keyword via _EXTRA)
;   2) initialize member variables (properties of the operation)
;   3) register properties
;
; @returns 1L if successful, 0L otherwise
; @keyword _ref_extra {in}{optional}{type=keywords} keywords to 
;          IDLitDataOperation::init
;-
function mgitopadapthistequal::init, _ref_extra=e
    compile_opt strictarr
    
    ; Call parent IDLitDataOperation's init method. Keywords must be passed 
    ; along to this call. The TYPES keyword specifies all the iTools data types
    ; that this operation will work on. The REVERSIBLE_OPERATION and 
    ; EXPENSIVE_OPERATION keywords relate to the undo/redo system. 
    ; REVERSIBLE_OPERATION determines what happens when the user undo's the 
    ; operation. If REVERSIBLE_OPERATION is set, then the undoExecute method is 
    ; called. If REVERSIBLE_OPERATION is not set, then the itools will cache
    ; data before the operation is executed so that it can be restored when it is
    ; undone. EXPENSIVE_OPERATION determines the behavoir after the operation is
    ; undone. If EXPENSIVE_OPERATION is set, then the result of the operation is
    ; cached so it can be redone without having to calculate it again. If not set
    ; it must be calculated again via the execute method if it is redone.
    if (~self->idlitdataoperation::init(types=['IDLARRAY2D'], $ 
                                  name='Adaptive Histogram Equalization', $
                                  icon='image', $
                                  reversible_operation=0B, $
                                  expensive_operation=0B, $
                                  _extra=e)) then return, 0L

    ; set initial values for properties
    self.clip = 0.0
    self.nregions = 12L
    self.top = 255L
    
    ; Register properties of the operation via IDLitComponent::registerProperty 
    ; (IDLitComponent is a parent class of IDLitDataOperation). The positional 
    ; parameter is the nmember variable name. The type is specified using the 
    ; INTEGER and FLOAT keywords (others are available, though not corresponding
    ; to all the IDL types), but could be specifed via a code as the second 
    ; positional parameter.
    self->registerProperty, 'top', /integer, $
                            description='Maximum value of the scaled output array', $
                            name='Top', $
                            sensitive=1
    self->registerProperty, 'clip', /float, $
                            description='Slope limit of histogram', $
                            name='Clip', $
                            sensitive=1
    self->registerProperty, 'nregions', /integer, $ 
                            description='Size of the overlapped tiles as a fraction image size', $
                            name='Number of regions', $
                            sensitive=1

    ; Don't forget to designate success.
    return, 1L
end


;+
; Define the member variables of the objects of the class. The registered 
; properties will be among these.
;
; @file_comments This subclass of IDLitDataOperation, implements the 
;                AdaptHistEqual operation for the itools system. 
;                IDLitDataOperation is subclassed because this operation doesn't
;                need the flexibility of IDLitOperation, it simply operates
;                on the data of the currently item.
;
; @field clip slope limit of histogram
; @field top maximum value of the scaled output array
; @field nregions Size of the overlapped tiles as a fraction image size
;-
pro mgitopadapthistequal__define
    compile_opt strictarr

    define = { mgitopadapthistequal, inherits idlitdataoperation, $
               clip : 0.0, $
               top : 0L, $
               nregions : 0L $
             } 
end
