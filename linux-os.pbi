; +---------------------------------------+
; | PureBasic Standard Library - Linux OS |
; +---------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_LinuxOS_Included, #PB_Constant))
  #_PBSL_LinuxOS_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  CompilerIf (#IsLinuxBuild)
    
    ;- - Initialization
    
    CompilerIf (#True)
      ;
      ; On Linux, launching executable from file explorer seems to default its CWD to user's home.
      ; This will adjust it to the executable's directory, if it makes sense (eg. not in TEMP folder via PB IDE!)
      ;
      If (GetCurrentDirectory() <> GetPathPart(ProgramFilename()))
        If (GetPathPart(ProgramFilename()) <> GetTemporaryDirectory())
          If (GetCurrentDirectory() = GetHomeDirectory())
            SetCurrentDirectory(GetPathPart(ProgramFilename()))
          EndIf
        EndIf
      EndIf
    CompilerEndIf
    
    ;-
    ;- - Linux Constants
    
    Enumeration
      ; https://gitlab.gnome.org/GNOME/gtk/-/blob/main/gdk/gdkkeysyms.h
      #GDK_KEY_ISO_Left_Tab = $fe20 ; aka LEFTTAB
                                    ;
      #GDK_KEY_BackSpace = $ff08
      #GDK_KEY_Tab       = $ff09
      #GDK_KEY_Linefeed  = $ff0a
      #GDK_KEY_Clear     = $ff0b
      #GDK_KEY_Return    = $ff0d
      #GDK_KEY_Escape    = $ff1b
      #GDK_KEY_Delete    = $ffff
      #GDK_KEY_Left      = $ff51
      #GDK_KEY_Up        = $ff52
      #GDK_KEY_Right     = $ff53
      #GDK_KEY_Down      = $ff54
      #GDK_KEY_Undo      = $ff65
      #GDK_KEY_Redo      = $ff66
      #GDK_KEY_Cancel    = $ff69
      #GDK_KEY_KP_Enter  = $ff8d
    EndEnumeration
    
    Enumeration
      #DisplayServer_Unknown = 0
      #DisplayServer_X11     = 1
      #DisplayServer_Wayland = 2
    EndEnumeration
    
    ;-
    ;- - Linux Procedures
    
    Procedure.i GetDisplayServer()
      Protected Result.i = #DisplayServer_Unknown
      ; https://askubuntu.com/questions/904940/how-can-i-tell-if-i-am-running-wayland
      Select (LCase(GetEnvironmentVariable("XDG_SESSION_TYPE")))
        Case "x11"
          Result = #DisplayServer_X11
        Case "wayland"
          Result = #DisplayServer_Wayland
        Default
          If (FindString(GetEnvironmentVariable("DESKTOP_SESSION"), "wayland", 1, #PB_String_NoCase))
            Result = #DisplayServer_Wayland
          ElseIf (FindString(GetEnvironmentVariable("WAYLAND_DISPLAY"), "wayland", 1, #PB_String_NoCase))
            Result = #DisplayServer_Wayland
          EndIf
      EndSelect
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i IsX11Session()
      ProcedureReturn (Bool(GetDisplayServer() = #DisplayServer_X11))
    EndProcedure
    
    Procedure.i IsWaylandSession()
      ProcedureReturn (Bool(GetDisplayServer() = #DisplayServer_Wayland))
    EndProcedure
    
  CompilerEndIf
  
CompilerEndIf
;-
