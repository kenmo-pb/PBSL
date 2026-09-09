; +-------------------------------------+
; | PureBasic Standard Library - Mac OS |
; +-------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_MacOS_Included, #PB_Constant))
  #_PBSL_MacOS_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  CompilerIf (#IsMacBuild)
    
    ;-
    ;- - Mac Constants
    #AppleQuarantineAttribute = "com.apple.quarantine"
    
    ;-
    ;- - Mac Procedures
    
    Procedure.i IsAppTranslocated()
      ; https://lapcatsoftware.com/articles/app-translocation.html
      ;   or use 'translocate-status-check' ?
      ; https://lapcatsoftware.com/articles/translocate-relocated.html
      Protected Path.s = ProgramFilename()
      If (FindString(Path, "/AppTranslocation/"))
        ;If (StartsWith(Path, "/private/"))
        ProcedureReturn (#True)
        ;EndIf
      EndIf
      ProcedureReturn (#False)
    EndProcedure
    
    Procedure.i HasXAttribute(Path.s, Attribute.s)
      ; https://stackoverflow.com/questions/46198557/understanding-output-of-xattr-p-com-apple-quarantine
      ;   or 'ls -l@'
      Protected Result.i = #False
      If (Path And Attribute)
        Protected Output.s = RunProgramOutputHidden("xattr", "-p " + Attribute + " " + QuoteIfSpaces(Path), GetCurrentDirectory(), #PB_Program_Read)
        If (Output)
          Result = #True
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure RemoveXAttribute(Path.s, Attribute.s, Recursive.i = #False)
      ; https://superuser.com/questions/526920/how-to-remove-quarantine-from-file-permissions-in-os-x
      If (Path And Attribute)
        Protected Params.s = "-d"
        If (Recursive)
          Params + "r";" -r"
        EndIf
        Params + " " + Attribute + " " + QuoteIfSpaces(Path)
        RunProgramHidden("xattr", Params, GetCurrentDirectory(), #PB_Program_Wait)
      EndIf
    EndProcedure
    
    Procedure.s GetUntranslocatedPath(TranslocatedPath.s)
      ; https://lapcatsoftware.com/articles/translocate-relocated.html
      Protected Result.s = ""
      If (TranslocatedPath)
        ;Protected Output.s = RunProgramOutputHidden("security", "translocate-status-check " + QuoteIfSpaces(TranslocatedPath))
        Protected Output.s = RunProgramOutputHidden("security", "translocate-original-path " + QuoteIfSpaces(TranslocatedPath), GetCurrentDirectory(), #PB_Program_Read)
        If (Output)
          Result = After(Output, #TAB$)
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
    Procedure.i LaunchAppUntranslocated(ProgramParams.s = "")
      Protected Result.i = #False
      If (IsAppTranslocated())
        Protected AppPath.s = GetProgramAppPath()
        Protected Untranslocated.s = GetUntranslocatedPath(AppPath)
        If (Untranslocated)
          ;If (HasXAttribute(Untranslocated, #AppleQuarantineAttribute))
          RemoveXAttribute(Untranslocated, #AppleQuarantineAttribute, #True)
          ;EndIf
          Protected Params.s = ProgramParams
          If ((Params = "") And (#True))
            Params = ProgramParametersString()
          EndIf
          Result = LaunchApp(Untranslocated, Params, GetCurrentDirectory())
          If (Result And (#False))
            End
          EndIf
        EndIf
      EndIf
      ProcedureReturn (Result)
    EndProcedure
    
  CompilerEndIf
  
CompilerEndIf
;-
