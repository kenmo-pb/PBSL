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
    ;- - Archive Structures
    
    Structure ArchiveEntry
      Name.s
      Size.q
      Modified.i
    EndStructure
    
    Structure Archive
      Pack.i
      File.s
      Examined.i
      
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
      
      List Entry.ArchiveEntry()
    EndStructure
    
    ;-
    ;- - Archive Procedures
    
    Declare.i ExamineArchive(*Archive.Archive)
    
    Procedure.i _EnsureArchiveExamined(*Archive.Archive)
      Protected Result.i = #False
      If (*Archive\Examined)
        Result = #True
      Else
        Result = ExamineArchive(*Archive)
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i ExtractArchive(*Archive.Archive, Destination.s)
      Protected Result.i = #False
      If (*Archive And Destination)
        Destination = EnsurePathSeparator(Destination)
        
        _EnsureArchiveExamined(*Archive)
        
        ; TODO - Make these all optional
        Protected Overwrite.i = #True
        Protected DeduplicateTopFolder.i = #True
        Protected PreserveModifiedDate.i = #True
        
        If (CreateDirectoryRecursive(Destination))
          
          Protected SkipChars.i = 0
          If (DeduplicateTopFolder)
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
                ;If (PreserveModifiedDate) ; doesn't apply to folders?
                ;  SetModifiedDate(DestPath, *Archive\Entry()\Modified)
                ;EndIf
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
              DestSize = FileSize(DestPath)
              If (DestSize = #PB_FileSize_Directory)
                *Archive\FileErrors + 1
              ElseIf (Overwrite Or (FileSize(DestPath) = #PB_FileSize_Missing))
                If (UncompressPackFile(*Archive\Pack, DestPath, *Archive\Entry()\Name))
                  If (PreserveModifiedDate)
                    SetModifiedDate(DestPath, *Archive\Entry()\Modified)
                  EndIf
                  If (FileSize(DestPath) = *Archive\Entry()\Size)
                    *Archive\FilesExtracted + 1
                  Else
                    *Archive\FileErrors + 1
                  EndIf
                Else
                  *Archive\FileErrors + 1
                EndIf
              Else
                *Archive\FilesSkipped + 1
              EndIf
            EndIf
          Next
          
          *Archive\ItemsExtracted = *Archive\FilesExtracted + *Archive\FoldersExtracted
          *Archive\ItemsSkipped   = *Archive\FilesSkipped + *Archive\FoldersSkipped
          *Archive\ItemErrors     = *Archive\FileErrors + *Archive\FolderErrors
          If (*Archive\ItemsExtracted + *Archive\ItemsSkipped > 0);If (*Archive\ItemsExtracted > 0)
            If (*Archive\ItemErrors = 0);(#True)
              Result = #True
            EndIf
          EndIf
          
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
          If (#True)
            SortStructuredList(*Archive\Entry(), #PB_Sort_Ascending|#PB_Sort_NoCase, OffsetOf(ArchiveEntry\Name), #PB_String)
          EndIf
          
          *Archive\NumFiles   = 0
          *Archive\NumFolders = 0
          *Archive\TopLevelFiles = 0
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
          
          ResetList(*Archive\Entry())
          *Archive\Examined = #True
          Result = #True
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i CloseArchive(*Archive.Archive)
      If (*Archive)
        ClearAndFreeList(*Archive\Entry())
        If (*Archive\Pack)
          ClosePack(*Archive\Pack)
        EndIf
        FreeStructure(*Archive)
      EndIf
      ProcedureReturn (#Null)
    EndProcedure
    
    Procedure.i OpenArchive(File.s, PluginID.i = #PackerPlugin_Default)
      Protected *Archive.Archive = #Null
      If (File)
        Protected Pack.i = OpenPackMultiPlugin(#PB_Any, File, PluginID)
        If (Pack)
          *Archive = AllocateStructure(Archive)
          If (*Archive)
            *Archive\Pack = Pack
            *Archive\File = File
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
