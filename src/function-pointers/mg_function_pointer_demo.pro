; docformat = 'rst'

function mg_function_pointer_demo, im, op
  compile_opt strictarr

  return, op(im)
end


; main-level example

he = mg_hist_equal(percent=10.0, top=255)

dims = [248, 248]
file = filepath('convec.dat', subdir=['examples', 'data'])
mantle = read_binary(file, data_dims=dims)

equ_mantle = mg_function_pointer_demo(mantle, he)

window, xsize=dims[0] * 2, ysize=dims[1]
tv, mantle, 0
tv, equ_mantle, 1

end