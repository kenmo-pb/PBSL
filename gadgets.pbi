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
  
  
CompilerEndIf
;-
