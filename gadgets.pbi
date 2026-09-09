; +--------------------------------------+
; | PureBasic Standard Library - Gadgets |
; +--------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Gadgets_Included, #PB_Constant))
  #_PBSL_Gadgets_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Gadget Constants
  
  #PB_GadgetType_Minimum = 1
  CompilerIf (PBGTE(610))
    #PB_GadgetType_Maximum = 35 ; WebView added
  CompilerElseIf (PBGTE(530))
    #PB_GadgetType_Maximum = 34 ; OpenGL added
  CompilerElse
    #PB_GadgetType_Maximum = 33 ; Canvas last added
  CompilerEndIf
  
  ;-
  ;- - Gadget Macros
  
  Macro MoveGadget(_Gadget, _x, _y)
    ResizeGadget((_Gadget), (_x), (_y), #PB_Ignore, #PB_Ignore)
  EndMacro
  Macro SetGadgetSize(_Gadget, _Width, _Height)
    ResizeGadget((_Gadget), #PB_Ignore, #PB_Ignore, (_Width), (_Height))
  EndMacro
  
  Macro GadgetExtentX(_Gadget)
    (GadgetX(_Gadget) + GadgetWidth(_Gadget))
  EndMacro
  Macro GadgetExtentY(_Gadget)
    (GadgetY(_Gadget) + GadgetHeight(_Gadget))
  EndMacro
  
  Macro GadgetRequiredWidth(_Gadget)
    (GadgetWidth((_Gadget), #PB_Gadget_RequiredSize))
  EndMacro
  Macro GadgetRequiredHeight(_Gadget)
    (GadgetHeight((_Gadget), #PB_Gadget_RequiredSize))
  EndMacro
  
  Macro FitGadgetRequiredWidth(_Gadget)
    ResizeGadget((_Gadget), #PB_Ignore, #PB_Ignore, GadgetRequiredWidth(_Gadget), #PB_Ignore)
  EndMacro
  Macro FitGadgetRequiredHeight(_Gadget)
    ResizeGadget((_Gadget), #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetRequiredHeight(_Gadget))
  EndMacro
  Macro FitGadgetRequiredSize(_Gadget)
    ResizeGadget((_Gadget), #PB_Ignore, #PB_Ignore, GadgetRequiredWidth(_Gadget), GadgetRequiredHeight(_Gadget))
  EndMacro
  
  Macro FinishOptionGadgetGroup()
    FreeGadget(TextGadget(#PB_Any, 0, 0, 20, 20, ""))
  EndMacro
  
  ;-
  ;- Gadget Attribute Macros
  
  
  Macro GetCanvasKey(_CanvasGadget)
    (GetGadgetAttribute((_CanvasGadget), #PB_Canvas_Key))
  EndMacro
  Macro GetCanvasModifiers(_CanvasGadget)
    (GetGadgetAttribute((_CanvasGadget), #PB_Canvas_Modifiers))
  EndMacro
  Macro GetCanvasMouseX(_CanvasGadget)
    (GetGadgetAttribute((_CanvasGadget), #PB_Canvas_MouseX))
  EndMacro
  Macro GetCanvasMouseY(_CanvasGadget)
    (GetGadgetAttribute((_CanvasGadget), #PB_Canvas_MouseY))
  EndMacro
  Macro GetCanvasWheelDelta(_CanvasGadget)
    (GetGadgetAttribute((_CanvasGadget), #PB_Canvas_WheelDelta))
  EndMacro
  
  Macro SetCanvasCursor(_CanvasGadget, _Cursor)
    SetGadgetAttribute((_CanvasGadget), #PB_Canvas_Cursor, (_Cursor))
  EndMacro
  
  Macro GetScrollAreaX(_ScrollAreaGadget)
    (GetGadgetAttribute((_ScrollAreaGadget), #PB_ScrollArea_X))
  EndMacro
  Macro GetScrollAreaY(_ScrollAreaGadget)
    (GetGadgetAttribute((_ScrollAreaGadget), #PB_ScrollArea_Y))
  EndMacro
  Macro GetScrollAreaInnerWidth(_ScrollAreaGadget)
    (GetGadgetAttribute((_ScrollAreaGadget), #PB_ScrollArea_InnerWidth))
  EndMacro
  Macro GetScrollAreaInnerHeight(_ScrollAreaGadget)
    (GetGadgetAttribute((_ScrollAreaGadget), #PB_ScrollArea_InnerHeight))
  EndMacro
  Macro SetScrollAreaInnerWidth(_ScrollAreaGadget, _Width)
    SetGadgetAttribute((_ScrollAreaGadget), #PB_ScrollArea_InnerWidth, (_Width))
  EndMacro
  Macro SetScrollAreaInnerHeight(_ScrollAreaGadget, _Height)
    SetGadgetAttribute((_ScrollAreaGadget), #PB_ScrollArea_InnerHeight, (_Height))
  EndMacro
  
  CompilerIf ((#IsGTK2Subsystem Or #IsGTK3Subsystem) And (#False))
    ; Per PB 6.21 Help, PanelGadget attributes "not supported on Linux GTK" !
  CompilerElse
    Macro GetPanelWidth(_PanelGadget)
      (GetGadgetAttribute((_PanelGadget), #PB_Panel_ItemWidth))
    EndMacro
    Macro GetPanelHeight(_PanelGadget)
      (GetGadgetAttribute((_PanelGadget), #PB_Panel_ItemHeight))
    EndMacro
    Macro GetPanelTabHeight(_PanelGadget)
      (GetGadgetAttribute((_PanelGadget), #PB_Panel_TabHeight))
    EndMacro
  CompilerEndIf
  
  ;-
  ;- - Gadget Procedures
  
  Procedure GetGadgetRequiredSize(Gadget.i, *Width.INTEGER, *Height.INTEGER)
    If (*Width)
      *Width\i = GadgetRequiredWidth(Gadget)
    EndIf
    If (*Height)
      *Height\i = GadgetRequiredHeight(Gadget)
    EndIf
  EndProcedure
  
  Procedure SelectGadget(Gadget.i)
    CompilerIf (#IsWindowsBuild)
      SendMessage_(GadgetID(Gadget), #EM_SETSEL, 0, -1)
    CompilerEndIf
    SetActiveGadget(Gadget)
  EndProcedure
  
  CompilerIf (#IsLinuxBuild)
    CompilerIf (Not Defined(gtk_entry_set_alignment, #PB_Procedure))
      ImportC ""
        gtk_entry_set_alignment(*entry, xalign.f)
      EndImport
    CompilerEndIf
  CompilerEndIf
  
  Procedure CenterStringGadget(Gadget.i)
    ; https://www.purebasic.fr/english/viewtopic.php?p=642136
    CompilerIf (#IsWindowsBuild)
      SetWindowLongPtr_(GadgetID(Gadget), #GWL_STYLE, (GetWindowLongPtr_(GadgetID(Gadget), #GWL_STYLE) & ~#ES_RIGHT) | #ES_CENTER)
      InvalidateRect_(GadgetID(Gadget), 0, #True)
    CompilerElseIf (#IsLinuxBuild)
      gtk_entry_set_alignment(GadgetID(Gadget), 0.5)
    CompilerElseIf (#IsMacBuild)
      CocoaMessage(0, GadgetID(Gadget), "setAlignment:", #NSCenterTextAlignment)
    CompilerEndIf
  EndProcedure
  
  ;-
  ;- - Gadget Item Procedures
  
  Procedure.i GetSelectedGadgetItemData(Gadget.i, DefaultValue.i = 0)
    Protected Result.i = DefaultValue
    Protected i.i = GetGadgetState(Gadget)
    If (i >= 0)
      Result = GetGadgetItemData(Gadget, i)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s GetSelectedGadgetItemText(Gadget.i, DefaultString.s = "")
    Protected Result.s = DefaultString
    Protected i.i = GetGadgetState(Gadget)
    If (i >= 0)
      Result = GetGadgetItemText(Gadget, i)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure _RemoveGadgetItemsWithState(Gadget.i, ItemState.i, SelectNew.i = #False)
    If (ItemState)
      Protected N.i = CountGadgetItems(Gadget)
      Protected OrigState.i = GetGadgetState(Gadget)
      If (OrigState = -1)
        SelectNew = #False
      EndIf
      Protected NewState.i = -1
      Protected i.i
      While (i < N)
        If (GetGadgetItemState(Gadget, i) & ItemState)
          CompilerIf (#IsWindowsBuild And (#False))
            ; Windows: This prevents the "delete all following items" bug
            ; but it also loses all selection. See better fix, below.
            If ((ItemState = #PB_Tree_Selected) And (GadgetType(Gadget) = #PB_GadgetType_Tree))
              SetGadgetState(Gadget, -1);SetGadgetState(Gadget, i + 1)
            EndIf
          CompilerEndIf
          RemoveGadgetItem(Gadget, i)
          If (SelectNew)
            If (OrigState > N)
              OrigState - 1
            EndIf
          EndIf
          N - 1
          CompilerIf (#IsWindowsBuild And (#True))
            ; Windows: This prevents the "delete all following items" bug
            ; but also maintains the "next item" selected.
            ; Assumes only 1 Tree item can be selected! Which seems to be true on Windows.
            If ((ItemState = #PB_Tree_Selected) And (GadgetType(Gadget) = #PB_GadgetType_Tree))
              Break
            EndIf
          CompilerEndIf
        Else
          If (SelectNew And (OrigState = i))
            NewState = i
          EndIf
          i + 1
        EndIf
      Wend
      If (SelectNew)
        If (NewState = -1)
          NewState = N-1
        EndIf
        If (NewState >= 0)
          SetGadgetState(Gadget, NewState)
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Procedure RemoveSelectedGadgetItems(Gadget.i)
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_ListView
        _RemoveGadgetItemsWithState(Gadget, 1, #True)
      Case #PB_GadgetType_ListIcon
        _RemoveGadgetItemsWithState(Gadget, #PB_ListIcon_Selected, #True)
      Case #PB_GadgetType_Tree
        _RemoveGadgetItemsWithState(Gadget, #PB_Tree_Selected, #False)
    EndSelect
  EndProcedure
  
  Procedure RemoveCheckedGadgetItems(Gadget.i)
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_ListIcon
        _RemoveGadgetItemsWithState(Gadget, #PB_ListIcon_Checked, #False)
      Case #PB_GadgetType_Tree
        _RemoveGadgetItemsWithState(Gadget, #PB_Tree_Checked, #False)
    EndSelect
  EndProcedure
  
  Procedure.i _CountGadgetItemsWithState(Gadget.i, ItemState.i)
    Protected Result.i = 0
    If (ItemState)
      Protected N.i = CountGadgetItems(Gadget)
      Protected i.i
      For i = 0 To N-1
        If (GetGadgetItemState(Gadget, i) & ItemState)
          Result + 1
        EndIf
      Next i
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CountSelectedGadgetItems(Gadget.i)
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_ListView
        ProcedureReturn (_CountGadgetItemsWithState(Gadget, 1))
      Case #PB_GadgetType_ListIcon
        ProcedureReturn (_CountGadgetItemsWithState(Gadget, #PB_ListIcon_Selected))
      Case #PB_GadgetType_Tree
        ProcedureReturn (_CountGadgetItemsWithState(Gadget, #PB_Tree_Selected))
      Case #PB_GadgetType_ExplorerList
        ; This gadget has no SetGadgetState() support!
        ;ProcedureReturn (_CountGadgetItemsWithState(Gadget, #PB_Explorer_Selected))
        ProcedureReturn (Bool(GetGadgetState(Gadget) >= 0))
    EndSelect
    ProcedureReturn (0)
  EndProcedure
  
  Procedure.i CountCheckedGadgetItems(Gadget.i)
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_ListIcon
        ProcedureReturn (_CountGadgetItemsWithState(Gadget, #PB_ListIcon_Checked))
      Case #PB_GadgetType_Tree
        ProcedureReturn (_CountGadgetItemsWithState(Gadget, #PB_Tree_Checked))
    EndSelect
    ProcedureReturn (0)
  EndProcedure
  
  Procedure DeselectAllGadgetItems(Gadget.i)
    Protected N.i, Flag.i
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_ListView
        SetGadgetState(Gadget, -1)
      Case #PB_GadgetType_ListIcon
        SetGadgetState(Gadget, -1)
      Case #PB_GadgetType_Tree
        If (#False)
          SetGadgetState(Gadget, -1) ; doesn't seem to work reliably?
        Else
          N = CountGadgetItems(Gadget)
          Flag = #PB_Tree_Selected
        EndIf
      Case #PB_GadgetType_ExplorerList
        ; This gadget has no SetGadgetState() support!
        ;SetGadgetState(Gadget, -1)
    EndSelect
    If ((N > 0) And (Flag))
      Protected i.i
      For i = 0 To N-1
        SetGadgetItemState(Gadget, i, GetGadgetItemState(Gadget, i) & (~Flag))
      Next i
    EndIf
  EndProcedure
  
  Procedure UncheckAllGadgetItems(Gadget.i)
    Protected N.i, Flag.i
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_ListIcon
        N = CountGadgetItems(Gadget)
        Flag = #PB_ListIcon_Checked
      Case #PB_GadgetType_Tree
        N = CountGadgetItems(Gadget)
        Flag = #PB_Tree_Checked
    EndSelect
    If ((N > 0) And (Flag))
      Protected i.i
      For i = 0 To N-1
        SetGadgetItemState(Gadget, i, GetGadgetItemState(Gadget, i) & (~Flag))
      Next i
    EndIf
  EndProcedure
  
  Procedure SelectAllGadgetItems(Gadget.i)
    Protected N.i, Flag.i
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_ListView
        N = CountGadgetItems(Gadget)
        Flag = 1
      Case #PB_GadgetType_ListIcon
        N = CountGadgetItems(Gadget)
        Flag = #PB_ListIcon_Selected
      Case #PB_GadgetType_Tree
        CompilerIf (Not #IsWindowsBuild)
          ; TreeGadget multi-selection seems buggy on Windows
          N = CountGadgetItems(Gadget)
          Flag = #PB_Tree_Selected
        CompilerEndIf
      Case #PB_GadgetType_ExplorerList
        ; This gadget has no MultiSelect support!
        ;N = CountGadgetItems(Gadget)
        ;Flag = #PB_Explorer_Selected
    EndSelect
    If ((N > 0) And (Flag))
      Protected i.i
      For i = 0 To N-1
        SetGadgetItemState(Gadget, i, GetGadgetItemState(Gadget, i) | Flag)
      Next i
    EndIf
  EndProcedure
  
  Procedure CheckAllGadgetItems(Gadget.i)
    Protected N.i, Flag.i
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_ListIcon
        N = CountGadgetItems(Gadget)
        Flag = #PB_ListIcon_Checked
      Case #PB_GadgetType_Tree
        N = CountGadgetItems(Gadget)
        Flag = #PB_Tree_Checked
    EndSelect
    If ((N > 0) And (Flag))
      Protected i.i
      For i = 0 To N-1
        SetGadgetItemState(Gadget, i, GetGadgetItemState(Gadget, i) | Flag)
      Next i
    EndIf
  EndProcedure
  
  Procedure ExpandAllGadgetItems(Gadget.i)
    If (GadgetType(Gadget) = #PB_GadgetType_Tree)
      Protected N.i
      N = CountGadgetItems(Gadget)
      Protected i.i
      For i = 0 To N-1
        SetGadgetItemState(Gadget, i, (GetGadgetItemState(Gadget, i) & (~#PB_Tree_Collapsed)) | #PB_Tree_Expanded)
      Next i
    EndIf
  EndProcedure
  
  Procedure CollapseAllGadgetItems(Gadget.i)
    If (GadgetType(Gadget) = #PB_GadgetType_Tree)
      Protected N.i
      N = CountGadgetItems(Gadget)
      Protected i.i
      For i = 0 To N-1
        SetGadgetItemState(Gadget, i, (GetGadgetItemState(Gadget, i) & (~#PB_Tree_Expanded)) | #PB_Tree_Collapsed)
      Next i
    EndIf
  EndProcedure
  
  Procedure ToggleSelectedGadgetItems(Gadget.i)
    Protected N.i, Flag.i
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_ListView
        N = CountGadgetItems(Gadget)
        Flag = 1
      Case #PB_GadgetType_ListIcon
        N = CountGadgetItems(Gadget)
        Flag = #PB_ListIcon_Selected
      Case #PB_GadgetType_Tree
        CompilerIf (Not #IsWindowsBuild)
          ; TreeGadget multi-selection seems buggy on Windows
          N = CountGadgetItems(Gadget)
          Flag = #PB_Tree_Selected
        CompilerEndIf
    EndSelect
    If ((N > 0) And (Flag))
      Protected i.i
      For i = 0 To N-1
        Protected State.i = GetGadgetItemState(Gadget, i)
        If (State & Flag)
          State & (~Flag)
        Else
          State | Flag
        EndIf
        SetGadgetItemState(Gadget, i, State)
      Next i
    EndIf
  EndProcedure
  
CompilerEndIf
;-
