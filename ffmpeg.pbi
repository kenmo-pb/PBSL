; +-------------------------------------+
; | PureBasic Standard Library - FFmpeg |
; +-------------------------------------+
; | https://ffmpeg.org/ffmpeg.html

;-
CompilerIf (Not Defined(_PBSL_FFmpeg_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_FFmpeg_Included, #PB_Constant))
  #_PBSL_FFmpeg_Included = #True
  
  ;- - FFmpeg Constants (Private)
  
  #_FFmpeg_DefaultExecutable = WindowsElse("ffmpeg", "ffmpeg")
  
  #_FFmpeg_SuccessCode = $00
  
  #_FFmpeg_PixelMultipleForImages = 1
  #_FFmpeg_PixelMultipleForVideos = 2;4
  
  ;-
  ;- - FFmpeg Globals (Private)
  
  Global _FFmpegInit.i    = #False
  Global _FFmpegExe.s     = #_FFmpeg_DefaultExecutable
  Global _FFmpegVersion.s = ""
  
  Global _FFmpegOverwrite.i = #False
  
  Global NewMap _FFmpegMetadata.s()
  
  Threaded _FFmpegTempFile.s = ""
  Threaded _FFmpegDestinationFile.s = ""
  
  Threaded _FFmpegPixelMultiple.i = 1
  
  ;-
  ;- - FFmpeg Macros (Private)
  
  Macro _FFmpegExecute()
    RunProgramExitCodeHidden(_FFmpegExe, Params, GetCurrentDirectory(), #Null)
  EndMacro
  
  Macro _FFmpegAddInputParams()
    Params + ""
  EndMacro
  Macro _FFmpegAddInputFile(_File)
    Params + " -i " + Quote(_File)
  EndMacro
  Macro _FFmpegAddOutputParams()
    If (_FFmpegOverwrite)
      Params + " -y"
    Else
      Params + " -n"
    EndIf
  EndMacro
  Macro _FFmpegCopyVideoCodec()
    Params + " -c:v copy"
  EndMacro
  Macro _FFmpegCopyAudioCodec()
    Params + " -c:a copy"
  EndMacro
  Macro _FFmpegAddMetadataParams()
    Params + _FFmpegMetadataParamsString()
  EndMacro
  Macro _FFmpegAddOutputFile(_File)
    Params + " " + Quote(_File)
  EndMacro
  Macro _FFmpegAddFinalParams()
    Params + ""
    ;Debug Params
  EndMacro
  
  Macro _FFmpegPushIfOverwritingSelf(_InputFile, _OutputFileVar)
    If (_InputFile = _OutputFileVar)
      _OutputFileVar = _FFmpegPushTempFile(_OutputFileVar)
    EndIf
  EndMacro
  
  Macro _FFmpegPopIfOverwritingSelf(_OutputFileVar)
    _OutputFileVar = _FFmpegPopTempFile(_OutputFileVar)
  EndMacro
  
  ;-
  ;- - FFmpeg Macros (Public)
  
  Macro ConvertAudioFile(_InputFile, _OutputFile)
    ConvertMediaFile(_InputFile, _OutputFile)
  EndMacro
  Macro ConvertVideoFile(_InputFile, _OutputFile)
    ConvertMediaFile(_InputFile, _OutputFile)
  EndMacro
  Macro ConvertImageFile(_InputFile, _OutputFile)
    ConvertMediaFile(_InputFile, _OutputFile)
  EndMacro
  
  ;-
  ;- - FFmpeg Procedures (Private)
  
  Procedure.i _FFmpegValidateExe(Executable.s)
    Protected Result.i = #False
    If (Executable)
      ;If (FileExists(Executable)) ; if we require this, then 'ffmpeg' found via $PATH won't work
      Protected Output.s = RunProgramOutputHidden(Executable, "-version", GetCurrentDirectory())
      If (Output)
        _FFmpegVersion = Between(Output, "version ", " Copyright")
        If (_FFmpegVersion Or (#True))
          Result = #True
        EndIf
      EndIf
      ;EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i _FFmpegInitInternal()
    If (Not _FFmpegInit)
      If (_FFmpegValidateExe(_FFmpegExe))
        _FFmpegInit = #True
      EndIf
    EndIf
    ProcedureReturn (_FFmpegInit)
  EndProcedure
  
  Procedure.s _FFmpegTimestamp(Seconds.d)
    Protected Result.s
    If (#False)
      ; HH:MM:SS._ms
    Else
      Result = StrD(Seconds, 3)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s _FFmpegGetFileInfo(File.s, VideoOnly.i = #False)
    Protected Result.s = ""
    If (File And FileExists(File))
      If (_FFmpegInitInternal())
        Protected Params.s = ""
        If (VideoOnly)
          Params + " -an"
        EndIf
        Params + " -i " + Quote(File)
        Result = RunProgramOutputHidden(_FFmpegExe, Params, GetCurrentDirectory())
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i _FFmpegGetFileVideoDimension(File.s, GetHeight.i)
    Protected Result.i = 0
    If (File)
      Protected Output.s = _FFmpegGetFileInfo(File, #True)
      Output = After(Output, "Input #")
      If (Output)
        Output = After(Output, "Video:")
        If (Output)
          Protected N.i = 1 + CountString(Output, ",")
          Protected i.i
          For i = 1 To N
            Protected Term.s = Trim(StringField(Output, i, ","))
            If (CountString(Term, "x") = 1)
              Protected Width.i  = Val(StringField(Term, 1, "x"))
              Protected Height.i = Val(StringField(Term, 2, "x"))
              If ((Width > 0) And (Height > 0))
                If (GetHeight)
                  Result = Height
                Else
                  Result = Width
                EndIf
                Break
              EndIf
            EndIf
          Next i
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s _FFmpegPushTempFile(OutputFile.s)
    _FFmpegDestinationFile = OutputFile
    _FFmpegTempFile = UniqueFileName("ffmpeg", "." + GetExtensionPart(OutputFile), GetTemporaryDirectory())
    ;Debug "Temporarily writing " + _FFmpegTempFile
    ;Debug "  instead of " + _FFmpegDestinationFile
    ProcedureReturn (_FFmpegTempFile)
  EndProcedure
  
  Procedure.s _FFmpegPopTempFile(OutputFile.s)
    If (_FFmpegDestinationFile And _FFmpegTempFile)
      DeleteFile(_FFmpegDestinationFile)
      If (FileExists(_FFmpegTempFile))
        RenameFile(_FFmpegTempFile, _FFmpegDestinationFile)
      EndIf
      OutputFile = _FFmpegDestinationFile
      _FFmpegDestinationFile = ""
      _FFmpegTempFile = ""
    EndIf
    ProcedureReturn (OutputFile)
  EndProcedure
  
  Procedure.s _FFmpegEscapeAndQuote(Param.s)
    Protected Result.s = ""
    If (#True)
      Param = ReplaceString(Param, #DQ$, #SQ$)
    EndIf
    Result = Quote(Param)
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s _FFmpegMetadataParamsString()
    Protected Result.s = ""
    ; https://gist.github.com/eyecatchup/0757b3d8b989fe433979db2ea7d95a01
    ForEach _FFmpegMetadata()
      If (MapKey(_FFmpegMetadata()))
        Result + " -metadata " + MapKey(_FFmpegMetadata()) + "=" + _FFmpegEscapeAndQuote(_FFmpegMetadata())
      EndIf
    Next
    If (Result)
      If (#True)
        Result + " -id3v2_version 3"
      EndIf
      If (#True)
        Result + " -write_id3v1 1"
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - FFmpeg Procedures (Public)
  
  Procedure.i InitFFmpeg(Executable.s = "")
    _FFmpegInit = #False
    _FFmpegExe = MapEmptyString(Executable, #_FFmpeg_DefaultExecutable)
    ProcedureReturn (_FFmpegInitInternal())
  EndProcedure
  
  Procedure.s GetFFmpegVersionString()
    If (_FFmpegInit)
      ProcedureReturn (_FFmpegVersion)
    EndIf
    ProcedureReturn ("")
  EndProcedure
  
  Procedure SetFFmpegOverwrite(State.i)
    _FFmpegOverwrite = Bool(State)
  EndProcedure
  
  Procedure.i RunFFmpegCustomFilter(InputFile.s, VideoFilter.s, AudioFilter.s, OutputFile.s = "")
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile)
      If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          _FFmpegAddInputParams()
          _FFmpegAddInputFile(InputFile)
          _FFmpegAddOutputParams()
          VideoFilter = RemoveString(VideoFilter, "-filter:v", #PB_String_NoCase)
          If (VideoFilter)
            Params + " -filter:v "
            If (Asc(VideoFilter) = #DQ)
              Params + VideoFilter
            Else
              Params + Quote(VideoFilter)
            EndIf
          Else
            _FFmpegCopyVideoCodec()
          EndIf
          AudioFilter = RemoveString(VideoFilter, "-filter:a", #PB_String_NoCase)
          If (AudioFilter)
            Params + " -filter:a "
            If (Asc(AudioFilter) = #DQ)
              Params + AudioFilter
            Else
              Params + Quote(AudioFilter)
            EndIf
          Else
            _FFmpegCopyAudioCodec()
          EndIf
          _FFmpegAddOutputFile(OutputFile)
          _FFmpegAddFinalParams()
          Protected ExitCode.i = _FFmpegExecute()
          _FFmpegPopIfOverwritingSelf(OutputFile)
          If (ExitCode = #_FFmpeg_SuccessCode)
            If (FileExists(OutputFile))
              Result = #True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  CompilerIf (Not Defined(SeemsAudioFile, #PB_Procedure))
    Procedure.i SeemsAudioFile(FileOrExtension.s)
      Protected Result.i = #False
      If (GetExtensionPart(FileOrExtension))
        FileOrExtension = GetExtensionPart(FileOrExtension)
      EndIf
      FileOrExtension = LCase(RemoveString(RemoveString(FileOrExtension, "."), "*"))
      Select (FileOrExtension)
        Case "wav", "mp3", "m4a", "wma", "ogg", "flac", "aac", "fla"
          Result = #True
      EndSelect
      ProcedureReturn (Result)
    EndProcedure
  CompilerEndIf
  
  CompilerIf (Not Defined(SeemsVideoFile, #PB_Procedure))
    Procedure.i SeemsVideoFile(FileOrExtension.s)
      Protected Result.i = #False
      If (GetExtensionPart(FileOrExtension))
        FileOrExtension = GetExtensionPart(FileOrExtension)
      EndIf
      FileOrExtension = LCase(RemoveString(RemoveString(FileOrExtension, "."), "*"))
      Select (FileOrExtension)
        Case "mp4", "avi", "mpg", "mpeg", "wmv", "mkv", "webm", "flv"
          Result = #True
        Case "dat"
          Result = #True
      EndSelect
      ProcedureReturn (Result)
    EndProcedure
  CompilerEndIf
  
  CompilerIf (Not Defined(SeemsImageFile, #PB_Procedure))
    Procedure.i SeemsImageFile(FileOrExtension.s)
      Protected Result.i = #False
      If (GetExtensionPart(FileOrExtension))
        FileOrExtension = GetExtensionPart(FileOrExtension)
      EndIf
      FileOrExtension = LCase(RemoveString(RemoveString(FileOrExtension, "."), "*"))
      Select (FileOrExtension)
        Case "bmp", "jpg", "jpeg", "png", "webp", "tif", "tiff", "tga"
          Result = #True
        Case "gif" ; consider GIF a 'video' ?
          Result = #True
      EndSelect
      ProcedureReturn (Result)
    EndProcedure
  CompilerEndIf
  
  ;-
  ;- - Get Media Info
  
  Procedure.i GetMediaDurationMilliseconds(File.s)
    Protected Result.i = 0
    If (File)
      Protected Output.s = _FFmpegGetFileInfo(File)
      Output = RemoveSpaces(Between(Output, "Duration: ", ","))
      If (Output)
        If (CountString(Output, ".") = 1)
          Result = Val(LSet(StringField(Output, 2, "."), 3, "0"))
          Output = StringField(Output, 1, ".")
          Select (CountString(Output, ":"))
            Case 2 ; HH:MM:SS
              Result + 1000 * Val(StringField(Output, 1, ":")) * 60 * 60
              Result + 1000 * Val(StringField(Output, 2, ":")) * 60
              Result + 1000 * Val(StringField(Output, 3, ":"))
            Case 1 ; MM:SS
              Result + 1000 * Val(StringField(Output, 1, ":")) * 60
              Result + 1000 * Val(StringField(Output, 2, ":"))
            Case 0 ; SS
              Result + 1000 * Val(Output)
            Default ; invalid?
              Result = 0
          EndSelect
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.d GetMediaDurationSeconds(File.s)
    ProcedureReturn (0.001 * GetMediaDurationMilliseconds(File))
  EndProcedure
  
  Procedure.i GetMediaWidth(File.s)
    ProcedureReturn (_FFmpegGetFileVideoDimension(File, #False))
  EndProcedure
  
  Procedure.i GetMediaHeight(File.s)
    ProcedureReturn (_FFmpegGetFileVideoDimension(File, #True))
  EndProcedure
  
  ;-
  ;- - General Processing
  
  Procedure.i _FFmpegTemplateIfCanOverwriteSelf(InputFile.s, OutputFile.s = "")
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile)
      If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          _FFmpegAddInputParams()
          _FFmpegAddInputFile(InputFile)
          _FFmpegAddOutputParams()
          _FFmpegAddOutputFile(OutputFile)
          _FFmpegAddFinalParams()
          Protected ExitCode.i = _FFmpegExecute()
          _FFmpegPopIfOverwritingSelf(OutputFile)
          If (ExitCode = #_FFmpeg_SuccessCode)
            If (FileExists(OutputFile))
              Result = #True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i _FFmpegTemplateIfCannotOverwriteSelf(InputFile.s, OutputFile.s)
    Protected Result.i = #False
    If (InputFile And OutputFile)
      If (InputFile <> OutputFile)
        If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
          If (_FFmpegInitInternal())
            Protected Params.s
            _FFmpegAddInputParams()
            _FFmpegAddInputFile(InputFile)
            _FFmpegAddOutputParams()
            _FFmpegAddOutputFile(OutputFile)
            _FFmpegAddFinalParams()
            If (_FFmpegExecute() = #_FFmpeg_SuccessCode)
              If (FileExists(OutputFile))
                Result = #True
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ConvertMediaFile(InputFile.s, OutputFile.s)
    Protected Result.i = #False
    If (InputFile And OutputFile)
      If (InputFile <> OutputFile)
        If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
          If (_FFmpegInitInternal())
            Protected Params.s
            _FFmpegAddInputParams()
            _FFmpegAddInputFile(InputFile)
            _FFmpegAddOutputParams()
            _FFmpegAddOutputFile(OutputFile)
            _FFmpegAddFinalParams()
            If (_FFmpegExecute() = #_FFmpeg_SuccessCode)
              If (FileExists(OutputFile))
                Result = #True
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        Result = #True ; indicate "success" to convert a file into itself??
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ResetMediaMetadataStrings()
    ClearMap(_FFmpegMetadata())
    ProcedureReturn (#True)
  EndProcedure
  
  Procedure.i SetMediaMetadataString(TagName.s, TagValue.s)
    Protected Result.i = #False
    TagName = Trim(TagName)
    If (TagName)
      If (TagValue)
        AddMapElement(_FFmpegMetadata(), TagName)
        _FFmpegMetadata() = TagValue
      Else
        DeleteMapElement(_FFmpegMetadata(), TagName)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i WriteMediaFileMetadata(InputFile.s, OutputFile.s = "", PreserveExistingTags.i = #False)
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile)
      If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          _FFmpegAddInputParams()
          _FFmpegAddInputFile(InputFile)
          _FFmpegAddOutputParams()
          _FFmpegCopyAudioCodec()
          _FFmpegCopyVideoCodec()
          If (Not PreserveExistingTags)
            Params + " -map_metadata -1"
            If (#False)
              Params + " -map_metadata:s:a -1"
              Params + " -map_metadata:s:v -1"
            EndIf
          EndIf
          _FFmpegAddMetadataParams()
          _FFmpegAddOutputFile(OutputFile)
          _FFmpegAddFinalParams()
          Debug Params
          Protected ExitCode.i = _FFmpegExecute()
          _FFmpegPopIfOverwritingSelf(OutputFile)
          If (ExitCode = #_FFmpeg_SuccessCode)
            If (FileExists(OutputFile))
              Result = #True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i RemoveMediaFileMetadata(InputFile.s, OutputFile.s = "")
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile)
      If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          _FFmpegAddInputParams()
          _FFmpegAddInputFile(InputFile)
          _FFmpegAddOutputParams()
          _FFmpegCopyAudioCodec()
          _FFmpegCopyVideoCodec()
          ; https://gist.github.com/eyecatchup/0757b3d8b989fe433979db2ea7d95a01
          Params + " -map_metadata -1"
          If (#True)
            Params + " -map_metadata:s:a -1"
            Params + " -map_metadata:s:v -1"
          EndIf
          _FFmpegAddOutputFile(OutputFile)
          _FFmpegAddFinalParams()
          Protected ExitCode.i = _FFmpegExecute()
          _FFmpegPopIfOverwritingSelf(OutputFile)
          If (ExitCode = #_FFmpeg_SuccessCode)
            If (FileExists(OutputFile))
              Result = #True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - Video Processing
  
  Procedure.i ExtractFrameFromVideo(InputVideoFile.s, OutputImageFile.s, Seconds.d = 0.000)
    Protected Result.i = #False
    If (InputVideoFile And OutputImageFile And (InputVideoFile <> OutputImageFile) And (Seconds >= 0.0))
      If (_FFmpegOverwrite Or (Not FileExists(OutputImageFile)))
        If (_FFmpegInitInternal())
          Protected Params.s
          ; https://www.ffmpeg-micro.com/blog/extract-frames-from-video-ffmpeg
          _FFmpegAddInputParams()
          Params + " -ss " + _FFmpegTimestamp(Seconds)
          _FFmpegAddInputFile(InputVideoFile)
          _FFmpegAddOutputParams()
          Params + " -frames:v 1"
          _FFmpegAddOutputFile(OutputImageFile)
          _FFmpegAddFinalParams()
          If (_FFmpegExecute() = #_FFmpeg_SuccessCode)
            If (FileExists(OutputImageFile))
              Result = #True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ResizeMediaFile(InputFile.s, Width.i, Height.i, OutputFile.s = "")
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile And (Width > 0) And (Height > 0))
      If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          ; https://superuser.com/questions/624563/how-to-resize-a-video-to-make-it-smaller-with-ffmpeg
          _FFmpegAddInputParams()
          _FFmpegAddInputFile(InputFile)
          _FFmpegAddOutputParams()
          Params + " -s " + Str(Width) + "x" + Str(Height)
          If (Not SeemsImageFile(InputFile))
            _FFmpegCopyAudioCodec()
          EndIf
          _FFmpegAddOutputFile(OutputFile)
          _FFmpegAddFinalParams()
          Protected ExitCode.i = _FFmpegExecute()
          _FFmpegPopIfOverwritingSelf(OutputFile)
          If (ExitCode = #_FFmpeg_SuccessCode)
            If (FileExists(OutputFile))
              Result = #True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ResizeMediaFileToWidth(InputFile.s, Width.i, OutputFile.s = "")
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile And (Width > 0))
      If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          ; https://superuser.com/questions/624563/how-to-resize-a-video-to-make-it-smaller-with-ffmpeg
          _FFmpegAddInputParams()
          _FFmpegAddInputFile(InputFile)
          _FFmpegAddOutputParams()
          If (_FFmpegPixelMultiple < 1)
            _FFmpegPixelMultiple = 0
          EndIf
          Params + " -filter:v scale=" + Str(Width) + ":-" + Str(_FFmpegPixelMultiple)
          If (Not SeemsImageFile(InputFile))
            _FFmpegCopyAudioCodec()
          EndIf
          _FFmpegAddOutputFile(OutputFile)
          _FFmpegAddFinalParams()
          Protected ExitCode.i = _FFmpegExecute()
          _FFmpegPopIfOverwritingSelf(OutputFile)
          If (ExitCode = #_FFmpeg_SuccessCode)
            If (FileExists(OutputFile))
              Result = #True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ResizeMediaFileToHeight(InputFile.s, Height.i, OutputFile.s = "")
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile And (Height > 0))
      If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          ; https://superuser.com/questions/624563/how-to-resize-a-video-to-make-it-smaller-with-ffmpeg
          _FFmpegAddInputParams()
          _FFmpegAddInputFile(InputFile)
          _FFmpegAddOutputParams()
          If (_FFmpegPixelMultiple < 1)
            _FFmpegPixelMultiple = 0
          EndIf
          Params + " -filter:v scale=-" + Str(_FFmpegPixelMultiple) + ":" + Str(Height)
          If (Not SeemsImageFile(InputFile))
            _FFmpegCopyAudioCodec()
          EndIf
          _FFmpegAddOutputFile(OutputFile)
          _FFmpegAddFinalParams()
          Protected ExitCode.i = _FFmpegExecute()
          _FFmpegPopIfOverwritingSelf(OutputFile)
          If (ExitCode = #_FFmpeg_SuccessCode)
            If (FileExists(OutputFile))
              Result = #True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ResizeImageFileToWidth(InputFile.s, Width.i, OutputFile.s = "")
    _FFmpegPixelMultiple = #_FFmpeg_PixelMultipleForImages
    ProcedureReturn (ResizeMediaFileToWidth(InputFile, Width, OutputFile))
  EndProcedure
  Procedure.i ResizeImageFileToHeight(InputFile.s, Height.i, OutputFile.s = "")
    _FFmpegPixelMultiple = #_FFmpeg_PixelMultipleForImages
    ProcedureReturn (ResizeMediaFileToHeight(InputFile, Height, OutputFile))
  EndProcedure
  
  Procedure.i ResizeVideoFileToWidth(InputFile.s, Width.i, OutputFile.s = "")
    _FFmpegPixelMultiple = #_FFmpeg_PixelMultipleForVideos
    ProcedureReturn (ResizeMediaFileToWidth(InputFile, Width, OutputFile))
  EndProcedure
  Procedure.i ResizeVideoFileToHeight(InputFile.s, Height.i, OutputFile.s = "")
    _FFmpegPixelMultiple = #_FFmpeg_PixelMultipleForVideos
    ProcedureReturn (ResizeMediaFileToHeight(InputFile, Height, OutputFile))
  EndProcedure
  
  ;-
  ;- - Audio Processing
  
  Procedure.i RemoveAudio(InputFile.s, OutputFile.s = "")
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile)
      If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          _FFmpegAddInputParams()
          Params + " -an"
          _FFmpegAddInputFile(InputFile)
          _FFmpegAddOutputParams()
          _FFmpegCopyVideoCodec()
          _FFmpegAddOutputFile(OutputFile)
          _FFmpegAddFinalParams()
          Protected ExitCode.i = _FFmpegExecute()
          _FFmpegPopIfOverwritingSelf(OutputFile)
          If (ExitCode = #_FFmpeg_SuccessCode)
            If (FileExists(OutputFile))
              Result = #True
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i NormalizeLoudness(InputFile.s, TargetLUFS.d = -16.0, OutputFile.s = "")
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile)
      If (_FFmpegOverwrite Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          If (#True)
            Params + " -hide_banner"
          EndIf
          _FFmpegAddInputFile(InputFile)
          ; https://k.ylo.ph/2016/04/04/loudnorm.html
          Params + " -af loudnorm=I=" + StrD(TargetLUFS, 1) + ":TP=-1.5:LRA=11:print_format=json"
          Params + " -f null -"
          Protected Text.s = RunProgramOutputHidden(_FFmpegExe, Params, GetCurrentDirectory())
          Text = After(Text, "Parsed_loudnorm")
          Text = Between(Text, "{", "}")
          Protected MeasuredI.s, MeasuredLRA.s, MeasuredTP.s, MeasuredThresh.s, Offset.s
          If (Text)
            Text = "{" + Text + "}"
            ;Debug Text
            Protected JSON.i = ParseJSON(#PB_Any, Text)
            If (JSON)
              Protected *Obj = JSONValue(JSON)
              If (*Obj And (JSONType(*Obj) = #PB_JSON_Object))
                MeasuredI      = GetJSONString(GetJSONMember(*Obj, "input_i"))
                MeasuredLRA    = GetJSONString(GetJSONMember(*Obj, "input_lra"))
                MeasuredTP     = GetJSONString(GetJSONMember(*Obj, "input_tp"))
                MeasuredThresh = GetJSONString(GetJSONMember(*Obj, "input_thresh"))
                Offset         = GetJSONString(GetJSONMember(*Obj, "target_offset"))
                Result = #True
              EndIf
              FreeJSON(JSON)
            EndIf
          EndIf
          If (Result)
            Result = #False
            Params = ""
            _FFmpegAddInputParams()
            _FFmpegAddInputFile(InputFile)
            _FFmpegAddOutputParams()
            Params + " -af loudnorm=I=" + StrD(TargetLUFS, 1) + ":TP=-1.5:LRA=11"
            Params + ":measured_I="      + MeasuredI
            Params + ":measured_LRA="    + MeasuredLRA
            Params + ":measured_TP="     + MeasuredTP
            Params + ":measured_thresh=" + MeasuredThresh
            Params + ":offset="          + Offset
            If (#True)
              Params + ":linear=true"
            EndIf
            If (#True)
              Params + ":print_format=summary"
            EndIf
            Protected AudioRateStr.s = "48k"
            If (AudioRateStr <> "")
              Params + " -ar " + AudioRateStr
            EndIf
            If (Not SeemsAudioFile(InputFile))
              _FFmpegCopyVideoCodec()
            EndIf
            _FFmpegAddOutputFile(OutputFile)
            _FFmpegAddFinalParams()
            Protected ExitCode.i = _FFmpegExecute()
            _FFmpegPopIfOverwritingSelf(OutputFile)
            If (ExitCode = #_FFmpeg_SuccessCode)
              If (FileExists(OutputFile))
                Result = #True
              EndIf
            EndIf
          Else
            _FFmpegPopIfOverwritingSelf(OutputFile)
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i LoudNorm(InputFile.s, TargetLUFS.d = -16.0, OutputFile.s = "")
    ProcedureReturn (NormalizeLoudness(InputFile, TargetLUFS, OutputFile))
  EndProcedure
  
CompilerEndIf
;-
