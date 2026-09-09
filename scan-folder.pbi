; +------------------------------------------+
; | PureBasic Standard Library - Scan Folder |
; +------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_ScanFolder_Included, #PB_Constant))
  #_PBSL_ScanFolder_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Scan Folder Constants
  
  Enumeration ; Flags for ScanFolder()
    #ScanFolder_Absolute          = $001
    #ScanFolder_Recursive         = $002
    #ScanFolder_ExcludeHidden     = $004
    #ScanFolder_IncludeFolders    = $008
    #ScanFolder_ExcludeFiles      = $010
    #ScanFolder_SortCaseSensitive = $020
    #ScanFolder_NoSort            = $040
    #ScanFolder_PreserveList      = $080
    #ScanFolder_ReturnCount       = $100
    ;
    #ScanFolder_FoldersOnly       = #ScanFolder_IncludeFolders | #ScanFolder_ExcludeFiles
    ;
    #ScanFolder_Relative       = 0
    #ScanFolder_Nonrecursive   = 0
    #ScanFolder_IncludeHidden  = 0
    #ScanFolder_ExcludeFolders = 0
    #ScanFolder_IncludeFiles   = 0
    #ScanFolder_SortNoCase     = 0
    ;
    #ScanFolder_DefaultFlags   = 0
  EndEnumeration
  
  ;-
  ;- - Scan Folder Procedures
  
  Procedure.i _ScanFolderToList(BaseFolder.s, RelSubfolder.s, Depth.i, List Entry.s(), Flags.i, Extensions.s, MaxSubfolderDepth.i)
    Protected Result.i = #False
    Protected DN.i = ExamineDirectory(#PB_Any, BaseFolder + RelSubfolder, "")
    If (DN)
      Result = #True
      Protected Match.i
      Protected Name.s, Ext.s
      While (NextDirectoryEntry(DN))
        Name = DirectoryEntryName(DN)
        If (DirectoryEntryType(DN) = #PB_DirectoryEntry_File)
          If (Not (Flags & #ScanFolder_ExcludeFiles))
            Match = #True
            If (Flags & #ScanFolder_ExcludeHidden)
              If (IsHidden(BaseFolder + RelSubfolder + Name))
                Match = #False
              EndIf
            EndIf
            If (Match)
              If (Extensions)
                Ext = LCase(GetExtensionPart(Name))
                If (Ext)
                  If (Not FindString(Extensions, " " + Ext + " "))
                    Match = #False
                  EndIf
                Else
                  Match = #False ; reject files without extensions, if extensions specified
                EndIf
              Else
                ; no extensions specified: so accept all
              EndIf
            EndIf
            If (Match)
              AddElement(Entry())
              Entry() = RelSubfolder + Name
              If (Flags & #ScanFolder_Absolute)
                Entry() = BaseFolder + Entry()
              EndIf
            EndIf
          EndIf
        Else
          If ((Name <> ".") And (Name <> ".."))
            If (Flags & #ScanFolder_IncludeFolders)
              Match = #True
              If (Flags & #ScanFolder_ExcludeHidden)
                If (IsHidden(BaseFolder + RelSubfolder + Name))
                  Match = #False
                EndIf
              EndIf
              If (Match)
                AddElement(Entry())
                Entry() = RelSubfolder + Name + #PS$
                If (Flags & #ScanFolder_Absolute)
                  Entry() = BaseFolder + Entry()
                EndIf
              EndIf
            EndIf
            If (Flags & #ScanFolder_Recursive)
              If ((MaxSubfolderDepth <= 0) Or (Depth < MaxSubfolderDepth))
                _ScanFolderToList(BaseFolder, RelSubfolder + Name + #PS$, Depth + 1, Entry(), Flags, Extensions, MaxSubfolderDepth)
              EndIf
            EndIf
          EndIf
        EndIf
      Wend
      FinishDirectory(DN)
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ScanFolderToList(Folder.s, List Entry.s(), Flags.i = #ScanFolder_DefaultFlags, Extensions.s = "", MaxSubfolderDepth.i = 0)
    Protected Result.i = #False
    If (Folder)
      Folder = EnsurePathSeparator(Folder)
      
      Flags = MapPBDefault(Flags, #ScanFolder_DefaultFlags)
      If (Flags & #ScanFolder_PreserveList)
        LastElement(Entry())
      Else
        ClearList(Entry())
      EndIf
      Protected OriginalCount.i = ListSize(Entry())
      
      Protected *C.CHARACTER = @Extensions
      While (*C\c)
        Select (*C\c)
          Case ',', ';', '*', '.'
            *C\c = ' '
        EndSelect
        *C + SizeOf(CHARACTER)
      Wend
      Extensions = Trim(Extensions)
      If (Extensions)
        Extensions = LCase(Extensions)
        Extensions = " " + Extensions + " "
      EndIf
      
      Result = _ScanFolderToList(Folder, "", 0, Entry(), Flags, Extensions, MaxSubfolderDepth)
      If (Result)
        If (Flags & #ScanFolder_NoSort)
          ; skip sorting
        ElseIf (Flags & #ScanFolder_SortCaseSensitive)
          SortList(Entry(), #PB_Sort_Ascending)
        Else
          SortList(Entry(), #PB_Sort_Ascending | #PB_Sort_NoCase)
        EndIf
        If (Flags & #ScanFolder_ReturnCount)
          Result = (ListSize(Entry()) - OriginalCount)
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ScanFolderCount(Folder.s, Flags.i = #ScanFolder_DefaultFlags, Extensions.s = "", MaxSubfolderDepth.i = 0)
    Protected Result.i = 0
    NewList Temp.s()
    Result = ScanFolderToList(Folder, Temp(), Flags | #ScanFolder_ReturnCount, Extensions, MaxSubfolderDepth)
    FreeList(Temp())
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
