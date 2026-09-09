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
  Macro CurrentMonth()
    Month(Date())
  EndMacro
  Macro CurrentDayOfMonth()
    Day(Date())
  EndMacro
  Macro CurrentDayOfWeek()
    DayOfWeek(Date())
  EndMacro
  Macro CurrentDayOfYear()
    DayOfYear(Date())
  EndMacro
  
  Macro DateString(_Timestamp = Now())
    FormatDate("%yyyy-%mm-%dd", _Timestamp)
  EndMacro
  Macro TimeString(_Timestamp = Now())
    FormatDate("%hh:%ii:%ss", _Timestamp)
  EndMacro
  Macro TimestampString(_Timestamp = Now())
    FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", _Timestamp)
  EndMacro
  
  ;-
  ;- - Time Conversions
  
  Macro SecondsToMilliseconds(_Seconds)
    ((_Seconds) * #MillisecondsPerSecond)
  EndMacro
  Macro MinutesToMilliseconds(_Minutes)
    ((_Minutes) * #MillisecondsPerSecond * #SecondsPerMinute)
  EndMacro
  Macro HoursToMilliseconds(_Hours)
    ((_Hours) * #MillisecondsPerSecond * #SecondsPerHour)
  EndMacro
  Macro DaysToMilliseconds(_Days)
    ((_Days) * #MillisecondsPerSecond * #SecondsPerDay)
  EndMacro
  
  Macro MinutesToSeconds(_Minutes)
    ((_Minutes) * #SecondsPerMinute)
  EndMacro
  Macro HoursToSeconds(_Hours)
    ((_Hours) * #SecondsPerHour)
  EndMacro
  Macro DaysToSeconds(_Days)
    ((_Days) * #SecondsPerDay)
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
  
  Procedure.i IsLeapYear(Year.i)
    ProcedureReturn (Bool(AddDate(Date(Year, #February, 28, 0, 0, 0), #PB_Date_Day, 1) = Date(Year, #February, 29, 0, 0, 0)))
  EndProcedure
  
  Procedure.i DaysInMonth(Month.i, Year.i = #PB_Default)
    If (Year = #PB_Default)
      Year = CurrentYear()
    EndIf
    Year = MapPBDefault(Year, CurrentYear())
    Select (Month)
      Case #January, #March, #May, #July, #August, #October, #December
        ProcedureReturn (31)
      Case #April, #June, #September, #November
        ProcedureReturn (30)
      Case #February
        If (IsLeapYear(Year))
          ProcedureReturn (29)
        Else
          ProcedureReturn (28)
        EndIf
    EndSelect
    ProcedureReturn (0)
  EndProcedure
  
  Procedure.i DaysInYear(Year.i = #PB_Default)
    If (Year = #PB_Default)
      Year = CurrentYear()
    EndIf
    ProcedureReturn (365 + IsLeapYear(Year))
  EndProcedure
  
  Procedure.i FirstDayOfWeekOfMonth(Month.i, Year.i = #PB_Default)
    If (Year = #PB_Default)
      Year = CurrentYear()
    EndIf
    ProcedureReturn (DayOfWeek(Date(Year, Month, 1, 0, 0, 0)))
  EndProcedure
  
  Procedure.i FirstDayOfWeekOfYear(Year.i = #PB_Default)
    ProcedureReturn (FirstDayOfWeekOfMonth(#January, Year))
  EndProcedure
  
CompilerEndIf
;-
