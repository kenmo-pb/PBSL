; +-----------------------------------------------+
; | PureBasic Standard Library - PB Compatibility |
; +-----------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_PBCompatibility_Included, #PB_Constant))
  #_PBSL_PBCompatibility_Included = #True
  
  ;- - Compatibility Constants
  
  #TLSSupport = PBGTE(620)
  
  #RequestersSupportParentID = PBGTE(610)
  
  CompilerIf (Not Defined(PB_Compiler_Backend, #PB_Constant))
    #PB_Backend_Asm      = 0
    #PB_Backend_C        = 1
    #PB_Compiler_Backend = #PB_Backend_Asm
  CompilerEndIf
  
  #IsAsmBackend = Bool(#PB_Compiler_Backend = #PB_Backend_Asm)
  #IsCBackend   = Bool(#PB_Compiler_Backend = #PB_Backend_C)
  
  CompilerIf (Not Defined(PB_Compiler_Optimizer, #PB_Constant))
    #PB_Compiler_Optimizer = #False
  CompilerEndIf
  
  CompilerIf (Not Defined(PB_2DDrawing_NativeText, #PB_Constant))
    #PB_2DDrawing_NativeText = #Null
  CompilerEndIf
  CompilerIf (Not Defined(PB_2DDrawing_FastText, #PB_Constant))
    #PB_2DDrawing_FastText = #Null
  CompilerEndIf
  
  CompilerIf (Not Defined(PB_FontRequester_Effects, #PB_Constant))
    #PB_FontRequester_Effects = 0
  CompilerEndIf
  
  #PB_Date_LocalTime = 0
  #PB_Date_UTC       = 1
  
  #PB_SoundPlugin_WAV  = $564157
  #PB_SoundPlugin_FLAC = $43414C46
  #PB_SoundPlugin_OGG  = $47474F
  #PB_SoundPlugin_MP3  = $33504D
  #PB_SoundPlugin_Opus = $5355504F
  
  #PB_ImagePlugin_WEBP = $50424557
  
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
