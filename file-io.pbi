; +---------------------------------------+
; | PureBasic Standard Library - File I/O |
; +---------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_FileIO_Included, #PB_Constant))
  #_PBSL_FileIO_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - File Procedures
  
  Procedure.i ReadFileInteger(File.s)
    Protected Result.i = 0
    Protected FN.i = ReadFile(#PB_Any, File)
    If (FN)
      ReadStringFormat(FN)
      Result = Val(ReadString(FN))
      CloseFile(FN)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i WriteFileInteger(File.s, Value.i)
    Protected Result.i = #False
    Protected FN.i = CreateFile(#PB_Any, File)
    If (FN)
      WriteStringN(FN, Str(Value))
      CloseFile(FN)
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
