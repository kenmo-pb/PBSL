; +------------------------------------+
; | PureBasic Standard Library - Paths |
; +------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Paths_Included, #PB_Constant))
  #_PBSL_Paths_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Path Manipulation
  
  CompilerIf ((#IsWindowsBuild And (#True)) Or (#False)) ; Case Insensitive filesystem?
    Macro SameFile(_File1, _File2)
      Bool(LCase(_File1) = LCase(_File2))
    EndMacro
  CompilerElse
    Macro SameFile(_File1, _File2)
      Bool(_File1 = _File2)
    EndMacro
  CompilerEndIf
  
  Macro GetNamePart(_File)
    GetFilePart(_File, #PB_FileSystem_NoExtension)
  EndMacro
  
  Macro RemoveExtensionPart(_File)
    SetExtensionPart((_File), "")
  EndMacro
  
  Procedure.s RemovePathSeparator(Path.s)
    If (Path)
      CompilerIf (#IsWindowsBuild Or (#False))
        While (EndsWith(Path, #PS$) Or EndsWith(Path, #NPS$))
          Path = RTrim(Path, #PS$)
          Path = RTrim(Path, #NPS$)
        Wend
      CompilerElse
        Path = RTrim(Path, #PS$)
      CompilerEndIf
    EndIf
    ProcedureReturn (Path)
  EndProcedure
  
  Procedure.s EnsurePathSeparator(Path.s)
    If (Path)
      CompilerIf (#IsWindowsBuild Or (#False))
        If (Not (EndsWith(Path, #PS$) Or EndsWith(Path, #NPS$)))
          Path + #PS$
        EndIf
      CompilerElse
        If (Not EndsWith(Path, #PS$))
          Path + #PS$
        EndIf
      CompilerEndIf
    EndIf
    ProcedureReturn (Path)
  EndProcedure
  
  Procedure.s GetParentDirectory(Directory.s)
    ProcedureReturn (GetPathPart(RemovePathSeparator(Directory)))
  EndProcedure
  
  Procedure.s GetTopDirectoryName(Directory.s)
    ProcedureReturn (GetFilePart(RemovePathSeparator(Directory)))
  EndProcedure
  
  Procedure.s AppendFileName(File.s, Suffix.s)
    Protected Result.s = ""
    If (File And Suffix)
      Protected Ext.s = GetExtensionPart(File)
      If (Ext)
        Result = Left(File, Len(File) - (1 + Len(Ext))) + Suffix + "." + Ext
      Else
        Result = File + Suffix
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s SetExtensionPart(File.s, NewExtension.s)
    Protected Result.s = ""
    If (File)
      Result = GetPathPart(File)
      File = GetFilePart(File)
      NewExtension = Trim(NewExtension, ".")
      If (GetExtensionPart(File) = "")
        If (NewExtension)
          File + "." + NewExtension
        EndIf
      Else
        File = GetFilePart(File, #PB_FileSystem_NoExtension)
        If (NewExtension)
          File + "." + NewExtension
        EndIf
      EndIf
      Result + File
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i IsAbsolutePath(Path.s)
    Protected Result.i = #False
    If (Path)
      CompilerIf (#IsWindowsBuild)
        If (FindString(Path, ":"))
          Result = #True
        EndIf
      CompilerElse
        If (Left(Path, 1) = "/")
          Result = #True
        ElseIf (Left(Path, 1) = #HomeDirectory$)
          Result = #True
        EndIf
      CompilerEndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s EnsureAbsolutePath(Path.s, RootDir.s = "")
    If (Not IsAbsolutePath(Path))
      If (RootDir = "")
        RootDir = GetCurrentDirectory()
      Else
        RootDir = EnsurePathSeparator(RootDir)
      EndIf
      CompilerIf (#IsWindowsBuild)
        Path = LTrim(Path, #PS$)
        Path = LTrim(Path, #NPS$)
      CompilerEndIf
      Path = RootDir + Path
    EndIf
    ProcedureReturn (Path)
  EndProcedure
  
  Procedure.s NormalizePathSeparators(Path.s, SeparatorToUse.s = #PS$)
    Select (SeparatorToUse)
      Case "/"
        ReplaceStringInPlace(Path, "\", "/")
      Case "\"
        ReplaceStringInPlace(Path, "/", "\")
      Case ""
        ReplaceStringInPlace(Path, #NPS$, #PS$)
      Default
        CompilerIf (#IsWindowsBuild Or (#True))
          ReplaceStringInPlace(Path, "\", SeparatorToUse)
        CompilerEndIf
        ReplaceStringInPlace(Path, "/", SeparatorToUse)
    EndSelect
    ProcedureReturn (Path)
  EndProcedure
  
  Procedure.s NormalizePath(Path.s, ExpandCurrentDirectory.i = #False)
    Protected Result.s = ""
    
    If ((Path = "") And (ExpandCurrentDirectory) And (#False))
      Path = #CurrentDirectory$
    EndIf
    
    If (Path)
      Path = NormalizePathSeparators(Path, #PS$)
      Protected IsAbsolute.i = IsAbsolutePath(Path)
      Protected File.s = GetFilePart(Path)
      Path = GetPathPart(Path)
      If (File = #CurrentDirectory$)
        If (ExpandCurrentDirectory)
          File = GetCurrentDirectory()
        Else
          File = ""
        EndIf
      ElseIf (File = #ParentDirectory$)
        File = ""
        Path + #ParentDirectory$ + #PS$
      EndIf
      If (Path)
        Protected ExtraParents.i = 0
        Protected N.i = 1 + CountString(Path, #PS$)
        Protected i.i
        For i = 1 To N
          Protected Term.s = StringField(Path, i, #PS$)
          If (Term <> "")
            If (Term = #CurrentDirectory$)
              If ((Result = "") And (ExpandCurrentDirectory))
                Result = GetCurrentDirectory()
              Else
                ; ignore
              EndIf
            ElseIf (Term = #ParentDirectory$)
              If (IsAbsolute)
                Result = GetParentDirectory(Result)
                If (Result = "")
                  Result = ""
                  File = ""
                  ExtraParents = 0
                  Break
                Else
                  ; OK
                EndIf
              Else
                If (Result)
                  Result = GetParentDirectory(Result)
                Else
                  ExtraParents + 1
                EndIf
              EndIf
            ElseIf ((Term = #HomeDirectory$) And (Result = "") And (Not #IsWindowsBuild))
              Result = GetHomeDirectory()
            Else
              Result + Term + #PS$
            EndIf
          Else
            If (i = 1)
              Result + #PS$
            Else
              ; ignore
            EndIf
          EndIf
        Next i
        While (ExtraParents > 0)
          Result = #ParentDirectory$ + #PS$ + Result
          ExtraParents - 1
        Wend
      EndIf
      Result + File
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s MakeRelativePath(Path.s, RootDir.s)
    Protected Result.s = ""
    If (Path And RootDir)
      Protected IsAbsolute.i = #False
      If (IsAbsolutePath(Path) And IsAbsolutePath(RootDir))
        IsAbsolute = #True
      EndIf
      Path    = NormalizePath(Path)
      RootDir = EnsurePathSeparator(NormalizePath(RootDir))
      If (Path And RootDir)
        If (Path = RootDir)
          ; exact match - result is empty string
        Else
          Protected Prefix.s = ""
          While (#True)
            If (SameFile(Left(Path, Len(RootDir)), RootDir))
              Result = Mid(Path, 1 + Len(RootDir))
              Break
            Else
              RootDir = GetParentDirectory(RootDir)
              If (IsAbsolute And (RootDir = ""))
                Result = ""
                Prefix = ""
                Break
              Else
                Prefix + #ParentDirectory$ + #PS$
              EndIf
            EndIf
          Wend
          Result = Prefix + Result
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - File/Folder Information
  
  Declare.i CreateDirectoryRecursive(Path.s)
  
  Macro FolderExists(_Folder)
    (Bool(FileSize(_Folder) = #PB_FileSize_Directory))
  EndMacro
  
  Macro FileExists(_File)
    (Bool(FileSize(_File) >= 0))
  EndMacro
  
  Macro FileOrFolderExists(_Path)
    (Bool(FileSize(_Path) <> #PB_FileSize_Missing))
  EndMacro
  
  Macro GetCreatedDate(_File)
    GetFileDate((_File), #PB_Date_Created)
  EndMacro
  Macro GetModifiedDate(_File)
    GetFileDate((_File), #PB_Date_Modified)
  EndMacro
  
  CompilerIf (#IsWindowsBuild)
    Macro IsHidden(_FileOrFolder)
      (Bool(GetFileAttributes(_FileOrFolder) & #PB_FileSystem_Hidden))
    EndMacro
    Macro IsReadOnly(_FileOrFolder)
      (Bool(GetFileAttributes(_FileOrFolder) & #PB_FileSystem_ReadOnly))
    EndMacro
  CompilerElse
    Macro IsHidden(_FileOrFolder)
      (StartsWith(GetFilePart(RemovePathSeparator(_FileOrFolder)), "."))
    EndMacro
  CompilerEndIf
  
  CompilerIf (#IsWindowsBuild)
    Procedure.i SetHidden(FileOrFolder.s, State.i)
      Protected Result.i
      If (State)
        Result = SetFileAttributes(FileOrFolder, GetFileAttributes(FileOrFolder) | #PB_FileSystem_Hidden)
      Else
        Result = SetFileAttributes(FileOrFolder, GetFileAttributes(FileOrFolder) & (~#PB_FileSystem_Hidden))
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i SetReadOnly(FileOrFolder.s, State.i)
      Protected Result.i
      If (State)
        Result = SetFileAttributes(FileOrFolder, GetFileAttributes(FileOrFolder) | #PB_FileSystem_ReadOnly)
      Else
        Result = SetFileAttributes(FileOrFolder, GetFileAttributes(FileOrFolder) & (~#PB_FileSystem_ReadOnly))
      EndIf
      ProcedureReturn (Result)
    EndProcedure
  CompilerEndIf
  
  Procedure.s _GetUserDataPathFormat(Name.s)
    CompilerIf (#IsWindowsBuild)
      Name = Trim(Name)
    CompilerElse
      Name = RemoveString(Name, " ")
    CompilerEndIf
    
    CompilerIf (#False)
      Name = LCase(Name)
    CompilerEndIf
    
    CompilerIf (#True)
      ReplaceStringInPlace(Name, "<", "_")
      ReplaceStringInPlace(Name, ">", "_")
      ReplaceStringInPlace(Name, ":", "_")
      ReplaceStringInPlace(Name, "/", "_")
      ReplaceStringInPlace(Name, "\", "_")
      ReplaceStringInPlace(Name, "|", "_")
      ReplaceStringInPlace(Name, "?", "_")
      ReplaceStringInPlace(Name, "*", "_")
      ReplaceStringInPlace(Name, #DQ$, "_")
    CompilerEndIf
    
    ProcedureReturn (Name)
  EndProcedure
  
  Procedure.s GetUserDataPath(AppName.s, OrgName.s = "", Alternate.i = #False)
    Protected Result.s = ""
    
    CompilerIf (#IsWindowsBuild)
      Protected Parent.s
      If (Not Alternate)
        Parent = GetEnvironmentVariable("LOCALAPPDATA")
      EndIf
      If (Parent = "")
        Parent = GetEnvironmentVariable("APPDATA")
      EndIf
      If (Parent = "")
        Parent = GetHomeDirectory()
      EndIf
      Result = EnsurePathSeparator(Parent)
      If (OrgName)
        Result = Result + _GetUserDataPathFormat(OrgName) + #PS$
      EndIf
      If (AppName)
        Result = Result + _GetUserDataPathFormat(AppName) + #PS$
      EndIf
      
    CompilerElseIf (#IsMacBuild)
      Result = GetHomeDirectory() + "Library" + #PS$ + "Application Support" + #PS$
      If (OrgName)
        Result = Result + _GetUserDataPathFormat(OrgName) + #PS$
      EndIf
      If (AppName)
        Result = Result + _GetUserDataPathFormat(AppName) + #PS$
      EndIf
      
    CompilerElseIf (#IsLinuxBuild)
      If (Alternate)
        Result = GetHomeDirectory()
        If (OrgName)
          Result = Result + "." + _GetUserDataPathFormat(OrgName) + #PS$
          If (AppName)
            Result = Result + _GetUserDataPathFormat(AppName) + #PS$
          EndIf
        ElseIf (AppName)
          Result = Result + "." + _GetUserDataPathFormat(AppName) + #PS$
        EndIf
      Else
        Protected Parent.s
        Parent = GetEnvironmentVariable("XDG_DATA_HOME")
        If (Parent = "")
          Parent = GetHomeDirectory() + ".local" + #PS$ + "share" + #PS$
        EndIf
        Result = EnsurePathSeparator(Parent)
        If (OrgName)
          Result = Result + _GetUserDataPathFormat(OrgName) + #PS$
        EndIf
        If (AppName)
          Result = Result + _GetUserDataPathFormat(AppName) + #PS$
        EndIf
      EndIf
      
    CompilerEndIf
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s FindFirstFile(Pattern.s, Directory.s = "")
    Protected Result.s = ""
    If (Directory = "")
      Directory = GetCurrentDirectory()
    EndIf
    Protected DN.i = ExamineDirectory(#PB_Any, Directory, Pattern)
    If (DN)
      While (NextDirectoryEntry(DN))
        If (DirectoryEntryType(DN) = #PB_DirectoryEntry_File)
          Result = DirectoryEntryName(DN)
          Break
        EndIf
      Wend
      FinishDirectory(DN)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s UniqueFileName(Prefix.s = "", Suffix.s = "", Directory.s = "")
    Protected Result.s = ""
    If (Directory)
      Directory = EnsurePathSeparator(Directory)
    EndIf
    Suffix = RemovePathSeparator(Suffix)
    
    Protected Attempt.i = 1
    While (#True)
      Protected Try.s = Directory + Prefix
      If ((Attempt < 10) And (#True))
        Try + "0"
      EndIf
      Try + Str(Attempt)
      Try + Suffix
      If (FileSize(Try) = -1)
        Result = Try
        Break
      EndIf
      Attempt + 1
    Wend
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s UniqueDirectory(Prefix.s = "", Suffix.s = "", ParentDirectory.s = "", Create.i = #False)
    Protected Result.s = ""
    Result = UniqueFileName(Prefix, Suffix, ParentDirectory)
    If (Result)
      Result + #PS$
      If (Create)
        If (CreateDirectoryRecursive(Result))
          ; OK
        Else
          Result = ""
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- Executable Information
  
  Procedure.i IsExecutableWithinBundle(Executable.s)
    CompilerIf (#IsMacBuild)
      If (GetFilePart(Executable))
        If (EndsWith(GetPathPart(Executable), ".app/Contents/MacOS/")) ; is .app case sensitive in the OS ?
          ProcedureReturn (#True)
        EndIf
      EndIf
      ProcedureReturn (#False)
    CompilerElse
      ProcedureReturn (#False)
    CompilerEndIf
  EndProcedure
  
  Procedure.s GetAppPathForExecutable(Executable.s)
    CompilerIf (#IsMacBuild) ; will NOT include ending "/" character, despite technically being a directory!
      If (IsExecutableWithinBundle(Executable))
        Protected Path.s = Executable
        While (Right(Path, 5) <> ".app/")
          Path = GetParentDirectory(Path)
          If (Path = "")
            Break
          EndIf
        Wend
        Path = RTrim(Path, "/")
        ProcedureReturn (Path)
      Else
        ProcedureReturn (Executable)
      EndIf
    CompilerElse
      ProcedureReturn (Executable)
    CompilerEndIf
  EndProcedure
  
  Procedure.i IsProgramWithinBundle()
    CompilerIf (#IsMacBuild)
      ProcedureReturn (IsExecutableWithinBundle(ProgramFilename()))
    CompilerElse
      ProcedureReturn (#False)
    CompilerEndIf
  EndProcedure
  
  Procedure.s GetProgramAppPath()
    CompilerIf (#IsMacBuild)
      ProcedureReturn (GetAppPathForExecutable(ProgramFilename()))
    CompilerElse
      ProcedureReturn (ProgramFilename())
    CompilerEndIf
  EndProcedure
  
  Procedure.s GetProgramDirectory()
    ProcedureReturn (GetPathPart(ProgramFilename()))
  EndProcedure
  
  Procedure.s FindResourcePath(ResourceName.s)
    Protected Result.s = ""
    
    If (ResourceName)
      NewList PathToTry.s()
      
      AddString(PathToTry(), GetCurrentDirectory())
      AddString(PathToTry(), GetProgramDirectory())
      If (#True)
        AddString(PathToTry(), GetParentDirectory(GetCurrentDirectory()))
        AddString(PathToTry(), GetParentDirectory(GetProgramDirectory()))
      EndIf
      CompilerIf (#PB_Compiler_Debugger And (#False))
        AddString(PathToTry(), #PB_Compiler_FilePath)
        AddString(PathToTry(), GetParentDirectory(#PB_Compiler_FilePath))
      CompilerEndIf
      
      CompilerSelect (#PB_Compiler_OS)
        CompilerCase (#PB_OS_Windows)
        CompilerCase (#PB_OS_Linux)
        CompilerCase (#PB_OS_MacOS)
          If (IsProgramWithinBundle())
            AddString(PathToTry(), EnsurePathSeparator(GetProgramAppPath()) + "Contents/Resources/")
          EndIf
      CompilerEndSelect
      
      ForEach (PathToTry())
        If (PathToTry())
          PathToTry() = EnsurePathSeparator(PathToTry())
          Select (FileSize(PathToTry() + ResourceName))
            Case #PB_FileSize_Missing
              ; continue searching...
            Case #PB_FileSize_Directory
              Result = EnsurePathSeparator(PathToTry() + ResourceName)
              Break
            Default
              Result = PathToTry()
              Break
          EndSelect
        EndIf
      Next
      
      FreeList(PathToTry())
    EndIf
    
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - File/Folder Actions
  
  Procedure.i DeleteFolder(Folder.s, Force.i = #True)
    Protected Result.i = #False
    If (Folder)
      DeleteDirectory(Folder, "", #PB_FileSystem_Recursive | (Bool(Force) * #PB_FileSystem_Force))
      Result = Bool(FileSize(Folder) = #PB_FileSize_Missing)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i DeleteFileOrFolder(Path.s, Force.i = #True)
    Protected Result.i = #False
    If (Path)
      Select (FileSize(Path))
        Case #PB_FileSize_Missing
          Result = #True
        Case #PB_FileSize_Directory
          DeleteDirectory(Path, "", #PB_FileSystem_Recursive | (Bool(Force) * #PB_FileSystem_Force))
          Result = Bool(FileSize(Path) = #PB_FileSize_Missing)
        Default
          DeleteFile(Path, Bool(Force) * #PB_FileSystem_Force)
          Result = Bool(FileSize(Path) = #PB_FileSize_Missing)
      EndSelect
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i CreateDirectoryRecursive(Path.s)
    Protected Result.i = #False
    If (Path)
      If (FileSize(Path) = #PB_FileSize_Missing)
        Path = EnsurePathSeparator(NormalizePath(Path))
        If (CreateDirectoryRecursive(GetParentDirectory(Path)))
          CreateDirectory(Path)
        EndIf
      EndIf
      Result = Bool(FileSize(Path) = #PB_FileSize_Directory)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s CreateAndReturnDirectory(Path.s)
    If (Path)
      CreateDirectoryRecursive(Path)
    EndIf
    ProcedureReturn (Path)
  EndProcedure
  
CompilerEndIf
;-
