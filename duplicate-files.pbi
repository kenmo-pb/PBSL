; +----------------------------------------------+
; | PureBasic Standard Library - Duplicate Files |
; +----------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_DuplicateFiles_Included, #PB_Constant))
  #_PBSL_DuplicateFiles_Included = #True
  
  XIncludeFile "scan-folder.pbi"
  
  ;- Duplicate Files Constants
  
  CompilerIf (Not Defined(DuplicateFiles_UseMD5Hash, #PB_Constant))
    #DuplicateFiles_UseMD5Hash = #True
  CompilerEndIf
  
  CompilerIf (#DuplicateFiles_UseMD5Hash)
    UseMD5Fingerprint()
    Macro _DuplicateFilesHash(_File)
      FileFingerprint(_File, #PB_Cipher_MD5)
    EndMacro
  CompilerEndIf
  
  ;-
  ;- Duplicate Files Structures
  
  Structure _DuplicateFilesStruct
    Path.s
    Size.q
    Hash.s
    NameWeight.i
  EndStructure
  
  ;-
  ;- Duplicate Files Procedures
  
  Procedure.i _DuplicateFilesNameWeight(FileName.s)
    Protected Result.i = 0
    Protected *C.CHARACTER = @FileName
    While (*C\c)
      Select (*C\c)
        Case '(', ')'
          Result + 3
        Case '0' To '9'
          Result + 2 + (*C\c - '0')
        Default
          Result + 1
      EndSelect
      *C + #CharSize
    Wend
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i FindDuplicateFiles(Folder.s, List Duplicate.s(), Recursive.i = #False, Extensions.s = "", MaxSubfolderDepth.i = 0)
    ClearList(Duplicate())
    
    ; Phase 1 - Scan for all files
    Folder = EnsurePathSeparator(Folder)
    NewList FoundFile.s()
    If (ScanFolderToList(Folder, FoundFile(), #ScanFolder_Absolute | #ScanFolder_NoSort | #ScanFolder_ReturnCount | (Bool(Recursive) * #ScanFolder_Recursive), Extensions, MaxSubfolderDepth) > 0)
      
      ; Phase 2 - Check for matching file sizes
      NewList ProcessedFile._DuplicateFilesStruct()
      NewMap MatchCount.i()
      ForEach FoundFile()
        Protected Size.q = FileSize(FoundFile())
        If ((Size > 0) Or (#False)) ; include 0-byte files as "duplicates" ?
          AddElement(ProcessedFile())
          ProcessedFile()\Path = FoundFile()
          ProcessedFile()\Size = Size
          ProcessedFile()\Hash = Str(Size)
          MatchCount(ProcessedFile()\Hash) + 1
        EndIf
      Next
      ClearList(FoundFile())
      ForEach ProcessedFile()
        If (MatchCount(ProcessedFile()\Hash) <= 1)
          DeleteElement(ProcessedFile())
        EndIf
      Next
      
      ; Phase 3 - Check for matching file hash too
      If (ListSize(ProcessedFile()) > 0)
        ClearMap(MatchCount())
        ForEach (ProcessedFile())
          ProcessedFile()\Hash + "-" + _DuplicateFilesHash(ProcessedFile()\Path)
          MatchCount(ProcessedFile()\Hash) + 1
        Next
        ForEach ProcessedFile()
          If (MatchCount(ProcessedFile()\Hash) <= 1)
            DeleteElement(ProcessedFile())
          EndIf
        Next
        
        ; Phase 4 - Duplicates found, weight them by file name!
        If (ListSize(ProcessedFile()) > 0)
          ForEach ProcessedFile()
            ProcessedFile()\NameWeight = _DuplicateFilesNameWeight(GetFilePart(ProcessedFile()\Path))
          Next
          SortStructuredList(ProcessedFile(), #PB_Sort_Ascending, OffsetOf(_DuplicateFilesStruct\NameWeight), #PB_Integer)
          
          ; Phase 5 - For each match group, return the more-weighted duplicates!
          Protected FoundFileToKeep.i
          ForEach MatchCount()
            FoundFileToKeep = #False
            Protected Hash.s = MapKey(MatchCount())
            ForEach ProcessedFile()
              If (ProcessedFile()\Hash = Hash)
                If (FoundFileToKeep)
                  AddString(Duplicate(), ProcessedFile()\Path)
                Else
                  FoundFileToKeep = #True
                EndIf
                DeleteElement(ProcessedFile())
              EndIf
            Next
          Next
        EndIf
        
      EndIf
      
      ClearMap(MatchCount())
      FreeMap(MatchCount())
      ClearList(ProcessedFile())
      FreeList(ProcessedFile())
    EndIf
    FreeList(FoundFile())
    
    ProcedureReturn (ListSize(Duplicate()))
  EndProcedure
  
  Procedure.i DeleteDuplicateFiles(Folder.s, Recursive.i = #False, Extensions.s = "", MaxSubfolderDepth.i = 0)
    Protected Result.i = 0 ; Number Deleted
    NewList DupeToDelete.s()
    If (FindDuplicateFiles(Folder, DupeToDelete(), Recursive, Extensions, MaxSubfolderDepth))
      ForEach DupeToDelete()
        If (DeleteFile(DupeToDelete(), #PB_FileSystem_Force))
          Result + 1
        EndIf
      Next
    EndIf
    ClearList(DupeToDelete())
    FreeList(DupeToDelete())
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
