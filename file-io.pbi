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
  
  Procedure.s ReadFileToString(File.s, FileFormat.i = #PB_Default)
    Protected Result.s = ""
    Protected FN.i = ReadFile(#PB_Any, File)
    If (FN)
      Protected ReadFormat.i = 0
      If (FileFormat <> #PB_Ascii)
        ReadFormat = ReadStringFormat(FN)
      EndIf
      If (FileFormat = #PB_Default)
        If (ReadFormat = #PB_Ascii) ; no BOM was detected
          ReadFormat = #DefaultIOStringFormat
        EndIf
      Else
        ReadFormat = FileFormat ; use specified
      EndIf
      Select (ReadFormat)
        Case #PB_Ascii, #PB_UTF8, #PB_Unicode
          Result = ReadString(FN, ReadFormat | #PB_File_IgnoreEOL)
      EndSelect
      CloseFile(FN)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CreateFileFromString(File.s, String.s, Format.i = #PB_Default, WriteBOM.i = #PB_Default)
    Protected Result.i = #False
    If (Format = #PB_Default)
      Format = #DefaultIOStringFormat
    EndIf
    If (WriteBOM = #PB_Default)
      WriteBOM = Bool(Format = #PB_Unicode)
    EndIf
    Select (Format)
      Case #PB_Ascii, #PB_UTF8, #PB_Unicode
        Protected FN.i = CreateFile(#PB_Any, File)
        If (FN)
          If (WriteBOM)
            WriteStringFormat(FN, Format)
          EndIf
          WriteString(FN, String, Format)
          CloseFile(FN)
          Result = #True
        EndIf
    EndSelect
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
