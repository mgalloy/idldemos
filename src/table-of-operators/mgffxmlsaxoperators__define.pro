;+
; Function to associate particular colors to groups of operators.
; 
; @returns bytarr(3)
; @param name {in}{required}{type=string} name of group of operators
;-
function getColor, name
  compile_opt strictarr

  case strlowcase(name) of
    'access' : color = [200, 255, 200]
    'arithmetic' : color = [200, 200, 255]
    'assignment' : color = [200, 175, 255]
    'bitwise' : color = [175, 255, 255]
    'comparison' : color = [255, 255, 175]
    'creation' : color = [255, 210, 210]
    'grouping' : color = [255, 175, 125]
    'logical' : color = [255, 175, 255]
    else : color = [255, 255, 255]
  endcase

  return, byte(color)
end


;+
; Lookup given attribute name in attNames array and find its corresponding value.
;
; @returns string
; @param attNames {in}{required}{type=strarr} names of attributes
; @param attValues {in}{required}{type=strarr} values of attributes
; @param attName {in}{required}{type=string} name of attribute to lookup
; @keyword found {out}{optional}{type=boolean} true if attName is found
;-
function getAttribute, attNames, attValues, attName, found=found
  compile_opt strictarr

  index = where(attNames eq attName, found)
  return, attValues[index[0]]
end


;+
; Parse an element.
;
; @param uri {in}{required}{string} namespace URI
; @param local {in}{required}{string} name with any prefix removed
; @param qName {in}{required}{string} name of element from the XML file
; @param attNames {in}{required}{type=strarr} names of attributes of element
; @param attValues {in}{required}{type=strarr} values of attributes of element
;-
pro mgffxmlsaxoperators::startElement, uri, local, qName, attNames, attValues
  compile_opt strictarr

  myLocal = strlowcase(local)
  case myLocal of
    'table' :
    'operator' : begin
      name = getAttribute(attNames, attValues, 'name')
      symbol = getAttribute(attNames, attValues, 'symbol')
      group = getAttribute(attNames, attValues, 'group')
      precedence = getAttribute(attNames, attValues, 'precedence')
      vectorizable = byte(getAttribute(attNames, attValues, 'vectorizable'))
      col = long(getAttribute(attNames, attValues, 'col'))
      row = long(getAttribute(attNames, attValues, 'row'))
      
      x = [0, 1, 1, 0, 0] + col
      y = [0, 0, 1, 1, 0] + row
      outline = obj_new('IDLgrPolyline', x, y)
      self.model->add, outline

      shading = obj_new('IDLgrPolygon', x, y, color=getColor(group), depth_offset=1)
      self.model->add, shading
       
      shadow = obj_new('IDLgrPolygon', x + self.shadowX, y + self.shadowY, $
                       color=[200, 200, 200], depth_offset=2)
      self.model->add, shadow

      symbolText = obj_new('IDLgrText', symbol, $
                           locations=[col + self.symbolX, row + self.symbolY, 0.0], $
                           alignment=0.5, vertical_alignment=0.5, $
                           font=self.symbolFont)
      self.model->add, symbolText

      nameText = obj_new('IDLgrText', name, $
                           locations=[col + self.nameX, row + self.nameY, 0.0], $
                           alignment=0.5, vertical_alignment=1.0, $
                           font=self.nameFont, /enable_formatting)
      self.model->add, nameText

      precedenceText = obj_new('IDLgrText', precedence, $
                               location=[col + self.precX, row + self.precY, 0.0], $
                               alignment=1.0, vertical_alignment=1.0, $
                               font=self.detailFont)
      self.model->add, precedenceText

      if (vectorizable) then begin
        vectorizableText = obj_new('IDLgrText', 'V', $
                                   locations=[col + self.vecX, $
                                              row + self.vecY, 0.0], $
                                   alignment=0.0, vertical_alignment=1.0, $
                                   font=self.detailFont)
        self.model->add, vectorizableText
      endif
    end
  endcase
end


;+
; Cleanup resources.
;-
pro mgffxmlsaxoperators::cleanup
  compile_opt strictarr

  obj_destroy, [self.symbolFont, self.nameFont, self.detailFont]
  self->IDLffXMLSAX::cleanup
end


;+
; Initialize parser.
;
; @returns 1 for succces, 0 otherwise
; @keyword model {in}{required}{type=object} IDLgrModel reference to add
;          operator graphics to
; @keyword _extra {in}{optional}{type=keywords} keywords to IDLffXMLSAX::init
;-
function mgffxmlsaxoperators::init, model=model, _extra=e
  compile_opt strictarr

  if (~self->IDLffXMLSAX::init(_strict_extra=e)) then return, 0
  self.model = model

  self.detailFont = obj_new('IDLgrFont', 'Helvetica', size=6.0)
  self.nameFont = obj_new('IDLgrFont', 'Helvetica', size=5.0)
  self.symbolFont = obj_new('IDLgrFont', 'Courier*Bold', size=11.0)

  self.nameX = 0.5
  self.nameY = 0.40

  self.symbolX = 0.5
  self.symbolY = 0.60

  self.vecX = 0.1
  self.vecY = 0.9

  self.precX = 0.9
  self.precY = 0.9

  self.shadowX = 0.1
  self.shadowY = -0.1

  return, 1
end


;+
; Define instance variables.
;
; @field symbolFont font used for large symbol of operator
; @field detailsFont font used for precedence and vectorizable status
; @field nameFont font used for name of operator
; @field nameX relative x location of name
; @field nameY relative y location of name
; @field symbolX relative x location of symbol
; @field symbolY relative y location of symbol
; @field vecX relative x location of vectorizable status
; @field vecY relative y location of vectorizable status
; @field precX relative x location of precedence
; @field precY relative y location of precedence
; @field shadowX x offset of shadow
; @field shadowY y offset of shadow
; @field model IDLgrModel to add operator graphics to
;-
pro mgffxmlsaxoperators__define
  compile_opt strictarr

  define = { mgffxmlsaxoperators, inherits IDLffXMLSAX, $
             symbolFont: obj_new(), $
             detailFont: obj_new(), $
             nameFont: obj_new(), $
             nameX: 0.0, $
             nameY: 0.0, $
             symbolX: 0.0, $
             symbolY:0.0, $
             vecX: 0.0, $
             vecY: 0.0, $
             precX: 0.0, $
             precY: 0.0, $
             shadowX: 0.0, $
             shadowY: 0.0, $
             model: obj_new() $
           }
end
