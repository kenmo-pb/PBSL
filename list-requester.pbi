; +--------------------------------------------+
; | PureBasic Standard Library - ListRequester |
; +--------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_ListRequester_Included, #PB_Constant))
  #_PBSL_ListRequester_Included = #True
  
  IncludeFile "gadget-sizes.pbi"
  
  ;- - ListRequester Constants
  
  #ListRequester_MultiSelect  = $01
  #ListRequester_FilterGadget = $02
  
  ;-
  ;- - ListRequester Globals
  
  Global _ListRequesterWindow.i = #Null
  
  Global _PBSL_ListRequesterOKLabel.s     = "OK"
  Global _PBSL_ListRequesterCancelLabel.s = "Cancel"
  
  Prototype.i PBSL_ListRequesterCallback(Selection.s) ; return 0 to accept, non-zero to reject
  
  ;-
  ;- - ListRequester Procedures
  
  Procedure.i ListRequesterWindowID()
    If (_ListRequesterWindow)
      ProcedureReturn (WindowID(_ListRequesterWindow))
    EndIf
    ProcedureReturn (#Null)
  EndProcedure
  
  Procedure _ListRequesterUpdateFilter(Filter.i, ListView.i, List String.s())
    Protected PrevSel.i = GetGadgetState(ListView)
    Protected PrevSelText.s = ""
    If (PrevSel >= 0)
      PrevSelText = GetGadgetItemText(ListView, PrevSel)
    EndIf
    Protected FilterText.s = Trim(GetGadgetText(Filter))
    ClearGadgetItems(ListView)
    NewList SearchTerm.s()
    SplitStringToList(FilterText, SearchTerm(), " ", #True)
    If (ListSize(SearchTerm()) > 0)
      Protected Match.i
      Protected i.i = 0
      ForEach (String())
        Match = #True
        ForEach SearchTerm()
          If (Not FindString(String(), SearchTerm(), 1, #PB_String_NoCase))
            Match = #False
            Break
          EndIf
        Next
        If (Match)
          AddGadgetItem(ListView, i, String())
          If (String() = PrevSelText)
            SetGadgetState(ListView, i)
          EndIf
          i + 1
        EndIf
      Next
      If (i = 1)
        SetGadgetState(ListView, 0)
      EndIf
    Else
      ForEach (String())
        AddGadgetItem(ListView, ListIndex(String()), String())
        If (String() = PrevSelText)
          SetGadgetState(ListView, ListIndex(String()))
        EndIf
      Next
    EndIf
  EndProcedure
  
  Procedure.s ListRequester(Title.s, Message.s, List String.s(), ParentWindow.i = #PB_Ignore, Flags.i = #Null, Callback.PBSL_ListRequesterCallback = #Null)
    Protected Result.s = ""
    
    If (Flags = #PB_Default)
      Flags = #Null
    EndIf
    
    Protected ParentID.i = #Null
    If (ParentWindow <> #PB_Ignore)
      ParentID = WindowID(ParentWindow)
    EndIf
    If (ListSize(String()) > 0)
      Protected WinFlags.i = #PB_Window_SystemMenu | #PB_Window_Invisible
      _ListRequesterWindow = OpenWindow(#PB_Any, 0, 0, 320, 240, Title, WinFlags, ParentID)
      If (_ListRequesterWindow)
        If (ParentID)
          DisableWindow(ParentWindow, #True)
        EndIf
        
        Protected Padding.i = 0.67 * StandardTextGadgetHeight()
        
        Protected OKButton.i, CancelButton.i
        OKButton = ButtonGadget(#PB_Any, 0, 0, 10, 10, _PBSL_ListRequesterOKLabel)
        Protected ButtonH.i = GadgetRequiredHeight(OKButton)
        Protected ButtonW.i = MaxI(4 * ButtonH, GadgetRequiredWidth(OKButton))
        SetGadgetText(OKButton, _PBSL_ListRequesterCancelLabel)
        ButtonW = MaxI(ButtonW, GadgetRequiredWidth(OKButton))
        FreeGadget(OKButton)
        
        Protected ContentsW.i = (Padding + ButtonW + 2*Padding + ButtonW + Padding)
        Protected LabelH.i = StandardTextGadgetHeight()
        Protected Label.i = TextGadget(#PB_Any, Padding, Padding, ContentsW, LabelH, Message, #PB_Text_Center)
        ContentsW = MaxI(ContentsW, GadgetRequiredWidth(Label))
        
        ForEach (String())
          SetGadgetText(Label, String())
          ContentsW = MaxI(ContentsW, GadgetRequiredWidth(Label) + 3 * Padding)
        Next
        If (ExamineDesktops())
          ContentsW = MinI(ContentsW, DesktopWidth(0) * 0.50)
        EndIf
        
        ResizeGadget(Label, Padding, Padding, ContentsW, LabelH)
        Protected y.i = Padding
        If (Message <> "")
          SetGadgetText(Label, Message)
          y + LabelH + Padding
        Else
          HideGadget(Label, #True)
        EndIf
        
        Protected Filter.i = #Null
        If (Flags & #ListRequester_FilterGadget)
          Filter = StringGadget(#PB_Any, Padding, y, ContentsW, StandardStringGadgetHeight(), "")
          CenterStringGadget(Filter)
          y + GadgetHeight(Filter)
          y + Padding/2
        EndIf
        
        WinFlags = #PB_ListView_MultiSelect * Bool(Flags & #ListRequester_MultiSelect)
        Protected ListView.i = ListViewGadget(#PB_Any, Padding, y, ContentsW, LabelH * (3 + 5.0 * Log10(ListSize(String()))), WinFlags)
        ForEach (String())
          AddGadgetItem(ListView, ListIndex(String()), String())
        Next
        y + GadgetHeight(ListView) + Padding
        
        OKButton     = ButtonGadget(#PB_Any, Padding + (ContentsW/2) - (ButtonW + Padding), y, ButtonW, ButtonH, _PBSL_ListRequesterOKLabel, #PB_Button_Default)
        CancelButton = ButtonGadget(#PB_Any, Padding + (ContentsW/2) + (Padding), y, ButtonW, ButtonH, _PBSL_ListRequesterCancelLabel)
        y + ButtonH + Padding
        
        AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Return, 0)
        AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Escape, 1)
        If (Flags & #ListRequester_MultiSelect)
          AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Command | #PB_Shortcut_A, 3)
        EndIf
        
        ResizeWindow(_ListRequesterWindow, #PB_Ignore, #PB_Ignore, ContentsW + 2*Padding, y)
        If (ParentID)
          HideWindow(_ListRequesterWindow, #False, #PB_Window_WindowCentered)
        Else
          HideWindow(_ListRequesterWindow, #False, #PB_Window_ScreenCentered)
        EndIf
        SetActiveWindow(_ListRequesterWindow)
        If (Flags & #ListRequester_FilterGadget)
          SetActiveGadget(Filter)
        Else
          SetGadgetState(ListView, 0)
          SetActiveGadget(ListView)
        EndIf
        
        Protected Done.i = #False
        Protected Event.i
        Repeat
          Event = WaitWindowEvent()
          If (EventWindow() = _ListRequesterWindow)
            If (Event = #PB_Event_CloseWindow)
              Done = #True
            ElseIf (Event = #PB_Event_Gadget)
              If ((EventGadget() = OKButton) Or ((EventGadget() = ListView) And (EventType() = #PB_EventType_LeftDoubleClick)))
                PostEvent(#PB_Event_Menu, _ListRequesterWindow, 0)
              ElseIf (EventGadget() = CancelButton)
                PostEvent(#PB_Event_Menu, _ListRequesterWindow, 1)
              ElseIf (Filter And (EventGadget() = Filter))
                If (EventType() = #PB_EventType_Change)
                  _ListRequesterUpdateFilter(Filter, ListView, String())
                ElseIf (EventType() = #PB_EventType_Focus)
                  AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Up,       2)
                  AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Down,     2)
                  AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_PageUp,   2)
                  AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_PageDown, 2)
                  If (Flags & #ListRequester_MultiSelect)
                    RemoveKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Command | #PB_Shortcut_A)
                  EndIf
                ElseIf (EventType() = #PB_EventType_LostFocus)
                  RemoveKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Up      )
                  RemoveKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Down    )
                  RemoveKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_PageUp  )
                  RemoveKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_PageDown)
                  If (Flags & #ListRequester_MultiSelect)
                    AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Command | #PB_Shortcut_A, 3)
                  EndIf
                EndIf  
              EndIf
            ElseIf (Event = #PB_Event_Menu)
              If (EventMenu() = 0)
                Result = ""
                If (Flags & #ListRequester_MultiSelect)
                  Protected i.i
                  For i = 0 To (CountGadgetItems(ListView) - 1)
                    If (GetGadgetItemState(ListView, i))
                      Result + #LF$ + GetGadgetItemText(ListView, i)
                      Done = #True
                    EndIf
                  Next i
                  Result = Mid(Result, 2)
                Else
                  Event = GetGadgetState(ListView)
                  If (Event >= 0)
                    Result = GetGadgetItemText(ListView, Event)
                    Done = #True
                  EndIf
                EndIf
                If (Done)
                  If (Callback And (Callback(Result) <> 0))
                    Done = #False
                  EndIf
                EndIf
              ElseIf (EventMenu() = 1)
                Result = ""
                Done = #True
              ElseIf (EventMenu() = 2)
                If (CountGadgetItems(ListView) > 0)
                  If (GetGadgetState(ListView) = -1)
                    SetGadgetState(ListView, 0)
                  EndIf
                  SetActiveGadget(ListView)
                EndIf
              ElseIf (EventMenu() = 3)
                SelectAllGadgetItems(ListView)
              EndIf
            EndIf
          EndIf
        Until (Done)
        
        HideWindow(_ListRequesterWindow, #True)
        If (Filter)
          FreeGadget(Filter)
        EndIf
        FreeGadget(Label)
        FreeGadget(ListView)
        FreeGadget(OKButton)
        FreeGadget(CancelButton)
        CloseWindow(_ListRequesterWindow)
        _ListRequesterWindow = #Null
        If (ParentID)
          DisableWindow(ParentWindow, #False)
          SetActiveWindow(ParentWindow)
        EndIf
      EndIf
    EndIf
    
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
