; +--------------------------------------+
; | PureBasic Standard Library - Drawing |
; +--------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Drawing_Included, #PB_Constant))
  #_PBSL_Drawing_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
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
  
  ;-
  ;- - Drawing Procedures
  
  Procedure ClearOutput(Color.i)
    DrawingMode(#PB_2DDrawing_AllChannels)
    UnclipOutput()
    Box(0, 0, OutputWidth(), OutputHeight(), Color)
  EndProcedure
  
CompilerEndIf
;-
