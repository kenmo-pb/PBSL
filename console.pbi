; +---------------------------------------+
; | PureBasic Standard Library - Console |
; +---------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Console_Included, #PB_Constant))
  #_PBSL_Console_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Console Procedures
  
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
  
CompilerEndIf
;-
