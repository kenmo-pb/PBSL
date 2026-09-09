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
  
  ;- - Event Constants
  
  ; There is no #PB_Menu_FirstCustomValue...
  ;   AddKeyboardShortcut() implies a max of 64000
  ;   MenuItem()            implies a max of 65535
  CompilerIf (Not Defined(PBSL_MenuItem_FirstCustomValue, #PB_Constant))
    #PBSL_MenuItem_FirstCustomValue = 48000
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
    Static MenuItemValue.i = (#PBSL_MenuItem_FirstCustomValue - 1)
    MenuItemValue + 1
    If (MinimumMenuItemValue > #PBSL_MenuItem_FirstCustomValue)
      If (MenuItemValue < MinimumMenuItemValue)
        MenuItemValue = MinimumMenuItemValue
      EndIf
    EndIf
    ProcedureReturn (MenuItemValue)
  EndProcedure
  
  ;-
  ;- - Window Macros
  
  Macro ShowWindow(_Window)
    HideWindow((_Window), #False)
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
  
CompilerEndIf
;-
