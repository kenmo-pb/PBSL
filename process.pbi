; +--------------------------------------+
; | PureBasic Standard Library - Process |
; +--------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Process_Included, #PB_Constant))
  #_PBSL_Process_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Process Macros
  
  Macro WriteProgramEOF(_Program)
    WriteProgramData(_Program, #PB_Program_Eof, 0)
  EndMacro
  
  Macro RunProgramHidden(_ProgramName, _Parameter = "", _WorkingDirectory = "", _Flags = #Null)
    RunProgram(_ProgramName, _Parameter, _WorkingDirectory, (_Flags) | #PB_Program_Hide)
  EndMacro
  Macro RunProgramOutputHidden(_ProgramName, _Parameter = "", _WorkingDirectory = "", _Flags = #Null)
    RunProgramOutput(_ProgramName, _Parameter, _WorkingDirectory, (_Flags) | #PB_Program_Hide)
  EndMacro
  
  ;-
  ;- - Environment Variables
  
  Global NewList _PBSL_EnvironmentPath.s()
  
  Procedure.i ExamineEnvironmentPaths()
    ClearList(_PBSL_EnvironmentPath())
    
    CompilerIf (#IsWindowsBuild)
      SplitStringToList(GetEnvironmentVariable("PATH"), _PBSL_EnvironmentPath(), ";", #True)
      ForEach (_PBSL_EnvironmentPath())
        _PBSL_EnvironmentPath() = NormalizePathSeparators(_PBSL_EnvironmentPath())
      Next
    CompilerElse
      SplitStringToList(GetEnvironmentVariable("PATH"), _PBSL_EnvironmentPath(), ":", #True)
    CompilerEndIf
    
    ForEach (_PBSL_EnvironmentPath())
      _PBSL_EnvironmentPath() = EnsurePathSeparator(_PBSL_EnvironmentPath())
    Next
    DeduplicateStringList(_PBSL_EnvironmentPath())
    ResetList(_PBSL_EnvironmentPath())
    ProcedureReturn (ListSize(_PBSL_EnvironmentPath()))
  EndProcedure
  
  Procedure.i NextEnvironmentPath()
    If (NextElement(_PBSL_EnvironmentPath()))
      ProcedureReturn (#True)
    Else
      ProcedureReturn (#False)
    EndIf
  EndProcedure
  
  Procedure.s EnvironmentPath()
    If (ListIndex(_PBSL_EnvironmentPath()) >= 0)
      ProcedureReturn (_PBSL_EnvironmentPath())
    Else
      ProcedureReturn ("")
    EndIf
  EndProcedure
  
  ;-
  ;- - Process Procedures
  
  Procedure.s RunProgramOutput(ProgramName.s, Parameter.s = "", WorkingDirectory.s = "", Flags.i = #Null)
    Protected Result.s = ""
    If (Flags = #PB_Default)
      Flags = #Null
    EndIf
    If (ProgramName)
      
      Protected StdOut.i = #False
      Protected StdErr.i = #False
      Flags & ~#PB_Program_Wait
      Flags |  #PB_Program_Open
      If (Flags & #PB_Program_Read)
        StdOut = #True
      EndIf
      If (Flags & #PB_Program_Error)
        StdErr = #True
      Else
        If (Not (Flags & #PB_Program_Read))
          Flags | #PB_Program_Read
          Flags | #PB_Program_Error
          StdOut = #True
          StdErr = #True
        EndIf
      EndIf
      
      Protected *Prog = RunProgram(ProgramName, Parameter, WorkingDirectory, Flags)
      If (*Prog)
        Protected StartTime.i = ElapsedMilliseconds()
        Protected Line.s
        While (ProgramRunning(*Prog))
          
          If (StdOut)
            While (AvailableProgramOutput(*Prog) > 0)
              Line = ReadProgramString(*Prog)
              If (Result)
                Result + #LF$
              EndIf
              Result + Line
            Wend
          EndIf
          
          If (StdErr)
            While (#True)
              ; Wish there was AvailableProgramError() !
              Line = ReadProgramError(*Prog)
              If (Line <> "")
                If (Result)
                  Result + #LF$
                EndIf
                Result + Line
              Else
                Break
              EndIf
            Wend
          EndIf
          
          If (ElapsedMilliseconds() - StartTime > 10*1000)
            Delay(100)
          ElseIf (ElapsedMilliseconds() - StartTime > 1*1000)
            Delay(10)
          Else
            Delay(0)
          EndIf
        Wend
        CloseProgram(*Prog)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  
  
  CompilerIf (#IsWindowsBuild)
    Macro LaunchFile(_File)
      RunProgram(_File)
    EndMacro
    Macro LaunchFolder(_Folder)
      RunProgram(_Folder)
    EndMacro
  CompilerElseIf (#IsMacBuild)
    Macro LaunchFile(_File)
      RunProgram("open", Quote(_File), GetPathPart(_File))
    EndMacro
    Macro LaunchFolder(_Folder)
      RunProgram("open", Quote(_Folder), _Folder)
    EndMacro
  CompilerElseIf (#IsLinuxBuild)
    Procedure LaunchFile(File.s)
      ;Protected Output.s = RunProgramOutput("open", Quote(File), GetPathPart(File), #PB_Program_Error)
      Protected Output.s = RunProgramOutput("xdg-open", Quote(File), GetPathPart(File), #PB_Program_Error)
      If (FindString(Output, "Failed"))
        RunProgram(File, "", GetPathPart(File))
      EndIf
    EndProcedure
    Macro LaunchFolder(_Folder)
      ;RunProgram("open", Quote(_Folder), _Folder)
      RunProgram("xdg-open", Quote(_Folder), _Folder)
    EndMacro
  CompilerEndIf
  
  Procedure.i LaunchApp(AppPath.s, Parameters.s = "", WorkingDirectory.s = "")
    Protected Result.i = #False
    If (AppPath)
      If (WorkingDirectory = "")
        WorkingDirectory = GetCurrentDirectory()
      EndIf
      CompilerIf (#IsMacBuild)
        Select (FileSize(AppPath))
          Case #PB_FileSize_Directory
            Protected FullParams.s = QuoteIfSpaces(AppPath)
            If (#True)
              FullParams = "-a " + FullParams
            EndIf
            If (Parameters)
              FullParams + " --args " + Parameters
            EndIf
            Result = Bool(RunProgram("open", FullParams, WorkingDirectory))
          Case 0, #PB_FileSize_Missing
            ;
          Default
            Result = Bool(RunProgram(AppPath, Parameters, WorkingDirectory))
        EndSelect
      CompilerElse
        Result = Bool(RunProgram(AppPath, Parameters, WorkingDirectory))
      CompilerEndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure ShowInExplorer(FileOrFolder.s)
    If (FileExists(FileOrFolder))
      CompilerIf (#IsWindowsBuild)
        RunProgram("explorer.exe", "/SELECT," + Quote(NormalizePathSeparators(FileOrFolder)), "")
        
      CompilerElseIf (#IsLinuxBuild)
        NewList TryCommand.s()
        ; Add more here, as "<executable>|<args>" where %f will be replaced with quoted FileOrFolder
        AddString(TryCommand(), "io.elementary.files| %f")
        
        Protected Executable.s
        ForEach (TryCommand())
          Executable = Which(StringField(TryCommand(), 1, "|"))
          If (Executable)
            RunProgram(Executable, ReplaceString(StringField(TryCommand(), 2, "|"), "%f", Quote(FileOrFolder)), GetPathPart(FileOrFolder))
            Break
          EndIf
        Next
        If (Executable = "")
          LaunchFolder(GetPathPart(FileOrFolder))
        EndIf
        
      CompilerElse
        LaunchFolder(GetPathPart(FileOrFolder))
      CompilerEndIf
      
    ElseIf (FolderExists(FileOrFolder))
      CompilerIf (#IsWindowsBuild)
        If (#False)
          RunProgram("explorer.exe", "/SELECT," + Quote(FileOrFolder), "")
        Else
          LaunchFolder(FileOrFolder)
        EndIf
      CompilerElse
        LaunchFolder(FileOrFolder)
      CompilerEndIf
    EndIf
  EndProcedure
  
  Procedure LaunchURL(URL.s)
    If (URL)
      If (Not FindString(URL, "://"))
        URL = "http://" + URL
      EndIf
      CompilerIf (#IsWindowsBuild)
        RunProgram(URL)
      CompilerElseIf (#IsLinuxBuild)
        ;RunProgram("open", Quote(URL), "")
        RunProgram("xdg-open", Quote(URL), "")
      CompilerElse
        RunProgram("open", Quote(URL), "")
      CompilerEndIf
    EndIf
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
  
  Procedure.i GetSystemBootTimestamp()
    CompilerIf (#IsLinuxBuild)
      ProcedureReturn (ParseDate("%yyyy-%mm-%dd %hh:%ii:%ss", RunProgramOutputHidden("uptime", "-s", "")))
    CompilerEndIf
    ProcedureReturn (0) ; unknown boot time
  EndProcedure
  
  Procedure.s ProgramParametersString()
    Protected Result.s = ""
    Protected N.i = CountProgramParameters()
    If (N > 0)
      Protected i.i
      For i = 0 To (N-1)
        If (i > 0)
          Result + " "
        EndIf
        Result + QuoteIfSpaces(ProgramParameter(i), #True)
      Next i
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ProgramParametersToList(List StrList.s())
    ClearList(StrList())
    Protected N.i = CountProgramParameters()
    If (N > 0)
      Protected i.i
      For i = 0 To (N-1)
        AddString(StrList(), ProgramParameter(i))
      Next i
    EndIf
    ProcedureReturn (N)
  EndProcedure
  
  Procedure.i ProgramParametersToArray(Array StrArray.s(1))
    Protected N.i = CountProgramParameters()
    If (N > 0)
      Dim StrArray.s(N-1)
      Protected i.i
      For i = 0 To (N-1)
        StrArray(i) = ProgramParameter(i)
      Next i
    Else
      Dim StrArray.s(0)
    EndIf
    ProcedureReturn (N)
  EndProcedure
  
CompilerEndIf
;-
