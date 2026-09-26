; +----------------------------------------+
; | PureBasic Standard Library - Animation |
; +----------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Animation_Included, #PB_Constant))
  #_PBSL_Animation_Included = #True
  
  CompilerIf (Not #IsThreadsafe)
    CompilerWarning "ThreadSafe mode is recommended for " + #PB_Compiler_Filename
  CompilerEndIf
  
  ;- - Animation Constants
  
  Enumeration ; AnimationTimer Status
    #AnimationTimer_Invalid = 0
    #AnimationTimer_Paused
    #AnimationTimer_Playing
    ;
    #AnimationTimer_Freeing
  EndEnumeration
  
  #AnimationTimer_LoopForever = -1
  
  #Animation_DefaultFrameDelay = 100 ; ms
  
  ;-
  ;- - Animation Structures
  
  Structure AnimationTimer
    NumFrames.i
    CurrentFrame.i
    TotalMS.i
    LoopsLeft.i
    
    UnpauseTime.q
    ElapsedMSWhenPaused.q
    Status.i
    Thread.i
    
    FrameChanged.i
    Callback.i
    Image.i
    ImageGadget.i
    CanvasGadget.i
    
    Array FrameMS.i(0)
  EndStructure
  
  ;-
  ;- - Animation Procedures
  
  Procedure _AnimationTimerThread(*Timer.AnimationTimer)
    Protected NewTime.q
    Protected ElapsedTime.q
    Protected PrevFrame.i
    Protected i.i, Sum.i
    While (*Timer\Status <> #AnimationTimer_Freeing)
      If (*Timer\Status = #AnimationTimer_Playing)
        NewTime = ElapsedMilliseconds()
        PrevFrame = *Timer\CurrentFrame
        ElapsedTime = *Timer\ElapsedMSWhenPaused + (NewTime - *Timer\UnpauseTime)
        While (ElapsedTime >= *Timer\TotalMS)
          *Timer\UnpauseTime + *Timer\TotalMS
          ElapsedTime - *Timer\TotalMS
          If (*Timer\LoopsLeft > 0)
            *Timer\LoopsLeft - 1
            If (*Timer\LoopsLeft = 0)
              *Timer\Status = #AnimationTimer_Paused
              *Timer\CurrentFrame = *Timer\NumFrames - 1
              *Timer\ElapsedMSWhenPaused = *Timer\TotalMS - 1
            EndIf
          EndIf
        Wend
        If (*Timer\Status = #AnimationTimer_Playing)
          Sum = 0
          For i = 0 To (*Timer\NumFrames - 1)
            Sum + *Timer\FrameMS(i)
            If (ElapsedTime < Sum)
              *Timer\CurrentFrame = i
              Break
            EndIf
          Next i
        EndIf
        If (*Timer\CurrentFrame <> PrevFrame)
          If (*Timer\Image <> #PB_Ignore)
            SetImageFrame(*Timer\Image, *Timer\CurrentFrame)
            If (*Timer\ImageGadget <> #PB_Ignore)
              SetGadgetState(*Timer\ImageGadget, ImageID(*Timer\Image))
            EndIf
            If (*Timer\CanvasGadget <> #PB_Ignore)
              SetCanvasImage(*Timer\CanvasGadget, ImageID(*Timer\Image))
            EndIf
          EndIf
          *Timer\FrameChanged = #True
          If (*Timer\Callback)
            CallFunctionFast(*Timer\Callback, *Timer)
          EndIf
          ; TODO optional PostEvent too ?
        EndIf
      EndIf
      Delay(5)
    Wend
    *Timer\Thread = #Null
  EndProcedure
  
  ;-
  ;- - Get AnimationTimer Info
  
  Procedure.i GetAnimationTimerTotalMS(*Timer.AnimationTimer)
    Protected Result.i = 0
    If (*Timer)
      Result = *Timer\TotalMS
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GetAnimationTimerElapsedMS(*Timer.AnimationTimer)
    Protected Result.i = 0
    If (*Timer)
      If (*Timer\Status = #AnimationTimer_Playing)
        Result = (*Timer\ElapsedMSWhenPaused + (ElapsedMilliseconds() - *Timer\UnpauseTime)) % *Timer\TotalMS
      Else
        Result = *Timer\ElapsedMSWhenPaused
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GetAnimationTimerFrame(*Timer.AnimationTimer)
    Protected Result.i = 0
    If (*Timer)
      Result = *Timer\CurrentFrame
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GetAnimationTimerFrameCount(*Timer.AnimationTimer)
    Protected Result.i = 0
    If (*Timer)
      Result = *Timer\NumFrames
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GetAnimationTimerStatus(*Timer.AnimationTimer)
    Protected Result.i = #AnimationTimer_Invalid
    If (*Timer)
      Result = *Timer\Status
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i AnimationTimerFramechanged(*Timer.AnimationTimer)
    Protected Result.i = #False
    If (*Timer)
      Result = *Timer\FrameChanged
      *Timer\FrameChanged = #False
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- AnimationTimer Control
  
  Procedure SetAnimationTimerCallback(*Timer.AnimationTimer, *Procedure)
    If (*Timer)
      *Timer\Callback = *Procedure
    EndIf
  EndProcedure
  
  Procedure SetAnimationTimerImageGadget(*Timer.AnimationTimer, ImageGadget.i)
    If (*Timer)
      *Timer\ImageGadget = ImageGadget
    EndIf
  EndProcedure
  
  Procedure SetAnimationTimerCanvasGadget(*Timer.AnimationTimer, CanvasGadget.i)
    If (*Timer)
      *Timer\CanvasGadget = CanvasGadget
    EndIf
  EndProcedure
  
  Procedure ResetAnimationTimer(*Timer.AnimationTimer, Stop.i = #True)
    If (*Timer)
      Select (*Timer\Status)
        Case #AnimationTimer_Playing, #AnimationTimer_Paused
          If (Stop)
            *Timer\Status = #AnimationTimer_Paused
          EndIf
          *Timer\ElapsedMSWhenPaused = 0
          *Timer\CurrentFrame = 0
      EndSelect
    EndIf
  EndProcedure
  
  Procedure PauseAnimationTimer(*Timer.AnimationTimer, Reset.i = #False)
    If (*Timer)
      Select (*Timer\Status)
        Case #AnimationTimer_Playing
          *Timer\Status = #AnimationTimer_Paused
          If (Not Reset)
            *Timer\ElapsedMSWhenPaused = (*Timer\ElapsedMSWhenPaused + (ElapsedMilliseconds() - *Timer\UnpauseTime)) % *Timer\TotalMS
          EndIf
      EndSelect
      If (Reset)
        *Timer\ElapsedMSWhenPaused = 0
        *Timer\CurrentFrame = 0
      EndIf
    EndIf
  EndProcedure
  
  Procedure UnpauseAnimationTimer(*Timer.AnimationTimer, Reset.i = #False)
    If (*Timer)
      If (Reset)
        *Timer\CurrentFrame = 0
        *Timer\ElapsedMSWhenPaused = 0
      EndIf
      Select (*Timer\Status)
        Case #AnimationTimer_Paused
          If ((*Timer\LoopsLeft = 0) And (#True))
            *Timer\LoopsLeft = #AnimationTimer_LoopForever
          EndIf
          *Timer\UnpauseTime = ElapsedMilliseconds()
          *Timer\Status = #AnimationTimer_Playing
      EndSelect
    EndIf
  EndProcedure
  
  Procedure ToggleAnimationTimerPaused(*Timer.AnimationTimer)
    If (*Timer)
      If (*Timer\Status = #AnimationTimer_Paused)
        UnpauseAnimationTimer(*Timer)
      ElseIf (*Timer\Status = #AnimationTimer_Playing)
        PauseAnimationTimer(*Timer)
      EndIf
    EndIf
  EndProcedure
  
  Procedure StartAnimationTimer(*Timer.AnimationTimer, Reset.i = #True, NumLoops.i = #AnimationTimer_LoopForever)
    If (*Timer)
      *Timer\LoopsLeft = NumLoops
      If (NumLoops = 0)
        PauseAnimationTimer(*Timer, Reset)
      Else
        UnpauseAnimationTimer(*Timer, Reset)
      EndIf
    EndIf
  EndProcedure
  
  Procedure StopAnimationTimer(*Timer.AnimationTimer, Reset.i = #True)
    PauseAnimationTimer(*Timer, Reset)
  EndProcedure
  
  Procedure WaitAnimationTimerDone(*Timer.AnimationTimer)
    If (*Timer)
      If (*Timer\Status = #AnimationTimer_Playing)
        Repeat
          Delay(5)
        Until (*Timer\Status <> #AnimationTimer_Playing)
      EndIf
    EndIf
  EndProcedure
  
  ;-
  ;- - Create/Free AnimationTimer
  
  Procedure.i FreeAnimationTimer(*Timer.AnimationTimer)
    If (*Timer)
      *Timer\Callback = #Null
      *Timer\Image = #PB_Ignore
      *Timer\ImageGadget = #PB_Ignore
      *Timer\CanvasGadget = #PB_Ignore
      *Timer\Status = #AnimationTimer_Freeing
      While (*Timer\Thread)
        Delay(1)
      Wend
      Delay(1)
      Dim *Timer\FrameMS(0)
      FreeArray(*Timer\FrameMS())
      ClearStructure(*Timer, AnimationTimer)
      FreeMemory(*Timer)
    EndIf
    ProcedureReturn (#Null)
  EndProcedure
  
  Procedure.i CreateAnimationTimer(NumFrames.i, FrameDelayMS.i = #Animation_DefaultFrameDelay)
    Protected *Timer.AnimationTimer = #Null
    If (FrameDelayMS = #PB_Default)
      FrameDelayMS = #Animation_DefaultFrameDelay
    EndIf
    If ((NumFrames > 0) And (FrameDelayMS >= 0))
      *Timer = AllocateMemory(SizeOf(AnimationTimer))
      If (*Timer)
        InitializeStructure(*Timer, AnimationTimer)
        *Timer\NumFrames = NumFrames
        *Timer\CurrentFrame = 0
        *Timer\TotalMS = NumFrames * FrameDelayMS
        *Timer\Image = #PB_Ignore
        *Timer\ImageGadget = #PB_Ignore
        *Timer\CanvasGadget = #PB_Ignore
        Dim *Timer\FrameMS(NumFrames-1)
        FillMemory(@*Timer\FrameMS(0), NumFrames * SizeOf(INTEGER), FrameDelayMS, #PB_Integer)
        If (FrameDelayMS > 0)
          *Timer\Status = #AnimationTimer_Paused
        Else
          *Timer\Status = #AnimationTimer_Invalid
        EndIf
        *Timer\Thread = CreateThread(@_AnimationTimerThread(), *Timer)
        If (*Timer\Thread)
          StopAnimationTimer(*Timer, #True)
        Else
          *Timer = FreeAnimationTimer(*Timer)
        EndIf
      EndIf
    EndIf
    ProcedureReturn (*Timer)
  EndProcedure
  
  Procedure.i CreateAnimationTimerFromImage(Image.i)
    Protected *Timer.AnimationTimer = #Null
    Protected NumFrames.i = ImageFrameCount(Image)
    If (NumFrames > 1)
      *Timer = CreateAnimationTimer(NumFrames, 0)
      *Timer\TotalMS = 0
      *Timer\Image = Image
      
      Protected PrevFrame.i = GetImageFrame(Image)
      Protected i.i
      For i = 0 To (NumFrames-1)
        SetImageFrame(Image, i)
        *Timer\FrameMS(i) = GetImageFrameDelay(Image)
        *Timer\TotalMS + *Timer\FrameMS(i)
      Next i
      SetImageFrame(Image, PrevFrame)
      
      If (*Timer\TotalMS = 0)
        For i = 0 To (NumFrames-1)
          *Timer\FrameMS(i) = #Animation_DefaultFrameDelay
        Next i
        *Timer\TotalMS = NumFrames * #Animation_DefaultFrameDelay
      EndIf
      *Timer\Status = #AnimationTimer_Paused
    ElseIf (NumFrames = 1)
      *Timer = CreateAnimationTimer(1, 0)
    EndIf
    ProcedureReturn (*Timer)
  EndProcedure
  
CompilerEndIf
;-
