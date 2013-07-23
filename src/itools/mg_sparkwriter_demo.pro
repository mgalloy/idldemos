;+
; Demo of using the MGitWriteSparkline file writer for the iTools system. Needs
; mgitwritesparkline__define.pro and mg_sparkline.pro.
;-
pro mg_sparkwriter_demo
    compile_opt strictarr

    iplot, randomu(seed, 50)
    id = itGetCurrent(tool=oplot) 
    oplot->registerFileWriter, 'Sparkline writer', 'MGitWriteSparkline', $
                               description='PNG representation of a sparkline'
end
