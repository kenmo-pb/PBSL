; +-----------------------------------------+
; | PureBasic Standard Library - Lists/Maps |
; +-----------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_ListsMaps_Included, #PB_Constant))
  #_PBSL_ListsMaps_Included = #True
  
  ;- - List Macros
  
  Macro IsListEmpty(_List)
    (Bool(ListSize(_List) = 0))
  EndMacro
  
  Macro SelectRandomElement(_List)
    SelectElement(_List, Random(ListSize(_List) - 1))
  EndMacro
  
  Macro ClearAndFreeList(_List)
    ClearList(_List)
    FreeList(_List)
  EndMacro
  
  Macro CurrentElement(_List)
    (@_List)
  EndMacro
  
  ;-
  ;- - Map Macros
  
  Macro ClearAndFreeMap(_Map)
    ClearMap(_Map)
    FreeMap(_Map)
  EndMacro
  
  ;-
  ;- - List Procedures
  
  CompilerIf (#True) ; valid as of PB 6.40
    
    Procedure.i PreviousElementPtr(*ListElementPtr)
      Protected *Result = #Null
      If (*ListElementPtr)
        *Result = PeekI(*ListElementPtr - 1 * SizeOf(INTEGER))
        If (*Result)
          *Result + 2 * SizeOf(INTEGER)
        EndIf
      EndIf
      ProcedureReturn (*Result)
    EndProcedure
    
    Procedure.i NextElementPtr(*ListElementPtr)
      Protected *Result = #Null
      If (*ListElementPtr)
        *Result = PeekI(*ListElementPtr - 2 * SizeOf(INTEGER))
        If (*Result)
          *Result + 2 * SizeOf(INTEGER)
        EndIf
      EndIf
      ProcedureReturn (*Result)
    EndProcedure
    
  CompilerEndIf
  
  Procedure.s GetListString(List StrList.s(), Position.i)
    Protected Result.s = ""
    If (ListSize(StrList()) > 0)
      PushListPosition(StrList())
      If (SelectElement(StrList(), Position))
        Result = StrList()
      EndIf
      PopListPosition(StrList())
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s RandomString(List StrList.s())
    Protected Result.s = ""
    If (ListSize(StrList()) > 0)
      PushListPosition(StrList())
      SelectRandomElement(StrList())
      Result = StrList()
      PopListPosition(StrList())
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i RemoveStringListByPattern(List StrList.s(), Pattern.s, CaseInsensitive.i = #False, Invert.i = #False)
    Protected Removed.i = 0
    ForEach StrList()
      If (StringMatchesPattern(StrList(), Pattern, CaseInsensitive) XOr (Invert))
        DeleteElement(StrList())
        Removed + 1
      EndIf
    Next
    ProcedureReturn (Removed)
  EndProcedure
  
  Procedure.i FilterStringListByPattern(List StrList.s(), Pattern.s, CaseInsensitive.i = #False)
    ProcedureReturn (RemoveStringListByPattern(StrList(), Pattern, CaseInsensitive, #True))
  EndProcedure
  
  ;-
  ;- - Map Procedures
  
  Procedure.s GetMapString(Map StrMap.s(), Key.s, DefaultValue.s = "", NoCase.i = #False)
    Protected Result.s = DefaultValue
    If (NoCase And (Key <> ""))
      Key = LCase(Key)
      ForEach StrMap()
        If (LCase(MapKey(StrMap())) = Key)
          Result = StrMap()
          Break
        EndIf
      Next
    Else
      If (FindMapElement(StrMap(), Key))
        Result = StrMap()
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
