; +------------------------------------------+
; | PureBasic Standard Library - Preferences |
; +------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Preferences_Included, #PB_Constant))
  #_PBSL_Preferences_Included = #True
  
  ;- - Preferences Constants
  
  ; So that we can Compose and Parse font styles equally on all OS...
  #_PBSL_FontFlag_Bold   = #PB_Font_Bold
  #_PBSL_FontFlag_Italic = #PB_Font_Italic
  CompilerIf (#PB_Font_Underline <> 0)
    #_PBSL_FontFlag_Underline = #PB_Font_Underline
  CompilerElse
    #_PBSL_FontFlag_Underline = $01000000
  CompilerEndIf
  CompilerIf (#PB_Font_StrikeOut <> 0)
    #_PBSL_FontFlag_Strike = #PB_Font_StrikeOut
  CompilerElse
    #_PBSL_FontFlag_Strike = $02000000
  CompilerEndIf
  
  ;-
  ;- - Preferences Procedures
  
  Procedure.s ComposeFontStyle(Style.i, StringIfNormal.s = "")
    Protected Result.s = ""
    Protected Delimiter.s = ", "
    If (Style & #_PBSL_FontFlag_Bold)
      Result + Delimiter + "bold"
    EndIf
    If (Style & #_PBSL_FontFlag_Italic)
      Result + Delimiter + "italic"
    EndIf
    If (Style & #_PBSL_FontFlag_Underline)
      Result + Delimiter + "underline"
    EndIf
    If (Style & #_PBSL_FontFlag_Strike)
      Result + Delimiter + "strike"
    EndIf
    If (Result)
      Result = Mid(Result, 1 + Len(Delimiter))
    Else
      Result = StringIfNormal
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ParseFontStyle(StyleString.s)
    Protected Result.i = #PB_Font_Normal
    CompilerIf (#True) ; naive FindString method
      StyleString = LCase(StyleString)
      If (FindString(StyleString, "bold"))
        Result | #_PBSL_FontFlag_Bold
      EndIf
      If (FindString(StyleString, "ital"))
        Result | #_PBSL_FontFlag_Italic
      EndIf
      If (FindString(StyleString, "unde"))
        Result | #_PBSL_FontFlag_Underline
      EndIf
      If (FindString(StyleString, "strik"))
        Result | #_PBSL_FontFlag_Strike
      EndIf
    CompilerEndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure WritePreferenceFontStyle(Key.s, Value.i, StringIfNormal.s = "normal")
    WritePreferenceString(Key, ComposeFontStyle(Value, StringIfNormal))
  EndProcedure
  
  Procedure.i ReadPreferenceFontStyle(Key.s, DefaultValue.i = #PB_Font_Normal)
    Protected Text.s = Trim(ReadPreferenceString(Key, ""))
    If (Text)
      ProcedureReturn (ParseFontStyle(Text))
    EndIf
    ProcedureReturn (DefaultValue)
  EndProcedure
  
  Procedure WritePreferenceBool(Key.s, Value.i)
    ;WritePreferenceInteger(Key, Bool(Value))
    WritePreferenceString(Key, StrBool(Value))
  EndProcedure
  
  Procedure.i ReadPreferenceBool(Key.s, DefaultValue.i)
    Protected Text.s = Trim(ReadPreferenceString(Key, ""))
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
