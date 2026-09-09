; +-------------------------------------+
; | PureBasic Standard Library - Packer |
; +-------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Packer_Included, #PB_Constant))
  #_PBSL_Packer_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Packer Constants
  
  #PackerLevel_Minimum = 0
  #PackerLevel_Maximum = 9
  #PackerLevel_Default = #PackerLevel_Maximum
  
  ;-
  ;- - Packer Procedures
  
  Procedure.i PackerPluginIDByExtension(FileOrExtension.s, DefaultResult.i = 0)
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
  
  Procedure.i CreatePackFromFolder(PackFile.s, Folder.s, PluginID.i = #PB_Default, Level.i = #PackerLevel_Default)
    Protected Result.i = #False
    If (PackFile And Folder)
      Folder = EnsurePathSeparator(Folder)
      If (FileSize(Folder) = -2)
        If (PluginID = #PB_Default)
          PluginID = PackerPluginIDByExtension(PackFile, #PB_PackerPlugin_Zip)
        EndIf
        If (PluginID > 0)
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
  
  Procedure.i CreatePackFromFile(PackFile.s, File.s, PluginID.i = #PB_Default, Level.i = #PackerLevel_Default)
    Protected Result.i = #False
    If (PackFile And File)
      If (FileSize(File) >= 0)
        If (PluginID = #PB_Default)
          PluginID = PackerPluginIDByExtension(PackFile, 0)
        EndIf
        If (PluginID > 0)
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
  
  Procedure.i CreatePackFromApp(PackFile.s, AppPath.s, PluginID.i = #PB_Default, Level.i = #PackerLevel_Default)
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
  
CompilerEndIf
;-
