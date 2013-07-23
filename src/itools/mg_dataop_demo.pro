;+
; This demonstrates how to add a custom operation to an itool. The operation is 
; defined in mgitopadapthistequal__define.pro.
;-
pro mg_dataop_demo
    compile_opt strictarr

    ; Read in some default data.
    f = filepath('endocell.jpg', subdir=['examples', 'data'])
    endo = read_image(f)
    
    ; Start an itool.
    iimage, endo
    
    ; Use itGetCurrent to get the the itool identifier and object reference. We
    ; only need the object reference, but are required to get the object 
    ; reference. Be sure to use itGetCurrent right after creating the itool, 
    ; because if another itool is created or even becames the current window in 
    ; the OS, it will be the current itool.
    id = itGetCurrent(tool=otool)
    
    ; Register our operation on the itool. The positional parameters give a name
    ; for our operation and the classname that defines the operation. The 
    ; IDENTIFIER keyword locates the operation in the menu system. For instance,
    ; the identifier 'File/AdaptHistEqual' would put this in the File menu of the
    ; itool. More usefully, 'Operations/My Operations/AdaptHistEqual' would 
    ; create a new submenu in the Operations menu and put this operation in it.
    ; The ICON keyword specifies an icon for the operation in the operation 
    ; browser. In this case, it's in the default icon directory, the equivalent
    ; of filepath('image.bmp', subdir=['examples', 'data']).
    otool->registerOperation, 'AdaptHistEqual', $  
                              'MGitOpAdaptHistEqual', $  
                              identifier='Operations/AdaptHistEqual', $
                              icon='image'
end
