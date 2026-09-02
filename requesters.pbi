; +-----------------------------------------+
; | PureBasic Standard Library - Requesters |
; +-----------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Requesters_Included, #PB_Constant))
  #_PBSL_Requesters_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  XIncludeFile "pb-compatibility.pbi"
  
  ;- - Requester Constants
  
  #Confirm_Yes    = #PB_MessageRequester_Yes
  #Confirm_No     = #PB_MessageRequester_No
  #Confirm_Cancel = #PB_MessageRequester_Cancel
  
  #Confirm_YesNo       = #PB_MessageRequester_YesNo
  #Confirm_YesNoCancel = #PB_MessageRequester_YesNoCancel
  
  ;-
  ;- - Requester Macros
  
  CompilerIf (#RequestersSupportParentID)
    Macro Info(_Message, _ParentID = #Null)
      MessageRequester("Info", _Message, #PB_MessageRequester_Info | #PB_MessageRequester_Ok, (_ParentID))
    EndMacro
    Macro Warning(_Message, _ParentID = #Null)
      MessageRequester("Warning", _Message, #PB_MessageRequester_Warning | #PB_MessageRequester_Ok, (_ParentID))
    EndMacro
    Macro Error(_Message, _ParentID = #Null)
      MessageRequester("Error", _Message, #PB_MessageRequester_Error | #PB_MessageRequester_Ok, (_ParentID))
    EndMacro
    Macro Question(_Message, _Flags = #PB_MessageRequester_YesNo, _ParentID = #Null)
      MessageRequester("Question", _Message, #PB_MessageRequester_Question | (_Flags), (_ParentID))
    EndMacro
    
    Macro PasswordRequester(_Title, _Message, _DefaultString, _Flags = #Null, _ParentID = #Null)
      InputRequester(_Title, _Message, _DefaultString, ((_Flags) | #PB_InputRequester_Password), (_ParentID))
    EndMacro
  CompilerElse
    Macro Info(_Message, _ParentID = #Null)
      MessageRequester("Info", _Message, #PB_MessageRequester_Info | #PB_MessageRequester_Ok)
    EndMacro
    Macro Warning(_Message, _ParentID = #Null)
      MessageRequester("Warning", _Message, #PB_MessageRequester_Warning | #PB_MessageRequester_Ok)
    EndMacro
    Macro Error(_Message, _ParentID = #Null)
      MessageRequester("Error", _Message, #PB_MessageRequester_Error | #PB_MessageRequester_Ok)
    EndMacro
    Macro Question(_Message, _Flags = #PB_MessageRequester_YesNo, _ParentID = #Null)
      MessageRequester("Question", _Message, #PB_MessageRequester_Question | (_Flags))
    EndMacro
    
    Macro PasswordRequester(_Title, _Message, _DefaultString, _Flags = #Null, _ParentID = #Null)
      InputRequester(_Title, _Message, _DefaultString, ((_Flags) | #PB_InputRequester_Password))
    EndMacro
  CompilerEndIf
  
  Macro ConfirmYes(_Message, _AllowCancel = #False, _ParentID = #Null)
    (Bool(Confirm(_Message, _AllowCancel, _ParentID) = #Confirm_Yes))
  EndMacro
  
  ;-
  ;- - Requester Procedures
  
  Procedure.i Confirm(Message.s, AllowCancel.i = #False, ParentID.i = #Null)
    Protected Result.i
    Protected Flags.i = #PB_MessageRequester_YesNo
    If (AllowCancel)
      Flags = #PB_MessageRequester_YesNoCancel
    EndIf
    CompilerIf (#RequestersSupportParentID)
      Result = MessageRequester("Confirm", Message, (Flags | #PB_MessageRequester_Question), ParentID)
    CompilerElse
      Result = MessageRequester("Confirm", Message, (Flags | #PB_MessageRequester_Question))
    CompilerEndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
