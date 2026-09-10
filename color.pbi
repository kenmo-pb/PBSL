; +------------------------------------+
; | PureBasic Standard Library - Color |
; +------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_Color_Included, #PB_Constant))
  #_PBSL_Color_Included = #True
  
  ;- - Color Constants
  
  #RGBMask   = $00FFFFFF
  #RGBAMask  = $FFFFFFFF
  #AlphaMask = $FF000000
  
  #OpaqueAlpha = #AlphaMask
  
  #RedOpaque     = #Red     | #OpaqueAlpha
  #GreenOpaque   = #Green   | #OpaqueAlpha
  #BlueOpaque    = #Blue    | #OpaqueAlpha
  #CyanOpaque    = #Cyan    | #OpaqueAlpha
  #MagentaOpaque = #Magenta | #OpaqueAlpha
  #YellowOpaque  = #Yellow  | #OpaqueAlpha
  #BlackOpaque   = #Black   | #OpaqueAlpha
  #WhiteOpaque   = #White   | #OpaqueAlpha
  
  Enumeration ; ColorFormats for the Compose procedures
    #ColorFormat_Integer = 0
    #ColorFormat_HexPB
    #ColorFormat_HexCSS
    #ColorFormat_RGBComponents
  EndEnumeration
  
  ;-
  ;- - Color Procedures
  
  Procedure.i SetAlpha(Color.i, Alpha.i)
    Alpha = (Alpha & $FF)
    ProcedureReturn ((Color & #RGBMask) | (Alpha << 24))
  EndProcedure
  
  Procedure.i Transparent(Color.i)
    ProcedureReturn (Color & #RGBMask)
  EndProcedure
  
  Procedure.i Opaque(Color.i)
    ProcedureReturn ((Color & #RGBMask) | #OpaqueAlpha)
  EndProcedure
  
  Procedure.i SwapRGBOrder(Color.i)
    ProcedureReturn (RGBA(Blue(Color), Green(Color), Red(Color), Alpha(Color)))
  EndProcedure
  
  Procedure.i Gray(Level.i, Alpha.i = $00)
    Level = (Level & $FF)
    Alpha = (Alpha & $FF)
    ProcedureReturn (RGBA(Level, Level, Level, Alpha))
  EndProcedure
  
  Procedure.i RandomGray(Alpha.i = $00)
    ProcedureReturn (Gray(Random($FF), Alpha))
  EndProcedure
  
  Procedure.i RandomColor(Alpha.i = $00)
    Alpha = (Alpha & $FF)
    ProcedureReturn (Random(#White) | (Alpha << 24))
  EndProcedure
  
  Procedure.i RandomBasicColor(Alpha.i = $00)
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
  
  ;-
  ;- - Color String Procedures
  
  Procedure.s ComposeRGB(RGBColor.i, ColorFormat.i = #ColorFormat_HexCSS)
    Protected Result.s = ""
    
    RGBColor = RGBColor & #RGBMask
    Select (ColorFormat)
      Case #ColorFormat_HexPB
        Result = "$" + Hex24(RGBColor)
      Case #ColorFormat_HexCSS
        Result = "#" + Hex24(SwapRGBOrder(RGBColor))
      Case #ColorFormat_RGBComponents
        Result = "RGB(" + Str(Red(RGBColor)) + ", " + Str(Green(RGBColor)) + ", " + Str(Blue(RGBColor)) + ")"
      Default ;Case #ColorFormat_Integer
        Result = StrU(RGBColor)
    EndSelect
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s ComposeRGBA(RGBAColor.i, ColorFormat.i = #ColorFormat_HexCSS)
    Protected Result.s = ""
    
    RGBAColor = RGBAColor & #RGBAMask
    Select (ColorFormat)
      Case #ColorFormat_HexPB
        Result = "$" + Hex32(RGBAColor)
      Case #ColorFormat_HexCSS
        If (#True) ; move AA to the end, after #RRGGBB
          Result = "#" + Hex24(SwapRGBOrder(RGBAColor) & #RGBMask) + Hex8(Alpha(RGBAColor))
        Else
          Result = "#" + Hex32(SwapRGBOrder(RGBAColor))
        EndIf
      Case #ColorFormat_RGBComponents
        Result = "RGBA(" + Str(Red(RGBAColor)) + ", " + Str(Green(RGBAColor)) + ", " + Str(Blue(RGBAColor)) + ", " + Str(Alpha(RGBAColor)) + ")"
      Default ;Case #ColorFormat_Integer
        Result = StrU(RGBAColor & #RGBAMask)
    EndSelect
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i ParseColor(Text.s)
    Protected Result.i = 0
    
    Text = LCase(RemoveSpaces(Text))
    Select (Text)
        
      Case ""
        Result = #Black
      Case "black"
        Result = #Black
      Case "red"
        Result = #Red
      Case "green"
        Result = #Green
      Case "blue"
        Result = #Blue
      Case "cyan"
        Result = #Cyan
      Case "yellow"
        Result = #Yellow
      Case "magenta"
        Result = #Magenta
      Case "gray"
        Result = #Gray
      Case "white"
        Result = #White
        
      Default
        
        Protected IsHex.i      = #False
        Protected SwapOrder.i  = #False
        Protected Expand3to6.i = #False
        Protected Handled.i    = #False
        
        If (Left(Text, 1) = "$")
          Text = Mid(Text, 2)
          IsHex = #True
        ElseIf (Left(Text, 2) = "0x")
          Text = Mid(Text, 3)
          IsHex = #True
        ElseIf (Left(Text, 1) = "#")
          Text = Mid(Text, 2)
          IsHex = #True
          SwapOrder = #True
          If (Len(Text) = 3)
            Expand3to6 = #True
          ElseIf (Len(Text) = 8)
            If (#True) ; assume AA is at the end, swap #RRGGBBAA --> AARRGGBB
              Text = Mid(Text, 7, 2) + Left(Text, 6)
            EndIf
          ElseIf (Len(Text) = 4)
            Expand3to6 = #True
            If (#True) ; assume A is at the end, swap #RGBA --> ARGB
              Text = Mid(Text, 4, 1) + Left(Text, 3)
            EndIf
          EndIf
        ElseIf (FindString(Text, "rgb(") Or FindString(Text, "rgba("))
          Handled = #True
          Text = After(Text, "(")
          Text = Before(Text, ")")
          Result = RGBA(Val(StringField(Text, 1, ",")), Val(StringField(Text, 2, ",")), Val(StringField(Text, 3, ",")), Val(StringField(Text, 4, ",")))
        EndIf
        
        If (Not Handled)
          If (IsHex)
            Result = Val("$" + Text)
          Else
            Result = Val(Text)
          EndIf
          If (Expand3to6)
            Result = ((Result & $F000) << 12) | ((Result & $F00) << 8) | ((Result & $0F0) << 4) | (Result & $00F)
            Result = (Result << 4) | (Result)
          EndIf
          If (SwapOrder)
            Result = SwapRGBOrder(Result)
          EndIf
        EndIf
        
    EndSelect
    
    Result = Result & $FFFFFFFF
    
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
