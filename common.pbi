; +-------------------------------------+
; | PureBasic Standard Library - Common |
; +-------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  #_PBSL_Common_Included = #True
  
  CompilerIf (#PB_Compiler_Version < 510) ; for Bool, IsMainFile, line continuation, etc.
    CompilerError "PBSL requires PureBasic 5.10 or newer"
  CompilerEndIf
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - OS Information
  
  CompilerIf (#PB_Compiler_OS = #PB_OS_Windows)
    Macro WLMO(_WindowsExpr, _LinuxExpr, _MacExpr, _OtherExpr)
      _WindowsExpr
    EndMacro
    Macro WindowsElse(_WindowsExpr, _ElseExpr)
      _WindowsExpr
    EndMacro
    Macro OnWindows(_WindowsExpr)
      _WindowsExpr
    EndMacro
  CompilerElse
    Macro WindowsElse(_WindowsExpr, _ElseExpr)
      _ElseExpr
    EndMacro
    Macro OnWindows(_WindowsExpr)
      ;
    EndMacro
  CompilerEndIf
  
  CompilerIf (#PB_Compiler_OS = #PB_OS_Linux)
    Macro WLMO(_WindowsExpr, _LinuxExpr, _MacExpr, _OtherExpr)
      _LinuxExpr
    EndMacro
    Macro LinuxElse(_LinuxExpr, _ElseExpr)
      _LinuxExpr
    EndMacro
    Macro OnLinux(_LinuxExpr)
      _LinuxExpr
    EndMacro
  CompilerElse
    Macro LinuxElse(_LinuxExpr, _ElseExpr)
      _ElseExpr
    EndMacro
    Macro OnLinux(_LinuxExpr)
      ;
    EndMacro
  CompilerEndIf
  
  CompilerIf (#PB_Compiler_OS = #PB_OS_MacOS)
    Macro WLMO(_WindowsExpr, _LinuxExpr, _MacExpr, _OtherExpr)
      _MacExpr
    EndMacro
    Macro MacElse(_MacExpr, _ElseExpr)
      _MacExpr
    EndMacro
    Macro OnMac(_MacExpr)
      _MacExpr
    EndMacro
  CompilerElse
    Macro MacElse(_MacExpr, _ElseExpr)
      _ElseExpr
    EndMacro
    Macro OnMac(_MacExpr)
      ;
    EndMacro
  CompilerEndIf
  
  #IsWindowsBuild = WindowsElse(#True, #False)
  #IsLinuxBuild   = LinuxElse(#True, #False)
  #IsMacBuild     = MacElse(#True, #False)
  #IsUnixBuild    = WindowsElse(#False, #True)
  
  #OSName$ = WLMO("Windows", "Linux", "Mac", "Other")
  
  CompilerIf (#IsUnixBuild)
    Macro UnixElse(_UnixExpr, _ElseExpr)
      _UnixExpr
    EndMacro
    Macro OnUnix(_UnixExpr)
      _UnixExpr
    EndMacro
  CompilerElse
    Macro UnixElse(_UnixExpr, _ElseExpr)
      _ElseExpr
    EndMacro
    Macro OnUnix(_UnixExpr)
      ;
    EndMacro
  CompilerEndIf
  
  ;-
  ;- - Build Information
  
  #IsDebugging    = #PB_Compiler_Debugger
  #IsThreadSafe   = #PB_Compiler_Thread
  #IsConsoleBuild = Bool(#PB_Compiler_ExecutableFormat = #PB_Compiler_Console)
  
  CompilerIf (SizeOf(INTEGER) = 8)
    #Is32BitBuild = #False
    #Is64BitBuild = #True
    
    #PB_Compiler_32Bit = #False
    #PB_Compiler_64Bit = #True
    
    #IntSize = 8
  CompilerElse
    #Is32BitBuild = #True
    #Is64BitBuild = #False
    
    #PB_Compiler_32Bit = #True
    #PB_Compiler_64Bit = #False
    
    #IntSize = 4
  CompilerEndIf
  
  CompilerIf (#PB_Compiler_Unicode)
    #IsAsciiBuild   = #False
    #IsUnicodeBuild = #True
    
    #InternalStringFormat  = #PB_Unicode
    #DefaultIOStringFormat = #PB_UTF8
    
    #CharSize = 2
  CompilerElse
    #IsAsciiBuild   = #True
    #IsUnicodeBuild = #False
    
    #InternalStringFormat  = #PB_Ascii
    #DefaultIOStringFormat = #PB_Ascii
    
    #CharSize = 1
  CompilerEndIf
  
  #PB_Compiler_Examples            = #PB_Compiler_Home     + WindowsElse("Examples\", "examples/")
  #PB_Compiler_ExamplesSourcesData = #PB_Compiler_Examples + WindowsElse("Sources\Data\", "sources/data/")
  #PB_Compiler_Examples3DData      = #PB_Compiler_Examples + WindowsElse("3D\Data\", "3d/data/")
  
  ;-
  ;- - PB Version Information
  
  Macro PBGTE(_PBVersion)
    (Bool(#PB_Compiler_Version >= (_PBVersion)))
  EndMacro
  Macro PBGT(_PBVersion)
    (Bool(#PB_Compiler_Version >  (_PBVersion)))
  EndMacro
  Macro PBLTE(_PBVersion)
    (Bool(#PB_Compiler_Version <= (_PBVersion)))
  EndMacro
  Macro PBLT(_PBVersion)
    (Bool(#PB_Compiler_Version <  (_PBVersion)))
  EndMacro
  
  ;-
  ;- - Subsystem Information
  
  CompilerIf (Not Defined(PB_Compiler_Wayland, #PB_Constant))
    #PB_Compiler_Wayland = #False
  CompilerEndIf
  #IsWaylandBuild = #PB_Compiler_Wayland
  
  ;-
  ;- - Common Constants
  
  #False = 0
  #True  = 1
  
  #NO  = 0
  #YES = 1
  
  #Red     = $0000FF
  #Green   = $00FF00
  #Blue    = $FF0000
  #Cyan    = $FFFF00
  #Magenta = $FF00FF
  #Yellow  = $00FFFF
  #Black   = $000000
  #White   = $FFFFFF
  
  #PS   = WindowsElse('\', '/')
  #NPS  = WindowsElse('/', '\')
  #PS$  = Chr(#PS)
  #NPS$ = Chr(#NPS)
  
  #EOL$ = WindowsElse(#CRLF$, #LF$)
  
  #LFLF$    = #LF$ + #LF$
  #CRLFCRLF = #CRLF$ + #CRLF$
  
  #SP = $20
  #DQ = $22
  #SQ = $27
  
  #SP$ = Chr(#SP)
  #DQ$ = Chr(#DQ)
  #SQ$ = Chr(#SQ)
  
  #CurrentDirectory$ = "."
  #ParentDirectory$  = ".."
  #HomeDirectory$    = "~"
  
  #PB_FileSize_Missing   = -1
  #PB_FileSize_Directory = -2
  
  CompilerIf (Not Defined(PB_MessageRequester_Info, #PB_Constant))
    #PB_MessageRequester_Info    = WindowsElse(#MB_ICONINFORMATION, #Null)
    #PB_MessageRequester_Warning = WindowsElse(#MB_ICONWARNING,     #Null)
    #PB_MessageRequester_Error   = WindowsElse(#MB_ICONERROR,       #Null)
  CompilerEndIf
  #PB_MessageRequester_Question = WindowsElse(#MB_ICONQUESTION, #PB_MessageRequester_Info)
  
  #Localhost = "localhost"
  #LocalIPv4 = "127.0.0.1"
  #LocalIPv6 = "::1"
  
  ;-
  ;- - Common Macros
  
  Macro CharsToBytes(_NumChars)
    ((_NumChars) * #CharSize)
  EndMacro
  Macro BytesToChars(_NumBytes)
    ((_NumBytes) / #CharSize)
  EndMacro
  
  Macro AddString(_List, _String)
    AddElement(_List)
    _List = _String
  EndMacro
  
  Macro GetDesktopDirectory()
    GetUserDirectory(#PB_Directory_Desktop)
  EndMacro
  Macro GetDocumentsDirectory()
    GetUserDirectory(#PB_Directory_Documents)
  EndMacro
  Macro GetDownloadsDirectory()
    GetUserDirectory(#PB_Directory_Downloads)
  EndMacro
  Macro GetMusicDirectory()
    GetUserDirectory(#PB_Directory_Musics)
  EndMacro
  Macro GetPicturesDirectory()
    GetUserDirectory(#PB_Directory_Pictures)
  EndMacro
  Macro GetVideosDirectory()
    GetUserDirectory(#PB_Directory_Videos)
  EndMacro
  
  ;-
  ;- - Common Procedures
  
  Procedure.i MapPBDefault(CurrentValue.i, NewValueIfPBDefault.i)
    If (CurrentValue = #PB_Default)
      CurrentValue = NewValueIfPBDefault
    EndIf
    ProcedureReturn (CurrentValue)
  EndProcedure
  
  Procedure.i MapPBAny(CurrentValue.i, NewValueIfPBAny.i)
    If (CurrentValue = #PB_Any)
      CurrentValue = NewValueIfPBAny
    EndIf
    ProcedureReturn (CurrentValue)
  EndProcedure
  
  Procedure.i MapPBIgnore(CurrentValue.i, NewValueIfPBIgnore.i)
    If (CurrentValue = #PB_Ignore)
      CurrentValue = NewValueIfPBIgnore
    EndIf
    ProcedureReturn (CurrentValue)
  EndProcedure
  
  Procedure.s MapEmptyString(CurrentString.s, NewStringIfEmpty.s)
    If (CurrentString = "")
      CurrentString = NewStringIfEmpty
    EndIf
    ProcedureReturn (CurrentString)
  EndProcedure
  
  ;-
  ;- - OS Includes
  
  CompilerIf (#IsWindowsBuild)
    XIncludeFile "windows-os.pbi"
  CompilerEndIf
  CompilerIf (#IsLinuxBuild)
    XIncludeFile "linux-os.pbi"
  CompilerEndIf
  CompilerIf (#IsMacBuild)
    XIncludeFile "mac-os.pbi"
  CompilerEndIf
  
  ;-
  ;- - Library Includes
  
  CompilerIf (Not Defined(PBSL_IncludeAll, #PB_Constant))
    #PBSL_IncludeAll = #False
  CompilerEndIf
  
  CompilerIf (#True)
    XIncludeFile "pb-compatibility.pbi"
    XIncludeFile "math.pbi"
    XIncludeFile "strings.pbi"
    XIncludeFile "paths.pbi"
    XIncludeFile "date-time.pbi"
    XIncludeFile "color.pbi"
    XIncludeFile "images.pbi"
  CompilerEndIf
  
  CompilerIf (#PBSL_IncludeAll)
    XIncludeFile "network.pbi"
  CompilerEndIf
  
CompilerEndIf
;-
