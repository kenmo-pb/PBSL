; +--------------------------------------+
; | PureBasic Standard Library - Drawing |
; +--------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Drawing_Included, #PB_Constant))
  #_PBSL_Drawing_Included = #True
  
  ;- - Drawing Macros
  
  Macro StartScreenDrawing()
    StartDrawing(ScreenOutput())
  EndMacro
  
  Macro StartPrinterDrawing()
    StartDrawing(PrinterOutput())
  EndMacro
  
  Macro StartImageDrawing(_Image)
    StartDrawing(ImageOutput(_Image))
  EndMacro
  
  Macro StartCanvasDrawing(_CanvasGadget)
    StartDrawing(CanvasOutput(_CanvasGadget))
  EndMacro
  
  CompilerIf (Not #PBSL_NoGraphics)
    
    ;-
    ;- - Drawing Procedures
    
    Procedure ClearOutput(Color.i)
      DrawingMode(#PB_2DDrawing_AllChannels)
      UnclipOutput()
      Box(0, 0, OutputWidth(), OutputHeight(), Color)
    EndProcedure
    
  CompilerEndIf
  
CompilerEndIf
;-
