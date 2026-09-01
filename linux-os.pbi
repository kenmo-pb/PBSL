; +---------------------------------------+
; | PureBasic Standard Library - Linux OS |
; +---------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_LinuxOS_Included, #PB_Constant))
  #_PBSL_LinuxOS_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  CompilerIf (#IsLinuxBuild)
    
  CompilerEndIf
  
CompilerEndIf
;-
