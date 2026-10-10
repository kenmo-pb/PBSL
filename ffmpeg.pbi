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
  
  #_FFmpeg_DefaultExecutable = WLMO("ffmpeg", "ffmpeg", "ffmpeg", "ffmpeg")
  
  #_FFmpeg_SuccessCode = $00
  
  #_FFmpeg_PixelMultipleForImages = 1
  #_FFmpeg_PixelMultipleForVideos = 2;4
  
  ;-
  ;- - FFmpeg Globals (Private)
  
  Global _FFmpegInit.i    = #False
  Global _FFmpegExe.s     = #_FFmpeg_DefaultExecutable
  Global _FFmpegVersion.s = ""
  
  Global _FFmpegOverwrite.i = #True
  
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
  Macro _FFmpegAddOutputFile(_File)
    Params + " " + Quote(_File)
  EndMacro
  Macro _FFmpegAddFinalParams()
    Params + ""
    ;Debug Params
  EndMacro
  
  Macro _FFmpegPushIfOverwritingSelf(_InputFile, _OutputFile)
    If (_InputFile = _OutputFile)
      _OutputFile = _FFmpegPushTempFile(_OutputFile)
    EndIf
  EndMacro
  
  Macro _FFmpegPopIfOverwritingSelf(_OutputFile)
    _OutputFile = _FFmpegPopTempFile(_OutputFile)
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
  
  Procedure.s _FFmpegGetFileInfo(File.s)
    Protected Result.s = ""
    If (File And FileExists(File))
      If (_FFmpegInitInternal())
        Result = RunProgramOutputHidden(_FFmpegExe, "-i " + Quote(File), GetCurrentDirectory())
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
  
  ;-
  
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
  
  ;-
  
  Procedure SetFFmpegOverwrite(State.i)
    _FFmpegOverwrite = Bool(State)
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
      If (_FFmpegOverwrite Or (InputFile = OutputFile) Or (Not FileExists(OutputFile)))
        If (_FFmpegInitInternal())
          _FFmpegPushIfOverwritingSelf(InputFile, OutputFile)
          Protected Params.s
          ; https://superuser.com/questions/624563/how-to-resize-a-video-to-make-it-smaller-with-ffmpeg
          _FFmpegAddInputParams()
          _FFmpegAddInputFile(InputFile)
          _FFmpegAddOutputParams()
          Params + " -s " + Str(Width) + "x" + Str(Height)
          If (Not SeemsImageFile(InputFile))
            Params + " -c:a copy"
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
      If (_FFmpegOverwrite Or (InputFile = OutputFile) Or (Not FileExists(OutputFile)))
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
            Params + " -c:a copy"
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
      If (_FFmpegOverwrite Or (InputFile = OutputFile) Or (Not FileExists(OutputFile)))
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
            Params + " -c:a copy"
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
  
  Procedure.i RunFFmpegCustomFilter(InputFile.s, VideoFilter.s, AudioFilter.s, OutputFile.s = "")
    Protected Result.i = #False
    OutputFile = MapEmptyString(OutputFile, InputFile)
    If (InputFile)
      If (_FFmpegOverwrite Or (InputFile = OutputFile) Or (Not FileExists(OutputFile)))
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
            Params + " -c:v copy"
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
            Params + " -c:a copy"
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
  
CompilerEndIf
;-
