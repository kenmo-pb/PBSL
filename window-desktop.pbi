; +---------------------------------------------+
; | PureBasic Standard Library - Window/Desktop |
; +---------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_WindowDesktop_Included, #PB_Constant))
  #_PBSL_WindowDesktop_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Window Constants
  
  #PrimaryDesktop = 0
  
  CompilerIf (#True)
    #PB_Window_AllSizeGadgets = #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
  CompilerEndIf
  CompilerIf (#True)
    #PB_Window_Hidden = #PB_Window_Invisible
  CompilerEndIf
  
  #PB_Shortcut_Equal  = WindowsElse(#VK_OEM_PLUS,  '=')
  #PB_Shortcut_Hyphen = WindowsElse(#VK_OEM_MINUS, '-')
  
  ;-
  ;- - Event Constants
  
  ; There is no #PB_Menu_FirstCustomValue...
  ;   AddKeyboardShortcut() implies a max of 64000
  ;   MenuItem()            implies a max of 65535
  CompilerIf (Not Defined(MenuItem_FirstCustomValue, #PB_Constant))
    #MenuItem_FirstCustomValue = 48000
  CompilerEndIf
  
  ;-
  ;- - Event Procedures
  
  Procedure.i RegisterCustomEvent(MinimumEventValue.i = #PB_Ignore)
    Static EventValue.i = (#PB_Event_FirstCustomValue - 1)
    EventValue + 1
    If (MinimumEventValue > #PB_Event_FirstCustomValue)
      If (EventValue < MinimumEventValue)
        EventValue = MinimumEventValue
      EndIf
    EndIf
    ProcedureReturn (EventValue)
  EndProcedure
  
  Procedure.i RegisterCustomEventType(MinimumEventTypeValue.i = #PB_Ignore)
    Static EventTypeValue.i = (#PB_EventType_FirstCustomValue - 1)
    EventTypeValue + 1
    If (MinimumEventTypeValue > #PB_EventType_FirstCustomValue)
      If (EventTypeValue < MinimumEventTypeValue)
        EventTypeValue = MinimumEventTypeValue
      EndIf
    EndIf
    ProcedureReturn (EventTypeValue)
  EndProcedure
  
  Procedure.i RegisterCustomMenuItem(MinimumMenuItemValue.i = #PB_Ignore)
    Static MenuItemValue.i = (#MenuItem_FirstCustomValue - 1)
    MenuItemValue + 1
    If (MinimumMenuItemValue > #MenuItem_FirstCustomValue)
      If (MenuItemValue < MinimumMenuItemValue)
        MenuItemValue = MinimumMenuItemValue
      EndIf
    EndIf
    ProcedureReturn (MenuItemValue)
  EndProcedure
  
  ;-
  ;- - Window Macros
  
  Macro MoveWindow(_Window, _x, _y)
    ResizeWindow((_Window), (_x), (_y), #PB_Ignore, #PB_Ignore)
  EndMacro
  Macro SetWindowSize(_Window, _Width, _Height)
    ResizeWindow((_Window), #PB_Ignore, #PB_Ignore, (_Width), (_Height))
  EndMacro
  
  Macro ShowWindow(_Window)
    HideWindow((_Window), #False)
  EndMacro
  
  Macro WaitCloseWindow(_Window = #PB_Any)
    Repeat
    Until ((WaitWindowEvent() = #PB_Event_CloseWindow) And (((_Window) = #PB_Any) Or (EventWindow() = (_Window))))
  EndMacro
  
  ;-
  ;- - Window Procedures
  
  Procedure.i StandardWindowFlags(Resizable.i = #False, Hidden.i = #False)
    Protected Result.i = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget
    If (Resizable)
      Result | (#PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
    EndIf
    If (Hidden)
      Result | #PB_Window_Invisible
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i OpenStandardWindow(Window.i, Width.i, Height.i, Title.s, Resizable.i = #False, Hidden.i = #False, ParentID.i = #Null)
    Protected Flags.i = StandardWindowFlags(Resizable, Hidden)
    ProcedureReturn (OpenWindow(Window, #PB_Ignore, #PB_Ignore, Width, Height, Title, Flags, ParentID))
  EndProcedure
  
  Procedure EnsureGadgetListOpen()
    Static DummyWindow.i = #Null
    If (UseGadgetList(0) = 0)
      If (Not DummyWindow)
        DummyWindow = OpenWindow(#PB_Any, 0, 0, 100, 100, "", #PB_Window_Invisible | #PB_Window_BorderLess)
      EndIf
      If (DummyWindow)
        UseGadgetList(WindowID(DummyWindow))
      EndIf
    EndIf
  EndProcedure
  
  CompilerIf (#PB_Compiler_OS = #PB_OS_Windows)
    Procedure.i GetWindowMenuHeight(Window.i, Menu.i)
      Protected ItemRect.RECT, TotalRect.RECT
      Protected N.i = GetMenuItemCount_(MenuID(Menu))
      Protected i.i
      For i = 0 To N-1
        GetMenuItemRect_(WindowID(Window), MenuID(Menu), i, @ItemRect)
        UnionRect_(@TotalRect, @TotalRect, @ItemRect)
      Next i
      ProcedureReturn (TotalRect\bottom - TotalRect\top + 1) ; is +1 correct ? matches MenuHeight() for one row...
    EndProcedure
  CompilerElse
    Macro GetWindowMenuHeight(_Window, _Menu)
      MenuHeight()
    EndMacro
  CompilerEndIf
  
  Procedure.i GetWindowFromWindowID(WindowID.i)
    Protected Result.i = -1
    If (WindowID)
      PB_Object_EnumerateStart(PB_Window_Objects)
      If (PB_Window_Objects)
        Protected Window.i
        While (PB_Object_EnumerateNext(PB_Window_Objects, @Window))
          If (WindowID(Window) = WindowID)
            Result = Window
            Break
          EndIf
        Wend
        PB_Object_EnumerateAbort(PB_Window_Objects)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  CompilerIf (#IsMacBuild)
    CompilerIf (Not Defined(sdkGadget, #PB_Structure))
      Structure sdkGadget
        *gadget
        *container
        *vt
        UserData.i
        Window.i
        Type.i
        Flags.i
      EndStructure
    CompilerEndIf
    
    CompilerIf (Not Defined(PB_Window_GetID, #PB_Procedure))
      Import ""
        PB_Window_GetID(Object.i)
      EndImport
    CompilerEndIf
  CompilerEndIf
  
  Procedure.i GetWindowFromGadget(Gadget.i)
    Protected Result.i = -1
    ; https://www.purebasic.fr/english/viewtopic.php?t=85547
    
    CompilerIf (Defined(PB_Gadget_GetRootWindow, #PB_Procedure) And (#True))
      Result = GetWindowFromWindowID(PB_Gadget_GetRootWindow(GadgetID(Gadget)))
      
    CompilerElseIf (#IsWindowsBuild)
      CompilerIf (#True)
        Result = GetProp_(GetAncestor_(GadgetID(Gadget), #GA_ROOT), "PB_WINDOWID")
        If (Result > 0)
          Result = Result - 1
        Else
          Result = -1
        EndIf
      CompilerElse
        Result = GetWindowFromWindowID(GetAncestor_(GadgetID(Gadget), #GA_ROOT))
      CompilerEndIf
      
    CompilerElseIf (#IsLinuxBuild)
      Result = gtk_widget_get_toplevel_(GadgetID(Gadget))
      If (Result)
        result = g_object_get_data_(ID, "pb_id" )
      Else
        Result = -1
      EndIf
      
    CompilerElseIf (#IsMacBuild)
      Protected *Gadget.sdkGadget = IsGadget(Gadget)
      If (*Gadget)
        CompilerIf (Defined(PB_Window_GetID, #PB_Procedure) And (#True))
          Result = PB_Window_GetID(WindowID(*Gadget\Window)) ; necessary?
        CompilerElse
          Result = *Gadget\Window
        CompilerEndIf
      EndIf
      
    CompilerEndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GetBuildWindow()
    ProcedureReturn (GetWindowFromWindowID(UseGadgetList(0)))
  EndProcedure
  
  Procedure.i IsMinimized(Window.i)
    ProcedureReturn (Bool(GetWindowState(Window) = #PB_Window_Minimize))
  EndProcedure
  Procedure.i IsMaximized(Window.i)
    ProcedureReturn (Bool(GetWindowState(Window) = #PB_Window_Maximize))
  EndProcedure
  
  Procedure.i WindowCenterX(Window.i)
    ProcedureReturn (WindowX(Window) + WindowWidth(Window)/2)
  EndProcedure
  Procedure.i WindowCenterY(Window.i, PercentDown.f = 0.50)
    ProcedureReturn (WindowY(Window) + WindowHeight(Window) * PercentDown)
  EndProcedure
  Procedure GetWindowCenterXY(Window.i, *CenterX.INTEGER, *CenterY.INTEGER, YPercentDown.f = 0.50)
    If (*CenterX)
      *CenterX\i = WindowCenterX(Window)
    EndIf
    If (*CenterY)
      *CenterY\i = WindowCenterY(Window, YPercentDown)
    EndIf
  EndProcedure
  
  Procedure CenterWindowInWindow(ChildWindow.i, ParentWindow.i, YPercentDown.f = 0.50)
    MoveWindow(ChildWindow, WindowX(ParentWindow) + (WindowWidth(ParentWindow) - WindowWidth(ChildWindow))/2, WindowY(ParentWindow) + (WindowHeight(ParentWindow) - WindowHeight(ChildWindow)) * YPercentDown)
  EndProcedure
  
  ;-
  ;- - Desktop Procedures
  
  Procedure.i CountDesktops()
    ProcedureReturn (ExamineDesktops())
  EndProcedure
  Procedure.i IsDesktop(i.i)
    ProcedureReturn (Bool((i >= 0) And (i < CountDesktops())))
  EndProcedure
  
  Procedure.i DesktopExtentX(i.i)
    ProcedureReturn (DesktopX(i) + DesktopWidth(i))
  EndProcedure
  Procedure.i DesktopExtentY(i.i)
    ProcedureReturn (DesktopY(i) + DesktopHeight(i))
  EndProcedure
  
  Procedure.i DesktopToGlobalX(dx.i, Desktop.i)
    ProcedureReturn (dx + DesktopX(Desktop))
  EndProcedure
  Procedure.i DesktopToGlobalY(dy.i, Desktop.i)
    ProcedureReturn (dy + DesktopY(Desktop))
  EndProcedure
  Procedure.i GlobalToDesktopX(gx.i, Desktop.i)
    ProcedureReturn (gx - DesktopX(Desktop))
  EndProcedure
  Procedure.i GlobalToDesktopY(gy.i, Desktop.i)
    ProcedureReturn (gy - DesktopY(Desktop))
  EndProcedure
  
  Procedure.i FindExactDesktop(ID.i = -1, Width.i = 0, Height.i = 0, Depth.i = 0, Frequency.i = 0)
    Protected Result.i = -1
    Protected N.i = CountDesktops()
    Protected i.i
    For i = 0 To N - 1
      Protected Match.i = #True
      If (Match And (ID >= 0))
        If (i <> ID)
          Match = #False
        EndIf
      EndIf
      If (Match And (Width > 0))
        If (DesktopWidth(i) <> Width)
          Match = #False
        EndIf
      EndIf
      If (Match And (Height > 0))
        If (DesktopHeight(i) <> Height)
          Match = #False
        EndIf
      EndIf
      If (Match And (Depth > 0))
        If (DesktopDepth(i) <> Depth)
          Match = #False
        EndIf
      EndIf
      If (Match And (Frequency > 0))
        If (DesktopFrequency(i) <> Frequency)
          Match = #False
        EndIf
      EndIf
      If (Match)
        Result = i
        Break
      EndIf
    Next i
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i FindClosestDesktop(ID.i = -1, Width.i = 0, Height.i = 0, Depth.i = 0, Frequency.i = 0)
    Protected Result.i = -1
    If (CountDesktops() > 1)
      Result = FindExactDesktop(ID, Width, Height, Depth, Frequency)
      If (Result < 0)
        Result = FindExactDesktop(-1, Width, Height, Depth, Frequency)
      EndIf
      If (Result < 0)
        Result = FindExactDesktop(-1, Width, Height, Depth, 0)
      EndIf
      If (Result < 0)
        Result = FindExactDesktop(-1, Width, Height, 0, 0)
      EndIf
      ;If (Result < 0)
      ;  Result = FindClosestDesktopFromResolution(Width, Height)
      ;EndIf
      If (Result < 0)
        Result = 0
      EndIf
    Else
      Result = 0
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i FindClosestDesktopFromIDString(IDString.s)
    Protected Term.s
    IDString = LCase(IDString)
    
    Protected ID.i = -1
    If (FindString(IDString, ":"))
      Term = Before(IDString, ":")
      If (Term)
        ID = Val(Term)
      EndIf
      IDString = After(IDString, ":")
    EndIf
    
    Protected Frequency.i = 0
    If (FindString(IDString, "@"))
      Term = After(IDString, "@")
      If (Term)
        Frequency = Val(Term)
      EndIf
      IDString = Before(IDString, "@")
    EndIf
    
    Protected Width.i = 0
    Protected Height.i = 0
    Protected Depth.i = 0
    If (CountString(IDString, "x") = 2)
      Width  = Val(StringField(IDString, 1, "x"))
      Height = Val(StringField(IDString, 2, "x"))
      Depth  = Val(StringField(IDString, 3, "x"))
    ElseIf (CountString(IDString, "x") = 1)
      Width  = Val(StringField(IDString, 1, "x"))
      Height = Val(StringField(IDString, 2, "x"))
    EndIf
    
    ProcedureReturn (FindClosestDesktop(ID, Width, Height, Depth, Frequency))
  EndProcedure
  
  Procedure.s DesktopIDString(i.i)
    Protected Result.s = ""
    If (IsDesktop(i))
      If (#True)
        Result + Str(i) + ":"
      EndIf
      Result + Str(DesktopWidth(i)) + "x" + Str(DesktopHeight(i))
      If (#True)
        Result + "x" + Str(DesktopDepth(i))
      EndIf
      If (#True)
        Result + "@" + Str(DesktopFrequency(i))
      EndIf
      If (#False)
        Result + "-" + DesktopName(i)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i DesktopFromPoint(x.i, y.i)
    Protected Result.i = -1
    Protected N.i = CountDesktops()
    If (N > 0)
      Protected i.i
      For i = 0 To (N - 1)
        If (x >= DesktopX(i))
          If (x < DesktopExtentX(i))
            If (y >= DesktopY(i))
              If (y < DesktopExtentY(i))
                Result = i
                Break
              EndIf
            EndIf
          EndIf
        EndIf
      Next i
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i DesktopFromWindowTopLeft(Window.i)
    ProcedureReturn (DesktopFromPoint(WindowX(Window), WindowY(Window)))
  EndProcedure
  
  Procedure.i DesktopFromWindowCenter(Window.i, YPercentDown.f = 0.50)
    ProcedureReturn (DesktopFromPoint(WindowCenterX(Window), WindowCenterY(Window, YPercentDown)))
  EndProcedure
  
  Procedure.i DesktopFromWindow(Window.i)
    Protected Result.i = DesktopFromWindowCenter(Window)
    If (Result < 0)
      Result = DesktopFromWindowTopLeft(Window)
    EndIf
    If (Result < 0)
      Result = 0
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure CenterWindowInDesktop(Window.i, Desktop.i, YPercentDown.f = 0.50)
    ExamineDesktops()
    MoveWindow(Window, DesktopX(Desktop) + (DesktopWidth(Desktop) - WindowWidth(Window))/2, DesktopY(Desktop) + (DesktopHeight(Desktop) - WindowHeight(Window)) * YPercentDown)
  EndProcedure
  
  Procedure.i SameDesktop(Window1.i, Window2.i)
    ProcedureReturn (Bool(DesktopFromWindow(Window1) = DesktopFromWindow(Window2)))
  EndProcedure
  
  Procedure EnsureSameDesktop(ChildWindow.i, ParentWindow.i)
    If (Not SameDesktop(ChildWindow, ParentWindow))
      CenterWindowInWindow(ChildWindow, ParentWindow)
    EndIf
  EndProcedure
  
CompilerEndIf
;-
