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
  
  #WEBPSupport = PBGTE(650)
  
  #TLSSupport = PBGTE(620)
  
  #SFTPSupport = PBGTE(612)
  
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
  
  #PB_Font_Normal = 0
  CompilerIf (Not Defined(PB_Font_Underline, #PB_Constant))
    #PB_Font_Underline = 0
  CompilerEndIf
  CompilerIf (Not Defined(PB_Font_StrikeOut, #PB_Constant))
    #PB_Font_StrikeOut = 0
  CompilerEndIf
  CompilerIf (Not Defined(PB_Font_HighQuality, #PB_Constant))
    #PB_Font_HighQuality = 0
  CompilerEndIf
  #PB_Font_AllowedStyleMask = #PB_Font_Bold | #PB_Font_Italic | #PB_Font_Underline | #PB_Font_StrikeOut | #PB_Font_HighQuality
  
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
  
  CompilerIf (Not #RequestersSupportParentID)
    CompilerIf (#True) ; automatically "patch" Requester calls which don't support ParentID
      
      Procedure.i _ColorRequester(Color.i)
        ProcedureReturn (ColorRequester(Color))
      EndProcedure
      Procedure.i _FontRequester(FontName.s, FontSize.i, Flags.i, Color.i, Style.i)
        ProcedureReturn (FontRequester(FontName, FontSize, Flags, Color, Style))
      EndProcedure
      Procedure.s _InputRequester(Title.s, Message.s, DefaultString.s, Flags.i)
        ProcedureReturn (InputRequester(Title, Message, DefaultString, Flags))
      EndProcedure
      Procedure.i _MessageRequester(Title.s, Text.s, Flags.i)
        ProcedureReturn (MessageRequester(Title, Text, Flags))
      EndProcedure
      Procedure.s _OpenFileRequester(Title.s, DefaultFile.s, Pattern.s, PatternPosition.i, Flags.i)
        ProcedureReturn (OpenFileRequester(Title, DefaultFile, Pattern, PatternPosition, Flags))
      EndProcedure
      Procedure.s _PathRequester(Title.s, InitialPath.s)
        ProcedureReturn (PathRequester(Title, InitialPath))
      EndProcedure
      Procedure.s _SaveFileRequester(Title.s, DefaultFile.s, Pattern.s, PatternPosition.i)
        ProcedureReturn (SaveFileRequester(Title, DefaultFile, Pattern, PatternPosition))
      EndProcedure
      
      Macro ColorRequester(_Color = #Black, _ParentID = #Null)
        _ColorRequester(_Color)
      EndMacro
      Macro FontRequester(_FontName, _FontSize, _Flags, _Color = #Black, _Style = #Null, _ParentID = #Null)
        _FontRequester(_FontName, (_FontSize), (_Flags), (_Color), (_Style))
      EndMacro
      Macro InputRequester(_Title, _Message, _DefaultString, _Flags = #Null, _ParentID = #Null)
        _InputRequester(_Title, _Message, _DefaultString, (_Flags))
      EndMacro
      Macro MessageRequester(_Title, _Text, _Flags = #Null, _ParentID = #Null)
        _MessageRequester(_Title, _Text, (_Flags))
      EndMacro
      Macro OpenFileRequester(_Title, _DefaultFile, _Pattern, _PatternPosition, _Flags = #Null, _ParentID = #Null)
        _OpenFileRequester(_Title, _DefaultFile, _Pattern, (_PatternPosition), (_Flags))
      EndMacro
      Macro PathRequester(_Title, _InitialPath, _ParentID = #Null)
        _PathRequester(_Title, _InitialPath)
      EndMacro
      Macro SaveFileRequester(_Title, _DefaultFile, _Pattern, _PatternPosition, _ParentID = #Null)
        _SaveFileRequester(_Title, _DefaultFile, _Pattern, (_PatternPosition))
      EndMacro
      
    CompilerEndIf
  CompilerEndIf
  
CompilerEndIf
;-
