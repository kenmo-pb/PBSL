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
  
  #Max7Bit  = $7F
  #Max8Bit  = $FF
  #Max15Bit = $7FFF
  #Max16Bit = $FFFF
  #Max23Bit = $7FFFFF
  #Max24Bit = $FFFFFF
  #Max31Bit = $7FFFFFFF
  #Max32Bit = $FFFFFFFF
  #Max63Bit = $7FFFFFFFFFFFFFFF
  #Max64Bit = $FFFFFFFFFFFFFFFF
  
  #LongMin = (-#Max31Bit - 1)
  #LongMax = #Max31Bit
  #QuadMin = (-#Max63Bit - 1)
  #QuadMax = #Max63Bit
  
  CompilerIf (#Is64BitBuild)
    #IntMin = #QuadMin
    #IntMax = #QuadMax
  CompilerElse
    #IntMin = #LongMin
    #IntMax = #LongMax
  CompilerEndIf
  
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
  
  Procedure.i _IIfI(Boolean.i, ValueIfTrue.i, ValueIfFalse.i)
    If (Boolean)
      ProcedureReturn  (ValueIfTrue)
    Else
      ProcedureReturn  (ValueIfFalse)
    EndIf
  EndProcedure
  Macro IIfI(_Expression, _IntIfTrue, _IntIfFalse)
    _IIfI(Bool(_Expression), (_IntIfTrue), (_IntIfFalse))
  EndMacro
  
  Procedure.s _IIfS(Boolean.i, ValueIfTrue.s, ValueIfFalse.s)
    If (Boolean)
      ProcedureReturn  (ValueIfTrue)
    Else
      ProcedureReturn  (ValueIfFalse)
    EndIf
  EndProcedure
  Macro IIfS(_Expression, _StringIfTrue, _StringIfFalse)
    _IIfS(Bool(_Expression), (_StringIfTrue), (_StringIfFalse))
  EndMacro
  
  ;-
  ;- - Endian Handling
  
  Procedure.u SwapEndian16(Value16Bit.u)
    Protected *BA.ByteArray = @Value16Bit
    Swap *BA\b[0], *BA\b[1]
    ProcedureReturn (Value16Bit)
  EndProcedure
  
  Procedure.l SwapEndian32(Value32Bit.l)
    Protected *BA.ByteArray = @Value32Bit
    Swap *BA\b[0], *BA\b[3]
    Swap *BA\b[1], *BA\b[2]
    ProcedureReturn (Value32Bit)
  EndProcedure
  
  Procedure.q SwapEndian64(Value64Bit.q)
    Protected *BA.ByteArray = @Value64Bit
    Swap *BA\b[0], *BA\b[7]
    Swap *BA\b[1], *BA\b[6]
    Swap *BA\b[2], *BA\b[5]
    Swap *BA\b[3], *BA\b[4]
    ProcedureReturn (Value64Bit)
  EndProcedure
  
CompilerEndIf
;-
