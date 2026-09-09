; +---------------------------------------------+
; | PureBasic Standard Library - Vector Drawing |
; +---------------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_VectorDrawing_Included, #PB_Constant))
  #_PBSL_VectorDrawing_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Vector Drawing Macros
  
  Macro StartPrinterVectorDrawing(_Unit = #PB_Unit_Point)
    StartVectorDrawing(PrinterVectorOutput(_Unit))
  EndMacro
  
  Macro StartImageVectorDrawing(_Image, _Unit = #PB_Unit_Pixel)
    StartVectorDrawing(ImageVectorOutput((_Image), (_Unit)))
  EndMacro
  
  Macro StartCanvasVectorDrawing(_CanvasGadget, _Unit = #PB_Unit_Pixel)
    StartVectorDrawing(CanvasVectorOutput((_CanvasGadget), (_Unit)))
  EndMacro
  
  Macro StartPDFVectorDrawing(_File, _Width, _Height, _Unit = #PB_Unit_Point)
    StartVectorDrawing(PdfVectorOutput(_File, (_Width), (_Height), (_Unit)))
  EndMacro
  
  ;-
  ;- - Vector Drawing Procedures
  
  Procedure ClearVectorOutput(RGBA.i)
    VectorSourceColor(RGBA)
    FillVectorOutput()
  EndProcedure
  
  Procedure AddPathPartialCircle(x.d, y.d, Radius.d, StartDegreesCW.d, EndDegreesCW.d)
    StartDegreesCW - 90.0
    EndDegreesCW   - 90.0
    MovePathCursor(x, y)
    AddPathCircle(x, y, Radius, StartDegreesCW, EndDegreesCW, #PB_Path_Connected)
    ClosePath()
  EndProcedure
  
  Procedure AddPathRoundBox(x.d, y.d, Width.d, Height.d, Radius.d)
    If (Radius > 0.0)
      If (Radius > 0.5 * Width)
        Radius = 0.5 * Width
      EndIf
      If (Radius > 0.5 * Height)
        Radius = 0.5 * Height
      EndIf
      MovePathCursor(x + Radius, y)
      AddPathArc(x + Width, y, x + Width, y + Height, Radius)
      AddPathArc(x + Width, y + Height, x, y + Height, Radius)
      AddPathArc(x, y + Height, x, y, Radius)
      AddPathArc(x, y, x + Width, y, Radius)
      ClosePath()
    Else
      AddPathBox(x, y, Width, Height)
    EndIf
  EndProcedure
  
  Procedure FillVectorPartialCircle(x.d, y.d, Radius.d, StartDegreesCW.d, EndDegreesCW.d, RGBA.q = #PB_Ignore)
    SaveVectorState()
    AddPathPartialCircle(x, y, Radius, StartDegreesCW, EndDegreesCW)
    If (RGBA <> #PB_Ignore)
      VectorSourceColor(RGBA & $FFFFFFFF)
    EndIf
    FillPath()
    RestoreVectorState()
  EndProcedure
  
  Procedure StrokeVectorPartialCircle(x.d, y.d, Radius.d, StartDegreesCW.d, EndDegreesCW.d, StrokeWidth.d, RGBA.q = #PB_Ignore)
    SaveVectorState()
    AddPathPartialCircle(x, y, Radius, StartDegreesCW, EndDegreesCW)
    If (RGBA <> #PB_Ignore)
      VectorSourceColor(RGBA & $FFFFFFFF)
    EndIf
    StrokePath(StrokeWidth)
    RestoreVectorState()
  EndProcedure
  
  Procedure FillVectorRoundBox(x.d, y.d, Width.d, Height.d, Radius.d, RGBA.q = #PB_Ignore)
    SaveVectorState()
    AddPathRoundBox(x, y, Width, Height, Radius)
    If (RGBA <> #PB_Ignore)
      VectorSourceColor(RGBA & $FFFFFFFF)
    EndIf
    FillPath()
    RestoreVectorState()
  EndProcedure
  
  Procedure StrokeVectorRoundBox(x.d, y.d, Width.d, Height.d, Radius.d, StrokeWidth.d, RGBA.q = #PB_Ignore)
    SaveVectorState()
    AddPathRoundBox(x, y, Width, Height, Radius)
    If (RGBA <> #PB_Ignore)
      VectorSourceColor(RGBA & $FFFFFFFF)
    EndIf
    StrokePath(StrokeWidth)
    RestoreVectorState()
  EndProcedure
  
CompilerEndIf
;-
