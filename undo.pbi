; +-----------------------------------+
; | PureBasic Standard Library - Undo |
; +-----------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Undo_Included, #PB_Constant))
  #_PBSL_Undo_Included = #True
  
  ;- - Undo Structures
  
  Structure UndoEntry
    Image.i
    s.s
    StructureUnion
      a.a
      b.b
      c.c
      d.d
      f.f
      i.i
      l.l
      q.q
      u.u
      w.w
    EndStructureUnion
  EndStructure
  
  Structure UndoStack
    *Current.UndoEntry
    *Saved.UndoEntry
    List Entry.UndoEntry()
  EndStructure
  
  ;-
  ;- - Undo Procedures
  
  Declare ClearUndoStackNewer(*UndoStack.UndoStack)
  
  Procedure _ReleaseUndoStackEntry(*UndoStack.UndoStack)
    If (*UndoStack\Entry()\Image <> #PB_Ignore)
      FreeImage(*UndoStack\Entry()\Image)
      *UndoStack\Entry()\Image = #PB_Ignore
    EndIf
    *UndoStack\Entry()\s = #Null$
    If (*UndoStack\Saved = @*UndoStack\Entry())
      *UndoStack\Saved = #Null
    EndIf
  EndProcedure
  
  Procedure.i _AddUndoStackEntry(*UndoStack.UndoStack)
    Protected *New.UndoEntry = #Null
    If (*UndoStack\Current)
      ClearUndoStackNewer(*UndoStack)
      ChangeCurrentElement(*UndoStack\Entry(), *UndoStack\Current)
    EndIf
    *New = AddElement(*UndoStack\Entry())
    If (*New)
      *New\Image = #PB_Ignore
      *UndoStack\Current = *New
    EndIf
    ProcedureReturn (*New)
  EndProcedure
  
  ;-
  
  Procedure.i UndoStackCanUndo(*UndoStack.UndoStack)
    Protected Result.i = #False
    If (*UndoStack And *UndoStack\Current)
      Result = Bool(PreviousElementPtr(*UndoStack\Current))
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i UndoStackCanRedo(*UndoStack.UndoStack)
    Protected Result.i = #False
    If (*UndoStack And *UndoStack\Current)
      Result = Bool(NextElementPtr(*UndoStack\Current))
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i UndoStackUndo(*UndoStack.UndoStack)
    Protected Result.i = #False
    If (UndoStackCanUndo(*UndoStack))
      *UndoStack\Current = PreviousElementPtr(*UndoStack\Current)
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i UndoStackRedo(*UndoStack.UndoStack)
    Protected Result.i = #False
    If (UndoStackCanRedo(*UndoStack))
      *UndoStack\Current = NextElementPtr(*UndoStack\Current)
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  
  Procedure.i GetUndoStackInteger(*UndoStack.UndoStack)
    Protected Result.i = 0
    If (*UndoStack And *UndoStack\Current)
      Result = *UndoStack\Current\i
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure AddUndoStackInteger(*UndoStack.UndoStack, i.i, SetSavePoint.i = #False)
    If (*UndoStack)
      Protected *New.UndoEntry = _AddUndoStackEntry(*UndoStack)
      If (*New)
        *New\i = i
        If (SetSavePoint)
          *UndoStack\Saved = *New
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Procedure.s GetUndoStackString(*UndoStack.UndoStack)
    Protected Result.s = ""
    If (*UndoStack And *UndoStack\Current)
      Result = *UndoStack\Current\s
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure AddUndoStackString(*UndoStack.UndoStack, s.s, SetSavePoint.i = #False)
    If (*UndoStack)
      Protected *New.UndoEntry = _AddUndoStackEntry(*UndoStack)
      If (*New)
        *New\s = s
        If (SetSavePoint)
          *UndoStack\Saved = *New
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Procedure.i GetUndoStackImage(*UndoStack.UndoStack)
    Protected Result.i = #PB_Ignore
    If (*UndoStack And *UndoStack\Current)
      Result = *UndoStack\Current\Image
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure AddUndoStackImage(*UndoStack.UndoStack, Image.i, SetSavePoint.i = #False)
    If (*UndoStack)
      Protected *New.UndoEntry = _AddUndoStackEntry(*UndoStack)
      If (*New)
        *New\Image = Image
        If (SetSavePoint)
          *UndoStack\Saved = *New
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  ;-
  
  Procedure SetUndoStackSavePoint(*UndoStack.UndoStack)
    If (*UndoStack)
      *UndoStack\Saved = *UndoStack\Current
    EndIf
  EndProcedure
  
  Procedure.i UndoStackAtSavePoint(*UndoStack.UndoStack)
    Protected Result.i = #False
    If (*UndoStack And *UndoStack\Saved)
      Result = Bool(*UndoStack\Current = *UndoStack\Saved)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure ClearUndoStackOlder(*UndoStack.UndoStack)
    If (*UndoStack And *UndoStack\Current)
      Protected *Prev.UndoEntry
      *Prev = PreviousElementPtr(*UndoStack\Current)
      While (*Prev)
        ChangeCurrentElement(*UndoStack\Entry(), *Prev)
        _ReleaseUndoStackEntry(*UndoStack)
        DeleteElement(*UndoStack\Entry())
        *Prev = PreviousElementPtr(*UndoStack\Current)
      Wend
    EndIf
  EndProcedure
  
  Procedure ClearUndoStackNewer(*UndoStack.UndoStack)
    If (*UndoStack And *UndoStack\Current)
      Protected *Next.UndoEntry
      *Next = NextElementPtr(*UndoStack\Current)
      While (*Next)
        ChangeCurrentElement(*UndoStack\Entry(), *Next)
        _ReleaseUndoStackEntry(*UndoStack)
        DeleteElement(*UndoStack\Entry())
        *Next = NextElementPtr(*UndoStack\Current)
      Wend
    EndIf
  EndProcedure
  
  Procedure ClearUndoStack(*UndoStack.UndoStack)
    If (*UndoStack)
      ForEach (*UndoStack\Entry())
        _ReleaseUndoStackEntry(*UndoStack)
      Next
      ClearList(*UndoStack\Entry())
      *UndoStack\Current = #Null
      *UndoStack\Saved   = #Null
    EndIf
  EndProcedure
  
  Procedure.i FreeUndoStack(*UndoStack.UndoStack)
    If (*UndoStack)
      ClearUndoStack(*UndoStack)
      FreeStructure(*UndoStack)
    EndIf
    ProcedureReturn (#Null)
  EndProcedure
  
  Procedure.i CreateUndoStack()
    ProcedureReturn (AllocateStructure(UndoStack))
  EndProcedure
  
CompilerEndIf
;-
