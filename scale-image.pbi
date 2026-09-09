; +------------------------------------------+
; | PureBasic Standard Library - Scale Image |
; +------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_ScaleImage_Included, #PB_Constant))
  #_PBSL_ScaleImage_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - ScaleImage Constants  
  
  #ScaleImage_Preserve = -1 ; for Width or Height param
  
  #ScaleImage_Overwrite = #PB_Ignore ; for DestinationImage param
  #ScaleImage_New       = #PB_Any    ; for DestinationImage param
  
  Enumeration
    #ScaleImage_Stretch     = $0001
    #ScaleImage_Fill        = $0002
    #ScaleImage_Tile        = $0004
    #ScaleImage_Align       = $0008
    #ScaleImage_Fit         = $0010
    #ScaleImage_FitAndCrop  = $0020
    #ScaleImage_FitIfLarger = $0040
    
    #ScaleImage_Left    = $00010000
    #ScaleImage_CenterX = $00020000
    #ScaleImage_Right   = $00040000
    #ScaleImage_Top     = $00100000
    #ScaleImage_CenterY = $00200000
    #ScaleImage_Bottom  = $00400000
    
    #ScaleImage_Raw     = $01000000
    #ScaleImage_Smooth  = $02000000
    
    
    #ScaleImage_TopLeft     = #ScaleImage_Top     | #ScaleImage_Left
    #ScaleImage_TopRight    = #ScaleImage_Top     | #ScaleImage_Right
    #ScaleImage_BottomLeft  = #ScaleImage_Bottom  | #ScaleImage_Left
    #ScaleImage_BottomRight = #ScaleImage_Bottom  | #ScaleImage_Right
    #ScaleImage_Center      = #ScaleImage_CenterX | #ScaleImage_CenterY
  EndEnumeration
  
  #ScaleImage_DefaultFlags = #ScaleImage_Fill
  
  ;-
  ;- - ScaleImage Procedure
  
  Procedure.i ScaleImage(Image.i, Width.i, Height.i, Flags.i = #ScaleImage_DefaultFlags, DestinationImage.i = #ScaleImage_Overwrite, BackgroundColor.i = #White)
    Protected Result.i = #Null
    
    If (IsImage(Image))
      Protected SourceW.i = ImageWidth(Image)
      Protected SourceH.i = ImageHeight(Image)
      Protected Is32Bit.i = Bool(ImageDepth(Image) = 32)
      If ((Width > 0) And (Height < 0))
        Height = SourceH * Width / SourceW
      ElseIf ((Width < 0) And (Height > 0))
        Width = SourceW * Height / SourceH
      EndIf
      If ((Width > 0) And (Height > 0))
        If (Flags = #PB_Default)
          Flags = #ScaleImage_DefaultFlags
        EndIf
        
        Protected DestW.i, DestH.i
        Protected DrawW.i, DrawH.i
        Protected DrawXOffset.i = 0
        Protected DrawYOffset.i = 0
        Protected MinGridX.i = 0
        Protected MaxGridX.i = 0
        Protected MinGridY.i = 0
        Protected MaxGridY.i = 0
        
        Protected RangeX.i, RangeY.i
        Protected AlignX.d, AlignY.d
        If (Flags & #ScaleImage_Left)
          AlignX = 0.0
        ElseIf (Flags & #ScaleImage_Right)
          AlignX = 1.0
        Else;ElseIf (Flags & #ScaleImage_CenterX)
          AlignX = 0.5
        EndIf
        If (Flags & #ScaleImage_Top)
          AlignY = 0.0
        ElseIf (Flags & #ScaleImage_Bottom)
          AlignY = 1.0
        Else;ElseIf (Flags & #ScaleImage_CenterY)
          AlignY = 0.5
        EndIf
        
        Protected Scale.d, yScale.d
        If ((Flags & #ScaleImage_Fit) Or (Flags & #ScaleImage_FitAndCrop) Or (Flags & #ScaleImage_FitIfLarger) Or (Flags & #ScaleImage_Fill))
          Scale  = 1.0 * Width  / SourceW
          yScale = 1.0 * Height / SourceH
          If (Flags & #ScaleImage_Fill)
            If (yScale > Scale)
              Scale = yScale
            EndIf
          Else
            If (yScale < Scale)
              Scale = yScale
            EndIf
          EndIf
          If (Flags & #ScaleImage_FitIfLarger)
            If (Scale > 1.0)
              Scale = 1.0
            EndIf
          EndIf
          DrawW = SourceW * Scale
          DrawH = SourceH * Scale
          If (Flags & #ScaleImage_FitAndCrop)
            DestW = DrawW
            DestH = DrawH
          Else
            DestW = Width
            DestH = Height
          EndIf
          
          RangeX = DestW - DrawW
          DrawXOffset = RangeX * AlignX
          RangeY = DestH - DrawH
          DrawYOffset = RangeY * AlignY
        ElseIf (Flags & #ScaleImage_Tile)
          DestW = Width
          DestH = Height
          DrawW = SourceW
          DrawH = SourceH
          
          RangeX = DestW - DrawW
          DrawXOffset = RangeX * AlignX
          RangeY = DestH - DrawH
          DrawYOffset = RangeY * AlignY
          
          While ((DrawXOffset + MinGridX * DrawW) > 0)
            MinGridX - 1
          Wend
          While ((DrawXOffset + (MaxGridX+1) * DrawW) < DestW)
            MaxGridX + 1
          Wend
          While ((DrawYOffset + MinGridY * DrawH) > 0)
            MinGridY - 1
          Wend
          While ((DrawYOffset + (MaxGridY+1) * DrawH) < DestH)
            MaxGridY + 1
          Wend
        ElseIf (Flags & #ScaleImage_Align)
          DestW = Width
          DestH = Height
          DrawW = SourceW
          DrawH = SourceH
          
          RangeX = DestW - DrawW
          DrawXOffset = RangeX * AlignX
          RangeY = DestH - DrawH
          DrawYOffset = RangeY * AlignY
        Else;ElseIf (Flags & #ScaleImage_Stretch)
          DestW = Width
          DestH = Height
          DrawW = Width
          DrawH = Height
        EndIf
        
        Protected TempCopy.i = #Null
        Protected SuccessResult.i = #Null
        If (DestinationImage = #PB_Ignore)
          SuccessResult = ImageID(Image)
          TempCopy = CopyImage(Image, #PB_Any)
          If (TempCopy)
            If (ResizeImage(Image, DestW, DestH, #PB_Image_Raw))
              DestinationImage = Image
              Image = TempCopy
            EndIf
          EndIf
        ElseIf (DestinationImage = #PB_Any)
          SuccessResult = CreateImage(#PB_Any, DestW, DestH, ImageDepth(Image))
          If (SuccessResult)
            DestinationImage = SuccessResult
          Else
            DestinationImage = #PB_Ignore
          EndIf
        Else
          SuccessResult = CreateImage(DestinationImage, DestW, DestH, ImageDepth(Image))
          If (SuccessResult)
            ; OK
          Else
            DestinationImage = #PB_Ignore
          EndIf
        EndIf
        
        If (DestinationImage <> #PB_Ignore)
          If (Flags & #ScaleImage_Raw)
            If (Not TempCopy)
              TempCopy = CopyImage(Image, #PB_Any)
              If (TempCopy)
                Image = TempCopy
              Else
                DestinationImage = #PB_Ignore
              EndIf
            EndIf
            If (TempCopy)
              ResizeImage(TempCopy, DrawW, DrawH, #PB_Image_Raw)
            EndIf
          EndIf
        EndIf
        
        If (DestinationImage <> #PB_Ignore)
          If (StartDrawing(ImageOutput(DestinationImage)))
            DrawingMode(#PB_2DDrawing_AllChannels)
            Box(0, 0, OutputWidth(), OutputHeight(), BackgroundColor)
            If (Is32Bit And (#True))
              DrawingMode(#PB_2DDrawing_AlphaBlend)
            EndIf
            
            Protected dx.i, dy.i
            Protected gx.i, gy.i
            For gy = MinGridY To MaxGridY
              For gx = MinGridX To MaxGridX
                dx = DrawXOffset + (gx * DrawW)
                dy = DrawYOffset + (gy * DrawH)
                DrawImage(ImageID(Image), dx, dy, DrawW, DrawH)
              Next gx
            Next gy
            
            StopDrawing()
            Result = SuccessResult
          EndIf
        EndIf
        
        If (TempCopy)
          FreeImage(TempCopy)
        EndIf
      EndIf
    EndIf
    
    ProcedureReturn (Result)
  EndProcedure
  
  ;-
  ;- ScaleImage Helper Procedures
  
  Procedure AlignImage(Image.i, Width.i, Height.i, AlignmentFlags.i = #ScaleImage_TopLeft, DestinationImage.i = #ScaleImage_Overwrite, BackgroundColor.i = #White)
    ProcedureReturn (ScaleImage(Image, Width, Height, #ScaleImage_Align | AlignmentFlags, DestinationImage, BackgroundColor))
  EndProcedure
  
  Procedure CenterImage(Image.i, Width.i, Height.i, DestinationImage.i = #ScaleImage_Overwrite, BackgroundColor.i = #White)
    ProcedureReturn (ScaleImage(Image, Width, Height, #ScaleImage_Align | #ScaleImage_Center, DestinationImage, BackgroundColor))
  EndProcedure
  
  Procedure FillImage(Image.i, Width.i, Height.i, DestinationImage.i = #ScaleImage_Overwrite, BackgroundColor.i = #White)
    ProcedureReturn (ScaleImage(Image, Width, Height, #ScaleImage_Fill, DestinationImage, BackgroundColor))
  EndProcedure
  
  Procedure FitImage(Image.i, Width.i, Height.i, DestinationImage.i = #ScaleImage_Overwrite, BackgroundColor.i = #White)
    ProcedureReturn (ScaleImage(Image, Width, Height, #ScaleImage_Fit, DestinationImage, BackgroundColor))
  EndProcedure
  
  Procedure FitAndCropImage(Image.i, Width.i, Height.i, DestinationImage.i = #ScaleImage_Overwrite, BackgroundColor.i = #White)
    ProcedureReturn (ScaleImage(Image, Width, Height, #ScaleImage_FitAndCrop, DestinationImage, BackgroundColor))
  EndProcedure
  
  Procedure FitIfLargerImage(Image.i, Width.i, Height.i, DestinationImage.i = #ScaleImage_Overwrite, BackgroundColor.i = #White)
    ProcedureReturn (ScaleImage(Image, Width, Height, #ScaleImage_FitIfLarger, DestinationImage, BackgroundColor))
  EndProcedure
  
  Procedure StretchImage(Image.i, Width.i, Height.i, DestinationImage.i = #ScaleImage_Overwrite, BackgroundColor.i = #White)
    ProcedureReturn (ScaleImage(Image, Width, Height, #ScaleImage_Stretch, DestinationImage, BackgroundColor))
  EndProcedure
  
  Procedure TileImage(Image.i, Width.i, Height.i, DestinationImage.i = #ScaleImage_Overwrite, BackgroundColor.i = #White)
    ProcedureReturn (ScaleImage(Image, Width, Height, #ScaleImage_Tile, DestinationImage, BackgroundColor))
  EndProcedure
  
CompilerEndIf
;-
