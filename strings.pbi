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
  
  #DegreeSign  = $B0
  #DegreeSign$ = Chr(#DegreeSign)
  
  #Euro  = $20AC
  #Euro$ = Chr(#Euro)
  
  #UpwardsWhiteArrow         = $21E7
  #UpwardsWhiteArrow$        = Chr(#UpwardsWhiteArrow)
  #UpwardsWhiteArrowFromBar  = $21EA
  #UpwardsWhiteArrowFromBar$ = Chr(#UpwardsWhiteArrowFromBar)
  #UpArrowhead               = $2303
  #UpArrowhead$              = Chr(#UpArrowhead)
  #PlaceOfInterestSign       = $2318
  #PlaceOfInterestSign$      = Chr(#PlaceOfInterestSign)
  #OptionKey                 = $2325
  #OptionKey$                = Chr(#OptionKey)
  
  #MacShift$    = #UpwardsWhiteArrow$
  #MacCapsLock$ = #UpwardsWhiteArrowFromBar$
  #MacControl$  = #UpArrowhead$
  #MacCommand$  = #PlaceOfInterestSign$
  #MacOption$   = #OptionKey$
  
  #Unicode_Codepoint_Min = $0000
  #Unicode_Codepoint_Max = $10FFFF
  
  #UTF16_HighSurrogate_Min = $D800
  #UTF16_HighSurrogate_Max = $DBFF
  #UTF16_LowSurrogate_Min  = $DC00
  #UTF16_LowSurrogate_Max  = $DFFF
  
  #VS15  = $FE0E
  #VS15$ = Chr(#VS15) ; Text Variant
  #VS16  = $FE0F
  #VS16$ = Chr(#VS16) ; Emoji Variant
  
  #BOM   = $FEFF
  #BOM$  = Chr(#BOM)
  #NBOM  = $FFFE
  #NBOM$ = Chr(#NBOM)
  
  #ReplacementChar  = $FFFD
  #ReplacementChar$ = Chr(#ReplacementChar)
  
  Global Dim _PBSL_StrBool.s((2)-1)
  _PBSL_StrBool(0) = "False"
  _PBSL_StrBool(1) = "True"
  
  Macro StrBool(_Expr)
    _PBSL_StrBool(Bool(_Expr))
  EndMacro
  
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
  ;- - String Manipulation
  
  Declare.s ChrU(Value.i)
  
  Macro FindStringNoCase(_String, _StringToFind, _StartPosition = 1)
    FindString(_String, _StringToFind, (_StartPosition), #PB_String_NoCase)
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
  
  Macro RemoveSpaces(_String)
    RemoveString(_String, " ")
  EndMacro
  
  Macro SQuote(_String)
    #SQ$ + _String + #SQ$
  EndMacro
  Macro DQuote(_String)
    #DQ$ + _String + #DQ$
  EndMacro
  Macro Quote(_String)
    DQuote(_String)
  EndMacro
  
  Macro SDQuote(_String)
    ReplaceString(_String, #SQ$, #DQ$)
  EndMacro
  Macro SDQuoteInPlace(_String)
    ReplaceStringInPlace(_String, #SQ$, #DQ$)
  EndMacro
  
  Procedure.s UQuote(String.s, Double.i, Heavy.i = #False) ; Unicode Quote
    CompilerIf (#IsUnicodeBuild)
      If (Heavy)
        If (Double)
          String = ChrU($275D) + String + ChrU($275E)
        Else
          String = ChrU($275B) + String + ChrU($275C)
        EndIf
      Else
        If (Double)
          String = ChrU($201C) + String + ChrU($201D)
        Else
          String = ChrU($2018) + String + ChrU($2019)
        EndIf
      EndIf
    CompilerElse
      If (Double)
        String = Quote(String)
      Else
        String = SQuote(String)
      EndIf
    CompilerEndIf
    ProcedureReturn (String)
  EndProcedure
  
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
  
  Procedure.s QuoteIfSpaces(Text.s, QuoteEmptyString.i = #False)
    If (FindString(Text, " ") Or (QuoteEmptyString And (Text = "")))
      Text = DQuote(Text)
    EndIf
    ProcedureReturn (Text)
  EndProcedure
  
  Procedure.s Plural(N.i, Singular.s, Multiple.s = "")
    If (N = 1)
      ProcedureReturn (Str(N) + " " + Singular)
    Else
      If (Multiple = "")
        Multiple = Singular + "s"
      EndIf
      ProcedureReturn (Str(N) + " " + Multiple)
    EndIf
  EndProcedure
  
  Procedure.s RepeatString(String.s, N.i)
    Protected Result.s = ""
    If (N >= 1)
      Protected Bytes.i = StringByteLength(String)
      If (Bytes >= 1)
        Result = Space(N * Bytes / SizeOf(CHARACTER))
        Protected i.i
        For i = 0 To (N-1)
          CopyMemory(@String, @Result + i * Bytes, Bytes)
        Next i
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i FindStringOccurrence(String.s, StringToFind.s, Occurrence.i, Mode.i = #PB_String_CaseSensitive)
    Protected Result.i = 0
    Protected Found.i  = 0
    If (Mode = #PB_String_NoCase)
      String = LCase(String)
      StringToFind = LCase(StringToFind)
    EndIf
    Protected i.i = 1
    While (Found < Occurrence)
      i = FindString(String, StringToFind, i, #PB_String_CaseSensitive)
      If (i)
        Found + 1
        If (Found = Occurrence)
          Result = i
          Break
        Else
          i + Len(StringToFind)
        EndIf
      Else
        Break
      EndIf
    Wend
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i FindLastOccurrence(String.s, StringToFind.s, Mode.i = #PB_String_CaseSensitive)
    Protected Result.i = 0
    If (Mode = #PB_String_NoCase)
      String = LCase(String)
      StringToFind = LCase(StringToFind)
    EndIf
    Protected i.i = CountString(String, StringToFind)
    If (i > 0)
      Result = FindStringOccurrence(String, StringToFind, i, #PB_String_CaseSensitive)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s Before(String.s, Suffix.s, Occurrence.i = 1)
    Protected Result.s
    If (String And Suffix)
      Protected i.i = FindStringOccurrence(String, Suffix, Occurrence)
      If (i)
        Result = Left(String, i-1)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s After(String.s, Prefix.s, Occurrence.i = 1)
    Protected Result.s
    If (String And Prefix)
      Protected i.i = FindStringOccurrence(String, Prefix, Occurrence)
      If (i)
        Result = Mid(String, i + Len(Prefix))
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s Between(String.s, Prefix.s, Suffix.s)
    Protected Result.s
    String = After(String, Prefix)
    Result = Before(String, Suffix)
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i IsWhitespaceCharacter(Codepoint.i)
    Select (Codepoint)
      Case #SP, #TAB, #CR, #LF
        ProcedureReturn (#True)
      Case #NUL
        ProcedureReturn (#True)
    EndSelect
    ProcedureReturn (#False)
  EndProcedure
  
  Procedure.i IsWhitespaceString(String.s)
    Protected Result.i = #True
    Protected *C.CHARACTER = @String
    While (*C\c)
      If (Not IsWhitespaceCharacter(*C\c))
        Result = #False
        Break
      EndIf
      *C + SizeOf(CHARACTER)
    Wend
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s LTrimWhitespace(String.s)
    Protected *C.CHARACTER = @String
    While (*C\c)
      If (Not IsWhitespaceCharacter(*C\c))
        ProcedureReturn (PeekS(*C))
      EndIf
      *C + SizeOf(CHARACTER)
    Wend
    ProcedureReturn ("")
  EndProcedure
  
  Procedure.s TrimWhitespace(String.s)
    Protected *Start.CHARACTER = @String
    While (#True)
      If ((*Start\c = #NUL) Or (Not IsWhitespaceCharacter(*Start\c)))
        Break
      EndIf
      *Start + SizeOf(CHARACTER)
    Wend
    If (*Start\c <> #NUL)
      Protected *Stop.CHARACTER = *Start
      Protected *C.CHARACTER = *Start
      While (*C\c)
        If (Not IsWhitespaceCharacter(*C\c))
          *Stop = *C
        EndIf
        *C + SizeOf(CHARACTER)
      Wend
      ProcedureReturn (PeekS(*Start, BytesToChars(*Stop - *Start) + 1))
    EndIf
    ProcedureReturn ("")
  EndProcedure
  
  ;-
  ;- - String Buffers
  
  Procedure.i IsStandardStringFormat(StringFormat.i)
    Select (StringFormat)
      Case #PB_Ascii, #PB_UTF8, #PB_Unicode
        ProcedureReturn (#True)
    EndSelect
    ProcedureReturn (#False)
  EndProcedure
  
  Procedure.i IsExtendedStringFormat(StringFormat.i)
    CompilerIf (#PB_Unicode <> #PB_UTF16)
      CompilerWarning "[" + #PB_Compiler_Filename + "] " + #PB_Compiler_Procedure + " assumes Unicode = UTF16"
    CompilerEndIf
    Select (StringFormat)
      Case #PB_Ascii, #PB_UTF8, #PB_Unicode, #PB_UTF16BE, #PB_UTF32, #PB_UTF32BE
        ProcedureReturn (#True)
    EndSelect
    ProcedureReturn (#False)
  EndProcedure
  
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
  
  Procedure.i StringByteLengthN(String.s, Format.i = #InternalStringFormat, NumNulls.i = 1)
    Protected Result.i = 0
    If (NumNulls >= 0)
      Format = MapPBDefault(Format, #InternalStringFormat)
      If (IsStandardStringFormat(Format))
        Result = StringByteLength(String, Format) + (NumNulls * NullTerminatorBytes(Format))
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i StringBuffer(String.s, Format.i = #InternalStringFormat, NumNulls.i = 1)
    Protected *Buffer = #Null
    If (NumNulls >= 0)
      Format = MapPBDefault(Format, #InternalStringFormat)
      If (IsStandardStringFormat(Format))
        Protected Bytes.i = StringByteLengthN(String, Format, NumNulls)
        If (Bytes > 0)
          *Buffer = AllocateMemory(Bytes)
          If (*Buffer)
            PokeS(*Buffer, String, -1, Format | #PB_String_NoZero)
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (*Buffer)
  EndProcedure
  
  CompilerIf (Not Defined(Ascii, #PB_Function))
    CompilerIf (Not Defined(Ascii, #PB_Procedure))
      Procedure.i Ascii(String.s)
        ProcedureReturn (StringBuffer(String, #PB_Ascii, 1))
      EndProcedure
    CompilerEndIf
  CompilerEndIf
  CompilerIf (Not Defined(UTF8, #PB_Function))
    CompilerIf (Not Defined(UTF8, #PB_Procedure))
      Procedure.i UTF8(String.s)
        ProcedureReturn (StringBuffer(String, #PB_UTF8, 1))
      EndProcedure
    CompilerEndIf
  CompilerEndIf
  CompilerIf (Not Defined(Unicode, #PB_Function))
    CompilerIf (Not Defined(Unicode, #PB_Procedure))
      Procedure.i Unicode(String.s)
        ProcedureReturn (StringBuffer(String, #PB_Unicode, 1))
      EndProcedure
    CompilerEndIf
  CompilerEndIf
  
  ;-
  ;- - String Lists/Maps
  
  Procedure.s ListToString(List StrList.s(), BetweenEach.s = #LF$, BeforeEach.s = "", AfterEach.s = "")
    Protected Result.s = ""
    
    PushListPosition(StrList())
    ForEach (StrList())
      If (ListIndex(StrList()) > 0)
        Result + BetweenEach
      EndIf
      Result + BeforeEach
      Result + StrList()
      Result + AfterEach
    Next
    PopListPosition(StrList())
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i DeduplicateStringList(List StrList.s())
    Protected Result.i = 0
    NewMap Found.i()
    ForEach StrList()
      If (FindMapElement(Found(), StrList()))
        DeleteElement(StrList())
        Result + 1
      Else
        AddMapElement(Found(), StrList(), #PB_Map_NoElementCheck)
      EndIf
    Next
    ClearMap(Found())
    FreeMap(Found())
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SplitStringToList(String.s, List StrList.s(), Delimiter.s, ExcludeEmpty.i = #False)
    Protected Result.i = 0
    ClearList(StrList())
    If (String And Delimiter)
      Protected N.i = 1 + CountString(String, Delimiter)
      Protected i.i
      For i = 1 To N
        AddString(StrList(), StringField(String, i, Delimiter))
        If (ExcludeEmpty And (StrList() = ""))
          DeleteElement(StrList())
        EndIf
      Next i
      Result = ListSize(StrList())
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i StringListToArray(List StrList.s(), Array StrArray.s(1))
    Protected N.i = ListSize(StrList())
    If (N > 0)
      Dim StrArray(N-1)
      ForEach (StrList())
        StrArray(ListIndex(StrList())) = StrList()
      Next
    Else
      Dim StrArray(0)
    EndIf
    ProcedureReturn (N)
  EndProcedure
  
  ;-
  ;- - Unicode Handling
  
  Macro TextVariant(_CharStr)
    RTrim(RTrim((_CharStr), #VS15$), #VS16$) + #VS15$
  EndMacro
  Macro EmojiVariant(_CharStr)
    RTrim(RTrim((_CharStr), #VS15$), #VS16$) + #VS16$
  EndMacro
  
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
  
  Procedure.i AscU(String.s)
    ProcedureReturn (PeekCodepoint(@String, #InternalStringFormat))
  EndProcedure
  
  Procedure.s ChrU(Value.i)
    CompilerIf (#IsUnicodeBuild)
      If (Value > $FFFF)
        Protected Result.s = "  "
        Value = (Value - $10000)
        PokeU(@Result + 0, #UTF16_HighSurrogate_Min + (Value >> 10) & $03FF)
        PokeU(@Result + 2, #UTF16_LowSurrogate_Min  + (Value >>  0) & $03FF)
        ProcedureReturn (Result)
      Else
        ProcedureReturn (Chr(Value))
      EndIf
    CompilerElse
      ProcedureReturn (Chr(Value))
    CompilerEndIf
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
  ;- - Pattern Matching / Glob
  
  Procedure.i _StringMatchesPattern(*String.CHARACTER, *Pattern.CHARACTER)
    Protected Result.i = #True
    While (#True)
      Select (*Pattern\c)
        Case '?'
          If (*String\c = #NUL)
            Result = #False
            Break
          EndIf
        Case '*'
          *Pattern + SizeOf(CHARACTER)
          Result = #False
          While (#True)
            If (_StringMatchesPattern(*String, *Pattern))
              Result = #True
              Break 2
            EndIf
            If (*String\c = #NUL)
              Break 2
            EndIf
            *String + SizeOf(CHARACTER)
          Wend
        Default
          If (*String\c <> *Pattern\c)
            Result = #False
            Break
          EndIf
          If (*Pattern\c = #NUL)
            Break
          EndIf
      EndSelect
      *String  + SizeOf(CHARACTER)
      *Pattern + SizeOf(CHARACTER)
    Wend
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i StringMatchesPattern(String.s, Pattern.s, CaseInsensitive.i = #False)
    ; Pattern supports
    ;   '?' for exactly 1 character
    ;   '*' for any number of characters (including 0!)
    If (CaseInsensitive)
      Protected LString.s  = LCase(String)
      Protected LPattern.s = LCase(Pattern)
      ProcedureReturn (_StringMatchesPattern(@LString, @LPattern))
    Else
      ProcedureReturn (_StringMatchesPattern(@String, @Pattern))
    EndIf
  EndProcedure
  
  Procedure.i StringMatchesPatternAny(String.s, PatternList.s, CaseInsensitive.i = #False, PatternDelimiter.s = ";")
    Protected Result.i = #False
    If (PatternList And PatternDelimiter)
      Protected N.i = 1 + CountString(PatternList, PatternDelimiter)
      Protected i.i
      For i = 1 To N
        Protected Pattern.s = StringField(PatternList, i, PatternDelimiter)
        Pattern = Trim(Pattern)
        If (Pattern)
          If (StringMatchesPattern(String, Pattern, CaseInsensitive))
            Result = #True
            Break
          EndIf
        EndIf
      Next i
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i StringMatchesPatternAll(String.s, PatternList.s, CaseInsensitive.i = #False, PatternDelimiter.s = ";")
    Protected Result.i = #False
    If (PatternList And PatternDelimiter)
      Protected N.i = 1 + CountString(PatternList, PatternDelimiter)
      Protected i.i
      For i = 1 To N
        Protected Pattern.s = StringField(PatternList, i, PatternDelimiter)
        Pattern = Trim(Pattern)
        If (Pattern)
          Result = #True
          If (Not StringMatchesPattern(String, Pattern, CaseInsensitive))
            Result = #False
            Break
          EndIf
        EndIf
      Next i
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- - Iterating Strings
  
  Prototype PBSL_IterateStringCallback(String.s, UserData.i)
  
  Enumeration ; Flags for the Interate procedures
    #Iterate_ExcludeBlank      = $0001
    #Iterate_ExcludeWhitespace = $0002
  EndEnumeration
  
  Procedure.i IterateStringList(List StrList.s(), Callback.PBSL_IterateStringCallback, UserData.i = #Null, Flags.i = #PB_Default, ExcludePrefix.s = "")
    Protected Result.i = 0
    
    If (Flags = #PB_Default)
      Flags = #Null
    EndIf
    If (Flags & #Iterate_ExcludeWhitespace)
      Flags | #Iterate_ExcludeBlank
    EndIf
    
    PushListPosition(StrList())
    ForEach (StrList())
      If ((Not (Flags & #Iterate_ExcludeBlank)) Or (StrList() <> ""))
        If ((Not (Flags & #Iterate_ExcludeWhitespace)) Or (TrimWhitespace(StrList()) <> ""))
          If ((ExcludePrefix = "") Or (Left(LTrimWhitespace(StrList()), Len(ExcludePrefix)) <> ExcludePrefix))
            If (Callback)
              Callback(StrList(), UserData)
            EndIf
            Result + 1
          EndIf
        EndIf
      EndIf
    Next
    PopListPosition(StrList())
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i IterateStringFields(String.s, Separator.s, Callback.PBSL_IterateStringCallback, UserData.i = #Null, Flags.i = #PB_Default, ExcludePrefix.s = "")
    Protected Result.i = 0
    
    If (Flags = #PB_Default)
      Flags = #Null
    EndIf
    If (Flags & #Iterate_ExcludeWhitespace)
      Flags | #Iterate_ExcludeBlank
    EndIf
    
    If (String And Separator)
      Protected N.i = 1 + CountString(String, Separator)
      Protected i.i
      For i = 1 To N
        Protected Field.s = StringField(String, i, Separator)
        If ((Not (Flags & #Iterate_ExcludeBlank)) Or (Field <> ""))
          If ((Not (Flags & #Iterate_ExcludeWhitespace)) Or (TrimWhitespace(Field) <> ""))
            If ((ExcludePrefix = "") Or (Left(LTrimWhitespace(Field), Len(ExcludePrefix)) <> ExcludePrefix))
              If (Callback)
                Callback(Field, UserData)
              EndIf
              Result + 1
            EndIf
          EndIf
        EndIf
      Next
    EndIf
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i IterateStringsFromFile(File.i, Callback.PBSL_IterateStringCallback, UserData.i = #Null, Flags.i = #PB_Default, ExcludePrefix.s = "")
    Protected Result.i = 0
    
    If (Flags = #PB_Default)
      Flags = #Null
    EndIf
    If (Flags & #Iterate_ExcludeWhitespace)
      Flags = Flags | #Iterate_ExcludeBlank
    EndIf
    
    Protected SpecificFormat.i
    If (Loc(File) = 0)
      Select (ReadStringFormat(File))
        Case #PB_UTF8
          SpecificFormat = #PB_UTF8
        Case #PB_Unicode
          SpecificFormat = #PB_Unicode
        Default
          SpecificFormat = -1
      EndSelect
    EndIf
    
    Protected Line.s
    While (Not Eof(File))
      If (SpecificFormat >= 0)
        Line = ReadString(File, SpecificFormat)
      Else
        Line = ReadString(File)
      EndIf
      If ((Not (Flags & #Iterate_ExcludeBlank)) Or (Line <> ""))
        If ((Not (Flags & #Iterate_ExcludeWhitespace)) Or (TrimWhitespace(Line) <> ""))
          If ((ExcludePrefix = "") Or (Left(LTrimWhitespace(Line), Len(ExcludePrefix)) <> ExcludePrefix))
            If (Callback)
              Callback(Line, UserData)
            EndIf
            Result + 1
          EndIf
        EndIf
      EndIf
    Wend
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i IterateStringsFromFilePath(FilePath.s, Callback.PBSL_IterateStringCallback, UserData.i = #Null, Flags.i = #PB_Default, ExcludePrefix.s = "")
    Protected Result.i = 0
    
    If (FilePath)
      Protected FN.i = ReadFile(#PB_Any, FilePath)
      If (FN)
        Result = IterateStringsFromFile(FN, Callback, UserData, Flags, ExcludePrefix)
        CloseFile(FN)
      EndIf
    EndIf
    
    ProcedureReturn (Result)
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
