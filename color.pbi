; +------------------------------------+
; | PureBasic Standard Library - Color |
; +------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Color_Included, #PB_Constant))
  #_PBSL_Color_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - Color Constants
  
  #RGBMask   = $00FFFFFF
  #AlphaMask = $FF000000
  
  #RedOpaque     = #Red     | #AlphaMask
  #GreenOpaque   = #Green   | #AlphaMask
  #BlueOpaque    = #Blue    | #AlphaMask
  #CyanOpaque    = #Cyan    | #AlphaMask
  #MagentaOpaque = #Magenta | #AlphaMask
  #YellowOpaque  = #Yellow  | #AlphaMask
  #BlackOpaque   = #Black   | #AlphaMask
  #WhiteOpaque   = #White   | #AlphaMask
  
  ;-
  ;- Color Procedures
  
  Procedure.i SetAlpha(Color.i, Alpha.i)
    Alpha = (Alpha & $FF)
    ProcedureReturn ((Color & #RGBMask) | (Alpha << 24))
  EndProcedure
  
  Procedure.i Transparent(Color.i)
    ProcedureReturn (Color & #RGBMask)
  EndProcedure
  
  Procedure.i Opaque(Color.i)
    ProcedureReturn ((Color & #RGBMask) | #AlphaMask)
  EndProcedure
  
  Procedure.i SwapRGBOrder(Color.i)
    ProcedureReturn (RGBA(Blue(Color), Green(Color), Red(Color), Alpha(Color)))
  EndProcedure
  
  Procedure.i Gray(Level.i, Alpha.i = 0)
    Level = (Level & $FF)
    Alpha = (Alpha & $FF)
    ProcedureReturn (RGBA(Level, Level, Level, Alpha))
  EndProcedure
  
  Procedure.i RandomGray(Alpha.i = 0)
    ProcedureReturn (Gray(Random($FF), Alpha))
  EndProcedure
  
  Procedure.i RandomColor(Alpha.i = 0)
    Alpha = (Alpha & $FF)
    ProcedureReturn (Random(#White) | (Alpha << 24))
  EndProcedure
  
  Procedure.i RandomBasicColor(Alpha.i = 0)
    Alpha = (Alpha & $FF)
    ProcedureReturn (RGBA(Random(1) * $FF, Random(1) * $FF, Random(1) * $FF, Alpha))
  EndProcedure
  
  Procedure.i IsColorLight(Color.i)
    ; https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/ui/apply-windows-themes
    ProcedureReturn (Bool((2 * Red(Color)) + (5 * Green(Color)) + (1 * Blue(Color)) > (8 * 128)))
  EndProcedure
  
  Procedure.i IsColorDark(Color.i)
    ProcedureReturn (Bool(Not IsColorLight(Color)))
  EndProcedure
  
  Procedure.i ComplementaryTextColor(BackgroundColor.i, LightTextColor.i = #White, DarkTextColor.i = #Black)
    If (IsColorLight(BackgroundColor))
      ProcedureReturn (DarkTextColor)
    EndIf
    ProcedureReturn (LightTextColor)
  EndProcedure
  
CompilerEndIf
;-
