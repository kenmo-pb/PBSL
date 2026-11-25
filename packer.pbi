; +-------------------------------------+
; | PureBasic Standard Library - Packer |
; +-------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Packer_Included, #PB_Constant))
  #_PBSL_Packer_Included = #True
  
  ;- - Packer Constants
  
  #PackerPlugin_Default = #PB_Default
  #PackerPlugin_Invalid = #Null
  
  #PackerLevel_Minimum = 0
  #PackerLevel_Maximum = 9
  #PackerLevel_Default = #PackerLevel_Maximum
  
  ;-
  ;- - Packer Procedures
  
  Procedure.i PackerPluginIDByExtension(FileOrExtension.s, DefaultResult.i = #PackerPlugin_Invalid)
    Protected Result.i = DefaultResult
    If (GetExtensionPart(FileOrExtension))
      FileOrExtension = GetExtensionPart(FileOrExtension)
    EndIf
    Select (LCase(FileOrExtension))
      Case "zip"
        Result = #PB_PackerPlugin_Zip
      Case "tar"
        Result = #PB_PackerPlugin_Tar
      Case "gz", "taz", "tgz"
        CompilerIf (Defined(PB_Packer_Gzip, #PB_Constant))
          Result = #PB_PackerPlugin_Tar | #PB_Packer_Gzip
        CompilerEndIf
      Case "bz2", "tb2", "tbz", "tbz2", "tz2"
        CompilerIf (Defined(PB_Packer_Bzip2, #PB_Constant))
          Result = #PB_PackerPlugin_Tar | #PB_Packer_Bzip2
        CompilerEndIf
    EndSelect
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i _CreatePackFromFolder(Pack.i, Folder.s, Prefix.s)
    Protected Result.i = #False
    Protected DN.i = ExamineDirectory(#PB_Any, Folder, "")
    If (DN)
      Result = #True
      If (#True)
        AddPackDirectory(Pack, Prefix)
      EndIf
      While (NextDirectoryEntry(DN))
        Protected Name.s = DirectoryEntryName(DN)
        If (DirectoryEntryType(DN) = #PB_DirectoryEntry_Directory)
          If ((Name <> ".") And (Name <> ".."))
            Result = _CreatePackFromFolder(Pack, Folder + Name + #PS$, Prefix + Name + "/")
          EndIf
        Else ; File
          If (AddPackFile(Pack, Folder + Name, Prefix + Name))
            ; OK
          Else
            Result = #False
          EndIf
        EndIf
        If ((Not Result) And (#True)) ; fail out if ANY file could not be added?
          Break
        EndIf
      Wend
      FinishDirectory(DN)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CreatePackFromFolder(PackFile.s, Folder.s, PluginID.i = #PackerPlugin_Default, Level.i = #PackerLevel_Default)
    Protected Result.i = #False
    If (PackFile And Folder)
      Folder = EnsurePathSeparator(Folder)
      If (FileSize(Folder) = -2)
        If (PluginID = #PackerPlugin_Default)
          PluginID = PackerPluginIDByExtension(PackFile, #PB_PackerPlugin_Zip)
        EndIf
        If (PluginID <> #PackerPlugin_Invalid)
          Level = MapPBDefault(Level, #PackerLevel_Default)
          Protected Pack.i = CreatePack(#PB_Any, PackFile, PluginID, Level)
          If (Pack)
            Protected TopLevelName.s = GetTopDirectoryName(Folder)
            Result = _CreatePackFromFolder(Pack, Folder, TopLevelName + "/")
            ClosePack(Pack)
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CreatePackFromFile(PackFile.s, File.s, PluginID.i = #PackerPlugin_Default, Level.i = #PackerLevel_Default)
    Protected Result.i = #False
    If (PackFile And File)
      If (FileSize(File) >= 0)
        If (PluginID = #PackerPlugin_Default)
          PluginID = PackerPluginIDByExtension(PackFile, #PB_PackerPlugin_Zip)
        EndIf
        If (PluginID <> #PackerPlugin_Invalid)
          Level = MapPBDefault(Level, #PackerLevel_Default)
          Protected Pack.i = CreatePack(#PB_Any, PackFile, PluginID, Level)
          If (Pack)
            If (AddPackFile(Pack, File, GetFilePart(File)))
              Result = #True
            EndIf
            ClosePack(Pack)
            If (Not Result)
              DeleteFile(PackFile)
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CreatePackFromApp(PackFile.s, AppPath.s, PluginID.i = #PackerPlugin_Default, Level.i = #PackerLevel_Default)
    Protected Result.i = #False
    If (PackFile And AppPath)
      Select (FileSize(AppPath))
        Case #PB_FileSize_Directory
          Result = CreatePackFromFolder(PackFile, AppPath, PluginID, Level)
        Case #PB_FileSize_Missing
          ;
        Default
          Result = CreatePackFromFile(PackFile, AppPath, PluginID, Level)
      EndSelect
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i OpenPackMultiPlugin(Pack.i, File.s, PluginID.i = #PackerPlugin_Default)
    Protected Result.i = #Null
    If (PluginID = #PackerPlugin_Default)
      CompilerIf (Defined(PB_PackerPlugin_Zip, #PB_Constant))
        If (Not Result)
          Result = OpenPack(Pack, File, #PB_PackerPlugin_Zip)
        EndIf
      CompilerEndIf
      CompilerIf (Defined(PB_PackerPlugin_Tar, #PB_Constant))
        If (Not Result)
          Result = OpenPack(Pack, File, #PB_PackerPlugin_Tar)
        EndIf
      CompilerEndIf
      CompilerIf (Defined(PB_PackerPlugin_BriefLZ, #PB_Constant))
        If (Not Result)
          Result = OpenPack(Pack, File, #PB_PackerPlugin_BriefLZ)
        EndIf
      CompilerEndIf
      CompilerIf (Defined(PB_PackerPlugin_Lzma, #PB_Constant))
        If (Not Result)
          Result = OpenPack(Pack, File, #PB_PackerPlugin_Lzma)
        EndIf
      CompilerEndIf
    Else
      Result = OpenPack(Pack, File, PluginID)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  CompilerIf (#True)
    
    ;-
    ;- - TAR Constants
    
    #TAR_Attr_Error = -1
    
    #TAR_FileType_Normal       = 0
    #TAR_FileType_HardLink     = 1
    #TAR_FileType_SymbolicLink = 2
    
    ; UStar Extended Types
    
    #TAR_FileType_Directory = 5
    
    ;- - TAR Structures
    
    CompilerIf (Not Defined(TAR_FileHeader, #PB_Structure))
      Structure TAR_FileHeader
        FileName.a[100] ; ASCII
        FileMode.a[8] ; octal
        OwnerID.a[8] ; octal
        GroupID.a[8] ; octal
        FileSize.a[12] ; octal
        Modified.a[12] ; octal
        Checksum.a[8]
        FileType.a
        LinkName.a[100] ; ASCII
        ;
        CompilerIf (#True) ; UStar extended header
          UStarTag.a[6] ; "ustar" in ASCII
          UStarVersion.u
          OwnerName.a[32]
          OwnerGroupName.a[32]
          DeviceMajorNum.a[8]
          DeviceMinorNum.a[8]
          FilenamePrefix.a[155]
          ;
          _Padding.a[12]
        CompilerElse
          _Padding.a[255]
        CompilerEndIf
      EndStructure
    CompilerEndIf
    
    ;- - TAR Procedures
    
    Procedure.l FormatTARAttributesForOS(Attributes.l, OS.i = #PB_Default)
      If (Attributes <> #TAR_Attr_Error)
        OS = MapPBDefault(OS, #PB_Compiler_OS)
        Select (OS)
          Case #PB_OS_Windows
            Attributes = 0 ; TAR doesn't store DOS/Windows file attributes
          Case #PB_Ignore
            ; leave as-is
          Default ; Mac/Linux/Unix
            Attributes = Attributes & $01FF
        EndSelect
      EndIf
      ProcedureReturn (Attributes)
    EndProcedure
    
    Procedure.i ReadTARAttributesToMap(TARFile.s, Map Attributes.l(), OS.i = #PB_Default)
      Protected Result.i = #False
      ; https://en.wikipedia.org/wiki/Tar_(computing)
      OS = MapPBDefault(OS, #PB_Compiler_OS)
      ClearMap(Attributes())
      If (TARFile)
        Protected FN.i = ReadFile(#PB_Any, TARFile, #PB_File_SharedRead)
        If (FN)
          If (Lof(FN) >= SizeOf(TAR_FileHeader))
            Protected Header.TAR_FileHeader
            Result = #True
            While (Not Eof(FN))
              If (ReadData(FN, @Header, SizeOf(TAR_FileHeader)) = SizeOf(TAR_FileHeader))
                Protected FileName.s = Trim(PeekS_Ascii(@Header\FileName[0], 100))
                If (FileName)
                  Protected FileSize.q = ValOctal(Trim(PeekS_Ascii(@Header\FileSize[0], 12)))
                  If (FileSize >= 0)
                    Protected Attr.l = ValOctal(Trim(PeekS_Ascii(@Header\FileMode[0], 8)))
                    CompilerIf (#True)
                      Select (OS)
                        Case #PB_Ignore
                          Attributes(FileName) = Attr
                        Case #PB_OS_Windows
                          Attributes(FileName) = 0
                        Default ; Unix
                          Attributes(FileName) = Attr & $01FF
                      EndSelect
                    CompilerElse
                      Attr = FormatTARAttributesForOS(Attr, OS)
                    CompilerEndIf
                    FileSize = ((FileSize + 511) / 512) * 512 ; pad out to 512-byte blocks
                    FileSkip(FN, FileSize)
                  Else
                    Result = #False
                    Break
                  EndIf
                Else
                  ;Result = #False
                  Break
                EndIf
              Else
                Result = #False
                Break
              EndIf
            Wend
          EndIf
          CloseFile(FN)
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf (#True)
    
    ;-
    ;- - ZIP Constants
    
    #ZIP_Attr_Error = -1 ; Don't use 0, because that could be valid File Attributes
    
    ; ZIP File Format 'Magic Numbers'
    #ZIP_CDFH_Magic = $02014B50
    #ZIP_LFH_Magic  = $04034B50
    #ZIP_EOCD_Magic = $06054B50
    
    ; ZIP File Creator OS
    #ZIP_OS_Windows = $00
    #ZIP_OS_Amiga   = $01
    #ZIP_OS_Unix    = $03
    #ZIP_OS_Mac     = $07 ; Rarely used? Check for 'Unix' usually
    
    ; DOS Attribute Bits in ZIP File 'External Attributes'
    #ZIP_DOSAttr_ReadOnly  = %000001 ; = #PB_FileSystem_ReadOnly
    #ZIP_DOSAttr_Hidden    = %000010 ; = #PB_FileSystem_Hidden
    #ZIP_DOSAttr_System    = %000100 ; = #PB_FileSystem_System
    #ZIP_DOSAttr_Volume    = %001000
    #ZIP_DOSAttr_Directory = %010000
    #ZIP_DOSAttr_Archive   = %100000 ; = #PB_FileSystem_Archive
    
    #ZIP_UnixAttributes_Default = #PB_FileSystem_ReadUser | #PB_FileSystem_WriteUser | #PB_FileSystem_ReadGroup | #PB_FileSystem_WriteGroup | #PB_FileSystem_ReadAll
    #ZIP_UnixAttributes_Minimum = #PB_FileSystem_ReadUser | #PB_FileSystem_WriteUser
    
    ; Unix File Type Bits in ZIP File 'External Attributes'
    #ZIP_UnixType_Mask      = $F0000000
    #ZIP_UnixType_Directory = $40000000
    #ZIP_UnixType_File      = $80000000
    
    ;- - ZIP Structures
    
    CompilerIf (Not Defined(ZIP_EOCD, #PB_Structure))
      Structure ZIP_EOCD ; ZIP 'End Of Central Directory'
        MagicNumber.l
        ThisDiskNumber.u
        StartDiskNumber.u
        NumRecords.u
        NumRecordsAllDisks.u
        SizeOfCentralDirectory.l
        OffsetOfCentralDirectory.l
        CommentLength.u
      EndStructure
    CompilerEndIf
    
    CompilerIf (Not Defined(ZIP_CDFH, #PB_Structure))
      Structure ZIP_CDFH ; ZIP 'Central Directory File Header'
        MagicNumber.l
        CreatorVersionLowerByte.a
        CreatorOS.a;CreatorVersionUpper.a
        MinExtractVersion.u
        GeneralPurposeBits.u
        CompressionMethod.u
        ModificationTime.u
        ModificationDate.u
        CRC32.l
        CompressedSize.l
        UncompressedSize.l
        NameLength.u
        ExtraFieldLength.u
        CommentLength.u
        StartDisk.u
        InternalAttributes.u
        ExternalAttributes.l
        OffsetOfLocalFile.l
      EndStructure
    CompilerEndIf
    
    ;- - ZIP Procedures
    
    Procedure.l FormatZIPAttributesForOS(Attributes.l, OS.i = #PB_Default)
      If (Attributes <> #ZIP_Attr_Error)
        OS = MapPBDefault(OS, #PB_Compiler_OS)
        Select (OS)
          Case #PB_OS_Windows
            Attributes & (#ZIP_DOSAttr_ReadOnly | #ZIP_DOSAttr_Hidden | #ZIP_DOSAttr_System) ; do not preserve #ZIP_DOSAttr_Archive
          Case #PB_Ignore
            ; leave as-is
          Default ; Mac/Linux/Unix
            Attributes = (Attributes >> 16) & $01FF ; (9) Read/Write/Execute Bits
        EndSelect
      EndIf
      ProcedureReturn (Attributes)
    EndProcedure
    
    Procedure.i ReadZIPAttributesToMap(ZIPFile.s, Map Attributes.l(), OS.i = #PB_Default)
      Protected Result.i = #False
      ; https://en.wikipedia.org/wiki/ZIP_(file_format)
      ; https://unix.stackexchange.com/questions/14705/the-zip-formats-external-file-attribute
      ; https://lukebemish.dev/2026/01/29/zip-files.html
      ClearMap(Attributes())
      If (ZIPFile)
        Protected FN.i = ReadFile(#PB_Any, ZIPFile, #PB_File_SharedRead)
        If (FN)
          If (Lof(FN) >= SizeOf(ZIP_EOCD))
            Protected EOCD.ZIP_EOCD
            FileSeek(FN, Lof(FN) - SizeOf(ZIP_EOCD))
            If (ReadData(FN, @EOCD, SizeOf(ZIP_EOCD)) = SizeOf(ZIP_EOCD))
              If (EOCD\MagicNumber = #ZIP_EOCD_Magic)
                If (EOCD\CommentLength = $0000)
                  If (EOCD\NumRecords > 0)
                    If ((EOCD\OffsetOfCentralDirectory > 0) And (EOCD\OffsetOfCentralDirectory < Lof(FN)))
                      Result = #True
                      FileSeek(FN, EOCD\OffsetOfCentralDirectory)
                      Protected CDFH.ZIP_CDFH
                      Protected i.i
                      While (i < EOCD\NumRecords)
                        If (ReadData(FN, @CDFH, SizeOf(ZIP_CDFH)) = SizeOf(ZIP_CDFH))
                          If (CDFH\MagicNumber = #ZIP_CDFH_Magic)
                            If (CDFH\NameLength > 0)
                              Protected Name.s = ReadString(FN, #PB_Ascii, CDFH\NameLength) ; TODO Should handle Unicode extensions
                              If (Name)
                                If (OS <> #PB_Ignore)
                                  Attributes(Name) = FormatZIPAttributesForOS(CDFH\ExternalAttributes, OS)
                                Else
                                  Attributes(Name) = CDFH\ExternalAttributes
                                EndIf
                              EndIf
                              FileSkip(FN, CDFH\ExtraFieldLength)
                              FileSkip(FN, CDFH\CommentLength)
                            Else
                              Result = #False
                              Break
                            EndIf
                          Else
                            Result = #False
                            Break
                          EndIf
                        Else
                          Result = #False
                          Break
                        EndIf
                        i + 1
                      Wend
                    EndIf
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
    
  CompilerEndIf
  
  CompilerIf (#True)
    
    ;-
    ;- - Archive Structures
    
    Prototype ExtractArchiveProgressCallback(ItemsComplete.i, TotalItems.i)
    
    Structure ArchiveEntry
      Name.s
      Size.q
      Modified.i
    EndStructure
    
    Structure Archive
      Pack.i
      File.s
      TempFile.s
      Examined.i
      OSForAttributes.i
      ExtractMS.q
      
      NumFiles.i
      NumFolders.i
      TopLevelFiles.i
      TopLevelFolders.i
      TopLevelItems.i
      TopLevelFileName.s
      TopLevelFolderName.s
      
      FilesExtracted.i
      FilesSkipped.i
      FileErrors.i
      FoldersExtracted.i
      FoldersSkipped.i
      FolderErrors.i
      ItemsExtracted.i
      ItemsSkipped.i
      ItemErrors.i
      
      ProgressCallback.ExtractArchiveProgressCallback ; see Prototype above
      
      ; Boolean Options
      DeduplicateTopFolder.i
      Overwrite.i
      PreserveModifiedDate.i
      PreserveFileAttributes.i
      
      List Entry.ArchiveEntry()
      Map  Attributes.l()
    EndStructure
    
    ;- - Archive Procedures
    
    Declare.i ExamineArchive(*Archive.Archive)
    
    Procedure.i ReadArchiveAttributesToMap(ArchiveFile.s, Map Attributes.l(), OS.i = #PB_Default)
      Protected Result.i = #False
      If (ArchiveFile)
        CompilerIf (Defined(ReadZIPAttributesToMap, #PB_Procedure))
          If (Not Result)
            Result = ReadZIPAttributesToMap(ArchiveFile, Attributes(), OS)
          EndIf
        CompilerEndIf
        CompilerIf (Defined(ReadTARAttributesToMap, #PB_Procedure))
          If (Not Result)
            Result = ReadTARAttributesToMap(ArchiveFile, Attributes(), OS)
          EndIf
        CompilerEndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i _EnsureArchiveExamined(*Archive.Archive)
      Protected Result.i = #False
      If (*Archive\Examined)
        Result = #True
      Else
        Result = ExamineArchive(*Archive)
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i _ExtractArchiveCurrentFile(*Archive.Archive, DestPath.s)
      Protected Result.i = #False
      
      ; Originally all within bulk ExtractArchive() ...
      Protected DestSize.q = FileSize(DestPath)
      If (DestSize = #PB_FileSize_Directory)
        *Archive\FileErrors + 1
      ElseIf (*Archive\Overwrite Or (FileSize(DestPath) = #PB_FileSize_Missing))
        If (UncompressPackFile(*Archive\Pack, DestPath, *Archive\Entry()\Name))
          If (FileSize(DestPath) = *Archive\Entry()\Size)
            
            If (*Archive\PreserveModifiedDate)
              SetModifiedDate(DestPath, *Archive\Entry()\Modified)
            ElseIf (#True)
              SetModifiedDate(DestPath, Date())
            EndIf
            
            If (*Archive\PreserveFileAttributes)
              If (FindMapElement(*Archive\Attributes(), *Archive\Entry()\Name))
                If (*Archive\Attributes() <> #ZIP_Attr_Error)
                  Protected Attr.i = *Archive\Attributes()
                  CompilerIf (#IsUnixBuild)
                    If (Attr = 0)
                      Attr = #ZIP_UnixAttributes_Default
                    EndIf
                    Attr | #ZIP_UnixAttributes_Minimum
                  CompilerEndIf
                  SetFileAttributes(DestPath, Attr)
                EndIf
              EndIf
            EndIf
            
            *Archive\FilesExtracted + 1
            Result = #True
          Else
            *Archive\FileErrors + 1
          EndIf
        Else
          *Archive\FileErrors + 1
        EndIf
      Else
        *Archive\FilesSkipped + 1
      EndIf
      
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i _SelectArchiveFile(*Archive.Archive, InternalFile.s)
      Protected Result.i = #False
      ForEach (*Archive\Entry())
        If (*Archive\Entry()\Name = InternalFile)
          Result = #True
          Break
        EndIf
      Next
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i ExtractArchiveFile(*Archive.Archive, InternalFile.s, Destination.s = "", CreateDir.i = #False)
      Protected Result.i = #False
      If (*Archive And InternalFile)
        *Archive\ExtractMS = ElapsedMilliseconds()
        _EnsureArchiveExamined(*Archive)
        If (_SelectArchiveFile(*Archive, InternalFile))
          If (Destination = "")
            Destination = GetCurrentDirectory()
          EndIf
          Protected DestPath.s
          If (EndsWith(Destination, "/") Or (#IsWindowsBuild And EndsWith(Destination, "\")))
            DestPath = Destination + GetFilePart(InternalFile)
          ElseIf (FolderExists(Destination))
            DestPath = Destination + #PS$ + GetFilePart(InternalFile)
          Else
            DestPath = Destination ; already a file
          EndIf
          
          If ((Not CreateDir) Or CreateDirectoryRecursive(GetPathPart(DestPath)))
            Result = _ExtractArchiveCurrentFile(*Archive, DestPath)
          Else
            *Archive\FileErrors + 1
          EndIf
          
        EndIf
        If (Result)
          *Archive\ExtractMS = ElapsedMilliseconds() - *Archive\ExtractMS
        Else
          *Archive\ExtractMS = 0
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i ExtractArchive(*Archive.Archive, Destination.s)
      Protected Result.i = #False
      If (*Archive And Destination)
        Destination = EnsurePathSeparator(Destination)
        
        *Archive\ExtractMS = ElapsedMilliseconds()
        _EnsureArchiveExamined(*Archive)
        
        If (CreateDirectoryRecursive(Destination))
          
          Protected SkipChars.i = 0
          If (*Archive\DeduplicateTopFolder)
            If ((*Archive\TopLevelFolders = 1) And (*Archive\TopLevelFiles = 0))
              If (GetTopDirectoryName(Destination) + "/" = *Archive\TopLevelFolderName)
                SkipChars = Len(*Archive\TopLevelFolderName)
              EndIf
            EndIf
          EndIf
          
          *Archive\FilesExtracted   = 0
          *Archive\FilesSkipped     = 0
          *Archive\FileErrors       = 0
          *Archive\FoldersExtracted = 0
          *Archive\FoldersSkipped   = 0
          *Archive\FolderErrors     = 0
          
          Protected DestPath.s
          Protected DestSize.q
          
          ForEach *Archive\Entry()
            If (*Archive\Entry()\Size = #PB_FileSize_Directory)
              DestPath = *Archive\Entry()\Name
              If (SkipChars)
                DestPath = Mid(DestPath, 1 + SkipChars)
              EndIf
              DestPath = Destination + DestPath
              DestSize = FileSize(DestPath)
              If (DestSize = #PB_FileSize_Directory)
                *Archive\FoldersSkipped + 1
              ElseIf (DestSize >= 0)
                *Archive\FolderErrors + 1
              ElseIf (CreateDirectoryRecursive(DestPath))
                ;If (*Archive\PreserveModifiedDate) ; doesn't apply to folders?
                ;  SetModifiedDate(DestPath, *Archive\Entry()\Modified)
                ;EndIf
                If (*Archive\PreserveFileAttributes)
                  If (FindMapElement(*Archive\Attributes(), *Archive\Entry()\Name))
                    If (*Archive\Attributes() <> #ZIP_Attr_Error)
                      SetFileAttributes(DestPath, *Archive\Attributes())
                    EndIf
                  EndIf
                EndIf
                *Archive\FoldersExtracted + 1
              Else
                *Archive\FolderErrors + 1
              EndIf
            EndIf
          Next
          
          ForEach *Archive\Entry()
            If (*Archive\Entry()\Size >= 0)
              DestPath = *Archive\Entry()\Name
              If (SkipChars)
                DestPath = Mid(DestPath, 1 + SkipChars)
              EndIf
              DestPath = Destination + DestPath
              _ExtractArchiveCurrentFile(*Archive, DestPath)
              If (*Archive\ProgressCallback)
                *Archive\ProgressCallback(*Archive\FilesExtracted + *Archive\FilesSkipped + *Archive\FileErrors, *Archive\NumFiles)
              EndIf
            EndIf
          Next
          
          If (*Archive\ProgressCallback)
            If (*Archive\NumFiles = 0)
              *Archive\ProgressCallback(1, 1)
            EndIf
          EndIf
          
          *Archive\ItemsExtracted = *Archive\FilesExtracted + *Archive\FoldersExtracted
          *Archive\ItemsSkipped   = *Archive\FilesSkipped + *Archive\FoldersSkipped
          *Archive\ItemErrors     = *Archive\FileErrors + *Archive\FolderErrors
          If (*Archive\ItemsExtracted + *Archive\ItemsSkipped > 0);If (*Archive\ItemsExtracted > 0)
            If (*Archive\ItemErrors = 0);(#True)
              Result = #True
            EndIf
          EndIf
          
        EndIf
        
        If (Result)
          *Archive\ExtractMS = ElapsedMilliseconds() - *Archive\ExtractMS
        Else
          *Archive\ExtractMS = 0
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i ExamineArchive(*Archive.Archive)
      Protected Result.i = #False
      If (*Archive And *Archive\Pack)
        If (ExaminePack(*Archive\Pack))
          ClearList(*Archive\Entry())
          Protected *Entry.ArchiveEntry
          NewMap FoundFolder.s()
          Protected Name.s
          While (NextPackEntry(*Archive\Pack))
            Name = PackEntryName(*Archive\Pack)
            CompilerIf (#False)
              ReplaceStringInPlace(Name, "\", "/")
            CompilerEndIf
            If (PackEntryType(*Archive\Pack) = #PB_Packer_Directory)
              Name = EnsureForwardSlash(Name)
              Name + "./" ; just so it gets added in the 'Add Parent Folders' loop below
            Else
              Name = RemovePathSeparator(Name)
              *Entry = AddElement(*Archive\Entry())
              *Entry\Name = Name
              *Entry\Size = PackEntrySize(*Archive\Pack, #PB_Packer_UncompressedSize)
              *Entry\Modified = PackEntryDate(*Archive\Pack, #PB_Date_Modified)
            EndIf
            While (#True)
              Name = GetParentDirectory(Name)
              If (Name = "")
                Break
              ElseIf (Not FindMapElement(FoundFolder(), Name))
                AddMapElement(FoundFolder(), Name)
                *Entry = AddElement(*Archive\Entry())
                *Entry\Name = Name
                *Entry\Size = #PB_FileSize_Directory
                *Entry\Modified = PackEntryDate(*Archive\Pack, #PB_Date_Modified)
              EndIf
            Wend
          Wend
          If (#False) ; May be faster to extract archive if in-archive order is maintained?
            SortStructuredList(*Archive\Entry(), #PB_Sort_Ascending|#PB_Sort_NoCase, OffsetOf(ArchiveEntry\Name), #PB_String)
          EndIf
          
          *Archive\NumFiles        = 0
          *Archive\NumFolders      = 0
          *Archive\TopLevelFiles   = 0
          *Archive\TopLevelFolders = 0
          ForEach *Archive\Entry()
            If (*Archive\Entry()\Size = #PB_FileSize_Directory)
              *Archive\NumFolders + 1
              If (GetPathPart(RemovePathSeparator(*Archive\Entry()\Name)) = "")
                *Archive\TopLevelFolders + 1
                If (*Archive\TopLevelFolders = 1)
                  *Archive\TopLevelFolderName = *Archive\Entry()\Name
                EndIf
              EndIf
            Else
              *Archive\NumFiles + 1
              If (GetPathPart(*Archive\Entry()\Name) = "")
                *Archive\TopLevelFiles + 1
                If (*Archive\TopLevelFiles = 1)
                  *Archive\TopLevelFileName = *Archive\Entry()\Name
                EndIf
              EndIf
            EndIf
          Next
          If (*Archive\TopLevelFiles <> 1)
            *Archive\TopLevelFileName = ""
          EndIf
          If (*Archive\TopLevelFolders <> 1)
            *Archive\TopLevelFolderName = ""
          EndIf
          *Archive\TopLevelItems = *Archive\TopLevelFiles + *Archive\TopLevelFolders
          If ((*Archive\TopLevelItems > 1) And (#True))
            *Archive\TopLevelFileName   = ""
            *Archive\TopLevelFolderName = ""
          EndIf
          
          ResetList(*Archive\Entry())
          
          If (#True)
            If (*Archive\TempFile)
              ReadArchiveAttributesToMap(*Archive\TempFile, *Archive\Attributes(), *Archive\OSForAttributes)
            Else
              ReadArchiveAttributesToMap(*Archive\File, *Archive\Attributes(), *Archive\OSForAttributes)
            EndIf
          EndIf
          
          *Archive\Examined = #True
          Result = #True
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i CloseArchive(*Archive.Archive)
      If (*Archive)
        ClearAndFreeList(*Archive\Entry())
        ClearAndFreeMap(*Archive\Attributes())
        If (*Archive\Pack)
          ClosePack(*Archive\Pack)
        EndIf
        If (*Archive\TempFile)
          DeleteFile(*Archive\TempFile)
        EndIf
        FreeStructure(*Archive)
      EndIf
      ProcedureReturn (#Null)
    EndProcedure
    
    Procedure.i OpenArchive(File.s, PluginID.i = #PackerPlugin_Default)
      Protected *Archive.Archive = #Null
      If (File)
        Protected FileToUse.s = File
        Protected TempFile.s = ""
        CompilerIf (Defined(_PBSL_GZip_Included, #PB_Constant))
          If (FileSeemsGZipped(File))
            TempFile = UniqueFileName(GetFilePart(File), ".tar", GetTemporaryDirectory())
            If (GZip_Decompress_FileToFile(File, TempFile))
              FileToUse = TempFile
            Else
              TempFile = ""
            EndIf
          EndIf
        CompilerEndIf
        Protected Pack.i = OpenPackMultiPlugin(#PB_Any, FileToUse, PluginID)
        If (Pack)
          *Archive = AllocateStructure(Archive)
          If (*Archive)
            *Archive\Pack = Pack
            *Archive\File = File
            
            *Archive\TempFile = TempFile
            
            *Archive\DeduplicateTopFolder   = #True
            *Archive\Overwrite              = #True
            *Archive\PreserveModifiedDate   = #True
            *Archive\PreserveFileAttributes = #True
            
            *Archive\ProgressCallback       = #Null
            
            *Archive\OSForAttributes        = #PB_Default
          Else
            ClosePack(Pack)
          EndIf
        EndIf
      EndIf
      ProcedureReturn (*Archive)
    EndProcedure
    
  CompilerEndIf
  
CompilerEndIf
;-
