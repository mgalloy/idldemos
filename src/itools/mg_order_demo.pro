;+
; Demo of programmatically changing the rendering order for items in an itool.
;-
pro mg_order_demo
    compile_opt strictarr

    x = randomu(seed, 20) * 20
    y = randomu(seed, 20) * 20
    z = randomu(seed, 20) * 20
    d = dist(20)
    
    isurface, d
    id = itGetCurrent(tool=otool)
    surfID = otool->findIdentifiers('*surface', /visualization)
    result = otool->doSetProperty(surfID[0], 'Transparency', 50)
    otool->commitActions
    
    iplot, x, y, z, /overplot
    sendToBackID = otool->findIdentifiers('*sendtoback', /operations)
    result = otool->doAction(sendToBackID)
end
