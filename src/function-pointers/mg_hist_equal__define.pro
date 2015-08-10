; docformat = 'rst'


;= operators

function mg_hist_equal::_overloadFunction, im
  compile_opt strictarr

  return, hist_equal(im, percent=self.percent, top=self.top)
end


;= property access

pro mg_hist_equal::setProperty, percent=percent, top=top
  compile_opt strictarr

  if (n_elements(percent) gt 0L) then self.percent = percent
  if (n_elements(top) gt 0L) then self.top = top
end


;= lifecycle methods

function mg_hist_equal::init, _extra=e
  compile_opt strictarr

  if (~self->IDL_Object::init()) then return, 0

  self->setProperty, _extra=e

  return, 1
end

pro mg_hist_equal__define
  compile_opt strictarr

  !null = { mg_hist_equal, inherits IDL_Object, $
            percent: 0.0, $
            top: 0 $
          }
end

