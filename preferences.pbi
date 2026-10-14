; +------------------------------------------+
; | PureBasic Standard Library - Preferences |
; +------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Preferences_Included, #PB_Constant))
  #_PBSL_Preferences_Included = #True
  
  ;- - Preferences Procedures
  
  Procedure WritePreferenceBool(Key.s, Value.i)
    WritePreferenceInteger(Key, Bool(Value))
  EndProcedure
  
  Procedure.i ReadPreferenceBool(Key.s, DefaultValue.i)
    Protected Text.s = LCase(Trim(ReadPreferenceString(Key, "")))
    If (Text)
      ProcedureReturn (ParseBool(Text))
    EndIf
    ProcedureReturn (DefaultValue)
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
  
  Procedure.i ReadPreferencesToMap(File.s, Map StrMap.s(), GroupDelimiter.s = ".", LCaseKeys.i = #False)
    Protected Result.i = #False
    ClearMap(StrMap())
    If (OpenPreferences(File))
      If (ExaminePreferenceGroups())
        Repeat
          If (ExaminePreferenceKeys())
            While (NextPreferenceKey())
              Protected Key.s = PreferenceKeyName()
              If (PreferenceGroupName())
                Key = PreferenceGroupName() + GroupDelimiter + Key
              EndIf
              If (LCaseKeys)
                Key = LCase(Key)
              EndIf
              StrMap(Key) = PreferenceKeyValue()
            Wend
          EndIf
        Until (Not NextPreferenceGroup())
        Result = #True
      EndIf
      ClosePreferences()
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
