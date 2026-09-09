; +--------------------------------------------+
; | PureBasic Standard Library - ListRequester |
; +--------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_ListRequester_Included, #PB_Constant))
  #_PBSL_ListRequester_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  ;XIncludeFile "common.pbi"
  XIncludeFile "gadget-sizes.pbi"
  
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
  
  Procedure.s ListRequester(Title.s, Message.s, List String.s(), ParentWindow.i = #PB_Ignore, MultiSelect.i = #False, Callback.PBSL_ListRequesterCallback = #Null)
    Protected Result.s = ""
    
    Protected ParentID.i = #Null
    If (ParentWindow <> #PB_Ignore)
      ParentID = WindowID(ParentWindow)
    EndIf
    If (ListSize(String()) > 0)
      Protected Flags.i = #PB_Window_SystemMenu | #PB_Window_Invisible
      _ListRequesterWindow = OpenWindow(#PB_Any, 0, 0, 320, 240, Title, Flags, ParentID)
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
        
        Flags = #PB_ListView_MultiSelect * Bool(MultiSelect)
        Protected ListView.i = ListViewGadget(#PB_Any, Padding, y, ContentsW, LabelH * (3 + 5.0 * Log10(ListSize(String()))), Flags)
        ForEach (String())
          AddGadgetItem(ListView, ListIndex(String()), String())
        Next
        SetGadgetState(ListView, 0)
        y + GadgetHeight(ListView) + Padding
        
        OKButton     = ButtonGadget(#PB_Any, Padding + (ContentsW/2) - (ButtonW + Padding), y, ButtonW, ButtonH, _PBSL_ListRequesterOKLabel, #PB_Button_Default)
        CancelButton = ButtonGadget(#PB_Any, Padding + (ContentsW/2) + (Padding), y, ButtonW, ButtonH, _PBSL_ListRequesterCancelLabel)
        y + ButtonH + Padding
        
        AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Return, 0)
        AddKeyboardShortcut(_ListRequesterWindow, #PB_Shortcut_Escape, 1)
        
        ResizeWindow(_ListRequesterWindow, #PB_Ignore, #PB_Ignore, ContentsW + 2*Padding, y)
        If (ParentID)
          HideWindow(_ListRequesterWindow, #False, #PB_Window_WindowCentered)
        Else
          HideWindow(_ListRequesterWindow, #False, #PB_Window_ScreenCentered)
        EndIf
        SetActiveWindow(_ListRequesterWindow)
        SetActiveGadget(ListView)
        
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
              EndIf
            ElseIf (Event = #PB_Event_Menu)
              If (EventMenu() = 0)
                Result = ""
                If (MultiSelect)
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
                    SelectElement(String(), Event)
                    Result = String()
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
              EndIf
            EndIf
          EndIf
        Until (Done)
        
        HideWindow(_ListRequesterWindow, #True)
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
