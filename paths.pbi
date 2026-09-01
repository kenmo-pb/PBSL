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
  
  ;- Path Manipulation
  
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
  
  Procedure.s GetParentDirectory(Directory.s)
    ProcedureReturn (GetPathPart(RemovePathSeparator(Directory)))
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
  
  ;-
  ;- Locate Files/Folders
  
  Macro FolderExists(_Folder)
    (Bool(FileSize(_Folder) = #PB_FileSize_Directory))
  EndMacro
  
  Macro FileExists(_File)
    (Bool(FileSize(_File) >= 0))
  EndMacro
  
  Macro FileOrFolderExists(_Path)
    (Bool(FileSize(_Path) <> #PB_FileSize_Missing))
  EndMacro
  
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
  
  Procedure.s Which(FileName.s)
    Protected Result.s = ""
    If (FileName And (Not FindString(FileName, "/")))
      CompilerIf (#IsWindowsBuild)
        If (Not FindString(FileName, "\"))
          If (ExamineEnvironmentPaths())
            Protected TryPath.s
            If (GetExtensionPart(FileName) <> "")
              While (NextEnvironmentPath())
                TryPath = EnvironmentPath() + FileName
                If (FileExists(TryPath))
                  Result = TryPath
                  Break 1
                EndIf
              Wend
            Else
              NewList PathExt.s()
              If (SplitStringToList(GetEnvironmentVariable("PATHEXT"), PathExt(), ";", #True))
                DeduplicateStringList(PathExt())
                FileName = RTrim(FileName, ".") + "."
                While (NextEnvironmentPath())
                  ForEach (PathExt())
                    TryPath = EnvironmentPath() + FileName + LTrim(PathExt(), ".")
                    If (FileExists(TryPath))
                      Result = TryPath
                      Break 2
                    EndIf
                  Next
                Wend
                ClearList(PathExt())
              EndIf
            EndIf
          EndIf
        EndIf
      CompilerElseIf (#IsUnixBuild)
        Protected Output.s = RunProgramOutputHidden("which", FileName)
        If (Output And FileExists(Output))
          Result = Output
        EndIf
      CompilerEndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - File/Folder Actions
  
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
  
CompilerEndIf
;-
