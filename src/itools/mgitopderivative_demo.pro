;+
; Creates a simple sine curve, displays it in an iTool, and registers a 
; derivative operation.
;-
pro mgitopderivative_demo
    compile_opt strictarr

    x = findgen(360) * !dtor
    y = sin(x)

    iplot, x, y
    id = itGetCurrent(tool=otool)
    otool->registerOperation, 'Derivative', 'mgitopderivative', $
                              identifier='Operations/Derivative'
end
