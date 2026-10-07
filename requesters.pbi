; +-----------------------------------------+
; | PureBasic Standard Library - Requesters |
; +-----------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Requesters_Included, #PB_Constant))
  #_PBSL_Requesters_Included = #True
  
  ;- - Requester Constants
  
  #Confirm_Yes    = #PB_MessageRequester_Yes
  #Confirm_No     = #PB_MessageRequester_No
  #Confirm_Cancel = #PB_MessageRequester_Cancel
  
  #Confirm_YesNo       = #PB_MessageRequester_YesNo
  #Confirm_YesNoCancel = #PB_MessageRequester_YesNoCancel
  
  ;-
  ;- - Requester Structures
  
  CompilerIf (Not #PBSL_NoGUI)
    
    Structure _RequesterExPattern
      Name.s
      RawPattern.s
      FormattedPattern.s
    EndStructure
    
    ;-
    ;- - Requester Globals
    
    Global _RequesterExFileList.s = ""
    Global _RequesterExLastIndex.i = 0
    
    ;-
    ;- - Requester Macros
    
    CompilerIf (#RequestersSupportParentID)
      Macro Info(_Message, _ParentID = #Null)
        MessageRequester("Info", _Message, #PB_MessageRequester_Info | #PB_MessageRequester_Ok, (_ParentID))
      EndMacro
      Macro Warning(_Message, _ParentID = #Null)
        MessageRequester("Warning", _Message, #PB_MessageRequester_Warning | #PB_MessageRequester_Ok, (_ParentID))
      EndMacro
      Macro Error(_Message, _ParentID = #Null)
        MessageRequester("Error", _Message, #PB_MessageRequester_Error | #PB_MessageRequester_Ok, (_ParentID))
      EndMacro
      Macro Question(_Message, _Flags = #PB_MessageRequester_YesNo, _ParentID = #Null)
        MessageRequester("Question", _Message, #PB_MessageRequester_Question | (_Flags), (_ParentID))
      EndMacro
      
      Macro PasswordRequester(_Title, _Message, _DefaultString, _Flags = #Null, _ParentID = #Null)
        InputRequester(_Title, _Message, _DefaultString, ((_Flags) | #PB_InputRequester_Password), (_ParentID))
      EndMacro
    CompilerElse
      Macro Info(_Message, _ParentID = #Null)
        MessageRequester("Info", _Message, #PB_MessageRequester_Info | #PB_MessageRequester_Ok)
      EndMacro
      Macro Warning(_Message, _ParentID = #Null)
        MessageRequester("Warning", _Message, #PB_MessageRequester_Warning | #PB_MessageRequester_Ok)
      EndMacro
      Macro Error(_Message, _ParentID = #Null)
        MessageRequester("Error", _Message, #PB_MessageRequester_Error | #PB_MessageRequester_Ok)
      EndMacro
      Macro Question(_Message, _Flags = #PB_MessageRequester_YesNo, _ParentID = #Null)
        MessageRequester("Question", _Message, #PB_MessageRequester_Question | (_Flags))
      EndMacro
      
      Macro PasswordRequester(_Title, _Message, _DefaultString, _Flags = #Null, _ParentID = #Null)
        InputRequester(_Title, _Message, _DefaultString, ((_Flags) | #PB_InputRequester_Password))
      EndMacro
    CompilerEndIf
    
    Macro ConfirmYes(_Message, _AllowCancel = #False, _ParentID = #Null)
      (Bool(Confirm(_Message, _AllowCancel, _ParentID) = #Confirm_Yes))
    EndMacro
    
    ;-
    ;- - Requester Procedures
    
    Procedure.i Confirm(Message.s, AllowCancel.i = #False, ParentID.i = #Null)
      Protected Result.i
      Protected Flags.i = #PB_MessageRequester_YesNo
      If (AllowCancel)
        Flags = #PB_MessageRequester_YesNoCancel
      EndIf
      CompilerIf (#RequestersSupportParentID)
        Result = MessageRequester("Confirm", Message, (Flags | #PB_MessageRequester_Question), ParentID)
      CompilerElse
        Result = MessageRequester("Confirm", Message, (Flags | #PB_MessageRequester_Question))
      CompilerEndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.s PathRequesterViaFileRequester(Title.s, InitialPath.s, ParentID.i = #Null)
      Protected Result.s = ""
      If (InitialPath = "")
        InitialPath = GetCurrentDirectory()
      EndIf
      InitialPath = InitialPath + ".ThisPath"
      Protected Path.s = OpenFileRequester(Title, InitialPath, "Path|*.*", 0, #Null, ParentID)
      If (Path)
        If (FileSize(Path) = #PB_FileSize_Directory)
          Result = Path
        Else
          Result = GetPathPart(Path)
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.s AppendFilePattern(ExistingList.s, PatternName.s, PatternExtensions.s, Prepend.i = #False)
      Protected Result.s = ""
      Protected NewLine.s = PatternName + "|" + PatternExtensions
      If (ExistingList)
        ExistingList = Trim(ExistingList, "|")
        If (Prepend)
          Result = NewLine + "|" + ExistingList
        Else
          Result = ExistingList + "|" + NewLine
        EndIf
      Else
        Result = NewLine
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Macro PrependFilePattern(_ExistingList, _PatternName, _PatternExtensions)
      AppendFilePattern(_ExistingList, _PatternName, _PatternExtensions, #True)
    EndMacro
    
    Procedure.s _RequesterExFormatPatterns(PatternList.s, DefaultFile.s, *DefaultPattern.INTEGER)
      Protected Result.s = ""
      Protected MatchingPattern.i = -1
      Protected AllFilesPattern.i = -1
      
      Protected DefaultExt.s = LCase(GetExtensionPart(DefaultFile))
      If (DefaultExt)
        DefaultExt = "*." + DefaultExt
      EndIf
      
      Result = PatternList
      NewList Pattern._RequesterExPattern()
      Protected N.i = 1 + CountString(PatternList, "|")
      If ((N % 2) = 0)
        N = (N / 2)
        Result = ""
        Protected i.i
        For i = 0 To (N-1)
          AddElement(Pattern())
          Pattern()\Name = Trim(StringField(PatternList, i*2 + 1, "|"))
          Pattern()\RawPattern = Trim(StringField(PatternList, i*2 + 2, "|"))
          If (Pattern()\RawPattern = "")
            Pattern()\RawPattern = WindowsElse("*.*", "*")
          EndIf
          CompilerIf (#IsWindowsBuild)
            If (Pattern()\RawPattern = "*")
              Pattern()\RawPattern = "*.*"
            EndIf
          CompilerEndIf
          If (Pattern()\Name = "")
            If ((Pattern()\RawPattern = "*") Or (Pattern()\RawPattern = "*.*"))
              Pattern()\Name = "All Files"
            Else
              Pattern()\Name = "(" + Pattern()\RawPattern + ")"
            EndIf
          EndIf
          If (#True) ; Automatically append extensions to pattern name? What if it grows too long?
            If (Not FindString(Pattern()\Name, "("))
              Pattern()\Name + " (" + RemoveSpaces(Pattern()\RawPattern) + ")"
            EndIf
          EndIf
          
          If (Pattern()\RawPattern = "*")
            AllFilesPattern = i
          ElseIf ((Pattern()\RawPattern = "*.*") And (AllFilesPattern = -1))
            AllFilesPattern = i
          EndIf
          If (DefaultExt And (MatchingPattern = -1))
            Pattern()\FormattedPattern = ";" + LCase(RemoveSpaces(Pattern()\RawPattern)) + ";"
            If (FindString(Pattern()\FormattedPattern, DefaultExt))
              MatchingPattern = i
            EndIf
          EndIf
          
          Result = AppendFilePattern(Result, Pattern()\Name, Pattern()\RawPattern, #False)
        Next i
      EndIf
      
      If (*DefaultPattern\i < 0)
        If (MatchingPattern >= 0)
          *DefaultPattern\i = MatchingPattern
        ElseIf ((DefaultExt <> "") And (AllFilesPattern >= 0))
          *DefaultPattern\i = AllFilesPattern
        Else
          *DefaultPattern\i = 0
        EndIf
      EndIf
      
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.s NextSelectedFileNameEx()
      _RequesterExLastIndex + 1
      ProcedureReturn (StringField(_RequesterExFileList, 1 + _RequesterExLastIndex, #LF$))
    EndProcedure
    
    Procedure.s SelectedFileListEx()
      ProcedureReturn (_RequesterExFileList)
    EndProcedure
    
    Procedure.s SaveFileRequesterEx(Title.s = "", DefaultFile.s = "", Pattern.s = "", PatternPosition.i = #PB_Default, ParentID.i = #Null)
      Protected Result.s = ""
      
      Title = MapEmptyString(Title, "Save")
      Protected DefaultFolder.s, DefaultFileName.s
      If (DefaultFile)
        If (FileSize(DefaultFile) = #PB_FileSize_Directory)
          DefaultFile = EnsurePathSeparator(DefaultFile)
        EndIf
        DefaultFolder   = GetPathPart(DefaultFile)
        DefaultFileName = GetFilePart(DefaultFile)
      Else
        DefaultFolder   = GetCurrentDirectory()
        DefaultFileName = ""
      EndIf
      CompilerIf (#IsWindowsBuild And (#True))
        DefaultFolder = DefaultFolder + Str(Date()) + #PS$ + ".." + #PS$
      CompilerEndIf
      DefaultFile = DefaultFolder + DefaultFileName
      Pattern = MapEmptyString(Pattern, "All Files|*.*")
      Pattern = _RequesterExFormatPatterns(Pattern, DefaultFileName, @PatternPosition)
      
      CompilerIf (#RequestersSupportParentID)
        Result = SaveFileRequester(Title, DefaultFile, Pattern, PatternPosition, ParentID)
      CompilerElse
        Result = SaveFileRequester(Title, DefaultFile, Pattern, PatternPosition)
      CompilerEndIf
      If (Result)
        If (GetExtensionPart(Result) = "")
          CompilerIf (#True)
            PatternPosition = SelectedFilePattern()
          CompilerElse
            PatternPosition = 0
          CompilerEndIf
          Protected Extension.s = StringField(Pattern, 2*PatternPosition + 2, "|")
          Extension = RemoveSpaces(Extension)
          Extension = StringField(Extension, 1, ";")
          Extension = RemoveString(Extension, "*.")
          If (Extension And (Extension <> "*"))
            Result + "." + Extension
          EndIf
        EndIf
      EndIf
      
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.s OpenFileRequesterEx(Title.s = "", DefaultFile.s = "", Pattern.s = "", PatternPosition.i = #PB_Default, MultiSelect.i = #False, ParentID.i = #Null)
      Protected Result.s = ""
      
      Title = MapEmptyString(Title, "Open")
      Protected DefaultFolder.s, DefaultFileName.s
      If (DefaultFile)
        If (FileSize(DefaultFile) = #PB_FileSize_Directory)
          DefaultFile = EnsurePathSeparator(DefaultFile)
        EndIf
        DefaultFolder   = GetPathPart(DefaultFile)
        DefaultFileName = GetFilePart(DefaultFile)
      Else
        DefaultFolder   = GetCurrentDirectory()
        DefaultFileName = ""
      EndIf
      CompilerIf (#IsWindowsBuild And (#True))
        DefaultFolder = DefaultFolder + Str(Date()) + #PS$ + ".." + #PS$
      CompilerEndIf
      DefaultFile = DefaultFolder + DefaultFileName
      Pattern = MapEmptyString(Pattern, "All Files|*.*")
      Pattern = _RequesterExFormatPatterns(Pattern, DefaultFileName, @PatternPosition)
      Protected Flags.i = Bool(MultiSelect) * #PB_Requester_MultiSelection
      
      CompilerIf (#RequestersSupportParentID)
        Protected FirstSelected.s = OpenFileRequester(Title, DefaultFile, Pattern, PatternPosition, Flags, ParentID)
      CompilerElse
        Protected FirstSelected.s = OpenFileRequester(Title, DefaultFile, Pattern, PatternPosition, Flags)
      CompilerEndIf
      _RequesterExFileList = FirstSelected
      _RequesterExLastIndex = 0
      If (FirstSelected)
        Result = FirstSelected
        If (Flags & #PB_Requester_MultiSelection)
          Protected NextFile.s = NextSelectedFileName()
          While (NextFile)
            _RequesterExFileList + #LF$ + NextFile
            NextFile = NextSelectedFileName()
          Wend
          If (#False) ; Return entire list in initial result? NO, for compatibility with PB native function
            Result = _RequesterExFileList
          EndIf
        EndIf
      EndIf
      
      ProcedureReturn (Result)
    EndProcedure
    
    CompilerIf (#True) ; Patch native commands?
      
      Macro NextSelectedFileName()
        NextSelectedFileNameEx()
      EndMacro
      
      Macro SelectedFileList()
        SelectedFileListEx()
      EndMacro
      
      Macro OpenFileRequester(_Title, _DefaultFile, _Pattern, _PatternPosition, _Flags = #Null, _ParentID = #Null)
        OpenFileRequesterEx(_Title, _DefaultFile, _Pattern, (_PatternPosition), (_Flags), (_ParentID))
      EndMacro
      
      Macro SaveFileRequester(_Title, _DefaultFile, _Pattern, _PatternPosition, _ParentID = #Null)
        SaveFileRequesterEx(_Title, _DefaultFile, _Pattern, (_PatternPosition), (_ParentID))
      EndMacro
      
    CompilerEndIf
    
  CompilerEndIf
  
CompilerEndIf
;-
