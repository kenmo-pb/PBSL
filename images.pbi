; +-------------------------------------+
; | PureBasic Standard Library - Images |
; +-------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Images_Included, #PB_Constant))
  #_PBSL_Images_Included = #True
  
  ;- - Image Constants
  
  #JPEGQualityMinimum = 0
  #JPEGQualityMaximum = 10
  #JPEGQualityDefault = 7  ; as of PB 6.40
  
  ;-
  ;- - Image Macros
  
  Macro UseJPEGCodec()
    UseJPEGImageDecoder()
    UseJPEGImageEncoder()
  EndMacro
  
  Macro UsePNGCodec()
    UsePNGImageDecoder()
    UsePNGImageEncoder()
  EndMacro
  
  Macro SaveBMP(_Image, _File)
    SaveImage((_Image), _File, #PB_ImagePlugin_BMP)
  EndMacro
  
  Macro SavePNG(_Image, _File)
    SaveImage((_Image), _File, #PB_ImagePlugin_PNG)
  EndMacro
  
  Macro SaveJPEG(_Image, _File, _Quality = #JPEGQualityDefault)
    SaveImage((_Image), _File, #PB_ImagePlugin_JPEG, MapPBDefault((_Quality), #JPEGQualityDefault))
  EndMacro
  
  CompilerIf (Not #PBSL_NoGraphics)
    
    ;-
    ;- - Image Procedures
    
    Procedure.i IsImageAnimated(Image.i)
      CompilerIf (PBGTE(560))
        ProcedureReturn (Bool(ImageFrameCount(Image) > 1))
      CompilerElse
        ProcedureReturn (#False)
      CompilerEndIf
    EndProcedure
    
    Procedure.i IsImage32Bit(Image.i)
      ProcedureReturn (Bool(ImageDepth(Image) = 32))
    EndProcedure
    
    Procedure.i SaveImageByExtension(Image.i, File.s, Quality.i = #PB_Default)
      Protected Result.i = #False
      Select (LCase(GetExtensionPart(File)))
        Case "bmp"
          Result = SaveBMP(Image, File)
        Case "png"
          Result = SavePNG(Image, File)
        Case "jpg", "jpeg"
          Result = SaveJPEG(Image, File, MapPBDefault(Quality, #JPEGQualityDefault))
      EndSelect
      ProcedureReturn (Result)
    EndProcedure
    
    CompilerIf (Not #PBSL_NoGUI)
      
      Procedure ShowImage(Image.i, Desktop.i = #PrimaryDesktop)
        Protected IW.i = ImageWidth(Image)
        Protected IH.i = ImageHeight(Image)
        Protected TempImg.i = #Null
        If (#True) ; Reasonably fit to screen?
          ExamineDesktops()
          Protected WMax.i = PrimaryDesktopWidth()  * 0.60
          Protected HMax.i = PrimaryDesktopHeight() * 0.60
          Protected Scale.d = FitRect(IW, IH, WMax, HMax, #False)
          If ((Scale > 0.0) And (Scale < 1.0))
            TempImg = CopyImage(Image, #PB_Any)
            If (TempImg)
              IW = IW * Scale
              IH = IH * Scale
              ResizeImage(TempImg, IW, IH, #PB_Image_Smooth)
            EndIf
          EndIf
        EndIf
        Protected WinFlags.i = #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget | #PB_Window_Invisible
        Protected Title.s = "Image " + Str(Image)
        If (TempImg)
          Title + " (scaled down from " + Str(ImageWidth(Image)) + "x" + Str(ImageHeight(Image)) + ")"
          Image = TempImg
        Else
          Title + " (" + Str(ImageWidth(Image)) + "x" + Str(ImageHeight(Image)) + ")"
        EndIf
        Protected Win.i = OpenWindow(#PB_Any, 0, 0, IW, IH, Title, WinFlags)
        If (Win)
          Protected Gad.i = ImageGadget(#PB_Any, 0, 0, IW, IH, ImageID(Image))
          If (Gad)
            If ((Desktop > 0) And (Desktop < ExamineDesktops()))
              CenterWindowInDesktop(Win, Desktop)
            EndIf
            HideWindow(Win, #False)
            AddKeyboardShortcut(Win, #PB_Shortcut_Escape, 0)
            SetActiveGadget(Gad)
            SetActiveWindow(Win)
            Repeat
              Protected Event.i = WaitWindowEvent()
              If ((Event = #PB_Event_Menu) And (EventWindow() = Win))
                Event = #PB_Event_CloseWindow
              EndIf
            Until ((Event = #PB_Event_CloseWindow) And (EventWindow() = Win))
            FreeGadget(Gad)
          EndIf
          CloseWindow(Win)
        EndIf
        If (TempImg)
          FreeImage(TempImg)
        EndIf
      EndProcedure
      
    CompilerEndIf
    
  CompilerEndIf
  
CompilerEndIf
;-
