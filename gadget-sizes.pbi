; +-------------------------------------------+
; | PureBasic Standard Library - Gadget Sizes |
; +-------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_GadgetSizes_Included, #PB_Constant))
  #_PBSL_GadgetSizes_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  XIncludeFile "gadgets.pbi"
  
  UndefineMacro GadgetRequiredWidth
  UndefineMacro GadgetRequiredHeight
  
  Declare.i GadgetRequiredWidth(Gadget.i)
  Declare.i GadgetRequiredHeight(Gadget.i)
  
  ;- - Gadget Size Macros
  
  Macro FitGadgetPreferredWidth(_Gadget)
    ResizeGadget((_Gadget), #PB_Ignore, #PB_Ignore, GadgetPreferredWidth(_Gadget), #PB_Ignore)
  EndMacro
  Macro FitGadgetPreferredHeight(_Gadget)
    ResizeGadget((_Gadget), #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetPreferredHeight(_Gadget))
  EndMacro
  Macro FitGadgetPreferredSize(_Gadget)
    ResizeGadget((_Gadget), #PB_Ignore, #PB_Ignore, GadgetPreferredWidth(_Gadget), GadgetPreferredHeight(_Gadget))
  EndMacro
  
  Macro StandardButtonHeight(_ButtonFlags = #Null)
    (StandardGadgetHeight(#PB_GadgetType_Button, (_ButtonFlags)))
  EndMacro
  Macro StandardCheckboxHeight()
    (StandardGadgetHeight(#PB_GadgetType_CheckBox))
  EndMacro
  Macro StandardComboBoxHeight(_ComboBoxFlags = #Null)
    (StandardGadgetHeight(#PB_GadgetType_ComboBox, (_ComboBoxFlags)))
  EndMacro
  Macro StandardOptionGadgetHeight()
    (StandardGadgetHeight(#PB_GadgetType_Option))
  EndMacro
  Macro StandardScrollbarSize()
    (StandardGadgetHeight(#PB_GadgetType_ScrollBar))
  EndMacro
  Macro StandardStringGadgetHeight(_StringFlags = #Null)
    (StandardGadgetHeight(#PB_GadgetType_String, (_StringFlags)))
  EndMacro
  Macro StandardTextGadgetHeight(_TextFlags = #Null)
    (StandardGadgetHeight(#PB_GadgetType_Text, (_TextFlags)))
  EndMacro
  
  Macro _PBGadgetRequiredWidth(_Gadget)
    (GadgetWidth((_Gadget), #PB_Gadget_RequiredSize))
  EndMacro
  Macro _PBGadgetRequiredHeight(_Gadget)
    (GadgetHeight((_Gadget), #PB_Gadget_RequiredSize))
  EndMacro
  
  ;-
  ;- - Gadget Size Globals
  
  Global NewMap _PBSL_StandardGadgetHeight.i()
  
  ;-
  ;- - Gadget Size Procedures
  
  Procedure.i StandardGadgetHeight(Type.i, Flags.i = #PB_Default)
    Protected Result.i = 0
    If ((Type >= #PB_GadgetType_Minimum) And (Type <= #PB_GadgetType_Maximum))
      If (Flags = #PB_Default)
        Flags = #Null
      EndIf
      Protected ID.s = Str(Type) + "-" + Str(Flags)
      If (FindMapElement(_PBSL_StandardGadgetHeight(), ID))
        Result = _PBSL_StandardGadgetHeight()
      Else
        Protected Dummy.i = #Null
        EnsureGadgetListOpen()
        Select (Type)
          Case #PB_GadgetType_Button
            CompilerIf (#IsMacBuild)
              ;Result = 25 ; from PB Help
              Result = 28 ; from IDE GetRequiredSize.pb
            CompilerElse
              Dummy = ButtonGadget(#PB_Any, 0, 0, 10, 10, " ", Flags)
              If (Dummy)
                Result = _PBGadgetRequiredHeight(Dummy)
              EndIf
            CompilerEndIf
          Case #PB_GadgetType_String
            Dummy = StringGadget(#PB_Any, 0, 0, 10, 10, " ", Flags)
            If (Dummy)
              Result = GadgetRequiredHeight(Dummy)
            EndIf
          Case #PB_GadgetType_Text
            Dummy = TextGadget(#PB_Any, 0, 0, 10, 10, " ", Flags)
            If (Dummy)
              Result = _PBGadgetRequiredHeight(Dummy)
            EndIf
          Case #PB_GadgetType_CheckBox
            Dummy = CheckBoxGadget(#PB_Any, 0, 0, 10, 10, " ", Flags)
            If (Dummy)
              Result = _PBGadgetRequiredHeight(Dummy)
            EndIf
          Case #PB_GadgetType_Option
            Dummy = OptionGadget(#PB_Any, 0, 0, 10, 10, " ")
            If (Dummy)
              Result = _PBGadgetRequiredHeight(Dummy)
            EndIf
          Case #PB_GadgetType_ListView
            Result = 4.0 * StandardTextGadgetHeight()
          Case #PB_GadgetType_Frame
            Dummy = FrameGadget(#PB_Any, 0, 0, 10, 10, " ", Flags)
            If (Dummy)
              Result = GadgetRequiredHeight(Dummy)
            EndIf
          Case #PB_GadgetType_ComboBox
            Dummy = ComboBoxGadget(#PB_Any, 0, 0, 10, 10, Flags)
            If (Dummy)
              Result = _PBGadgetRequiredHeight(Dummy)
            EndIf
            ;Case #PB_GadgetType_Image
          Case #PB_GadgetType_HyperLink
            Dummy = HyperLinkGadget(#PB_Any, 0, 0, 10, 10, " ", Flags)
            If (Dummy)
              Result = _PBGadgetRequiredHeight(Dummy)
            EndIf
            ;Case #PB_GadgetType_Container
          Case #PB_GadgetType_ListIcon
            Result = 8.0 * StandardTextGadgetHeight()
          Case #PB_GadgetType_IPAddress
            Dummy = IPAddressGadget(#PB_Any, 0, 0, 10, 10)
            If (Dummy)
              Result = _PBGadgetRequiredHeight(Dummy)
            EndIf
          Case #PB_GadgetType_ProgressBar
            Result = 1.0 * StandardTextGadgetHeight()
          Case #PB_GadgetType_ScrollBar
            Result = WindowsElse(GetSystemMetrics_(#SM_CXVSCROLL), StandardTextGadgetHeight())
          Case #PB_GadgetType_ScrollArea
            Result = 5 * StandardScrollbarSize()
          Case #PB_GadgetType_TrackBar
            Result = 1.0 * StandardButtonHeight()
          Case #PB_GadgetType_Web
            Result = 16.0 * StandardTextGadgetHeight()
            ;Case #PB_GadgetType_ButtonImage
          Case #PB_GadgetType_Calendar
            Dummy = CalendarGadget(#PB_Any, 0, 0, 10, 10, Date(), Flags)
            If (Dummy)
              Result = _PBGadgetRequiredHeight(Dummy)
            EndIf
          Case #PB_GadgetType_Date
            Dummy = DateGadget(#PB_Any, 0, 0, 10, 10, "%yyyy-%mm-%dd %hh:%ii", 0, Flags)
            If (Dummy)
              Result = GadgetRequiredHeight(Dummy)
            EndIf
          Case #PB_GadgetType_Editor
            Result = 4.0 * StandardTextGadgetHeight()
          Case #PB_GadgetType_ExplorerList
            Result = StandardGadgetHeight(#PB_GadgetType_Web)
          Case #PB_GadgetType_ExplorerTree
            Result = StandardGadgetHeight(#PB_GadgetType_Tree)
          Case #PB_GadgetType_ExplorerCombo
            Result = StandardGadgetHeight(#PB_GadgetType_ComboBox)
          Case #PB_GadgetType_Spin
            ;Result = StandardStringGadgetHeight()
            Result = 1.00 * StandardButtonHeight()
          Case #PB_GadgetType_Tree
            Result = 8.0 * StandardTextGadgetHeight()
            ;Case #PB_GadgetType_Panel
            ;Case #PB_GadgetType_Splitter
          Case #PB_GadgetType_MDI
            Result = StandardGadgetHeight(#PB_GadgetType_Web)
          Case #PB_GadgetType_Scintilla
            Result = 1.5 * StandardGadgetHeight(#PB_GadgetType_Editor)
          Case #PB_GadgetType_Shortcut
            Dummy = ShortcutGadget(#PB_Any, 0, 0, 10, 10, #PB_Shortcut_Command | #PB_Shortcut_W)
            If (Dummy)
              Result = GadgetRequiredHeight(Dummy)
            EndIf
            ;Case #PB_GadgetType_Canvas
            CompilerIf (Defined(PB_GadgetType_OpenGL, #PB_Constant))
            Case #PB_GadgetType_OpenGL
              Result = StandardGadgetHeight(#PB_GadgetType_Web)
            CompilerEndIf
            CompilerIf (Defined(PB_GadgetType_WebView, #PB_Constant))
            Case #PB_GadgetType_WebView
              Result = StandardGadgetHeight(#PB_GadgetType_Web)
            CompilerEndIf
            
          Default ; For those which don't make sense to have a "standard" height
            Result = 1.0 * StandardButtonHeight()
            ;Result = 0
            
        EndSelect
        If (Dummy)
          FreeGadget(Dummy)
        EndIf
        _PBSL_StandardGadgetHeight(ID) = Result
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GadgetBorderSize(Gadget.i)
    Protected Result.i = 0
    CompilerIf (#IsWindowsBuild)
      Result = GetHWNDBorderSize(GadgetID(Gadget))
    CompilerElse
      ; ...
    CompilerEndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Global NewMap _PBSL_GadgetBorderSize.i()
  
  Procedure.i StandardGadgetBorderSize(Type.i, Flags.i = #Null)
    Protected Result.i = 0
    If ((Type >= #PB_GadgetType_Minimum) And (Type <= #PB_GadgetType_Maximum))
      Protected ID.s = Str(Type) + "-" + Str(Flags)
      If (FindMapElement(_PBSL_GadgetBorderSize(), ID))
        Result = _PBSL_GadgetBorderSize()
      Else
        Protected Dummy.i = #Null
        EnsureGadgetListOpen()
        Select (Type)
            ;Case #PB_GadgetType_Button
          Case #PB_GadgetType_String
            If (Flags & #PB_String_BorderLess)
              Result = 0
            Else
              If (#False) ; This method seems to return 0, at least on Windows
                Dummy = StringGadget(#PB_Any, 0, 0, 10, 10, " ")
                Result = _PBGadgetRequiredHeight(Dummy)
                FreeGadget(Dummy)
                Dummy = StringGadget(#PB_Any, 0, 0, 10, 10, " ", #PB_String_BorderLess)
                Result = (Result - _PBGadgetRequiredHeight(Dummy)) / 2
              Else
                Result = StandardGadgetBorderSize(#PB_GadgetType_Text)
              EndIf
            EndIf
          Case #PB_GadgetType_Text
            If (#True) ; This method seems to work OK, at least on Windows
              Dummy = TextGadget(#PB_Any, 0, 0, 10, 10, " ", #PB_Text_Border)
              Result = _PBGadgetRequiredHeight(Dummy)
              FreeGadget(Dummy)
              Dummy = TextGadget(#PB_Any, 0, 0, 10, 10, " ")
              Result = (Result - _PBGadgetRequiredHeight(Dummy)) / 2
            EndIf
            ;Case #PB_GadgetType_CheckBox
            ;Case #PB_GadgetType_Option
            ;Case #PB_GadgetType_ListView
            ;Case #PB_GadgetType_Frame
            ;Case #PB_GadgetType_ComboBox
          Case #PB_GadgetType_Image
            If (#True)
              Protected DummyImage.i
              DummyImage = CreateImage(#PB_Any, 10, 10)
              If (DummyImage)
                Dummy = ImageGadget(#PB_Any, 0, 0, 10, 10, ImageID(DummyImage), Flags)
                Result = _PBGadgetRequiredHeight(Dummy)
                FreeGadget(Dummy)
                Dummy = ImageGadget(#PB_Any, 0, 0, 10, 10, ImageID(DummyImage), #Null)
                Result = (Result - _PBGadgetRequiredHeight(Dummy)) / 2
                FreeImage(DummyImage)
              EndIf
            EndIf
            ;Case #PB_GadgetType_HyperLink
            ;Case #PB_GadgetType_Container
            ;Case #PB_GadgetType_ListIcon
            ;Case #PB_GadgetType_IPAddress
            ;  Result = StandardGadgetBorderSize(#PB_GadgetType_String)
            ;Case #PB_GadgetType_ProgressBar
            ;Case #PB_GadgetType_ScrollBar
            ;Case #PB_GadgetType_ScrollArea
            ;Case #PB_GadgetType_TrackBar
            ;Case #PB_GadgetType_Web
            ;Case #PB_GadgetType_ButtonImage
            ;Case #PB_GadgetType_Calendar
            ;Case #PB_GadgetType_Date
            ;Case #PB_GadgetType_Editor
            ;Case #PB_GadgetType_ExplorerList
            ;Case #PB_GadgetType_ExplorerTree
            ;Case #PB_GadgetType_ExplorerCombo
            ;Case #PB_GadgetType_Spin
            ;Case #PB_GadgetType_Tree
            ;Case #PB_GadgetType_Panel
            ;Case #PB_GadgetType_Splitter
            ;Case #PB_GadgetType_MDI
            ;Case #PB_GadgetType_Scintilla
            ;Case #PB_GadgetType_Shortcut
            ;  Result = StandardGadgetBorderSize(#PB_GadgetType_String)
            ;Case #PB_GadgetType_Canvas
            ;Case #PB_GadgetType_OpenGL
            ;Case #PB_GadgetType_WebView
            
        EndSelect
        If (Dummy)
          FreeGadget(Dummy)
        EndIf
        _PBSL_GadgetBorderSize(ID) = Result
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GadgetRequiredHeight(Gadget.i)
    Protected Result.i = 0
    Protected Type.i = GadgetType(Gadget)
    Select (Type)
      Case #PB_GadgetType_Button
        CompilerIf (#IsMacBuild)
          ;Result = 25 ; from PB Help
          Result = 28 ; from IDE GetRequiredSize.pb
        CompilerElse
          Result = _PBGadgetRequiredHeight(Gadget)
          If (Result < StandardButtonHeight())
            Result = StandardButtonHeight()
          EndIf
        CompilerEndIf
      Case #PB_GadgetType_String
        Result = _PBGadgetRequiredHeight(Gadget)
        CompilerIf (#IsMacBuild)
          If (Result < 24) ; from IDE GetRequiredSize.pb
            Result = 24
          EndIf
        CompilerEndIf
      Case #PB_GadgetType_Text
        If (GetGadgetText(Gadget) = "")
          SetGadgetText(Gadget, " ")
          Result = _PBGadgetRequiredHeight(Gadget)
          SetGadgetText(Gadget, "")
        Else
          Result = _PBGadgetRequiredHeight(Gadget)
        EndIf
      Case #PB_GadgetType_ListView
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_Frame
        Result = 1.5 * StandardTextGadgetHeight()
      Case #PB_GadgetType_ListIcon
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_ProgressBar
        Result = StandardGadgetHeight(Type)
        CompilerIf (#IsWindowsBuild)
          If (GetWindowLong_(GadgetID(Gadget), #GWL_STYLE) & #PBS_VERTICAL)
            Result * 2
          EndIf
        CompilerEndIf
      Case #PB_GadgetType_ScrollBar
        Result = _PBGadgetRequiredHeight(Gadget)
        If (Result = 0) ; Vertical!
          Result = 4 * _PBGadgetRequiredWidth(Gadget)
        EndIf
      Case #PB_GadgetType_ScrollArea
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_TrackBar
        Result = StandardGadgetHeight(Type)
        CompilerIf (#IsWindowsBuild)
          If (GetWindowLong_(GadgetID(Gadget), #GWL_STYLE) & #TBS_VERT)
            Result * 3
          EndIf
        CompilerEndIf
      Case #PB_GadgetType_Web
        ;Result = StandardGadgetHeight(Type)
        Result = StandardGadgetHeight(#PB_GadgetType_ListIcon)
      Case #PB_GadgetType_Date
        Result = _PBGadgetRequiredHeight(Gadget)
        CompilerIf (#True)
          Result + 0.50 * StandardTextGadgetHeight()
        CompilerEndIf
      Case #PB_GadgetType_Editor
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_ExplorerList
        ;Result = StandardGadgetHeight(Type)
        Result = StandardGadgetHeight(#PB_GadgetType_ListIcon)
      Case #PB_GadgetType_ExplorerTree
        Result = StandardGadgetHeight(#PB_GadgetType_Tree)
      Case #PB_GadgetType_ExplorerCombo
        Result = StandardGadgetHeight(#PB_GadgetType_ComboBox)
      Case #PB_GadgetType_Spin
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_Tree
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_Splitter
        Protected First.i, Second.i
        First  = GetGadgetAttribute(Gadget, #PB_Splitter_FirstGadget)
        Second = GetGadgetAttribute(Gadget, #PB_Splitter_SecondGadget)
        If (GadgetY(First) = GadgetY(Second)) ; Vertical
          Result = GadgetRequiredHeight(First)
          Second = GadgetRequiredHeight(Second)
          If (Second > Result)
            Result = Second
          EndIf
        Else ; Horizontal
          Result = GadgetRequiredHeight(First)
          Result + GadgetRequiredHeight(Second)
          First  = GadgetHeight(First)
          Second = GadgetHeight(Second)
          Result + (GadgetHeight(Gadget) - First - Second)
        EndIf
      Case #PB_GadgetType_MDI
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_Scintilla
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_Shortcut
        Result = 1.10 * _PBGadgetRequiredHeight(Gadget)
      Case #PB_GadgetType_Canvas
        Result = StandardGadgetHeight(Type)
        CompilerIf (Defined(PB_GadgetType_OpenGL, #PB_Constant))
        Case #PB_GadgetType_OpenGL
          Result = StandardGadgetHeight(#PB_GadgetType_Web)
        CompilerEndIf
        CompilerIf (Defined(PB_GadgetType_WebView, #PB_Constant))
        Case #PB_GadgetType_WebView
          Result = StandardGadgetHeight(#PB_GadgetType_Web)
        CompilerEndIf
        
      Default
        If ((Type >= #PB_GadgetType_Minimum) And (Type <= #PB_GadgetType_Maximum))
          Result = _PBGadgetRequiredHeight(Gadget)
        EndIf
    EndSelect
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GadgetRequiredWidth(Gadget.i)
    Protected Result.i = 0
    Static DummyText.i = #Null
    Protected Type.i = GadgetType(Gadget)
    Select (Type)
      Case #PB_GadgetType_Button
        Result = _PBGadgetRequiredWidth(Gadget)
        If (Result < GadgetRequiredHeight(Gadget))
          Result = GadgetRequiredHeight(Gadget)
        EndIf
        OnLinux(Result = Result + 4)
      Case #PB_GadgetType_String
        Result = _PBGadgetRequiredWidth(Gadget)
        If (Result < GadgetRequiredHeight(Gadget))
          Result = GadgetRequiredHeight(Gadget)
        EndIf
      Case #PB_GadgetType_Text
        Result = _PBGadgetRequiredWidth(Gadget)
        Result = MaxI(Result, 1)
      Case #PB_GadgetType_ListView
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_Frame
        If (GetGadgetText(Gadget))
          If ((Not DummyText) Or (Not IsGadget(DummyText)))
            EnsureGadgetListOpen()
            DummyText = TextGadget(#PB_Any, 0, 0, 10, 10, "")
            HideGadget(DummyText, #True)
          EndIf
          SetGadgetText(DummyText, GetGadgetText(Gadget))
          Result = _PBGadgetRequiredWidth(DummyText) + 1.1 * StandardTextGadgetHeight()
        Else
          Result = 1.5 * StandardTextGadgetHeight()
        EndIf
      Case #PB_GadgetType_ComboBox
        Result = 3.0 * GadgetRequiredHeight(Gadget)
      Case #PB_GadgetType_ListIcon
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_ProgressBar
        Result = StandardGadgetHeight(Type)
        CompilerIf (#IsWindowsBuild)
          If (Not (GetWindowLong_(GadgetID(Gadget), #GWL_STYLE) & #PBS_VERTICAL))
            Result * 2
          EndIf
        CompilerEndIf
      Case #PB_GadgetType_ScrollBar
        Result = _PBGadgetRequiredWidth(Gadget)
        If (Result = 0) ; Horizontal!
          Result = 4 * _PBGadgetRequiredHeight(Gadget)
        EndIf
      Case #PB_GadgetType_ScrollArea
        Result = GadgetRequiredHeight(Gadget)
      Case #PB_GadgetType_TrackBar
        Result = StandardGadgetHeight(Type)
        CompilerIf (#IsWindowsBuild)
          If (Not (GetWindowLong_(GadgetID(Gadget), #GWL_STYLE) & #TBS_VERT))
            Result * 3
          EndIf
        CompilerEndIf
      Case #PB_GadgetType_Web
        Result = GadgetRequiredHeight(Gadget) * 4 / 3
      Case #PB_GadgetType_Date
        Result = _PBGadgetRequiredWidth(Gadget)
        CompilerIf (#True)
          Result + 0.50 * StandardTextGadgetHeight()
        CompilerEndIf
      Case #PB_GadgetType_Editor
        Result = GadgetRequiredHeight(Gadget) * 16 / 9
      Case #PB_GadgetType_ExplorerList
        Result = GadgetRequiredHeight(Gadget) * 4 / 3
      Case #PB_GadgetType_ExplorerTree
        Result = StandardGadgetHeight(#PB_GadgetType_Tree)
      Case #PB_GadgetType_ExplorerCombo
        Result = 5.0 * GadgetRequiredHeight(Gadget)
      Case #PB_GadgetType_Spin
        Result = _PBGadgetRequiredHeight(Gadget) + 1.5 * StandardButtonHeight()
      Case #PB_GadgetType_Tree
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_Splitter
        Protected First.i, Second.i
        First  = GetGadgetAttribute(Gadget, #PB_Splitter_FirstGadget)
        Second = GetGadgetAttribute(Gadget, #PB_Splitter_SecondGadget)
        If (GadgetY(First) = GadgetY(Second)) ; Vertical
          Result = GadgetRequiredWidth(First)
          Result + GadgetRequiredWidth(Second)
          First  = GadgetWidth(First)
          Second = GadgetWidth(Second)
          Result + (GadgetWidth(Gadget) - First - Second)
        Else ; Horizontal
          Result = GadgetRequiredWidth(First)
          Second = GadgetRequiredWidth(Second)
          If (Second > Result)
            Result = Second
          EndIf
        EndIf
      Case #PB_GadgetType_MDI
        Result = StandardGadgetHeight(Type)
      Case #PB_GadgetType_Scintilla
        Result = GadgetRequiredHeight(Gadget) * 16 / 9
      Case #PB_GadgetType_Shortcut
        Result = GadgetRequiredHeight(Gadget) * 6
      Case #PB_GadgetType_Canvas
        Result = StandardGadgetHeight(Type)
        CompilerIf (Defined(PB_GadgetType_OpenGL, #PB_Constant))
        Case #PB_GadgetType_OpenGL
          Result = StandardGadgetHeight(Type)
        CompilerEndIf
        CompilerIf (Defined(PB_GadgetType_WebView, #PB_Constant))
        Case #PB_GadgetType_WebView
          Result = StandardGadgetHeight(Type)
        CompilerEndIf
        
      Default
        If ((Type >= #PB_GadgetType_Minimum) And (Type <= #PB_GadgetType_Maximum))
          Result = _PBGadgetRequiredWidth(Gadget)
        EndIf
    EndSelect
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GadgetPreferredHeight(Gadget.i)
    Protected Result.i = GadgetRequiredHeight(Gadget)
    
    Protected Type.i = GadgetType(Gadget)
    Select (Type)
      Case #PB_GadgetType_ListView, #PB_GadgetType_ListIcon, #PB_GadgetType_Editor
        Protected N.i
        N = CountGadgetItems(Gadget)
        If (N > 0)
          Result = (4 + 2 * Log10(N)) * StandardTextGadgetHeight()
          If (Result < StandardGadgetHeight(Type))
            Result = StandardGadgetHeight(Type)
          Else
            CompilerIf (#True)
              Protected Limit.i
              If (ExamineDesktops())
                Limit = DesktopHeight(0) * 0.50
                If (Result > Limit)
                  Result = Limit
                EndIf
              EndIf
            CompilerEndIf
          EndIf
        EndIf
      Case #PB_GadgetType_ScrollArea
        Result = GetGadgetAttribute(Gadget, #PB_ScrollArea_InnerHeight)
      Case #PB_GadgetType_Web, #PB_GadgetType_ExplorerList
        Result = StandardGadgetHeight(#PB_GadgetType_Web)
      Case #PB_GadgetType_Tree
        N = CountGadgetItems(Gadget)
        If (N > 0)
          Result = (4 + 2 * Log10(N)) * StandardCheckboxHeight()
          If (Result < StandardGadgetHeight(Type))
            Result = StandardGadgetHeight(Type)
          Else
            CompilerIf (#True)
              If (ExamineDesktops())
                Limit = DesktopHeight(0) * 0.50
                If (Result > Limit)
                  Result = Limit
                EndIf
              EndIf
            CompilerEndIf
          EndIf
        EndIf
      Case #PB_GadgetType_ExplorerTree
        Result = 2.0 * GadgetRequiredHeight(Gadget)
    EndSelect
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GadgetPreferredWidth(Gadget.i)
    Protected Result.i = GadgetRequiredWidth(Gadget)
    
    Static DummyText.i = #Null
    Select (GadgetType(Gadget))
      Case #PB_GadgetType_String
        If ((Not DummyText) Or (Not IsGadget(DummyText)))
          EnsureGadgetListOpen()
          DummyText = TextGadget(#PB_Any, 0, 0, 10, 10, "")
          HideGadget(DummyText, #True)
        EndIf
        SetGadgetText(DummyText, GetGadgetText(Gadget))
        Result + _PBGadgetRequiredWidth(DummyText)
      Case #PB_GadgetType_ListView
        If ((Not DummyText) Or (Not IsGadget(DummyText)))
          EnsureGadgetListOpen()
          DummyText = TextGadget(#PB_Any, 0, 0, 10, 10, "")
          HideGadget(DummyText, #True)
        EndIf
        Protected N.i
        N = CountGadgetItems(Gadget)
        Protected Width.i
        Protected i.i
        For i = 0 To (N-1)
          SetGadgetText(DummyText, GetGadgetItemText(Gadget, i))
          Width = _PBGadgetRequiredWidth(DummyText) + 1.5 * StandardScrollbarSize()
          If (Result < Width)
            Result = Width
          EndIf
        Next i
      Case #PB_GadgetType_ComboBox
        If ((Not DummyText) Or (Not IsGadget(DummyText)))
          EnsureGadgetListOpen()
          DummyText = TextGadget(#PB_Any, 0, 0, 10, 10, "")
          HideGadget(DummyText, #True)
        EndIf
        N = CountGadgetItems(Gadget)
        Protected Height.i
        Height = _PBGadgetRequiredHeight(Gadget)
        For i = 0 To (N-1)
          SetGadgetText(DummyText, GetGadgetItemText(Gadget, i))
          Width = _PBGadgetRequiredWidth(DummyText) + 1.5 * Height
          If (Result < Width)
            Result = Width
          EndIf
        Next i
      Case #PB_GadgetType_ListIcon
        N = GetGadgetAttribute(Gadget, #PB_ListIcon_ColumnCount)
        Debug N
        Width = 0
        For i = 0 To (N-1)
          Width + GetGadgetItemAttribute(Gadget, 0, #PB_ListIcon_ColumnWidth, i)
        Next i
        Width + 1.5 * StandardScrollbarSize()
        Result = Width
      Case #PB_GadgetType_ScrollArea
        Result = GetGadgetAttribute(Gadget, #PB_ScrollArea_InnerWidth)
      Case #PB_GadgetType_Editor
        If ((Not DummyText) Or (Not IsGadget(DummyText)))
          EnsureGadgetListOpen()
          DummyText = TextGadget(#PB_Any, 0, 0, 10, 10, "")
          HideGadget(DummyText, #True)
        EndIf
        N = CountGadgetItems(Gadget)
        For i = 0 To (N-1)
          SetGadgetText(DummyText, GetGadgetItemText(Gadget, i))
          Width = _PBGadgetRequiredWidth(DummyText) + 2.0 * StandardScrollbarSize()
          If (Result < Width)
            Result = Width
          EndIf
        Next i
      Case #PB_GadgetType_Web, #PB_GadgetType_ExplorerList
        Result = GadgetPreferredHeight(Gadget) * 4 / 3
      Case #PB_GadgetType_ListIcon
        N = GetGadgetAttribute(Gadget, #PB_ListIcon_ColumnCount)
        Debug N
        Width = 0
        For i = 0 To (N-1)
          Width + GetGadgetItemAttribute(Gadget, 0, #PB_ListIcon_ColumnWidth, i)
        Next i
        Width + 1.5 * StandardScrollbarSize()
        Result = Width
      Case #PB_GadgetType_Tree
        If ((Not DummyText) Or (Not IsGadget(DummyText)))
          EnsureGadgetListOpen()
          DummyText = TextGadget(#PB_Any, 0, 0, 10, 10, "")
          HideGadget(DummyText, #True)
        EndIf
        N = CountGadgetItems(Gadget)
        For i = 0 To (N-1)
          SetGadgetText(DummyText, GetGadgetItemText(Gadget, i))
          Width = _PBGadgetRequiredWidth(DummyText)
          Width + (2.5 + GetGadgetItemAttribute(Gadget, i, #PB_Tree_SubLevel)) * StandardButtonHeight()
          If (Result < Width)
            Result = Width
          EndIf
        Next i
      Case #PB_GadgetType_ExplorerTree
        Result = 2.0 * GadgetRequiredWidth(Gadget)
      Case #PB_GadgetType_ExplorerCombo
        Result = 2.0 * GadgetRequiredWidth(Gadget)
    EndSelect
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure ResetGadgetSizeCache()
    ClearMap(_PBSL_StandardGadgetHeight())
    ClearMap(_PBSL_GadgetBorderSize())
  EndProcedure
  
CompilerEndIf
;-
