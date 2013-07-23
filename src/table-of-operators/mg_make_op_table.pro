;+
; Make the Periodic Table of IDL Operators.
;-
pro mg_make_op_table
  compile_opt strictarr
  
  ncols = 18
  nrows = 13

  oview = obj_new('IDLgrView', viewplane_rect=[-0.5, -0.5, ncols + 1, nrows + 1])

  omodel = obj_new('IDLgrModel')
  oview->add, omodel

  ; add operators
  oparser = obj_new('MGffXMLSAXOperators', model=omodel)
  oparser->parseFile, 'operators.xml'

  otitleFont = obj_new('IDLgrFont', 'Times', size=28.0)
  oAuthorFont = obj_new('IDLgrFont', 'Helvetica', size=11.0)
  oGroupNameFont = obj_new('IDLgrFont', 'Helvetica', size=12.0)

  otitle = obj_new('IDLgrText', 'Periodic Table of IDL Operators', $
                   locations=[ncols + 0.75, nrows], $
                   alignment=1.0, vertical_alignment=1.0, $
                   font=otitleFont)
  omodel->add, otitle
   
  oAuthor = obj_new('IDLgrText', $
                    'Michael Galloy, 2006 - michaelgalloy.com', $
                    locations=[ncols, nrows - 0.85], $
                    alignment=1.0, vertical_alignment=1.0, $
                    font=oAuthorFont)
  omodel->add, oAuthor

  yoffset = 0.35
  oAccess = obj_new('IDLgrText', 'Access', $
                    locations=[1.0, 10+yoffset], $
                    alignment=0.5, vertical_alignment=0.5, $
                    font=oGroupNameFont)
  omodel->add, oAccess

  oCompound = obj_new('IDLgrText', 'Assignment and compound assignment', $
                    locations=[4.0, 2+yoffset], $
                    alignment=0.0, vertical_alignment=0.5, $
                    font=oGroupNameFont)
  omodel->add, oCompound

  oMathematical = obj_new('IDLgrText', 'Mathematical', $
                    locations=[6.5, 9+yoffset], $
                    alignment=0.5, vertical_alignment=0.5, $
                    font=oGroupNameFont)
  omodel->add, oMathematical

  oRelational = obj_new('IDLgrText', 'Relational', $
                    locations=[12.0, 7+yoffset], $
                    alignment=0.5, vertical_alignment=0.5, $
                    font=oGroupNameFont)
  omodel->add, oRelational

  oLogical = obj_new('IDLgrText', 'Logical/bitwise', $
                    locations=[16.5, 7+yoffset], $
                    alignment=0.5, vertical_alignment=0.5, $
                    font=oGroupNameFont)
  omodel->add, oLogical

  oCreation = obj_new('IDLgrText', 'Creation', $
                    locations=[2.75, 11+yoffset], $
                    alignment=1.0, vertical_alignment=0.5, $
                    font=oGroupNameFont)
  omodel->add, oCreation

  oGrouping = obj_new('IDLgrText', 'Grouping', $
                    locations=[3.25, 11+yoffset], $
                    alignment=0.0, vertical_alignment=0.5, $
                    font=oGroupNameFont)
  omodel->add, oGrouping

  width = 10.5
  height = width * nrows / ncols

  ; UNITS = 1 is inches
  owindow = obj_new('IDLgrClipboard', $
                    dimensions=[width, height], units=1, $
                    graphics_tree=oview)
  owindow->draw, filename='operators.eps', /postscript, /vector

  obj_destroy, [otitleFont, oAuthorFont, oGroupNameFont]
end
