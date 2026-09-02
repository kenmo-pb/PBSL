; +----------------------------------------------+
; | PureBasic Standard Library - Single Instance |
; +----------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_SingleInstance_Included, #PB_Constant))
  #_PBSL_SingleInstance_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  XIncludeFile "window-desktop.pbi"
  
  ;- - Single Instance Constants
  #_PBSL_InstanceMethod_None         = $00
  #_PBSL_InstanceMethod_WindowsMutex = $01
  #_PBSL_InstanceMethod_LinuxPIDFile = $02
  #_PBSL_InstanceMethod_UseMapFile   = $10
  ;#_PBSL_InstanceMethod_UseCopyData  = $20 ; not yet implemented
  
  #_PBSL_InstanceMethod = WLMO(#_PBSL_InstanceMethod_WindowsMutex | #_PBSL_InstanceMethod_UseMapFile, #_PBSL_InstanceMethod_LinuxPIDFile | #_PBSL_InstanceMethod_UseMapFile, #_PBSL_InstanceMethod_None, #_PBSL_InstanceMethod_None)
  
  #_PBSL_InstanceTimeoutMS = 1000
  
  ;-
  ;- - Single Instance Globals
  
  Global _PBSL_IsAlreadyRunning.i = #False
  Global PBSL_Event_ReceivedInstanceMap.i        = RegisterCustomEvent()
  Global PBSL_Event_ReceivedInstanceParameters.i = RegisterCustomEvent()
  
  Global NewMap  PBSL_InstanceMap.s()
  Global NewList PBSL_InstanceParameter.s()
  
  CompilerIf (#_PBSL_InstanceMethod <> #_PBSL_InstanceMethod_None)
    UseMD5Fingerprint()
    Global _PBSL_MutexString.s = StringFingerprint("PBSL:" + ProgramFilename(), #PB_Cipher_MD5)
  CompilerEndIf
  
  CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_WindowsMutex)
    Global _PBSL_Mutex.i             = #Null
    Global _PBSL_RegisteredMessage.i = #Null
    Global _PBSL_InstanceWindow.i    = #Null
  CompilerElseIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_LinuxPIDFile)
    Global _PBSL_InstancePIDFile.s   = GetTemporaryDirectory() + _PBSL_MutexString + ".pid"
  CompilerEndIf
  
  CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_UseMapFile)
    Global _PBSL_InstanceMapFile.s = GetTemporaryDirectory() + _PBSL_MutexString + ".map"
  CompilerEndIf
  
  Procedure.i InstanceAlreadyRunning()
    ProcedureReturn (_PBSL_IsAlreadyRunning)
  EndProcedure
  
  CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_UseMapFile)
    Procedure _PBSL_ReadInstanceMapFile()
      ClearMap(PBSL_InstanceMap())
      ClearList(PBSL_InstanceParameter())
      If (_PBSL_InstanceMapFile)
        Protected FN.i = ReadFile(#PB_Any, _PBSL_InstanceMapFile)
        If (FN)
          While (Not Eof(FN))
            Protected Text.s = ReadString(FN)
            Protected i.i = FindString(Text, "=")
            If (i >= 2)
              PBSL_InstanceMap(Left(Text, i-1)) = Mid(Text, i+1)
            EndIf
          Wend
          CloseFile(FN)
          DeleteFile(_PBSL_InstanceMapFile)
          PostEvent(PBSL_Event_ReceivedInstanceMap)
          Protected N.i = 0
          If (FindMapElement(PBSL_InstanceMap(), "NumParameters"))
            N = Val(PBSL_InstanceMap())
            If (N > 0)
              For i = 0 To (N-1)
                AddString(PBSL_InstanceParameter(), PBSL_InstanceMap("Parameter" + Str(i)))
              Next i
            EndIf
            If (N >= 0)
              PostEvent(PBSL_Event_ReceivedInstanceParameters)
            EndIf
          EndIf
        EndIf
      EndIf
    EndProcedure
  CompilerEndIf
  
  CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_WindowsMutex)
    Procedure.i _PBSL_InstanceWindowCallback(hWnd.i, uMsg.i, wParam.i, lParam.i)
      If (uMsg = _PBSL_RegisteredMessage)
        CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_UseMapFile)
          _PBSL_ReadInstanceMapFile()
        CompilerEndIf
      EndIf
      ProcedureReturn (#PB_ProcessPureBasicEvents)
    EndProcedure
  CompilerEndIf
  
  CompilerIf (#IsGTK2Subsystem)
    
    CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_LinuxPIDFile)
      
      CompilerIf (Not Defined(XClientMessageEvent, #PB_Structure))
        ; Copied directly from PB IDE LinuxMisc.pb
        Structure XClientMessageEvent
          type.l        ; int
          CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
            alignment1.l
          CompilerEndIf
          serial.i      ; unsigned long    /* # of last request processed by server */
          send_event.l  ; Bool (=int)    /* true if this came from a SendEvent request */
          CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
            alignment2.l
          CompilerEndIf
          *display      ; pointer  /* Display the event was read from */
          window.i      ; Window (= pointer)
          message_type.i; Atom (= pointer)
          format.l      ; int
          CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
            alignment3.l
          CompilerEndIf
          StructureUnion
            b.b[20]      ; char
            s.w[10]      ; short
            l.i[5]       ; long is 64bit on Linux64!
          EndStructureUnion
        EndStructure
      CompilerEndIf
      
      ProcedureC.i _PBSL_InstanceAtomCallback(*XEvent.XClientMessageEvent, *Event, user_data.i)
        Static LastSender.l = 0
        If (#True)
          If (*XEvent\l[0] <> LastSender)
            _PBSL_ReadInstanceMapFile()
            LastSender = *XEvent\l[0]
          EndIf
          ProcedureReturn (#GDK_FILTER_REMOVE)
        Else
          ProcedureReturn (#GDK_FILTER_CONTINUE)
        EndIf
      EndProcedure
    CompilerEndIf
    
  CompilerEndIf ; #GTK2
  
  Procedure _PBSL_InitInstance()
    CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_WindowsMutex)
      _PBSL_RegisteredMessage = RegisterWindowMessage_(@_PBSL_MutexString)
      
      _PBSL_Mutex = CreateMutex_(#Null, #False, @_PBSL_MutexString)
      ; "If the mutex is a named mutex and the object existed before this function call, the return value is a handle to the existing object, and the GetLastError function returns ERROR_ALREADY_EXISTS."
      If ((Not _PBSL_Mutex) Or (GetLastError_() = #ERROR_ALREADY_EXISTS))
        _PBSL_IsAlreadyRunning = #True
      Else
        _PBSL_IsAlreadyRunning = #False
        If (Not _PBSL_InstanceWindow)
          _PBSL_InstanceWindow = OpenWindow(#PB_Any, 0, 0, 100, 100, "", #PB_Window_BorderLess | #PB_Window_NoGadgets | #PB_Window_NoActivate | #PB_Window_Invisible)
          If (_PBSL_InstanceWindow)
            SetWindowCallback(@_PBSL_InstanceWindowCallback(), _PBSL_InstanceWindow)
          EndIf
        EndIf
      EndIf
      
    CompilerElseIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_LinuxPIDFile)
      _PBSL_IsAlreadyRunning = #False
      Protected OldPID.i = ReadFileInteger(_PBSL_InstancePIDFile)
      If (OldPID > 0)
        If (kill_(OldPID, 0) = 0) ; process exists
          If (#True)              ; check that it's not an old PID from a previous system uptime? GetModifiedDate() vs "uptime -s" ?
            _PBSL_IsAlreadyRunning = #True
          EndIf
        EndIf
      EndIf
      If (Not _PBSL_IsAlreadyRunning)
        DeleteFile(_PBSL_InstancePIDFile)
        WriteFileInteger(_PBSL_InstancePIDFile, getpid_())
        CompilerIf (#IsGTK2Subsystem)
          gdk_add_client_message_filter_(gdk_atom_intern_(_PBSL_MutexString, #False), @_PBSL_InstanceAtomCallback(), #Null)
        CompilerEndIf
      EndIf
      
    CompilerEndIf
  EndProcedure
  
  Procedure SendMapToMainInstance(Map StringMap.s())
    If (_PBSL_IsAlreadyRunning)
      CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_UseMapFile)
        Protected Timeout.i
        Timeout = ElapsedMilliseconds() + #_PBSL_InstanceTimeoutMS
        While (ElapsedMilliseconds() < Timeout)
          If (Not FileExists(_PBSL_InstanceMapFile))
            Break
          EndIf
          Delay(50)
        Wend
        If (Not FileExists(_PBSL_InstanceMapFile))
          Protected FN.i = CreateFile(#PB_Any, _PBSL_InstanceMapFile)
          If (FN)
            ForEach (StringMap())
              WriteString(FN, #LF$ + MapKey(StringMap()) + "=" + StringMap())
            Next
            CloseFile(FN)
            
            ; Broadcast to all processes...
            CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_WindowsMutex)
              PostMessage_(#HWND_BROADCAST, _PBSL_RegisteredMessage, #Null, #Null)
            CompilerElseIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_LinuxPIDFile)
              CompilerIf (#IsGTK2Subsystem)
                Protected Event.GdkEventClient
                Event\type         = #GDK_CLIENT_EVENT
                Event\send_event   = #True
                Event\message_type = gdk_atom_intern_(_PBSL_MutexString, 0)
                Event\data_format  = 32
                Event\l[0]         = getpid_()
                gdk_event_send_clientmessage_toall_(@Event)
              CompilerEndIf
            CompilerEndIf
            
            Timeout = ElapsedMilliseconds() + #_PBSL_InstanceTimeoutMS
            While (ElapsedMilliseconds() < Timeout)
              If (Not FileExists(_PBSL_InstanceMapFile))
                ProcedureReturn
              EndIf
              Delay(50)
            Wend
            DeleteFile(_PBSL_InstanceMapFile)
          EndIf
        EndIf
      CompilerEndIf
    EndIf
  EndProcedure
  
  Procedure SendProgramParametersToMainInstance()
    NewMap ParameterMap.s()
    Protected N.i = CountProgramParameters()
    ParameterMap("NumParameters") = Str(N)
    Protected i.i
    For i = 0 To (N-1)
      ParameterMap("Parameter" + Str(i)) = ProgramParameter(i)
    Next i
    SendMapToMainInstance(ParameterMap())
  EndProcedure
  
  Procedure QuitInstance()
    CompilerIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_WindowsMutex)
      If (_PBSL_Mutex)
        ; "The system closes the handle automatically when the process terminates. The mutex object is destroyed when its last handle has been closed."
        CloseHandle_(_PBSL_Mutex)
        _PBSL_Mutex = #Null
      EndIf
    CompilerElseIf (#_PBSL_InstanceMethod & #_PBSL_InstanceMethod_LinuxPIDFile)
      DeleteFile(_PBSL_InstancePIDFile)
    CompilerEndIf
  EndProcedure
  
  ;-
  ;- - Single Instance Initialization
  
  _PBSL_InitInstance()
  
CompilerEndIf
;-
