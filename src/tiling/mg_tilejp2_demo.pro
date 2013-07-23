;+
; Demo MG_TILEJP2 on ohare.jp2 JPEG2000 image. This routine will construct the
; JPEG2000 file if not in the current directory. There will be a delay if this 
; is necessary.
;-
pro mg_tilejp2_demo
    compile_opt strictarr

    oharejp2filename = 'ohare.jp2'

    ; check if ohare.jp2 is present, create if not present
    if (~file_test(oharejp2Filename)) then begin 
       ohareJPEGFilename = filepath('ohare.jpg', $
                                    subdirectory=['examples', 'data'])
       read_jpeg, ohareJPEGFilename, jpegImage
       imageDims = size(jpegImage, /dimensions)

       ; prepare JPEG2000 object property values
       ncomponents = 3
       nLayers = 20
       nLevels = 6
       offset = [0,0]
       jp2TileDims = [1024, 1024]
       jp2TileOffset = [0,0]
       bitdepth = [8,8,8]

       ; create the JPEG2000 image object
       ojp2 = obj_new('IDLffJPEG2000', oharejp2Filename, write=1)
       ojp2->setProperty, n_components=nComponents, $
                          n_layers=nLayers, $
                          n_levels=nLevels, $
                          offset=offset, $
                          tile_dimensions=jp2TileDims, $
                          tile_offset=jp2TileOffset, $
                          bit_depth=bitDepth, $
                          dimensions=[imageDims[1], imageDims[2]]
 
       ; Set image data, and then destroy the object. You must create
       ; and close the JPEG2000 file object before you can access the
       ; data.
       ojp2->setData, jpegImage
       obj_destroy, ojp2
    endif

    ; start mg_tilejp2 
    mg_tilejp2, oharejp2Filename
 end
