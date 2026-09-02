; +--------------------------------------+
; | PureBasic Standard Library - Drawing |
; +--------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Drawing_Included, #PB_Constant))
  #_PBSL_Drawing_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
CompilerEndIf
;-
