; +-----------------------------------------------+
; | PureBasic Standard Library - PB Compatibility |
; +-----------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_PBCompatibility_Included, #PB_Constant))
  #_PBSL_PBCompatibility_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Compatibility Constants
  
  #TLSSupport = PBGTE(620)
  
  #RequestersSupportParentID = PBGTE(610)
  
  CompilerIf (Not Defined(PB_Compiler_Backend, #PB_Constant))
    #PB_Backend_Asm      = 0
    #PB_Backend_C        = 1
    #PB_Compiler_Backend = #PB_Backend_Asm
  CompilerEndIf
  
  #IsAsmBuild = Bool(#PB_Compiler_Backend = #PB_Backend_Asm)
  #IsCBuild   = Bool(#PB_Compiler_Backend = #PB_Backend_C)
  
  CompilerIf (Not Defined(PB_2DDrawing_NativeText, #PB_Constant))
    #PB_2DDrawing_NativeText = #Null
  CompilerEndIf
  CompilerIf (Not Defined(PB_2DDrawing_FastText, #PB_Constant))
    #PB_2DDrawing_FastText = #Null
  CompilerEndIf
  
  #PB_Date_LocalTime = 0
  #PB_Date_UTC       = 1
  
  ;-
  ;- - Compatibility Procedures
  
  CompilerIf (PBGTE(610))
    Procedure.i _InitScintilla()
      ProcedureReturn (#True)
    EndProcedure
    Macro InitScintilla(_Library = "")
      _InitScintilla()
    EndMacro
  CompilerEndIf
  
  CompilerIf (PBGTE(600))
    Procedure.i _InitNetwork()
      ProcedureReturn (#True)
    EndProcedure
    Macro InitNetwork()
      _InitNetwork()
    EndMacro
  CompilerEndIf
  
CompilerEndIf
;-
