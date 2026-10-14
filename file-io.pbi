; +---------------------------------------+
; | PureBasic Standard Library - File I/O |
; +---------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_FileIO_Included, #PB_Constant))
  #_PBSL_FileIO_Included = #True
  
  ;- - File Macros
  
  Macro WriteStringCRLF(_File, _Text, _Format = #DefaultIOStringFormat)
    WriteString((_File), _Text + #CRLF$, (_Format))
  EndMacro
  Macro WriteStringLF(_File, _Text, _Format = #DefaultIOStringFormat)
    WriteString((_File), _Text + #LF$, (_Format))
  EndMacro
  
  ;-
  ;- - File Procedures
  
  Procedure.i CreateEmptyFile(File.s)
    Protected Result.i = #False
    Protected FN.i = CreateFile(#PB_Any, File)
    If (FN)
      CloseFile(FN)
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i TouchFile(File.s, ModifiedDate.i = #PB_Default)
    Protected Result.i = #False
    If (File)
      If (FileSize(File) = #PB_FileSize_Missing)
        CreateEmptyFile(File)
      EndIf
      ModifiedDate = MapPBDefault(ModifiedDate, Date())
      Result = SetModifiedDate(File, ModifiedDate)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
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
  
  Procedure.i ReadFileToList(File.s, List StrList.s(), FileFormat.i = #PB_Default, AppendList.i = #False)
    Protected Result.i = #False
    If (AppendList)
      LastElement(StrList())
    Else
      ClearList(StrList())
    EndIf
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
          Result = #True
          While (Not Eof(FN))
            AddString(StrList(), ReadString(FN, ReadFormat))
          Wend
      EndSelect
      CloseFile(FN)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CreateFileFromList(File.s, List StrList.s(), Format.i = #PB_Default, WriteBOM.i = #PB_Default)
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
          ForEach StrList()
            WriteString(FN, StrList() + #LF$, Format)
          Next
          CloseFile(FN)
          Result = #True
        EndIf
    EndSelect
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CreateFileFromMemory(File.s, *DataPointer, DataBytes.i)
    Protected Result.i = #False
    If (File And *DataPointer And (DataBytes >= 0))
      Protected FN.i = CreateFile(#PB_Any, File)
      If (FN)
        If (DataBytes > 0)
          If (WriteData(FN, *DataPointer, DataBytes) = DataBytes)
            Result = #True
          EndIf
        Else
          Result = #True
        EndIf
        CloseFile(FN)
        If (Not Result)
          DeleteFile(File)
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CreateFileFromBuffer(File.s, *Buffer)
    Protected Result.i = #False
    If (File And *Buffer)
      Result = CreateFileFromMemory(File, *Buffer, MemorySize(*Buffer))
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ReadFileToMemory(File.s, *DataBuffer, DataBufferBytes.i)
    Protected Result.i = 0
    If (File And *DataBuffer And (DataBufferBytes > 0))
      Protected FN.i = ReadFile(#PB_Any, File)
      If (FN)
        Protected Length.i = Lof(FN)
        If (DataBufferBytes >= Length)
          If (ReadData(FN, *DataBuffer, Length) = Length)
            Result = Length
          EndIf
        EndIf
        CloseFile(FN)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ReadFileToBuffer(File.s)
    Protected *Result = #Null
    If (File)
      Protected Length.i = FileSize(File)
      If (Length > 0)
        *Result = AllocateMemory(Length, #PB_Memory_NoClear)
        If (*Result)
          If (ReadFileToMemory(File, *Result, Length) = Length)
            ; OK
          Else
            FreeMemory(*Result)
            *Result = #Null
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (*Result)
  EndProcedure
  
CompilerEndIf
;-
