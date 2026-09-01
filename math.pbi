; +-----------------------------------+
; | PureBasic Standard Library - Math |
; +-----------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Math_Included, #PB_Constant))
  #_PBSL_Math_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Math Constants
  
  #TwoPi = 2.0 * #PI
  
  ;-
  ;- - Math Procedures
  
  Procedure.i MaxI(a.i, b.i)
    If (a > b)
      ProcedureReturn (a)
    EndIf
    ProcedureReturn (b)
  EndProcedure
  Procedure.i MinI(a.i, b.i)
    If (a < b)
      ProcedureReturn (a)
    EndIf
    ProcedureReturn (b)
  EndProcedure
  
  Procedure.d MaxD(a.d, b.d)
    If (a > b)
      ProcedureReturn (a)
    EndIf
    ProcedureReturn (b)
  EndProcedure
  Procedure.d MinD(a.d, b.d)
    If (a < b)
      ProcedureReturn (a)
    EndIf
    ProcedureReturn (b)
  EndProcedure
  
  Procedure.i PercentChance(Percent.i)
    Protected Result.i = #False
    If (Percent >= 100)
      Result = #True
    ElseIf (Percent > 0)
      Result = Bool(Random(99) < Percent)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
