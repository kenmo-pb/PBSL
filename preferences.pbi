; +------------------------------------------+
; | PureBasic Standard Library - Preferences |
; +------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Preferences_Included, #PB_Constant))
  #_PBSL_Preferences_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  ;XIncludeFile "common.pbi"
  XIncludeFile "color.pbi"
  
  ;- - Preferences Procedures
  
  Procedure WritePreferenceBool(Key.s, Value.i)
    WritePreferenceInteger(Key, Bool(Value))
  EndProcedure
  
  Procedure.i ReadPreferenceBool(Key.s, DefaultValue.i)
    Protected Result.i
    Select (LCase(Trim(ReadPreferenceString(Key, ""))))
      Case "1", "t", "true", "y", "yes", "on", "en", "enable", "enabled"
        Result = #True
      Case "0", "f", "false", "n", "no", "off", "dis", "disable", "disabled"
        Result = #False
      Default
        Result = DefaultValue
    EndSelect
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure WritePreferenceRGB(Key.s, Color.i, ColorFormat.i = #ColorFormat_Integer)
    WritePreferenceString(Key, ComposeRGB(Color, ColorFormat))
  EndProcedure
  
  Procedure WritePreferenceRGBA(Key.s, Color.i, ColorFormat.i = #ColorFormat_Integer)
    WritePreferenceString(Key, ComposeRGBA(Color, ColorFormat))
  EndProcedure
  
  Procedure.i ReadPreferenceRGBA(Key.s, DefaultValue.i)
    Protected Result.i
    Protected Text.s = LCase(Trim(ReadPreferenceString(Key, "")))
    Select (Text)
      Case ""
        Result = DefaultValue
      Default
        Result = ParseColor(Text) & $FFFFFFFF
    EndSelect
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ReadPreferenceRGB(Key.s, DefaultValue.i)
    Protected Result.i
    Protected Text.s = LCase(Trim(ReadPreferenceString(Key, "")))
    Select (Text)
      Case ""
        Result = DefaultValue
      Default
        Result = ParseColor(Text) & $00FFFFFF
    EndSelect
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
