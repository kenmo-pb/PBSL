; +--------------------------------------+
; | PureBasic Standard Library - Strings |
; +--------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Strings_Included, #PB_Constant))
  #_PBSL_Strings_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - String Constants
  
  #Unicode_Codepoint_Min = $0000
  #Unicode_Codepoint_Max = $10FFFF
  
  #UTF16_HighSurrogate_Min = $D800
  #UTF16_HighSurrogate_Max = $DBFF
  #UTF16_LowSurrogate_Min  = $DC00
  #UTF16_LowSurrogate_Max  = $DFFF
  
  ;-
  ;- - Hex Representation
  
  Macro Hex8(_Value)
    RSet(Hex((_Value), #PB_Ascii), 2, "0")
  EndMacro
  Macro Hex16(_Value)
    RSet(Hex((_Value), #PB_Unicode), 4, "0")
  EndMacro
  Macro Hex24(_Value)
    RSet(Hex((_Value) & $00FFFFFF, #PB_Long), 6, "0")
  EndMacro
  Macro Hex32(_Value)
    RSet(Hex((_Value), #PB_Long), 8, "0")
  EndMacro
  Macro Hex64(_Value)
    RSet(Hex((_Value), #PB_Quad), 16, "0")
  EndMacro
  
  ;-
  ;- - String Searching
  
  Macro StartsWith(_String, _Prefix)
    (Bool(Left((_String), Len(_Prefix)) = (_Prefix)))
  EndMacro
  Macro EndsWith(_String, _Suffix)
    (Bool(Right((_String), Len(_Suffix)) = (_Suffix)))
  EndMacro
  Macro Contains(_String, _Substring)
    (Bool(FindString((_String), (_Substring)) > 0))
  EndMacro
  
  CompilerIf (PBGTE(640)) ; PB 6.40 dropped #PB_String_InPlace because it has side effects, strings are now passed "upward" by-reference!
                          ; https://www.purebasic.fr/english/viewtopic.php?p=650813
    CompilerIf (#False)   ; Confirm whether this approach actually works for PB 6.40+ string library!
      Procedure _ReplaceStringInPlace(*StringVar.CHARACTER, StringToFind.s, StringToReplace.s, Mode.i)
        Protected N.i = Len(StringToFind)
        If ((N > 0) And (Len(StringToReplace) = N))
          Protected Bytes.i = CharsToBytes(N)
          If (Mode & #PB_String_NoCase)
            While (*StringVar\c)
              If (CompareMemoryString(*StringVar, @StringToFind, #PB_String_NoCase, N, #InternalStringFormat) = #PB_String_Equal)
                CopyMemory(@StringToReplace, *StringVar, Bytes)
                *StringVar + Bytes
              Else
                *StringVar + #CharSize
              EndIf
            Wend
          Else
            While (*StringVar\c)
              If (CompareMemory(*StringVar, @StringToFind, Bytes) <> 0)
                CopyMemory(@StringToReplace, *StringVar, Bytes)
                *StringVar + Bytes
              Else
                *StringVar + #CharSize
              EndIf
            Wend
          EndIf
        EndIf
      EndProcedure
      Macro ReplaceStringInPlace(_StringVar, _StringToFind, _StringToReplace, _Mode = #PB_String_CaseSensitive)
        _ReplaceStringInPlace(@_StringVar, _StringToFind, _StringToReplace, (_Mode))
      EndMacro
    CompilerElse
      Macro ReplaceStringInPlace(_StringVar, _StringToFind, _StringToReplace, _Mode = #PB_String_CaseSensitive)
        _StringVar = ReplaceString(_StringVar, _StringToFind, _StringToReplace, (_Mode)) ; not actually in-place anymore! but should be code-compatible
      EndMacro
    CompilerEndIf
  CompilerElse
    Macro ReplaceStringInPlace(_StringVar, _StringToFind, _StringToReplace, _Mode = #PB_String_CaseSensitive)
      ReplaceString(_StringVar, _StringToFind, _StringToReplace, (_Mode | #PB_String_InPlace))
    EndMacro
  CompilerEndIf
  
  ;-
  ;- String Manipulation
  
  Procedure.s Unquote(Text.s, Character.s = "")
    If (Len(Character) = 1)
      If ((Left(Text, 1) = Character) And (Right(Text, 1) = Character))
        Text = Mid(Text, 2, Len(Text) - 2)
      EndIf
    Else
      If ((Left(Text, 1) = #DQ$) And (Right(Text, 1) = #DQ$))
        Text = Mid(Text, 2, Len(Text) - 2)
      ElseIf ((Left(Text, 1) = #SQ$) And (Right(Text, 1) = #SQ$))
        Text = Mid(Text, 2, Len(Text) - 2)
      EndIf
    EndIf
    ProcedureReturn (Text)
  EndProcedure
  
  ;-
  ;- - String Buffers
  
  Procedure.i NullTerminatorBytes(StringFormat.i)
    Select (StringFormat)
      Case #PB_Ascii, #PB_UTF8
        ProcedureReturn (1)
      Case #PB_Unicode, #PB_UTF16, #PB_UTF16BE
        ProcedureReturn (2)
      Case #PB_UTF32, #PB_UTF32BE
        ProcedureReturn (4)
    EndSelect
    ProcedureReturn (0)
  EndProcedure
  
  ;-
  ;- - Unicode Handling
  
  Procedure.i IsUTF8ContinuationByte(Byte.i)
    ProcedureReturn (Bool((Byte & %11000000) = %10000000))
  EndProcedure
  
  Procedure.i IsUTF16HighSurrogate(Codepoint.i)
    ProcedureReturn (Bool((Codepoint >= #UTF16_HighSurrogate_Min) And (Codepoint <= #UTF16_HighSurrogate_Max)))
  EndProcedure
  Procedure.i IsUTF16LowSurrogate(Codepoint.i)
    ProcedureReturn (Bool((Codepoint >= #UTF16_LowSurrogate_Min) And (Codepoint <= #UTF16_LowSurrogate_Max)))
  EndProcedure
  Procedure.i IsUTF16Surrogate(Codepoint.i)
    ProcedureReturn (Bool(IsUTF16HighSurrogate(Codepoint) Or IsUTF16LowSurrogate(Codepoint)))
  EndProcedure
  
  Procedure.i ExpectedUTF8ContinuationBytes(StartByte.i, *CodepointBits.INTEGER = #Null)
    Protected Result.i
    If (StartByte & %10000000) ; high bit set - multi-byte character
      If ((StartByte & %11111000) = (%11110000)) ; start of 4-byte character
        Result = 3
        If (*CodepointBits)
          *CodepointBits\i = StartByte & %00000111
        EndIf
      ElseIf ((StartByte & %11110000) = (%11100000)) ; start of 3-byte character
        Result = 2
        If (*CodepointBits)
          *CodepointBits\i = StartByte & %00001111
        EndIf
      ElseIf ((StartByte & %11100000) = (%11000000)) ; start of 2-byte character
        Result = 1
        If (*CodepointBits)
          *CodepointBits\i = StartByte & %00011111
        EndIf
      Else
        Result = -1 ; invalid, or a continuation byte!
      EndIf
    Else ; high bit not set - basic 7-bit character
      Result = 0
      If (*CodepointBits)
        *CodepointBits\i = StartByte & $7F
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i PeekCodepoint(*Pointer, Format.i = #InternalStringFormat, *PointerToNext.INTEGER = #Null)
    Protected Result.i = -1 ; -1 means invalid/error
    If (*Pointer)
      Protected BytesUsed.i = 0
      Protected NextValue.i
      Select (Format)
        Case #PB_Ascii
          Result = PeekA(*Pointer)
          BytesUsed = 1
        Case #PB_Unicode
          Result = PeekU(*Pointer)
          BytesUsed = 2
          If (IsUTF16HighSurrogate(Result))
            NextValue = PeekU(*Pointer + 2)
            If (IsUTF16LowSurrogate(NextValue))
              Result = ((Result << 10) & $FFC00)
              Result | (NextValue & $003FF)
              Result + $10000
              BytesUsed + 2
            Else
              Result = -1
            EndIf
          ElseIf (IsUTF16LowSurrogate(Result))
            Result = -1
          EndIf
        Case #PB_UTF8
          Result = PeekA(*Pointer)
          BytesUsed = 1
          Protected BytesLeft.i = ExpectedUTF8ContinuationBytes(Result, @Result)
          If (BytesLeft >= 0)
            While (BytesLeft > 0)
              NextValue = PeekA(*Pointer + BytesUsed)
              If (IsUTF8ContinuationByte(NextValue))
                Result = (Result << 6) | (NextValue & %00111111)
              Else
                Result = -1
                Break
              EndIf
              BytesUsed + 1
              BytesLeft - 1
            Wend
          Else
            Result = -1
          EndIf
      EndSelect
      If (Result >= 0)
        If (*PointerToNext)
          *PointerToNext\i = *Pointer + BytesUsed
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i RequiredUTF8Bytes(Codepoint.i)
    If ((Codepoint >= #Unicode_Codepoint_Min) And (Codepoint <= #Unicode_Codepoint_Max))
      If (Codepoint <= $7F)
        ProcedureReturn (1)
      ElseIf (Codepoint <= $7FF)
        ProcedureReturn (2)
      ElseIf (Codepoint <= $FFFF)
        ProcedureReturn (3)
      Else
        ProcedureReturn (4)
      EndIf
    Else
      ProcedureReturn (0)
    EndIf
  EndProcedure
  
  Procedure.i EncodeCodepointToUTF8Bytes(Codepoint.i, *ResultBytes.LONG)
    Protected RequiredBytes.i = 0
    ; Returns 1-4 (number of encoded bytes), or 0 for failure
    ; *ResultBytes must point to at least 4 available bytes (4 will be pre-cleared to 0!)
    If (*ResultBytes)
      RequiredBytes = RequiredUTF8Bytes(Codepoint)
      If (RequiredBytes > 0)
        *ResultBytes\l = 0
        Select (RequiredBytes)
          Case 4
            PokeA(*ResultBytes + 0, %11110000 | ((Codepoint >> 18) & %00000111))
            PokeA(*ResultBytes + 1, %10000000 | ((Codepoint >> 12) & %00111111))
            PokeA(*ResultBytes + 2, %10000000 | ((Codepoint >>  6) & %00111111))
            PokeA(*ResultBytes + 3, %10000000 | ((Codepoint >>  0) & %00111111))
          Case 3
            PokeA(*ResultBytes + 0, %11100000 | ((Codepoint >> 12) & %00001111))
            PokeA(*ResultBytes + 1, %10000000 | ((Codepoint >>  6) & %00111111))
            PokeA(*ResultBytes + 2, %10000000 | ((Codepoint >>  0) & %00111111))
          Case 2
            PokeA(*ResultBytes + 0, %11000000 | ((Codepoint >>  6) & %00011111))
            PokeA(*ResultBytes + 1, %10000000 | ((Codepoint >>  0) & %00111111))
          Case 1
            PokeA(*ResultBytes + 0, %00000000 | ((Codepoint >>  0) & %01111111))
        EndSelect
      EndIf
    EndIf
    ProcedureReturn (RequiredBytes)
  EndProcedure
  
  ;-
  ;- - Encodings
  
  Procedure.s URLParamEncoder(Text.s)
    Protected Result.s = ""
    Protected *C.CHARACTER = @Text
    While (*C\c)
      Select (*C\c)
        Case 'a' To 'z', 'A' To 'Z', '0' To '9', '-', '_', '.';, '~'
          Result + Chr(*C\c)
        Default
          If (*C\c = $20) ; space
                          ;Result + "%20"
            Result + "+"
          ElseIf (*C\c <= $7F) ; single-byte char
            Result + "%" + Hex8(*C\c)
          Else ; multi-byte char
            Protected Codepoint.i = PeekCodepoint(*C, #InternalStringFormat, @*C)
            Protected UTF8Bytes.l
            Protected NumUTF8Bytes.i = EncodeCodepointToUTF8Bytes(Codepoint, @UTF8Bytes)
            Protected i.i
            For i = 1 To NumUTF8Bytes
              Result + "%" + Hex8(PeekA(@UTF8Bytes + (i-1)))
            Next i
            *C - SizeOf(CHARACTER) ; (because it's about to be extra-incremented below)
          EndIf
      EndSelect
      *C + SizeOf(CHARACTER)
    Wend
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
