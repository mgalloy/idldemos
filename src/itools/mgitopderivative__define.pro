;+
; Record y data values before the operation for doing an undo later.
; 
; @returns 1 for success, 0 otherwise
; @param oCmdSet {in}{required}{type=object} IDLitCommandSet to record initial 
;        values in
; @param targets {in}{required}{type=objarr} array of object references to query
; @param idprop {in}{optional} not needed
;-
function mgitopderivative::recordInitialValues, oCmdSet, targets, idprop
  compile_opt strictarr

  for i = 0L, n_elements(targets) - 1L do begin
      ocmd = obj_new('IDLitCommand', $
                     target_identifier=targets[i]->getFullIdentifier())
 
      ydata = targets[i]->getParameter('Y')
      result = ydata->getData(y)
      result = ocmd->addItem('INITIAL_Y', y)

      oCmdSet->add, ocmd
  endfor

  return, 1B
end


;+
; Record y data values after the operation for doing a redo later.
; 
; @returns 1 for success, 0 otherwise
; @param oCmdSet {in}{required}{type=object} IDLitCommandSet to record final 
;        values in
; @param targets {in}{required}{type=objarr} array of object references to query
; @param idprop {in}{optional} not needed
;-
function mgitopderivative::recordFinalValues, oCmdSet, targets, idprop
  compile_opt strictarr

  for i = 0L, n_elements(targets) - 1L do begin
      ocmd = obj_new('IDLitCommand', $
                     target_identifier=targets[i]->getFullIdentifier())
 
      ydata = targets[i]->getParameter('Y')
      result = ydata->getData(y)
      result = ocmd->addItem('FINAL_Y', y)

      oCmdSet->add, ocmd
  endfor

  return, 1B
end


;+
; Do an undo of the operation.
;
; @returns 1 for success, 0 otherwise
; @param oCmdset {in}{required}{type=object} IDLitCommandSet containing the 
;        initial values information
;-
function mgitopderivative::undoOperation, oCmdSet
    compile_opt strictarr

    ocmds = oCmdSet->get(/all, count=ncmds)

    otool = self->getTool()

    for i = 0, ncmds - 1L do begin
        ocmds[i]->getProperty, target_identifier=id
        otarget = otool->getByIdentifier(id)
        if (ocmds[i]->getItem('INITIAL_Y', y)) then begin
            ydata = otarget->getParameter('Y')
            result = ydata->setData(y)
        endif
    endfor

    return, 1B
end


;+
; Do a redo of the operation.
;
; @returns 1 for success, 0 otherwise
; @param oCmdset {in}{required}{type=object} IDLitCommandSet containing the 
;        final values information
;-
function mgitopderivative::redoOperation, oCmdSet
    compile_opt strictarr

    ocmds = oCmdSet->get(/all, count=ncmds)

    otool = self->getTool()

    for i = 0, ncmds - 1L do begin
        ocmds[i]->getProperty, target_identifier=id
        otarget = otool->getByIdentifier(id)
        if (ocmds[i]->getItem('FINAL_Y', y)) then begin
            ydata = otarget->getParameter('Y')
            result = ydata->setData(y)
        endif
    endfor

    return, 1B
end


;+
; Do the derivative.
;
; @param plot {in}{required}{type=object} IDLitVisPlot object reference
;-
pro mgitopderivative::doDerivative, plot
    compile_opt strictarr

    xdata = plot->getParameter('X')
    ydata = plot->getParameter('Y')

    result = xdata->getData(x)
    result = ydata->getData(y)

    yprime = deriv(x, y)

    result = ydata->setData(yprime)
end


;+
; Do the operation.
;
; @returns IDLitCommandSet
; @param otool {in}{required}{type=object} IDLitTool object reference
;-
function mgitopderivative::doAction, otool
    compile_opt strictarr

    ; sanity check
    if (~obj_valid(otool)) then return, obj_new()

    ; find selected IDLitVisPlots
    otargets = otool->getSelectedItems()
    oplots = obj_new('IDL_Container')
    for i = 0L, n_elements(otargets) - 1L do begin
        if (obj_isa(otargets[i], 'IDLitVisPlot')) then begin
            oplots->add, otargets[i]
        endif
    endfor
    plots = oplots->get(/all, count=nplots)
    oplots->remove, /all
    obj_destroy, oplots
    
    ; if no selected IDLitVisPlots, then we're done
    if (nplots eq 0) then return, obj_new()
    
    ; get an empty IDLitCommandset
    oCmdSet = self->IDLitOperation::doAction(otool) 

    ; record initial values for undo
    result = self->recordInitialValues(oCmdSet, plots, idprop)

    ; find derivatives of plots data objects
    for i = 0L, nplots - 1L do begin
        self->doDerivative, plots[i]
    endfor

    ; record final values for redo
    result = self->recordFinalValues(oCmdSet, plots, idprop)

    otool->refreshCurrentWindow

    return, oCmdSet
end


;+
; Make sure to call parent's cleanup method.
;-
pro mgitopderivative::cleanup
    compile_opt strictarr

    self->IDLitOperation::cleanup
end


;+
; Make sure to call parent's init method with TYPES keyword and _EXTRA.
;
; @returns 1 for success, 0 otherwise
; @keyword _ref_extra {in}{out}{optional}{type=keywords} keywords passed to 
;          parent's init method
;-
function mgitopderivative::init, _ref_extra=e
    compile_opt strictarr
    
    if (~self->IDLitOperation::init(types=['IDLVector'], name='Derivative', $
                                    icon='plot', _extra=e)) then return, 0B
    
    return, 1B
end


;+
; Define member variables.
;-
pro mgitopderivative__define
    compile_opt strictarr

    define = { mgitopderivative, inherits IDLitOperation }
end
