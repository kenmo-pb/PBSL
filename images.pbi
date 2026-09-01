; +-------------------------------------+
; | PureBasic Standard Library - Images |
; +-------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Images_Included, #PB_Constant))
  #_PBSL_Images_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- Image Constants
  
  #JPEGQualityMinimum = 0
  #JPEGQualityMaximum = 10
  #JPEGQualityDefault = 7  ; as of PB 6.40
  
  ;-
  ;- Image Macros
  
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
  
  ;-
  ;- Image Procedures
  
  Procedure.i IsImageAnimated(Image.i)
    CompilerIf (PBGTE(560))
      ProcedureReturn (Bool(ImageFrameCount(Image) > 1))
    CompilerElse
      ProcedureReturn (#False)
    CompilerEndIf
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
  
CompilerEndIf
;-
