; +---------------------------------------+
; | PureBasic Standard Library - Console |
; +---------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Console_Included, #PB_Constant))
  #_PBSL_Console_Included = #True
  
  ;- - Console Constants
  
  #ConsoleReturn  = WindowsElse(#CR, #LF)
  #ConsoleReturn$ = Chr(#ConsoleReturn)
  
  ;-
  ;- - Console Procedures
  
  Global _ConsoleRequesterCanceled.i
  
  Procedure.i ConsoleRequesterWasCanceled()
    ProcedureReturn (_ConsoleRequesterCanceled)
  EndProcedure
  
  Procedure PrintBlankLine()
    PrintN("")
  EndProcedure
  
  Procedure EraseLastConsoleCharacter()
    Print(#BS$ + " " + #BS$)
  EndProcedure
  
  Procedure PrintNBordered(Text.s, UnderlineChar.s = "", OverlineChar.s = "", SideChars.s = "", CornerChar.s = "")
    Protected N.i = Len(Text)
    Protected SideLen.i = Len(SideChars)
    If (SideLen > 0)
      Text = SideChars + Text + ReverseString(SideChars)
    EndIf
    Protected Line.s
    If (OverlineChar)
      If (SideLen > 0)
        If (CornerChar <> "")
          Line = CornerChar + RepeatString(OverlineChar, N + 2*(SideLen-1)) + CornerChar
        Else
          Line = RepeatString(OverlineChar, N + 2*(SideLen))
        EndIf
      Else
        Line = RepeatString(OverlineChar, N)
      EndIf
      PrintN(Line)
    EndIf
    ;
    PrintN(Text)
    ;
    If (UnderlineChar)
      If (SideLen > 0)
        If (CornerChar <> "")
          Line = CornerChar + RepeatString(UnderlineChar, N + 2*(SideLen-1)) + CornerChar
        Else
          Line = RepeatString(UnderlineChar, N + 2*(SideLen))
        EndIf
      Else
        Line = RepeatString(UnderlineChar, N)
      EndIf
      PrintN(Line)
    EndIf
  EndProcedure
  
  Procedure.i ConsoleMessageRequester(Text.s, Flags.i = #PB_MessageRequester_Ok)
    Protected Result.i = 0
    
    _ConsoleRequesterCanceled = #False
    
    Protected Indent.s = ""
    If (Flags & #PB_MessageRequester_Error)
      Text = "(X) " + Text
      Indent = Space(4)
    ElseIf (Flags & #PB_MessageRequester_Warning)
      Text = "(!) " + Text
      Indent = Space(4)
    ElseIf (Flags & #PB_MessageRequester_Info)
      Text = "(i) " + Text
      Indent = Space(4)
    ElseIf (Flags & #PB_MessageRequester_Question)
      Text = "(?) " + Text
      Indent = Space(4)
    EndIf
    Flags = Flags & ~(#PB_MessageRequester_Info | #PB_MessageRequester_Warning | #PB_MessageRequester_Error | #PB_MessageRequester_Question)
    
    If (Text)
      PrintN(Text)
    EndIf
    If (#True)
      If (Flags = #PB_MessageRequester_YesNo)
        PrintN(Indent + "[Y]es or [N]o")
      ElseIf (Flags = #PB_MessageRequester_YesNoCancel)
        PrintN(Indent + "[Y]es [N]o or [C]ancel")
      EndIf
    EndIf
    Delay(100)
    
    Protected Key.s
    Repeat
      Delay(10)
      Key = UCase(Inkey())
      If (Key = "Y") And ((Flags = #PB_MessageRequester_YesNo) Or (Flags = #PB_MessageRequester_YesNoCancel))
        Result = #PB_MessageRequester_Yes
      ElseIf (Key = "N") And ((Flags = #PB_MessageRequester_YesNo) Or (Flags = #PB_MessageRequester_YesNoCancel))
        Result = #PB_MessageRequester_No
      ElseIf ((Key = " ") Or (Key = #ConsoleReturn$)) And (Flags = #Null)
        Result = 1
      ElseIf (Key = #ESC$) And (Flags = #Null)
        Result = 1
      ElseIf ((Key = #ESC$) Or (Key = "C")) And (Flags = #PB_MessageRequester_YesNoCancel)
        Result = #PB_MessageRequester_Cancel
        _ConsoleRequesterCanceled = #True
      EndIf
    Until (Result)
    Delay(100)
    RawKey()
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s ConsoleInputRequester(Message.s, DefaultString.s = "", Flags.i = #Null)
    Protected Result.s = ""
    
    _ConsoleRequesterCanceled = #False
    
    Protected Build.s = DefaultString
    Print(Message)
    If (Not (Flags & #PB_InputRequester_Password))
      If (Build)
        Print(Build)
      EndIf
    EndIf
    While (#True)
      Delay(10)
      Protected Key.s = Inkey()
      Select (Key)
        Case #BS$, Chr($7F)
          If (Len(Build) > 0)
            If (Not (Flags & #PB_InputRequester_Password))
              EraseLastConsoleCharacter()
            EndIf
            Build = Left(Build, Len(Build) - 1)
          EndIf
        Case #ESC$
          _ConsoleRequesterCanceled = #True
          Break
        Case #ConsoleReturn$
          Result = Build
          Break
        Default
          If (Asc(Key) >= $20)
            If (Not (Flags & #PB_InputRequester_Password))
              Print(Key)
            EndIf
            Build + Key
          EndIf
      EndSelect
    Wend
    PrintN("")
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s ConsolePasswordRequester(Message.s)
    ProcedureReturn (ConsoleInputRequester(Message, "", #PB_InputRequester_Password))
  EndProcedure
  
CompilerEndIf
;-
