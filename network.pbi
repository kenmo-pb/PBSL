; +--------------------------------------+
; | PureBasic Standard Library - Network |
; +--------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Network_Included, #PB_Constant))
  #_PBSL_Network_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Network Constants
  
  #DefaultUserAgent$ = "Mozilla/5.0 Gecko/41.0 Firefox/41.0" ; as of PB 6.40
  
  ;-
  ;- - Network Procedures
  
  Procedure.i InitNetworkTimeout(TimeoutMS.i)
    Protected Result.i = InitNetwork()
    If (Not Result)
      If (TimeoutMS > 0)
        Protected DelayMS.i = 1000
        If (TimeoutMS < 1500)
          TimeoutMS = 100
        EndIf
        Protected EndTime.i = ElapsedMilliseconds() + TimeoutMS
        While ((Not Result) And (ElapsedMilliseconds() < EndTime))
          Delay(DelayMS)
          Result = InitNetwork()
        Wend
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
