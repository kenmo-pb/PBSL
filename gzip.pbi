; +-----------------------------------+
; | PureBasic Standard Library - GZip |
; +-----------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_GZip_Included, #PB_Constant))
  #_PBSL_GZip_Included = #True
  
  ;- - Compile Switches
  
  ;#GZip_WriteOSByte = #True  ; if #True, GZip header will include byte indicating which OS it was compressed on
  CompilerIf (Not Defined(GZip_WriteOSByte, #PB_Constant))
    #GZip_WriteOSByte = #False
  CompilerEndIf
  
  ;#GZip_OSByteValue = $FF ; if defined, will use this OS value in written GZip headers
  
  ;-
  ;- - Dependencies
  
  UseZipPacker() ; required for DEFLATE via ZLib via "Zip"
  UseCRC32Fingerprint() ; required for GZip checksum
  
  ;-
  ;- - GZip Constants (Public)
  
  #GZip_StartOfFile =  0
  #GZip_RestOfFile  = -1
  
  ;-
  ;- - Constants (Private)
  
  #_GZip_MaximumUncompressedSize = ($7FFFFFFF - 10 - 8)
  #_GZip_MinimumCompressedSize   = (10 + 1 + 8)
  #_GZip_MinimumAllocatedBuffer  = (64)
  
  ;-
  ;- - Procedures (Private)
  
  Declare.i GZip_Compress_MemoryToMemory(*Source, SourceBytes.i, *Destination, DestinationBytes.i)
  Declare.i GZip_Compress_MemoryToBuffer(*Source, SourceBytes.i)
  
  Procedure.i _GZip_FileToMemoryOrBuffer(File.s, RangeStart.q, RangeSize.q, *Destination, DestinationBytes.i)
    Protected Result.i = 0
    
    If (File)
      Protected FN.i = ReadFile(#PB_Any, File, #PB_File_SharedRead)
      If (FN)
        Protected FileSize.q = Lof(FN)
        If (FileSize > 0)
          If (RangeStart < 0)
            RangeStart = 0
          EndIf
          If (RangeStart < FileSize)
            If (RangeSize < 0)
              RangeSize = FileSize - RangeStart
            EndIf
            If ((RangeSize > 0) And (RangeStart + RangeSize <= FileSize))
              If (RangeSize <= #_GZip_MaximumUncompressedSize)
                Protected *Buffer = AllocateMemory(RangeSize, #PB_Memory_NoClear)
                If (*Buffer)
                  FileSeek(FN, RangeStart)
                  If (ReadData(FN, *Buffer, RangeSize) = RangeSize)
                    If (*Destination)
                      Result = GZip_Compress_MemoryToMemory(*Buffer, RangeSize, *Destination, DestinationBytes)
                    Else
                      Result = GZip_Compress_MemoryToBuffer(*Buffer, RangeSize)
                    EndIf
                  EndIf
                  FreeMemory(*Buffer)
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
        CloseFile(FN)
      EndIf
    EndIf
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i _GZip_StringToMemoryOrBuffer(String.s, Format.i, IncludeNull.i, *Destination, DestinationBytes.i)
    Protected Result.i = 0
    
    If ((String <> "") Or IncludeNull)
      Select (Format)
        Case #PB_Ascii, #PB_UTF8, #PB_Unicode
          ; OK
        Case #PB_Default
          CompilerIf (#PB_Compiler_Unicode)
            Format = #PB_UTF8
          CompilerElse
            Format = #PB_Ascii
          CompilerEndIf
        Default
          Format = #PB_Ignore
      EndSelect
      If (Format <> #PB_Ignore)
        Protected *Buffer = #Null
        Protected ByteLen.i = 0
        Select (Format)
          Case (#PB_Ascii)
            ByteLen = StringByteLength(String, #PB_Ascii) + (1 * Bool(IncludeNull))
            If (ByteLen > 0)
              *Buffer = AllocateMemory(ByteLen, #PB_Memory_NoClear)
              If (*Buffer)
                PokeS(*Buffer, String, ByteLen, #PB_Ascii | (#PB_String_NoZero * Bool(Not IncludeNull)))
              EndIf
            EndIf
          Case (#PB_UTF8)
            ByteLen = StringByteLength(String, #PB_UTF8) + (1 * Bool(IncludeNull))
            If (ByteLen > 0)
              *Buffer = AllocateMemory(ByteLen, #PB_Memory_NoClear)
              If (*Buffer)
                PokeS(*Buffer, String, ByteLen, #PB_UTF8 | (#PB_String_NoZero * Bool(Not IncludeNull)))
              EndIf
            EndIf
          Case (#PB_Unicode)
            ByteLen = StringByteLength(String, #PB_Unicode) + (2 * Bool(IncludeNull))
            If (ByteLen > 0)
              *Buffer = AllocateMemory(ByteLen, #PB_Memory_NoClear)
              If (*Buffer)
                PokeS(*Buffer, String, ByteLen, #PB_Unicode | (#PB_String_NoZero * Bool(Not IncludeNull)))
              EndIf
            EndIf
        EndSelect
        If (*Buffer)
          If (*Destination)
            Result = GZip_Compress_MemoryToMemory(*Buffer, ByteLen, *Destination, DestinationBytes)
          Else
            Result = GZip_Compress_MemoryToBuffer(*Buffer, ByteLen)
          EndIf
          FreeMemory(*Buffer)
        EndIf
      EndIf
    EndIf
    
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - Procedures (Public)
  
  ;-
  ;- - GZip Information
  
  Procedure.i FileSeemsGZipped(File.s)
    Protected Result.i = #False
    If (File)
      Protected FN.i = ReadFileAny(File, #PB_File_SharedRead)
      If (FN)
        Protected Value.l = 0
        If (ReadData(FN, @Value, 3) = 3)
          If (Value = $088B1F) ; 1F 8B 08
            Result = #True
          EndIf
        EndIf
        CloseFile(FN)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_GetUncompressedSizeFromMemory(*GZip, GZipBytes.i)
    Protected Result.i = 0
    If (*GZip And (GZipBytes >= #_GZip_MinimumCompressedSize))
      Result = PeekL(*GZip + GZipBytes - 4)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_GetUncompressedSizeFromBuffer(*GZip)
    ProcedureReturn (GZip_GetUncompressedSizeFromMemory(*GZip, MemorySize(*GZip)))
  EndProcedure
  
  Procedure.i GZip_GetUncompressedCRC32FromMemory(*GZip, GZipBytes.i)
    Protected Result.i = 0
    If (*GZip And (GZipBytes >= #_GZip_MinimumCompressedSize))
      Result = PeekL(*GZip + GZipBytes - 8)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_GetUncompressedCRC32FromBuffer(*GZip)
    ProcedureReturn (GZip_GetUncompressedCRC32FromMemory(*GZip, MemorySize(*GZip)))
  EndProcedure
  
  Procedure.i GZip_GetRequiredBufferSize(*Source, SourceBytes.i)
    ; Note: This performs the entire GZip compression (to temporary buffer) to determine the required GZip size!
    Protected Result.i = 0
    Protected *Buffer = GZip_Compress_MemoryToBuffer(*Source, SourceBytes)
    If (*Buffer)
      Result = MemorySize(*Buffer)
      FreeMemory(*Buffer)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  
  
  
  
  ;-
  ;- - GZip Compress
  
  Procedure.i GZip_Compress_MemoryToMemory(*Source, SourceBytes.i, *Destination, DestinationBytes.i)
    Protected Result.i = 0
    If (*Source And (SourceBytes > 0) And (SourceBytes <= #_GZip_MaximumUncompressedSize))
      If (*Destination And (DestinationBytes >= #_GZip_MinimumCompressedSize))
        Protected ZLibBytes.i = CompressMemory(*Source, SourceBytes, (*Destination + 10) - 2, DestinationBytes - (10 - 2), #PB_PackerPlugin_Zip)
        If (ZLibBytes > 0)
          Protected GZipBytes.i = (ZLibBytes - 2 - 4) + 10 + 8
          If (DestinationBytes >= GZipBytes)
            
            ; Write GZip Header
            PokeA(*Destination + 0, $1F)
            PokeA(*Destination + 1, $8B)
            PokeA(*Destination + 2, $08)
            PokeA(*Destination + 3, $00)
            PokeL(*Destination + 4, $00000000)
            PokeA(*Destination + 8, $00)
            CompilerIf (Defined(GZip_OSByteValue, #PB_Constant))
              PokeA(*Destination + 9, #GZip_OSByteValue)
            CompilerElseIf (#GZip_WriteOSByte)
              CompilerSelect (#PB_Compiler_OS)
                CompilerCase (#PB_OS_Windows)
                  PokeA(*Destination + 9, $00)
                CompilerCase (#PB_OS_AmigaOS)
                  PokeA(*Destination + 9, $01)
                CompilerCase (#PB_OS_Linux)
                  PokeA(*Destination + 9, $03)
                CompilerCase (#PB_OS_MacOS)
                  PokeA(*Destination + 9, $07)
                CompilerDefault
                  PokeA(*Destination + 9, $FF)
              CompilerEndSelect
            CompilerElse
              PokeA(*Destination + 9, $FF)
            CompilerEndIf
            
            ; Write GZip Trailer
            PokeL(*Destination + GZipBytes - 8, Val("$" + Fingerprint(*Source, SourceBytes, #PB_Cipher_CRC32)))
            PokeL(*Destination + GZipBytes - 4, SourceBytes)
            
            Result = GZipBytes
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_Compress_MemoryToBuffer(*Source, SourceBytes.i)
    Protected *GZip = #Null
    If (*Source And (SourceBytes > 0) And (SourceBytes <= #_GZip_MaximumUncompressedSize))
      Protected BufferSize.i = (10 + SourceBytes + 8)
      If (BufferSize < #_GZip_MinimumAllocatedBuffer)
        BufferSize = #_GZip_MinimumAllocatedBuffer
      EndIf
      *GZip = AllocateMemory(BufferSize, #PB_Memory_NoClear)
      If (*GZip)
        BufferSize = GZip_Compress_MemoryToMemory(*Source, SourceBytes, *GZip, BufferSize)
        If (BufferSize > 0)
          Protected *NewPtr = ReAllocateMemory(*GZip, BufferSize, #PB_Memory_NoClear)
          If (*NewPtr)
            If (*NewPtr = *GZip)
              ; OK
            Else
              FreeMemory(*NewPtr)
              ;FreeMemory(*GZip)
              *GZip = #Null
            EndIf
          Else
            FreeMemory(*GZip)
            *GZip = #Null
          EndIf
        Else
          FreeMemory(*GZip)
          *GZip = #Null
        EndIf
      EndIf
    EndIf
    ProcedureReturn (*GZip)
  EndProcedure
  
  Procedure.i GZip_Compress_BufferToBuffer(*Source)
    ProcedureReturn (GZip_Compress_MemoryToBuffer(*Source, MemorySize(*Source)))
  EndProcedure
  
  Procedure.i GZip_Compress_BufferToMemory(*Source, *Destination, DestinationBytes.i)
    ProcedureReturn (GZip_Compress_MemoryToMemory(*Source, MemorySize(*Source), *Destination, DestinationBytes))
  EndProcedure
  
  Procedure.i GZip_Compress_StringToMemory(String.s, *Destination, DestinationBytes.i, Format.i = #PB_Default, IncludeNull.i = #False)
    Protected Result.i = 0
    If (*Destination And (DestinationBytes >= #_GZip_MinimumCompressedSize))
      Result = _GZip_StringToMemoryOrBuffer(String, Format, IncludeNull, *Destination, DestinationBytes)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_Compress_StringToBuffer(String.s, Format.i = #PB_Default, IncludeNull.i = #False)
    ProcedureReturn (_GZip_StringToMemoryOrBuffer(String, Format, IncludeNull, #Null, 0))
  EndProcedure
  
  Procedure.i GZip_Compress_FileToMemory(File.s, *Destination, DestinationBytes.i, RangeStart.q = #GZip_StartOfFile, RangeSize.q = #GZip_RestOfFile)
    Protected Result.i = 0
    If (*Destination And (DestinationBytes >= #_GZip_MinimumCompressedSize))
      Result = _GZip_FileToMemoryOrBuffer(File, RangeStart, RangeSize, *Destination, DestinationBytes)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_Compress_FileToBuffer(File.s, RangeStart.q = #GZip_StartOfFile, RangeSize.q = #GZip_RestOfFile)
    ProcedureReturn (_GZip_FileToMemoryOrBuffer(File, RangeStart, RangeSize, #Null, 0))
  EndProcedure
  
  Procedure.i GZip_Compress_FileToFile(SourceFile.s, GZipFile.s, RangeStart.q = #GZip_StartOfFile, RangeSize.q = #GZip_RestOfFile)
    Protected Result.i = #False
    If (SourceFile And GZipFile)
      Protected *Buffer = GZip_Compress_FileToBuffer(SourceFile, RangeStart, RangeSize)
      If (*Buffer)
        Result = CreateFileFromBuffer(GZipFile, *Buffer)
        FreeMemory(*Buffer)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_Compress_MemoryToFile(*Source, SourceBytes.i, File.s)
    Protected Result.i = #False
    If (File)
      Protected *Buffer = GZip_Compress_MemoryToBuffer(*Source, SourceBytes)
      If (*Buffer)
        Result = CreateFileFromBuffer(File, *Buffer)
        FreeMemory(*Buffer)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_Compress_BufferToFile(*GZip, File.s)
    Protected Result.i = #False
    If (*GZip)
      Result = GZip_Compress_MemoryToFile(*GZip, MemorySize(*GZip), File)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_Compress_StringToFile(String.s, File.s, Format.i = #PB_Default, IncludeNull.i = #False)
    Protected Result.i = #False
    If (File)
      Protected *Buffer = GZip_Compress_StringToBuffer(String, Format, IncludeNull)
      If (*Buffer)
        Result = CreateFileFromBuffer(File, *Buffer)
        FreeMemory(*Buffer)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  
  
  
  
  ;-
  ;- - GZip Decompress
  
  Procedure.i GZip_Decompress_MemoryToMemory(*GZip, GZipBytes.i, *Destination, DestinationBytes.i)
    Protected Result.i = 0
    If (*GZip And (GZipBytes >= #_GZip_MinimumCompressedSize))
      Protected UncompressedSize.i = GZip_GetUncompressedSizeFromMemory(*GZip, GZipBytes)
      If (*Destination And (DestinationBytes >= UncompressedSize))
        Protected SavedWord.w = PeekW((*GZip + 10) - 2)
        
        ; Form a temporary ZLib compression header
        PokeA((*GZip + 10) - 2, $78)
        PokeA((*GZip + 10) - 1, $9C) ; 01 = None, 5E = Fast, 9C = Default, DA = Best
        
        ; UncompressMemory() will claim it failed, because ZLib's Adler32 checksum won't match GZip's CRC32 checksum...
        UncompressMemory((*GZip + 10) - 2, (GZipBytes - 10 - 8) + (2 + 4), *Destination, DestinationBytes)
        Protected CalcCRC.l = Val("$" + Fingerprint(*Destination, UncompressedSize, #PB_Cipher_CRC32))
        If (CalcCRC = PeekL(*GZip + GZipBytes - 8))
          ; OK - actual CRC32 of new data matches GZip's saved CRC32
          Result = UncompressedSize
        EndIf
        
        PokeW((*GZip + 10) - 2, SavedWord)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_Decompress_MemoryToBuffer(*GZip, GZipBytes.i)
    Protected *Uncompressed = #Null
    If (*GZip And (GZipBytes >= #_GZip_MinimumCompressedSize))
      Protected UncompressedSize.i = GZip_GetUncompressedSizeFromMemory(*GZip, GZipBytes)
      If ((UncompressedSize > 0) And (UncompressedSize <= #_GZip_MaximumUncompressedSize))
        *Uncompressed = AllocateMemory(UncompressedSize, #PB_Memory_NoClear)
        If (*Uncompressed)
          If (GZip_Decompress_MemoryToMemory(*GZip, GZipBytes, *Uncompressed, UncompressedSize) = UncompressedSize)
            ; OK
          Else
            FreeMemory(*Uncompressed)
            *Uncompressed = #Null
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (*Uncompressed)
  EndProcedure
  
  Procedure.i GZip_Decompress_BufferToBuffer(*GZip)
    ProcedureReturn (GZip_Decompress_MemoryToBuffer(*GZip, MemorySize(*GZip)))
  EndProcedure
  
  Procedure.i GZip_Decompress_BufferToMemory(*GZip, *Destination, DestinationBytes.i)
    ProcedureReturn (GZip_Decompress_MemoryToMemory(*GZip, MemorySize(*GZip), *Destination, DestinationBytes))
  EndProcedure
  
  Procedure.s GZip_Decompress_MemoryToString(*GZip, GZipBytes.i, Format.i = #PB_Default)
    Protected Result.s = ""
    Select (Format)
      Case #PB_Ascii, #PB_UTF8, #PB_Unicode
        ; OK
      Case #PB_Default
        CompilerIf (#PB_Compiler_Unicode)
          Format = #PB_UTF8
        CompilerElse
          Format = #PB_Ascii
        CompilerEndIf
      Default
        Format = #PB_Ignore
    EndSelect
    If (Format <> #PB_Ignore)
      Protected *Uncompressed = GZip_Decompress_MemoryToBuffer(*GZip, GZipBytes)
      If (*Uncompressed)
        Select (Format)
          Case #PB_Ascii
            Result = PeekS(*Uncompressed, MemorySize(*Uncompressed), #PB_Ascii)
          Case #PB_UTF8
            Result = PeekS(*Uncompressed, MemorySize(*Uncompressed), #PB_UTF8 | #PB_ByteLength)
          Case #PB_Unicode
            Result = PeekS(*Uncompressed, MemorySize(*Uncompressed) / 2, #PB_Unicode)
        EndSelect
        FreeMemory(*Uncompressed)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s GZip_Decompress_BufferToString(*GZip, Format.i = #PB_Default)
    ProcedureReturn (GZip_Decompress_MemoryToString(*GZip, MemorySize(*GZip), Format))
  EndProcedure
  
  Procedure.i GZip_Decompress_MemoryToFile(*GZip, GZipBytes.i, File.s)
    Protected Result.i = #False
    If (*GZip And (GZipBytes >= #_GZip_MinimumCompressedSize) And File)
      Protected *Buffer = GZip_Decompress_MemoryToBuffer(*GZip, GZipBytes)
      If (*Buffer)
        Result = CreateFileFromBuffer(File, *Buffer)
        FreeMemory(*Buffer)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_Decompress_BufferToFile(*GZip, File.s)
    ProcedureReturn (GZip_Decompress_MemoryToFile(*GZip, MemorySize(*GZip), File))
  EndProcedure
  
  Procedure.i GZip_Decompress_FileToMemory(GZipFile.s, *Destination, DestinationBytes.i)
    Protected Result.i = 0
    If (GZipFile And *Destination And (DestinationBytes > 0))
      Protected *GZip = ReadFileToBuffer(GZipFile)
      If (*GZip)
        Result = GZip_Decompress_BufferToMemory(*GZip, *Destination, DestinationBytes)
        FreeMemory(*GZip)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GZip_Decompress_FileToBuffer(GZipFile.s)
    Protected *Buffer = #Null
    Protected *GZip = ReadFileToBuffer(GZipFile)
    If (*GZip)
      *Buffer = GZip_Decompress_BufferToBuffer(*GZip)
      FreeMemory(*GZip)
    EndIf
    ProcedureReturn (*Buffer)
  EndProcedure
  
  Procedure.i GZip_Decompress_FileToFile(GZipFile.s, DestinationFile.s)
    Protected Result.i = #False
    If (DestinationFile)
      Protected *GZip = ReadFileToBuffer(GZipFile)
      If (*GZip)
        Result = GZip_Decompress_BufferToFile(*GZip, DestinationFile)
        FreeMemory(*GZip)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s GZip_Decompress_FileToString(GZipFile.s, Format.i = #PB_Default)
    Protected Result.s = ""
    Protected *GZip = ReadFileToBuffer(GZipFile)
    If (*GZip)
      Result = GZip_Decompress_BufferToString(*GZip, Format)
      FreeMemory(*GZip)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
