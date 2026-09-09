; +-----------------------------------------+
; | PureBasic Standard Library - Windows OS |
; +-----------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_WindowsOS_Included, #PB_Constant))
  #_PBSL_WindowsOS_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  ;XIncludeFile "common.pbi"
  XIncludeFile "pb-compatibility.pbi" ; UpdateStringLength
  
  CompilerIf (#IsWindowsBuild)
    
    ;- - Initialization
    
    ; https://learn.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-seterrormode
    ; "Best practice is that all applications call the process-wide SetErrorMode function
    ;  with a parameter of SEM_FAILCRITICALERRORS at startup.
    ;  This is to prevent error mode dialogs from hanging the application."
    CompilerIf (#True)
      SetErrorMode_(#SEM_FAILCRITICALERRORS)
    CompilerEndIf
    
    ;-
    ;- - Windows Structures
    
    CompilerIf (Not Defined(COMBOBOXINFO, #PB_Structure))
      Structure COMBOBOXINFO
        cbSize.l
        rcItem.RECT
        rcButton.RECT
        stateButton.l
        hwndCombo.i
        hwndItem.i
        hwndList.i
      EndStructure
    CompilerEndIf
    
    ;-
    ;- - Windows Procedures
    
    Procedure _SetWndProc(hWnd.i, *Proc, StorePrevProcAsUserData.i)
      If (hWnd And *Proc)
        If (StorePrevProcAsUserData)
          SetWindowLongPtr_(hWnd, #GWLP_USERDATA, GetWindowLongPtr_(hWnd, #GWLP_WNDPROC))
        EndIf
        SetWindowLongPtr_(hWnd, #GWLP_WNDPROC, *Proc)
      EndIf
    EndProcedure
    
    Procedure SetGadgetWndProc(Gadget.i, *Proc, StorePrevProcAsUserData.i = #True)
      _SetWndProc(GadgetID(Gadget), *Proc, StorePrevProcAsUserData)
    EndProcedure
    Procedure SetWindowWndProc(Window.i, *Proc, StorePrevProcAsUserData.i = #True)
      _SetWndProc(WindowID(Window), *Proc, StorePrevProcAsUserData)
    EndProcedure
    
    Procedure.i GetHWNDBorderSize(hWnd.i)
      Protected Result.i = 0
      If (hWnd)
        Protected WR.RECT, CR.RECT
        If (GetWindowRect_(hWnd, @WR) And GetClientRect_(hWnd, @CR))
          Result = ((WR\right - WR\left) - (CR\right - CR\left)) / 2
          If (Result < 0)
            Result = 0
          EndIf
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i _StringGadgetWithCtrlBackspaceEntire(hWnd.i, uMsg.i, wParam.i, lParam.i)
      If ((uMsg = #WM_CHAR) And (wParam = #DEL))
        ProcedureReturn (SendMessage_(hWnd, #WM_SETTEXT, #Null, #Null$))
      Else
        ProcedureReturn (CallFunctionFast(GetWindowLongPtr_(hWnd, #GWLP_USERDATA), hWnd, uMsg, wParam, lParam))
      EndIf
    EndProcedure
    
    Procedure.i _StringGadgetWithCtrlBackspace(hWnd.i, uMsg.i, wParam.i, lParam.i)
      If ((uMsg = #WM_CHAR) And (wParam = #DEL))
        Protected N.i = SendMessage_(hWnd, #WM_GETTEXTLENGTH, 0, 0)
        If (N > 0)
          Protected Text.s = Space(N)
          SendMessage_(hWnd, #WM_GETTEXT, N + 1, @Text)
          UpdateStringLength(Text)
          Protected StartPos.i, EndPos.i
          SendMessage_(hWnd, #EM_GETSEL, @StartPos, @EndPos)
          If ((StartPos >= 1) And (StartPos = EndPos))
            StartPos - 1
            Protected HaveSeenChars.i = #False
            While (#True)
              Select (PeekC(@Text + (StartPos * SizeOf(CHARACTER))))
                Case ' ', #TAB, #CR, #LF
                  If (HaveSeenChars)
                    StartPos + 1
                    Break
                  EndIf
                Case #NUL
                  Break
                Default
                  HaveSeenChars = #True
              EndSelect
              If (StartPos = 0)
                Break
              Else
                StartPos - 1
              EndIf
            Wend
            SendMessage_(hWnd, #EM_SETSEL, StartPos, EndPos)
          EndIf
          If (EndPos > StartPos)
            ProcedureReturn (SendMessage_(hWnd, #EM_REPLACESEL, #True, #Null$))
          Else
            ProcedureReturn (#Null)
          EndIf
        EndIf
      Else
        ProcedureReturn (CallFunctionFast(GetWindowLongPtr_(hWnd, #GWLP_USERDATA), hWnd, uMsg, wParam, lParam))
      EndIf
    EndProcedure
    
    Procedure.i StringGadgetWithCtrlBackspace(Gadget.i, x.i, y.i, Width.i, Height.i, Content.s, Flags.i = #Null)
      Protected Result.i = StringGadget(Gadget, x, y, Width, Height, Content, Flags)
      If (Result)
        Gadget = MapPBAny(Gadget, Result)
        If (Flags & #PB_String_ReadOnly)
          ; leave wndproc as-is
        Else
          If (Flags & #PB_String_Password)
            SetGadgetWndProc(Gadget, @_StringGadgetWithCtrlBackspaceEntire())
          Else
            SetGadgetWndProc(Gadget, @_StringGadgetWithCtrlBackspace())
          EndIf
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i ComboBoxGadgetWithCtrlBackspace(Gadget.i, x.i, y.i, Width.i, Height.i, Flags.i = #Null)
      Protected Result.i = ComboBoxGadget(Gadget, x, y, Width, Height, Flags)
      If (Result)
        Gadget = MapPBAny(Gadget, Result)
        If (Flags & #PB_ComboBox_Editable)
          Protected CBI.COMBOBOXINFO
          CBI\cbSize = SizeOf(COMBOBOXINFO)
          If (GetComboBoxInfo_(GadgetID(Gadget), @CBI))
            If (CBI\hwndItem)
              _SetWndProc(CBI\hwndItem, @_StringGadgetWithCtrlBackspace(), #True)
            EndIf
          EndIf
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    ;-
    ;- - Patch String/ComboBoxGadget
    
    CompilerIf (#True)
      Macro StringGadget(_Gadget, _x, _y, _Width, _Height, _Content, _Flags = #Null)
        StringGadgetWithCtrlBackspace((_Gadget), (_x), (_y), (_Width), (_Height), (_Content), (_Flags))
      EndMacro
      Macro ComboBoxGadget(_Gadget, _x, _y, _Width, _Height, _Flags = #Null)
        ComboBoxGadgetWithCtrlBackspace((_Gadget), (_x), (_y), (_Width), (_Height), (_Flags))
      EndMacro
    CompilerEndIf
    
  CompilerEndIf
  
CompilerEndIf
;-
