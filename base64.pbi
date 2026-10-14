; +-------------------------------------+
; | PureBasic Standard Library - Base64 |
; +-------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Base64_Included, #PB_Constant))
  #_PBSL_Base64_Included = #True
  
  ;- - Base64 Constants
  
  #Base64_URL        = #PB_Cipher_URL
  #Base64_NoPadding  = #PB_Cipher_NoPadding
  #Base64_AppendNull = $40000000
  
  #Base64_DefaultFlags = #Null
  
  ;-
  ;- - Base64 Procedures
  
  Procedure.i Base64ValueForCharacter(Char.c)
    Select (Char)
      Case 'A' To 'Z' : ProcedureReturn (Char - 'A')
      Case 'a' To 'z' : ProcedureReturn (Char - 'a' + 26)
      Case '0' To '9' : ProcedureReturn (Char - '0' + 52)
      Case '+', '-'   : ProcedureReturn (62)
      Case '/', '_'   : ProcedureReturn (63)
    EndSelect
    ProcedureReturn (-1)
  EndProcedure
  
  Procedure.i _Base64BytesNeededToDecode(*EncodedPointer, EncodedBytes.i, *CharPointer.CHARACTER)
    Protected Result.i = -1 ; -1 indicates invalid Base64
    If ((*EncodedPointer And (EncodedBytes >= 0)) Or (*CharPointer))
      Protected FoundEncodedBytes.i = 0
      Protected FoundPaddingBytes.i = 0
      Protected *Read.ASCII = *EncodedPointer
      Protected *End.ASCII  = *EncodedPointer + EncodedBytes
      Protected Value.i
      While (#True)
        If (*CharPointer)
          If (*CharPointer\c = #NUL)
            Break
          EndIf
          Value = *CharPointer\c
        Else
          If (*Read >= *End)
            Break
          EndIf
          Value = *Read\a
        EndIf
        Select (Value)
          Case 'A' To 'Z', 'a' To 'z', '0' To '9', '+', '/', '-', '_'
            If (FoundPaddingBytes > 0)
              FoundEncodedBytes = -1
              Break
            Else
              FoundEncodedBytes + 1
            EndIf
          Case '='
            FoundPaddingBytes + 1
            If (FoundPaddingBytes > 2)
              Break
            EndIf
          Case ' ', #TAB, #CR, #LF
            ; allow, but ignore, whitespace
          Case #NUL ; allow NUL where data expected?
            ;FoundEncodedBytes = -1
            ;Break
          Default ; any other invalid characters
            FoundEncodedBytes = -1
            Break
        EndSelect
        If (*CharPointer)
          *CharPointer + SizeOf(CHARACTER)
        Else
          *Read + 1
        EndIf
      Wend
      If (FoundEncodedBytes >= 0)
        Select (FoundPaddingBytes)
          Case 0, 1, 2
            If ((FoundPaddingBytes = 0) Or (((FoundEncodedBytes + FoundPaddingBytes) % 4) = 0))
              Select (FoundEncodedBytes % 4)
                Case 0 : Result = (FoundEncodedBytes / 4) * 3
                Case 2 : Result = (FoundEncodedBytes / 4) * 3 + 1
                Case 3 : Result = (FoundEncodedBytes / 4) * 3 + 2
                Default ; invalid encoded byte count
              EndSelect
            EndIf
          Default ; invalid number of padding bytes
        EndSelect
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i Base64BytesNeededToDecodeMemory(*EncodedPointer, EncodedBytes.i)
    ProcedureReturn (_Base64BytesNeededToDecode(*EncodedPointer, EncodedBytes, #Null))
  EndProcedure
  
  Procedure.i Base64BytesNeededToDecodeString(EncodedString.s)
    ProcedureReturn (_Base64BytesNeededToDecode(#Null, 0, @EncodedString))
  EndProcedure
  
  Procedure.i Base64BytesNeededToEncode(DataBytes.i, Flags.i = #Base64_DefaultFlags)
    Protected Result.i = 0
    If (DataBytes >= 0)
      Flags = MapPBDefault(Flags, #Base64_DefaultFlags)
      If (Flags & #Base64_NoPadding)
        Select (DataBytes % 3)
          Case 0 : Result = (DataBytes / 3) * 4
          Case 1 : Result = (DataBytes / 3) * 4 + 2
          Case 2 : Result = (DataBytes / 3) * 4 + 3
        EndSelect
      Else
        Result = ((DataBytes + 2) / 3) * 4
      EndIf
      If (Flags & #Base64_AppendNull)
        Result + 1
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - Base64 Encoding
  
  Procedure.i Base64EncodeMemoryToMemory(*DataPointer, DataBytes.i, *EncodedPointer, EncodedBufferBytes.i, Flags.i = #Base64_DefaultFlags)
    Protected Result.i = 0
    If (*DataPointer And (DataBytes > 0))
      If (*EncodedPointer And (EncodedBufferBytes > 0))
        Flags = MapPBDefault(Flags, #Base64_DefaultFlags)
        Protected BytesNeeded.i = Base64BytesNeededToEncode(DataBytes, Flags)
        If (BytesNeeded > 0)
          If (EncodedBufferBytes >= BytesNeeded)
            Protected *Read.ASCII  = *DataPointer
            Protected *Write.ASCII = *EncodedPointer
            
            Dim CharForValue.a(63)
            Protected i.i
            For i = 0 To 25
              CharForValue(i) = 'A' + i
            Next i
            For i = 0 To 25
              CharForValue(26 + i) = 'a' + i
            Next i
            For i = 0 To 9
              CharForValue(52 + i) = '0' + i
            Next i
            If (Flags & #Base64_URL)
              CharForValue(62) = '-'
              CharForValue(63) = '_'
            Else
              CharForValue(62) = '+'
              CharForValue(63) = '/'
            EndIf
            
            Protected Value.i
            Protected BytesLeft.i = DataBytes
            While (BytesLeft >= 3)
              Value = ((*Read\a >> 2) & $3F)
              *Write\a = CharForValue(Value) : *Write + 1
              Value = ((*Read\a << 4) & $30) : *Read + 1
              Value | ((*Read\a >> 4) & $0F)
              *Write\a = CharForValue(Value) : *Write + 1
              Value = ((*Read\a << 2) & $3C) : *Read + 1
              Value | ((*Read\a >> 6) & $03)
              *Write\a = CharForValue(Value) : *Write + 1
              Value = ((*Read\a << 0) & $3F) : *Read + 1
              *Write\a = CharForValue(Value) : *Write + 1
              BytesLeft - 3
            Wend
            If (BytesLeft = 2)
              Value = ((*Read\a >> 2) & $3F)
              *Write\a = CharForValue(Value) : *Write + 1
              Value = ((*Read\a << 4) & $30) : *Read + 1
              Value | ((*Read\a >> 4) & $0F)
              *Write\a = CharForValue(Value) : *Write + 1
              Value = ((*Read\a << 2) & $3C) : *Read + 1
              *Write\a = CharForValue(Value) : *Write + 1
              If (Not (Flags & #Base64_NoPadding))
                *Write\a = '=' : *Write + 1
              EndIf
            ElseIf (BytesLeft = 1)
              Value = ((*Read\a >> 2) & $3F)
              *Write\a = CharForValue(Value) : *Write + 1
              Value = ((*Read\a << 4) & $30) : *Read + 1
              *Write\a = CharForValue(Value) : *Write + 1
              If (Not (Flags & #Base64_NoPadding))
                *Write\a = '=' : *Write + 1
                *Write\a = '=' : *Write + 1
              EndIf
            EndIf
            If (Flags & #Base64_AppendNull)
              *Write\a = #NUL : *Write + 1
            EndIf
            Result = BytesNeeded
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i Base64EncodeMemoryToBuffer(*DataPointer, DataBytes.i, Flags.i = #Base64_DefaultFlags)
    Protected *Result = #Null
    If (*DataPointer And (DataBytes >= 0))
      Flags = MapPBDefault(Flags, #Base64_DefaultFlags)
      Protected BytesNeeded.i = Base64BytesNeededToEncode(DataBytes, Flags)
      If (BytesNeeded > 0)
        *Result = AllocateMemory(BytesNeeded, #PB_Memory_NoClear)
        If (*Result)
          If (Base64EncodeMemoryToMemory(*DataPointer, DataBytes, *Result, BytesNeeded, Flags) = BytesNeeded)
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
  
  Procedure.s Base64EncodeMemoryToString(*DataPointer, DataBytes.i, Flags.i = #Base64_DefaultFlags)
    Protected Result.s = ""
    Protected *EncodedBuffer = Base64EncodeMemoryToBuffer(*DataPointer, DataBytes, Flags)
    If (*EncodedBuffer)
      Result = PeekS(*EncodedBuffer, MemorySize(*EncodedBuffer), #PB_Ascii)
      FreeMemory(*EncodedBuffer)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i Base64EncodeStringToMemory(DataString.s, *EncodedPointer, EncodedBufferBytes.i, Flags.i = #Base64_DefaultFlags)
    Protected Result.i = #False
    If (*EncodedPointer And (EncodedBufferBytes > 0))
      Protected *DataBuffer = UTF8(DataString)
      If (*DataBuffer)
        Result = Base64EncodeMemoryToMemory(*DataBuffer, MemorySize(*DataBuffer) - 1, *EncodedPointer, EncodedBufferBytes, Flags)
        FreeMemory(*DataBuffer)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i Base64EncodeStringToBuffer(DataString.s, Flags.i = #Base64_DefaultFlags)
    Protected *Result = #Null
    Protected *DataBuffer = UTF8(DataString)
    If (*DataBuffer)
      *Result = Base64EncodeMemoryToBuffer(*DataBuffer, MemorySize(*DataBuffer) - 1, Flags)
      FreeMemory(*DataBuffer)
    EndIf
    ProcedureReturn (*Result)
  EndProcedure
  
  Procedure.s Base64EncodeStringToString(DataString.s, Flags.i = #Base64_DefaultFlags)
    Protected Result.s = ""
    Protected *DataBuffer = UTF8(DataString)
    If (*DataBuffer)
      Result = Base64EncodeMemoryToString(*DataBuffer, MemorySize(*DataBuffer) - 1, Flags)
      FreeMemory(*DataBuffer)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  CompilerIf (#True)
    
    Procedure.s Base64EncodeFileToString(File.s, Flags.i = #Base64_DefaultFlags)
      Protected Result.s = ""
      Protected *Buffer = ReadFileToBuffer(File)
      If (*Buffer)
        Result = Base64EncodeMemoryToString(*Buffer, MemorySize(*Buffer), Flags)
        FreeMemory(*Buffer)
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
  CompilerEndIf
  
  ;-
  ;- - Base64 Decoding
  
  Procedure.i _Base64EncodedStringToEncodedBuffer(EncodedString.s)
    Protected *Result = #Null
    Protected BytesNeeded.i = 0
    Protected *C.CHARACTER = @EncodedString
    While (*C\c)
      Select (*C\c)
        Case 'A' To 'Z', 'a' To 'z', '0' To '9', '+', '/', '-', '_'
          BytesNeeded + 1
        Case '='
          BytesNeeded + 1 ; include padding? parsed for validity later?
        Case ' ', #TAB, #CR, #LF
          ; ignore whitespace
        Default
          BytesNeeded = -1
          Break
      EndSelect
      *C + SizeOf(CHARACTER)
    Wend
    If (BytesNeeded > 0)
      *Result = AllocateMemory(BytesNeeded, #PB_Memory_NoClear)
      If (*Result)
        *C = @EncodedString
        Protected *Write.ASCII = *Result
        While (*C\c)
          Select (*C\c)
            Case 'A' To 'Z', 'a' To 'z', '0' To '9', '+', '/', '-', '_', '='
              *Write\a = *C\c
              *Write + 1
          EndSelect
          *C + SizeOf(CHARACTER)
        Wend
      EndIf
    EndIf
    ProcedureReturn (*Result)
  EndProcedure
  
  Procedure.i Base64DecodeMemoryToMemory(*EncodedPointer, EncodedBytes.i, *DataPointer, DataBufferBytes.i)
    Protected Result.i = 0
    If (*EncodedPointer And (EncodedBytes > 0))
      If (*DataPointer And (DataBufferBytes > 0))
        Protected DecodedBytesNeeded.i = Base64BytesNeededToDecodeMemory(*EncodedPointer, EncodedBytes)
        If (DecodedBytesNeeded > 0)
          If (DataBufferBytes >= DecodedBytesNeeded)
            Protected *Read.ASCII  = *EncodedPointer
            Protected *Write.ASCII = *DataPointer
            Protected Value.i
            Protected Index.i = 0
            Protected BytesLeftToWrite.i = DecodedBytesNeeded
            While (BytesLeftToWrite > 0)
              Select (Index)
                Case 0
                  Value = ((Base64ValueForCharacter(*Read\a) << 2) & $FC)  : *Read + 1
                  Value | ((Base64ValueForCharacter(*Read\a) >> 4) & $03)
                  Index + 1
                Case 1
                  Value = ((Base64ValueForCharacter(*Read\a) << 4) & $F0)  : *Read + 1
                  Value | ((Base64ValueForCharacter(*Read\a) >> 2) & $0F)
                  Index + 1
                Case 2
                  Value = ((Base64ValueForCharacter(*Read\a) << 6) & $C0)  : *Read + 1
                  Value | ((Base64ValueForCharacter(*Read\a) >> 0) & $3F)  : *Read + 1
                  Index = 0
              EndSelect
              *Write\a = Value
              *Write + 1
              BytesLeftToWrite - 1
            Wend
            Result = DecodedBytesNeeded
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i Base64DecodeBufferToMemory(*EncodedBuffer, *DataPointer, DataBufferBytes.i)
    ProcedureReturn (Base64DecodeMemoryToMemory(*EncodedBuffer, MemorySize(*EncodedBuffer), *DataPointer, DataBufferBytes))
  EndProcedure
  
  Procedure.i Base64DecodeStringToMemory(EncodedString.s, *DataPointer, DataBufferBytes.i)
    Protected Result.i = 0
    If (*DataPointer And (DataBufferBytes > 0))
      Protected *EncodedBuffer = _Base64EncodedStringToEncodedBuffer(EncodedString)
      If (*EncodedBuffer)
        Result = Base64DecodeBufferToMemory(*EncodedBuffer, *DataPointer, DataBufferBytes)
        FreeMemory(*EncodedBuffer)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i Base64DecodeStringToBuffer(EncodedString.s)
    Protected *Result = #Null
    Protected DataBytesNeeded.i = Base64BytesNeededToDecodeString(EncodedString)
    If (DataBytesNeeded > 0)
      *Result = AllocateMemory(DataBytesNeeded, #PB_Memory_NoClear)
      If (*Result)
        If (Base64DecodeStringToMemory(EncodedString, *Result, DataBytesNeeded) = DataBytesNeeded)
          ; OK
        Else
          FreeMemory(*Result)
          *Result = #Null
        EndIf
      EndIf
    EndIf
    ProcedureReturn (*Result)
  EndProcedure
  
  Procedure.s Base64DecodeStringToString(EncodedString.s)
    Protected Result.s = ""
    Protected *DataBuffer = Base64DecodeStringToBuffer(EncodedString)
    If (*DataBuffer)
      Result = PeekS(*DataBuffer, MemorySize(*DataBuffer), #PB_UTF8 | #PB_ByteLength)
      FreeMemory(*DataBuffer)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  CompilerIf (#True)
    
    Procedure.i Base64DecodeStringToFile(EncodedString.s, File.s)
      Protected Result.i = #False
      If (EncodedString And File)
        Protected *Buffer = Base64DecodeStringToBuffer(EncodedString)
        If (*Buffer)
          Result = CreateFileFromBuffer(File, *Buffer)
          FreeMemory(*Buffer)
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
  CompilerEndIf
  
CompilerEndIf
;-
