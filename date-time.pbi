; +----------------------------------------+
; | PureBasic Standard Library - Date/Time |
; +----------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_DateTime_Included, #PB_Constant))
  #_PBSL_DateTime_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Date/Time Constants
  
  #MillisecondsPerSecond = 1000
  #SecondsPerMinute      = 60
  #MinutesPerHour        = 60
  #HoursPerDay           = 24
  
  #SecondsPerHour = #SecondsPerMinute * #MinutesPerHour
  #SecondsPerDay  = #SecondsPerHour   * #HoursPerDay
  #MinutesPerDay  = #MinutesPerHour   * #HoursPerDay
  
  Enumeration ; Month()
    #January = 1
    #February
    #March
    #April
    #May
    #June
    #July
    #August
    #September
    #October
    #November
    #December
  EndEnumeration
  
  Enumeration ; DayOfWeek()
    #Sunday = 0
    #Monday
    #Tuesday
    #Wednesday
    #Thursday
    #Friday
    #Saturday
  EndEnumeration
  
  ;-
  ;- - Date/Time Macros
  
  Macro Now()
    Date()
  EndMacro
  
  Macro NowUTC()
    DateUTC()
  EndMacro
  
  Macro CurrentYear()
    Year(Date())
  EndMacro
  
  ;-
  ;- - Date/Time Procedures
  
  CompilerIf (Not Defined(DateUTC, #PB_Function))
    CompilerIf (Not Defined(DateUTC, #PB_Procedure))
      
      CompilerIf (Not Defined(time, #PB_Procedure)) ; imports as a Procedure
        ImportC ""
          time.l(*t)
        EndImport
      CompilerEndIf
      
      Procedure.q DateUTC()
        ProcedureReturn (time(#Null))
      EndProcedure
    CompilerEndIf
  CompilerEndIf
  
  Procedure.q OffsetFromUTC() ; seconds
    ProcedureReturn (Date() - DateUTC())
  EndProcedure
  
  CompilerIf (Not Defined(ConvertDate, #PB_Function))
    CompilerIf (Not Defined(ConvertDate, #PB_Procedure))
      Procedure.q ConvertDate(Date.q, Format.i)
        If (Format = #PB_Date_UTC)
          Date = Date - OffsetFromUTC()
        ElseIf (Format = #PB_Date_LocalTime)
          Date = Date + OffsetFromUTC()
        Else
          Date = 0
        EndIf
        ProcedureReturn (Date)
      EndProcedure
    CompilerEndIf
  CompilerEndIf
  
CompilerEndIf
;-
