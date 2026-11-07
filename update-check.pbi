; +-------------------------------------------+
; | PureBasic Standard Library - Update Check |
; +-------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_UpdateCheck_Included, #PB_Constant))
  #_PBSL_UpdateCheck_Included = #True
  
  ;-
  ;- - Update Check Structures
  
  Structure UpdateCheckEntry
    ID.i
    Name.s
    Date.q
    Tags.s
    Map Attribute.s()
  EndStructure
  
  ;-
  ;- - Update Check Globals
  
  Global NewList _PBSL_Update.UpdateCheckEntry()
  
  Global _PBSL_UpdateCheckBusy.i = #False
  
  ;-
  ;- - Update Check Procedures
  
  Procedure.i _UpdateCheckParseOpenedFile(FN.i)
    Protected Result.i = #True
    Protected Text.s, LHS.s, RHS.s, i.i
    Protected *Entry.UpdateCheckEntry = #Null
    
    ClearList(_PBSL_Update())
    If (#False)
      FileSeek(FN, 0, #PB_Absolute)
    EndIf
    ReadStringFormat(FN)
    While (Not Eof(FN))
      Text = ReadString(FN)
      Text = LTrimWhitespace(Text)
      If (Text)
        If (Asc(Text) = '[')
          Text = Trim(Between(Text, "[", "]"))
          If (Text)
            *Entry = AddElement(_PBSL_Update())
            *Entry\ID = Val(Text)
          EndIf
        Else
          If (*Entry)
            i = FindString(Text, "=")
            If (i > 1)
              LHS = LCase(Trim(Left(Text, i-1)))
              If (LHS)
                RHS = Trim(Mid(Text, i+1))
                *Entry\Attribute(LHS) = RHS
                Select (LHS)
                  Case "name"
                    *Entry\Name = RHS
                  Case "date"
                    *Entry\Date = ParseDateCommon(RHS)
                  Case "tags"
                    *Entry\Tags = "," + ReplaceString(LCase(RHS), " ", ",") + ","
                EndSelect
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Wend
    If (Result)
      If (ListSize(_PBSL_Update()) > 0)
        SortStructuredList(_PBSL_Update(), #PB_Sort_Descending, OffsetOf(UpdateCheckEntry\ID), #PB_Integer)
      Else
        Result = #False
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i UpdateCheckBusy()
    ProcedureReturn (_PBSL_UpdateCheckBusy)
  EndProcedure
  
  Procedure.i GetLatestUpdate()
    Protected Result.i = 0
    If (FirstElement(_PBSL_Update()))
      Result = _PBSL_Update()\ID
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GetLatestUpdateWithTags(Tags.s)
    Protected Result.i = 0
    Tags = LCase(ReplaceString(Tags, " ", ","))
    NewList Tag.s()
    SplitStringToList(Tags, Tag(), ",", #True)
    ForEach Tag()
      Tag() = "," + Tag() + ","
    Next
    
    Protected Match.i
    ForEach _PBSL_Update()
      Match = #True
      ForEach Tag()
        If (Not FindString(_PBSL_Update()\Tags, Tag()))
          Match = #False
          Break
        EndIf
      Next
      If (Match)
        Result = _PBSL_Update()\ID
        Break
      EndIf
    Next
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s GetUpdateName()
    Protected Result.s = ""
    If (ListIndex(_PBSL_Update()) >= 0)
      Result = _PBSL_Update()\Name
      If (Result = "")
        Result = Str(_PBSL_Update()\ID)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.q GetUpdateDate()
    Protected Result.q = 0
    If (ListIndex(_PBSL_Update()) >= 0)
      Result = _PBSL_Update()\Date
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s GetUpdateAttribute(AttributeName.s)
    Protected Result.s = ""
    AttributeName = LCase(Trim(AttributeName))
    If (AttributeName)
      If (ListIndex(_PBSL_Update()) >= 0)
        Result = _PBSL_Update()\Attribute(AttributeName)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ParseUpdatesFromFile(File.s)
    Protected Result.i = #False
    If (File)
      If (Not _PBSL_UpdateCheckBusy)
        _PBSL_UpdateCheckBusy = #True
        Protected FN.i = ReadFile(#PB_Any, File)
        If (FN)
          Result = _UpdateCheckParseOpenedFile(FN)
          CloseFile(FN)
        EndIf
        _PBSL_UpdateCheckBusy = #False
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  CompilerIf (Defined(_PBSL_Network_Included, #PB_Constant))
    
    Procedure.i ParseUpdatesFromURL(URL.s)
      Protected Result.i = #False
      If (URL)
        If (Not _PBSL_UpdateCheckBusy)
          _PBSL_UpdateCheckBusy = #True
          If (InitNetwork())
            Protected TempFile.s = GetTemporaryDirectory() + "updates.ini"
            If (ReceiveHTTPFile(URL, TempFile))
              Protected FN.i = ReadFile(#PB_Any, TempFile)
              If (FN)
                Result = _UpdateCheckParseOpenedFile(FN)
                CloseFile(FN)
              EndIf
              DeleteFile(TempFile)
            EndIf
          EndIf
          _PBSL_UpdateCheckBusy = #False
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
  CompilerEndIf
  
CompilerEndIf
;-
