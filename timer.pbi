; +------------------------------------+
; | PureBasic Standard Library - Timer |
; +------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Timer_Included, #PB_Constant))
  #_PBSL_Timer_Included = #True
  
  CompilerIf (Not #IsThreadsafe)
    CompilerWarning "ThreadSafe mode is recommended for " + #PB_Compiler_Filename
  CompilerEndIf
  
  ;- - Timer Constants
  
  #Timer_Forever = 0
  
  Enumeration ; Timer States
    #Timer_Freeing = -1
    ;
    #Timer_Stopped = 0
    #Timer_Active
    #Timer_Paused
  EndEnumeration
  
  ;-
  ;- - Timer Structures
  
  Structure Timer
    State.i
    Thread.i
    ;
    UnpauseTime.q
    ElapsedMSWhenPaused.q
    ;
    Timeout.q
    TimeoutCallback.i
    *TimeoutInteger.INTEGER
    TimeoutEvent.i
    TimeoutEventWindow.i
    ;
    Interval.q
    IntervalCallback.i
    IntervalsComplete.i
    *IntervalInteger.INTEGER
    IntervalEvent.i
    IntervalEventWindow.i
  EndStructure
  
  ;-
  ;- - Timer Procedures (Private)
  
  Procedure _TimerReset(*Timer.Timer)
    *Timer\ElapsedMSWhenPaused = 0
    *Timer\IntervalsComplete   = 0
    If (*Timer\State = #Timer_Active)
      *Timer\UnpauseTime = ElapsedMilliseconds()
    EndIf
    If (#True)
      If (*Timer\TimeoutInteger)
        *Timer\TimeoutInteger\i = #False
      EndIf
      If (*Timer\IntervalInteger)
        *Timer\IntervalInteger\i = 0
      EndIf
    EndIf
  EndProcedure
  
  Procedure _TimerPause(*Timer.Timer, Reset.i)
    If (*Timer\State <> #Timer_Freeing)
      If (*Timer\State = #Timer_Active)
        *Timer\ElapsedMSWhenPaused + (ElapsedMilliseconds() - *Timer\UnpauseTime)
        If (*Timer\Timeout > 0)
          If (*Timer\ElapsedMSWhenPaused > *Timer\Timeout)
            *Timer\ElapsedMSWhenPaused = *Timer\Timeout
          EndIf
        EndIf
      EndIf
      *Timer\State = #Timer_Paused
      If (Reset)
        _TimerReset(*Timer)
      EndIf
    EndIf
  EndProcedure
  
  Procedure _TimerUnpause(*Timer.Timer, Reset.i)
    If (*Timer\State <> #Timer_Freeing)
      If (Reset)
        *Timer\State = #Timer_Active
        _TimerReset(*Timer)
      Else
        *Timer\UnpauseTime = ElapsedMilliseconds()
        *Timer\State = #Timer_Active
      EndIf
    EndIf
  EndProcedure
  
  Procedure _TimerStop(*Timer.Timer, Reset.i)
    If (*Timer\State <> #Timer_Freeing)
      _TimerPause(*Timer, Reset)
      *Timer\State = #Timer_Stopped
    EndIf
  EndProcedure
  
  Procedure _TimerThread(*Timer.Timer)
    Protected Elapsed.q
    Protected NumIntervals.i
    Protected CallTimeout.i = #False
    Protected CallInterval.i = 0
    
    While (*Timer\State <> #Timer_Freeing)
      If (*Timer\State = #Timer_Active)
        Elapsed = *Timer\ElapsedMSWhenPaused + (ElapsedMilliseconds() - *Timer\UnpauseTime)
        If (*Timer\Timeout > 0)
          If (Elapsed >= *Timer\Timeout)
            _TimerStop(*Timer, #False)
            Elapsed = *Timer\Timeout
            CallTimeout = #True
          EndIf
        EndIf
        If (*Timer\Interval > 0)
          NumIntervals = (Elapsed / *Timer\Interval)
          If (NumIntervals > *Timer\IntervalsComplete)
            CallInterval + (NumIntervals - *Timer\IntervalsComplete)
          EndIf
        EndIf
        While (CallInterval > 0)
          *Timer\IntervalsComplete + 1
          If (*Timer\IntervalInteger)
            *Timer\IntervalInteger\i = *Timer\IntervalsComplete
          EndIf
          If (*Timer\IntervalEvent)
            PostEvent(*Timer\IntervalEvent, *Timer\IntervalEventWindow, 0, #Null, *Timer)
          EndIf
          If (*Timer\IntervalCallback)
            CallFunctionFast(*Timer\IntervalCallback, *Timer)
          EndIf
          CallInterval - 1
        Wend
        If (CallTimeout)
          If (*Timer\TimeoutInteger)
            *Timer\TimeoutInteger\i = #True
          EndIf
          If (*Timer\TimeoutEvent)
            PostEvent(*Timer\TimeoutEvent, *Timer\TimeoutEventWindow, 0, #Null, *Timer)
          EndIf
          If (*Timer\TimeoutCallback)
            CallFunctionFast(*Timer\TimeoutCallback, *Timer)
          EndIf
          CallTimeout = #False
        EndIf
      EndIf
      Delay(5)
    Wend
    
    *Timer\Thread = #Null
  EndProcedure
  
  ;-
  ;- - Timer Procedures (Public)
  
  Procedure.i TimerDone(*Timer.Timer)
    Protected Result.i = #False
    If (*Timer)
      If (*Timer\State = #Timer_Stopped)
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i TimerPaused(*Timer.Timer)
    Protected Result.i = #False
    If (*Timer)
      If (*Timer\State = #Timer_Paused)
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i TimerBusy(*Timer.Timer)
    Protected Result.i = #False
    If (*Timer)
      If (*Timer\State = #Timer_Active)
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i TimerState(*Timer.Timer)
    Protected Result.i = #Timer_Stopped
    If (*Timer)
      Result = *Timer\State
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i TimerCompletedIntervals(*Timer.Timer)
    Protected Result.i = 0
    If (*Timer)
      Result = *Timer\IntervalsComplete
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.q TimerElapsedMilliseconds(*Timer.Timer)
    Protected Result.q = 0
    If (*Timer)
      If (*Timer\State = #Timer_Active)
        Result = *Timer\ElapsedMSWhenPaused + (ElapsedMilliseconds() - *Timer\UnpauseTime)
      Else
        Result = *Timer\ElapsedMSWhenPaused
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.q TimerElapsedSeconds(*Timer.Timer)
    ProcedureReturn (TimerElapsedMilliseconds(*Timer) / 1000)
  EndProcedure
  
  Procedure.i StartTimer(*Timer.Timer, TimeoutMS.q = #PB_Ignore, Reset.i = #True)
    Protected Result.i = #False
    If (*Timer)
      If (*Timer\State <> #Timer_Freeing)
        If (TimeoutMS <> #PB_Ignore)
          *Timer\Timeout = TimeoutMS
        EndIf
        _TimerUnpause(*Timer, Reset)
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i StopTimer(*Timer.Timer, Reset.i = #False)
    Protected Result.i = #False
    If (*Timer)
      If (*Timer\State <> #Timer_Freeing)
        _TimerPause(*Timer, Reset)
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ResetTimer(*Timer.Timer, Stop.i = #False)
    Protected Result.i = #False
    If (*Timer)
      If (Stop)
        Result = StopTimer(*Timer, #True)
      Else
        _TimerReset(*Timer)
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i PauseTimer(*Timer.Timer)
    Protected Result.i = #False
    If (*Timer)
      If (*Timer\State = #Timer_Active)
        _TimerPause(*Timer, #False)
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i UnpauseTimer(*Timer.Timer)
    Protected Result.i = #False
    If (*Timer)
      If (*Timer\State = #Timer_Active)
        Result = #True
      ElseIf (*Timer\State = #Timer_Paused)
        _TimerUnpause(*Timer, #False)
        Result = #True
      ElseIf (*Timer\State = #Timer_Stopped)
        If ((*Timer\Timeout <= 0) Or (*Timer\Timeout > *Timer\ElapsedMSWhenPaused))
          _TimerUnpause(*Timer, #False)
          Result = #True
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure WaitTimer(*Timer.Timer)
    If (*Timer)
      If (*Timer\Timeout > 0)
        _TimerUnpause(*Timer, #False)
        While (*Timer\State > #Timer_Stopped)
          Delay(5)
        Wend
      EndIf
    EndIf
  EndProcedure
  
  Procedure.i SetTimerTimeoutMilliseconds(*Timer.Timer, TimeoutMS.q, *Callback = #Null)
    Protected Result.i = #False
    If (*Timer)
      If (TimeoutMS >= 0)
        *Timer\Timeout = TimeoutMS
        *Timer\TimeoutCallback = *Callback
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetTimerTimeoutSeconds(*Timer.Timer, TimeoutSeconds.d, *Callback = #Null)
    Protected Result.i = #False
    If (*Timer)
      If (TimeoutSeconds >= 0)
        *Timer\Timeout = TimeoutSeconds * 1000
        *Timer\TimeoutCallback = *Callback
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetTimerTimeoutCallback(*Timer.Timer, *Callback)
    Protected Result.i = #False
    If (*Timer)
      *Timer\TimeoutCallback = *Callback
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetTimerTimeoutIntegerPointer(*Timer.Timer, *Pointer.INTEGER)
    Protected Result.i = #False
    If (*Timer)
      *Timer\TimeoutInteger = *Pointer
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetTimerTimeoutEvent(*Timer.Timer, Event.i, Window.i = 0)
    Protected Result.i = #False
    If (*Timer)
      *Timer\TimeoutEvent = Event
      *Timer\TimeoutEventWindow = Window
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetTimerIntervalMilliseconds(*Timer.Timer, IntervalMS.q, *Callback = #Null)
    Protected Result.i = #False
    If (*Timer)
      If (IntervalMS >= 0)
        *Timer\Interval = IntervalMS
        *Timer\IntervalCallback = *Callback
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetTimerIntervalSeconds(*Timer.Timer, IntervalSeconds.d, *Callback = #Null)
    Protected Result.i = #False
    If (*Timer)
      If (IntervalSeconds >= 0)
        *Timer\Interval = IntervalSeconds * 1000
        *Timer\IntervalCallback = *Callback
        Result = #True
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetTimerIntervalCallback(*Timer.Timer, *Callback)
    Protected Result.i = #False
    If (*Timer)
      *Timer\IntervalCallback = *Callback
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetTimerIntervalIntegerPointer(*Timer.Timer, *Pointer.INTEGER)
    Protected Result.i = #False
    If (*Timer)
      *Timer\IntervalInteger = *Pointer
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetTimerIntervalEvent(*Timer.Timer, Event.i, Window.i = 0)
    Protected Result.i = #False
    If (*Timer)
      *Timer\IntervalEvent = Event
      *Timer\IntervalEventWindow = Window
      Result = #True
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i FreeTimer(*Timer.Timer)
    If (*Timer)
      *Timer\State = #Timer_Freeing
      While (*Timer\Thread)
        Delay(1)
      Wend
      FreeStructure(*Timer)
    EndIf
    ProcedureReturn (#Null)
  EndProcedure
  
  Procedure.i CreateTimer(TimeoutMS.q = #Timer_Forever)
    Protected *Timer.Timer = AllocateStructure(Timer)
    If (*Timer)
      *Timer\State = #Timer_Stopped
      If (TimeoutMS > 0)
        *Timer\Timeout = TimeoutMS
      EndIf
      *Timer\Thread = CreateThread(@_TimerThread(), *Timer)
      If (Not *Timer\Thread)
        *Timer = FreeTimer(*Timer)
      EndIf
    EndIf
    ProcedureReturn (*Timer)
  EndProcedure
  
CompilerEndIf
;-
