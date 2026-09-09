; +---------------------------------------------+
; | PureBasic Standard Library - String Builder |
; +---------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_StringBuilder_Included, #PB_Constant))
  #_PBSL_StringBuilder_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - StringBuilder Structures
  
  Structure _PBSL_StringBuilder
    Buffer.i
    AllocatedBytes.i
    WrittenBytes.i
    IncrementLength.i
  EndStructure
  
  ;-
  ;- - StringBuilder Globals
  
  Global NewMap _PBSL_StringBuilderMap.i()
  
  ;-
  ;- - StringBuilder Procedures
  
  Procedure.i PBSL_IsStringBuilder(StringBuilder.i)
    ProcedureReturn (Bool(FindMapElement(_PBSL_StringBuilderMap(), Str(StringBuilder))))
  EndProcedure
  
  Procedure PBSL_FreeStringBuilder(StringBuilder.i)
    If (FindMapElement(_PBSL_StringBuilderMap(), Str(StringBuilder)))
      Protected *SB._PBSL_StringBuilder = _PBSL_StringBuilderMap()
      DeleteMapElement(_PBSL_StringBuilderMap())
      If (*SB)
        If (*SB\Buffer)
          FreeMemory(*SB\Buffer)
        EndIf
        FreeStructure(*SB)
      EndIf
    EndIf
  EndProcedure
  
  Procedure.i PBSL_CreateStringBuilder(StringBuilder.i, IncrementLength.i = #PB_Default)
    Protected Result.i = #Null
    If (StringBuilder = #PB_Any)
      Protected i.i = $10000
      While (FindMapElement(_PBSL_StringBuilderMap(), Str(i)))
        i + 1
      Wend
      StringBuilder = i
    Else
      If (FindMapElement(_PBSL_StringBuilderMap(), Str(StringBuilder)))
        PBSL_FreeStringBuilder(StringBuilder)
      EndIf
    EndIf
    If (IncrementLength <= 0)
      IncrementLength = 8192
    EndIf
    Protected *SB._PBSL_StringBuilder = AllocateStructure(_PBSL_StringBuilder)
    If (*SB)
      AddMapElement(_PBSL_StringBuilderMap(), Str(StringBuilder))
      _PBSL_StringBuilderMap() = *SB
      *SB\IncrementLength = IncrementLength
      Result = StringBuilder
      If (StringBuilder = 0)
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure _PBSL_GrowStringBuilderBuffer(*SB._PBSL_StringBuilder, MinimumSize.i)
    If (*SB And (MinimumSize > 0))
      Protected NewSize.i = *SB\AllocatedBytes
      While (NewSize < MinimumSize)
        NewSize + *SB\IncrementLength
      Wend
      If (*SB\Buffer)
        Protected *NewBuffer = ReAllocateMemory(*SB\Buffer, NewSize, #PB_Memory_NoClear)
        If (*NewBuffer)
          If (*NewBuffer <> *SB\Buffer)
            *SB\Buffer = *NewBuffer
          EndIf
          *SB\AllocatedBytes = NewSize
        EndIf
      Else
        *SB\Buffer = AllocateMemory(NewSize, #PB_Memory_NoClear)
        If (*SB\Buffer)
          *SB\AllocatedBytes = NewSize
          *SB\WrittenBytes = 0
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Procedure.i PBSL_AppendStringBuilderString(StringBuilder.i, String.s)
    Protected Result.i = #False
    If (FindMapElement(_PBSL_StringBuilderMap(), Str(StringBuilder)))
      Protected *SB._PBSL_StringBuilder = _PBSL_StringBuilderMap()
      If (*SB)
        Protected AdditionalBytes.i = StringByteLength(String)
        If (AdditionalBytes > 0)
          Protected TotalBytes.i = *SB\WrittenBytes + AdditionalBytes
          If (*SB\AllocatedBytes < TotalBytes)
            _PBSL_GrowStringBuilderBuffer(*SB, TotalBytes)
          EndIf
          If (*SB\AllocatedBytes >= TotalBytes)
            CopyMemory(@String, *SB\Buffer + *SB\WrittenBytes, AdditionalBytes)
            *SB\WrittenBytes + AdditionalBytes
            Result = #True
          EndIf
        Else
          Result = #True
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i PBSL_AppendStringBuilderStringN(StringBuilder.i, String.s)
    ProcedureReturn (PBSL_AppendStringBuilderString(StringBuilder, String + #EOL$))
  EndProcedure
  
  Procedure.s PBSL_GetStringBuilderString(StringBuilder.i)
    Protected Result.s = ""
    If (FindMapElement(_PBSL_StringBuilderMap(), Str(StringBuilder)))
      Protected *SB._PBSL_StringBuilder = _PBSL_StringBuilderMap()
      If (*SB)
        If (*SB\WrittenBytes > 0)
          Result = PeekS(*SB\Buffer, *SB\WrittenBytes / SizeOf(CHARACTER))
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i PBSL_ResetStringBuilder(StringBuilder.i)
    Protected Result.i = #False
    If (FindMapElement(_PBSL_StringBuilderMap(), Str(StringBuilder)))
      Protected *SB._PBSL_StringBuilder = _PBSL_StringBuilderMap()
      If (*SB)
        *SB\WrittenBytes = 0
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - StringBuilder Patch Macros
  
  CompilerIf (PBLT(640))
    
    Macro AppendStringBuilderString(_StringBuilder, _String)
      PBSL_AppendStringBuilderString((_StringBuilder), _String)
    EndMacro
    Macro AppendStringBuilderStringN(_StringBuilder, _String)
      PBSL_AppendStringBuilderStringN((_StringBuilder), _String)
    EndMacro
    Macro CreateStringBuilder(_StringBuilder, _IncrementLength = #PB_Default)
      PBSL_CreateStringBuilder((_StringBuilder), (_IncrementLength))
    EndMacro
    Macro FreeStringBuilder(_StringBuilder)
      PBSL_FreeStringBuilder(_StringBuilder)
    EndMacro
    Macro GetStringBuilderString(_StringBuilder)
      PBSL_GetStringBuilderString(_StringBuilder)
    EndMacro
    Macro IsStringBuilder(_StringBuilder)
      PBSL_IsStringBuilder(_StringBuilder)
    EndMacro
    Macro ResetStringBuilder(_StringBuilder)
      PBSL_ResetStringBuilder(_StringBuilder)
    EndMacro
    
  CompilerEndIf
  
CompilerEndIf
;-
