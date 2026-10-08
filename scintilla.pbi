; +----------------------------------------+
; | PureBasic Standard Library - Scintilla |
; +----------------------------------------+
;   https://scintilla.org/ScintillaDoc.html

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Scintilla_Included, #PB_Constant))
  #_PBSL_Scintilla_Included = #True
  
  ;- - Scintilla Constants
  
  #STYLE_FIRST = 0
  #STYLE_COUNT = #STYLE_MAX + 1
  
  #SCI_FIRSTLINE   = 0
  #SCI_FIRSTCOLUMN = 0
  
  ;-
  ;- - Scintilla Prototypes
  
  Prototype ScintillaCallback(Gadget.i, *scinotify.SCNotification)
  
  ;-
  ;- - Scintilla Macros
  
  Macro _ScintillaStringBuffer(_String)
    UTF8(_String)
  EndMacro
  
  Macro SSM(_Gadget, _Message, _Param = 0, _lParam = 0)
    ScintillaSendMessage((_Gadget), (_Message), (_Param), (_lParam))
  EndMacro
  
  ;-
  
  Macro Sci_Allocate(_Gadget, _Bytes)
    SSM((_Gadget), #SCI_ALLOCATE, (_Bytes))
  EndMacro
  
  Macro Sci_AssignCmdKey(_Gadget, _KeyDefinition, _SciCommand)
    SSM((_Gadget), #SCI_ASSIGNCMDKEY, (_KeyDefinition), (_SciCommand))
  EndMacro
  
  ;-
  
  Macro Sci_BeginUndoAction(_Gadget)
    SSM((_Gadget), #SCI_BEGINUNDOACTION)
  EndMacro
  
  ;-
  
  Macro Sci_Cancel(_Gadget)
    SSM((_Gadget), #SCI_CANCEL)
  EndMacro
  
  Macro Sci_CanPaste(_Gadget)
    SSM((_Gadget), #SCI_CANPASTE)
  EndMacro
  
  Macro Sci_CanRedo(_Gadget)
    SSM((_Gadget), #SCI_CANREDO)
  EndMacro
  
  Macro Sci_CanUndo(_Gadget)
    SSM((_Gadget), #SCI_CANUNDO)
  EndMacro
  
  Macro Sci_Clear(_Gadget)
    SSM((_Gadget), #SCI_CLEAR)
  EndMacro
  
  Macro Sci_ClearAll(_Gadget)
    SSM((_Gadget), #SCI_CLEARALL)
  EndMacro
  
  Macro Sci_ClearAllCmdKeys(_Gadget)
    SSM((_Gadget), #SCI_CLEARALLCMDKEYS)
  EndMacro
  
  Macro Sci_ClearCmdKey(_Gadget, _KeyDefinition)
    SSM((_Gadget), #SCI_CLEARCMDKEY, (_KeyDefinition))
  EndMacro
  
  Macro Sci_ClearDocumentStyle(_Gadget)
    SSM((_Gadget), #SCI_CLEARDOCUMENTSTYLE)
  EndMacro
  
  Macro Sci_ConvertEOLs(_Gadget, _EOLMode)
    SSM((_Gadget), #SCI_CONVERTEOLS, (_EOLMode))
  EndMacro
  
  Macro Sci_Copy(_Gadget)
    SSM((_Gadget), #SCI_COPY)
  EndMacro
  
  Macro Sci_Cut(_Gadget)
    SSM((_Gadget), #SCI_CUT)
  EndMacro
  
  ;-
  
  Macro Sci_DeleteRange(_Gadget, _Start, _LengthDelete)
    SSM((_Gadget), #SCI_DELETERANGE, (_Start), (_LengthDelete))
  EndMacro
  
  ;-
  
  Macro Sci_EmptyUndoBuffer(_Gadget)
    SSM((_Gadget), #SCI_EMPTYUNDOBUFFER)
  EndMacro
  
  Macro Sci_EndUndoAction(_Gadget)
    SSM((_Gadget), #SCI_ENDUNDOACTION)
  EndMacro
  
  ;-
  
  Macro Sci_GetAnchor(_Gadget)
    SSM((_Gadget), #SCI_GETANCHOR)
  EndMacro
  
  Macro Sci_GetCharAt(_Gadget, _Pos)
    SSM((_Gadget), #SCI_GETCHARAT, (_Pos))
  EndMacro
  
  Macro Sci_GetColumn(_Gadget, _Pos)
    SSM((_Gadget), #SCI_GETCOLUMN, (_Pos))
  EndMacro
  
  Macro Sci_GetCurrentPos(_Gadget)
    SSM((_Gadget), #SCI_GETCURRENTPOS)
  EndMacro
  
  Macro Sci_GetEndStyled(_Gadget)
    SSM((_Gadget), #SCI_GETENDSTYLED)
  EndMacro
  
  Macro Sci_GetEOLMode(_Gadget)
    SSM((_Gadget), #SCI_GETEOLMODE)
  EndMacro
  
  Macro Sci_GetFocus(_Gadget)
    SSM((_Gadget), #SCI_GETFOCUS)
  EndMacro
  
  Macro Sci_GetIndent(_Gadget)
    SSM((_Gadget), #SCI_GETINDENT)
  EndMacro
  
  Macro Sci_GetLength(_Gadget)
    SSM((_Gadget), #SCI_GETLENGTH)
  EndMacro
  
  Macro Sci_GetLineCount(_Gadget)
    SSM((_Gadget), #SCI_GETLINECOUNT)
  EndMacro
  
  Macro Sci_GetLineEndPosition(_Line)
    SSM((_Gadget), #SCI_GETLINEENDPOSITION, (_Line))
  EndMacro
  
  Macro Sci_GetModify(_Gadget)
    SSM((_Gadget), #SCI_GETMODIFY)
  EndMacro
  
  Macro Sci_GetReadOnly(_Gadget)
    SSM((_Gadget), #SCI_GETREADONLY)
  EndMacro
  
  Macro Sci_GetStyleAt(_Gadget, _Pos)
    SSM((_Gadget), #SCI_GETSTYLEAT, (_Pos))
  EndMacro
  
  Macro Sci_GetTextLength(_Gadget)
    SSM((_Gadget), #SCI_GETTEXTLENGTH)
  EndMacro
  
  Macro Sci_GetUseTabs(_Gadget)
    SSM((_Gadget), #SCI_GETUSETABS)
  EndMacro
  
  Macro Sci_GrabFocus(_Gadget)
    SSM((_Gadget), #SCI_GRABFOCUS)
  EndMacro
  
  ;-
  
  Macro Sci_LineFromPosition(_Gadget, _Pos)
    SSM((_Gadget), #SCI_LINEFROMPOSITION, (_Pos))
  EndMacro
  
  ;-
  
  Macro Sci_MoveSelectedLinesDown(_Gadget)
    SSM((_Gadget), #SCI_MOVESELECTEDLINESDOWN)
  EndMacro
  
  Macro Sci_MoveSelectedLinesUp(_Gadget)
    SSM((_Gadget), #SCI_MOVESELECTEDLINESUP)
  EndMacro
  
  ;-
  
  Macro Sci_Paste(_Gadget)
    SSM((_Gadget), #SCI_PASTE)
  EndMacro
  
  Macro Sci_PositionFromLine(_Gadget, _Line)
    SSM((_Gadget), #SCI_POSITIONFROMLINE, (_Line))
  EndMacro
  
  ;-
  
  Macro Sci_Redo(_Gadget)
    SSM((_Gadget), #SCI_REDO)
  EndMacro
  
  Macro Sci_ReplaceSel(_Gadget, _Text)
    SSMIntString((_Gadget), #SCI_REPLACESEL, #Null, _Text)
  EndMacro
  
  ;-
  
  Macro Sci_ScrollToEnd(_Gadget)
    SSM((_Gadget), #SCI_SCROLLTOEND)
  EndMacro
  
  Macro Sci_ScrollToStart(_Gadget)
    SSM((_Gadget), #SCI_SCROLLTOSTART)
  EndMacro
  
  Macro Sci_SelectAll(_Gadget)
    SSM((_Gadget), #SCI_SELECTALL)
  EndMacro
  
  Macro Sci_SetAnchor(_Gadget, _Anchor)
    SSM((_Gadget), #SCI_SETANCHOR, (_Anchor))
  EndMacro
  
  Macro Sci_SetCodePage(_Gadget, _CodePage)
    SSM((_Gadget), #SCI_SETCODEPAGE, (_CodePage))
  EndMacro
  
  Macro Sci_SetCurrentPos(_Gadget, _Caret)
    SSM((_Gadget), #SCI_SETCURRENTPOS, (_Caret))
  EndMacro
  
  Macro Sci_SetEmptySelection(_Gadget, _Caret)
    SSM((_Gadget), #SCI_SETEMPTYSELECTION, (_Caret))
  EndMacro
  
  Macro Sci_SetEOLMode(_Gadget, _EOLMode)
    SSM((_Gadget), #SCI_SETEOLMODE, (_EOLMode))
  EndMacro
  
  Macro Sci_SetFocus(_Gadget, _Focus)
    SSM((_Gadget), #SCI_SETFOCUS, (_Focus))
  EndMacro
  
  Macro Sci_SetHScrollbar(_Gadget, _Visible)
    SSM((_Gadget), #SCI_SETHSCROLLBAR, (_Visible))
  EndMacro
  
  Macro Sci_SetIndent(_Gadget, _IndentSize)
    SSM((_Gadget), #SCI_SETINDENT, (_IndentSize))
  EndMacro
  
  Macro Sci_SetMarginTypeN(_Gadget, _Margin, _MarginType)
    SSM((_Gadget), #SCI_SETMARGINTYPEN, (_Margin), (_MarginType))
  EndMacro
  
  Macro Sci_SetMarginWidthN(_Gadget, _Margin, _PixelWidth)
    SSM((_Gadget), #SCI_SETMARGINWIDTHN, (_Margin), (_PixelWidth))
  EndMacro
  
  Macro Sci_SetReadOnly(_Gadget, _ReadOnly)
    SSM((_Gadget), #SCI_SETREADONLY, (_ReadOnly))
  EndMacro
  
  Macro Sci_SetSavePoint(_Gadget)
    SSM((_Gadget), #SCI_SETSAVEPOINT)
  EndMacro
  
  Macro Sci_SetScrollWidth(_Gadget, _PixelWidth)
    SSM((_Gadget), #SCI_SETSCROLLWIDTH, (_PixelWidth))
  EndMacro
  
  Macro Sci_SetScrollWidthTracking(_Gadget, _Tracking)
    SSM((_Gadget), #SCI_SETSCROLLWIDTHTRACKING, (_Tracking))
  EndMacro
  
  Macro Sci_SetSel(_Gadget, _Anchor, _Caret)
    SSM((_Gadget), #SCI_SETSEL, (_Anchor), (_Caret))
  EndMacro
  
  Macro Sci_SetStyling(_Gadget, _Length, _Style)
    SSM((_Gadget), #SCI_SETSTYLING, (_Length), (_Style))
  EndMacro
  
  Macro Sci_SetText(_Gadget, _Text)
    SSMIntString((_Gadget), #SCI_SETTEXT, #Null, _Text)
  EndMacro
  
  Macro Sci_SetUseTabs(_Gadget, _UseTabs)
    SSM((_Gadget), #SCI_SETUSETABS, (_UseTabs))
  EndMacro
  
  Macro Sci_SetViewEOL(_Gadget, _Visible)
    SSM((_Gadget), #SCI_SETVIEWEOL, (_Visible))
  EndMacro
  
  Macro Sci_SetViewWS(_Gadget, _ViewWS)
    SSM((_Gadget), #SCI_SETVIEWWS, (_ViewWS))
  EndMacro
  
  Macro Sci_SetVScrollbar(_Gadget, _Visible)
    SSM((_Gadget), #SCI_SETVSCROLLBAR, (_Visible))
  EndMacro
  
  Macro Sci_StartStyling(_Gadget, _Start)
    SSM((_Gadget), #SCI_STARTSTYLING, (_Start), (#Null)) ;  "The unused argument was used in earlier versions but is now ignored."
  EndMacro
  
  Macro Sci_StyleClearAll(_Gadget)
    SSM((_Gadget), #SCI_STYLECLEARALL)
  EndMacro
  
  Macro Sci_StyleSetBack(_Gadget, _Style, _Back)
    SSM((_Gadget), #SCI_STYLESETBACK, (_Style), (_Back))
  EndMacro
  
  Macro Sci_StyleSetBold(_Gadget, _Style, _Bold)
    SSM((_Gadget), #SCI_STYLESETBOLD, (_Style), (_Bold))
  EndMacro
  
  Macro Sci_StyleSetFont(_Gadget, _Style, _FontName)
    SSMIntString((_Gadget), #SCI_STYLESETFONT, (_Style), _FontName)
  EndMacro
  
  Macro Sci_StyleSetFore(_Gadget, _Style, _Fore)
    SSM((_Gadget), #SCI_STYLESETFORE, (_Style), (_Fore))
  EndMacro
  
  Macro Sci_StyleSetItalic(_Gadget, _Style, _Italic)
    SSM((_Gadget), #SCI_STYLESETITALIC, (_Style), (_Italic))
  EndMacro
  
  Macro Sci_StyleSetSize(_Gadget, _Style, _SizePoints)
    SSM((_Gadget), #SCI_STYLESETSIZE, (_Style), (_SizePoints))
  EndMacro
  
  Macro Sci_StyleSetUnderline(_Gadget, _Style, _Underline)
    SSM((_Gadget), #SCI_STYLESETUNDERLINE, (_Style), (_Underline))
  EndMacro
  
  Macro Sci_StyleSetWeight(_Gadget, _Style, _Weight)
    SSM((_Gadget), #SCI_STYLESETWEIGHT, (_Style), (_Weight))
  EndMacro
  
  ;-
  
  Macro Sci_TextHeight(_Gadget, _Line)
    SSM((_Gadget), #SCI_TEXTHEIGHT, (_Line))
  EndMacro
  
  Macro Sci_TextWidth(_Gadget, _Style, _Text)
    SSMIntString((_Gadget), #SCI_TEXTWIDTH, (_Style), _Text)
  EndMacro
  
  ;-
  
  Macro Sci_Undo(_Gadget)
    SSM((_Gadget), #SCI_UNDO)
  EndMacro
  
  Macro Sci_UsePopUp(_Gadget, _PopUpMode)
    SSM((_Gadget), #SCI_USEPOPUP, (_PopUpMode))
  EndMacro
  
  ;-
  ;- - Scintilla Procedures
  
  Procedure.i SSMIntString(Gadget.i, Message.i, IntParam.i, StringlParam.s)
    Protected Result.i
    Protected *Buffer = _ScintillaStringBuffer(StringlParam)
    Result = SSM(Gadget, Message, IntParam, *Buffer)
    If (*Buffer)
      FreeMemory(*Buffer)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i MakeScintillaKeyDefinition(KeyCode.i, KeyMod.i = #Null)
    CompilerIf (#True) ; Correct lowercase values to uppercase
      Select (KeyCode)
        Case 'a' To 'z'
          KeyCode + ('A' - 'a')
      EndSelect
    CompilerEndIf
    ProcedureReturn ((KeyCode) + ((KeyMod) << 16))
  EndProcedure
  
  Procedure.s Sci_GetText(Gadget.i)
    Protected Result.s = ""
    ;Protected N.i = 1 + Sci_GetLength(Gadget)
    Protected N.i = 1 + SSM(Gadget, #SCI_GETTEXT, 0, #Null)
    Protected *Buffer = AllocateMemory(N, #PB_Memory_NoClear)
    If (*Buffer)
      SSM(Gadget, #SCI_GETTEXT, N, *Buffer)
      Result = PeekS(*Buffer, N, #PB_UTF8 | #PB_ByteLength)
      FreeMemory(*Buffer)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s Sci_GetTextRangeFull(Gadget.i, Min.q, Max.q)
    Protected Result.s = ""
    If (Max = -1)
      Max = Sci_GetLength(Gadget)
    EndIf
    Protected N.i = 1 + (Max - Min)
    Protected *Buffer = AllocateMemory(N, #PB_Memory_NoClear)
    If (*Buffer)
      Protected TRF.SCTextRangeFull
      TRF\chrg\cpMin = Min
      TRF\chrg\cpMax = Max
      TRF\lpstrText = *Buffer
      SSM(Gadget, #SCI_GETTEXTRANGEFULL, #Null, @TRF)
      Result = PeekS(*Buffer, N, #PB_UTF8 | #PB_ByteLength)
      FreeMemory(*Buffer)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Macro Sci_GetTextRange(_Gadget, _Min, _Max)
    Sci_GetTextRangeFull((_Gadget), (_Min), (_Max))
  EndMacro
  
  Procedure.i ScintillaLoadFromFile(Gadget.i, File.s, MarkAsNew.i = #False)
    Protected Result.i = #False
    If (File)
      Protected FN.i = ReadFile(#PB_Any, File)
      If (FN)
        Protected Format.i = ReadStringFormat(FN)
        If (Format = #PB_Ascii)
          Format = #PB_UTF8
        EndIf
        Sci_SetText(Gadget, ReadString(FN, Format | #PB_File_IgnoreEOL))
        If (MarkAsNew)
          Sci_EmptyUndoBuffer(Gadget)
          Sci_SetSavePoint(Gadget)
          Sci_ClearDocumentStyle(Gadget)
        EndIf
        CloseFile(FN)
        Result = #True
        ProcedureReturn (FN)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
