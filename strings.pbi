; +--------------------------------------+
; | PureBasic Standard Library - Strings |
; +--------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Strings_Included, #PB_Constant))
  #_PBSL_Strings_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Hex Representation
  
  Macro Hex8(_Value)
    RSet(Hex((_Value), #PB_Ascii), 2, "0")
  EndMacro
  Macro Hex16(_Value)
    RSet(Hex((_Value), #PB_Unicode), 4, "0")
  EndMacro
  Macro Hex24(_Value)
    RSet(Hex((_Value) & $00FFFFFF, #PB_Long), 6, "0")
  EndMacro
  Macro Hex32(_Value)
    RSet(Hex((_Value), #PB_Long), 8, "0")
  EndMacro
  Macro Hex64(_Value)
    RSet(Hex((_Value), #PB_Quad), 16, "0")
  EndMacro
  
  ;-
  ;- - String Buffers
  
  Procedure.i NullTerminatorBytes(StringFormat.i)
    Select (StringFormat)
      Case #PB_Ascii, #PB_UTF8
        ProcedureReturn (1)
      Case #PB_Unicode, #PB_UTF16, #PB_UTF16BE
        ProcedureReturn (2)
      Case #PB_UTF32, #PB_UTF32BE
        ProcedureReturn (4)
    EndSelect
    ProcedureReturn (0)
  EndProcedure
  
CompilerEndIf
;-
