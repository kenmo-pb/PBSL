; +-----------------------------------------+
; | PureBasic Standard Library - Windows OS |
; +-----------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_WindowsOS_Included, #PB_Constant))
  #_PBSL_WindowsOS_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  CompilerIf (#IsWindowsBuild)
    
    ;- - Initialization
    
    ; https://learn.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-seterrormode
    ; "Best practice is that all applications call the process-wide SetErrorMode function
    ;  with a parameter of SEM_FAILCRITICALERRORS at startup.
    ;  This is to prevent error mode dialogs from hanging the application."
    CompilerIf (#True)
      SetErrorMode_(#SEM_FAILCRITICALERRORS)
    CompilerEndIf
    
  CompilerEndIf
  
CompilerEndIf
;-
