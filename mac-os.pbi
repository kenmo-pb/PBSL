; +-------------------------------------+
; | PureBasic Standard Library - Mac OS |
; +-------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_MacOS_Included, #PB_Constant))
  #_PBSL_MacOS_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  CompilerIf (#IsMacBuild)
    
  CompilerEndIf
  
CompilerEndIf
;-
