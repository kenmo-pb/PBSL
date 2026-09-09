; +---------------------------------------+
; | PureBasic Standard Library - TEMPLATE |
; +---------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_TEMPLATE_Included, #PB_Constant))
  #_PBSL_TEMPLATE_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  XIncludeFile "common.pbi"
  
  ;- - OS Version Procedures  
  
  Procedure.s OSVersionString()
    Protected Result.s = ""
    
    CompilerIf (#IsWindowsBuild)
      Select (OSVersion())
        Case #PB_OS_Windows_XP
          Result = "Windows XP"
        Case #PB_OS_Windows_Vista
          Result = "Windows Vista"
        Case #PB_OS_Windows_7
          Result = "Windows 7"
          CompilerIf (Defined(PB_OS_Windows_8, #PB_Constant)) ; unclear when added
          Case #PB_OS_Windows_8
            Result = "Windows 8"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_Windows_10, #PB_Constant)) ; added in 5.40
          Case #PB_OS_Windows_8_1
            Result = "Windows 8.1"
          Case #PB_OS_Windows_10
            Result = "Windows 10"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_Windows_11, #PB_Constant)) ; added in 6.00
          Case #PB_OS_Windows_11
            Result = "Windows 11"
          CompilerEndIf
          
        Case #PB_OS_Windows_Server_2003, #PB_OS_Windows_Server_2008, #PB_OS_Windows_Server_2008_R2
          Result = "Windows Server"
          CompilerIf (Defined(PB_OS_Windows_Server_2012_R2, #PB_Constant)) ; unclear when added
          Case #PB_OS_Windows_Server_2012, #PB_OS_Windows_Server_2012_R2
            Result = "Windows Server"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_Windows_Server_2025, #PB_Constant)) ; added in 6.21
          Case #PB_OS_Windows_Server_2016, #PB_OS_Windows_Server_2019, #PB_OS_Windows_Server_2022, #PB_OS_Windows_Server_2025
            Result = "Windows Server"
          CompilerEndIf
          
        Default
          If (OSVersion() < #PB_OS_Windows_XP)
            Result = "Windows (prior to XP)"
          Else
            Result = "Windows"
          EndIf
      EndSelect
      
    CompilerElseIf (#IsMacBuild)
      Select (OSVersion())
        Case #PB_OS_MacOSX_10_5
          Result = "Mac OS X 10.5 (Leopard)"
        Case #PB_OS_MacOSX_10_6
          Result = "Mac OS X 10.6 (Snow Leopard)"
          CompilerIf (Defined(PB_OS_MacOSX_10_7, #PB_Constant)) ; unclear when added
          Case #PB_OS_MacOSX_10_7
            Result = "Mac OS X 10.7 (Lion)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_10_8, #PB_Constant)) ; unclear when added
          Case #PB_OS_MacOSX_10_8
            Result = "OS X 10.8 (Mountain Lion)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_10_11, #PB_Constant)) ; added in 5.40
          Case #PB_OS_MacOSX_10_9
            Result = "OS X 10.9 (Mavericks)"
          Case #PB_OS_MacOSX_10_10
            Result = "OS X 10.10 (Yosemite)"
          Case #PB_OS_MacOSX_10_11
            Result = "OS X 10.11 (El Capitan)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_10_12, #PB_Constant)) ; unclear when added
          Case #PB_OS_MacOSX_10_12
            Result = "macOS 10.12 (Sierra)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_10_13, #PB_Constant)) ; unclear when added
          Case #PB_OS_MacOSX_10_13
            Result = "macOS 10.13 (High Sierra)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_10_14, #PB_Constant)) ; unclear when added
          Case #PB_OS_MacOSX_10_14
            Result = "macOS 10.14 (Mojave)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_10_15, #PB_Constant)) ; unclear when added
          Case #PB_OS_MacOSX_10_15
            Result = "macOS 10.15 (Catalina)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_12, #PB_Constant)) ; added in 6.00
          Case #PB_OS_MacOSX_11
            Result = "macOS 11 (Big Sur)"
          Case #PB_OS_MacOSX_12
            Result = "macOS 12 (Monterey)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_15, #PB_Constant)) ; added in 6.12
          Case #PB_OS_MacOSX_13
            Result = "macOS 13 (Ventura)"
          Case #PB_OS_MacOSX_14
            Result = "macOS 14 (Sonoma)"
          Case #PB_OS_MacOSX_15
            Result = "macOS 15 (Sequoia)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_26, #PB_Constant))
          Case #PB_OS_MacOSX_26
            Result = "macOS 26 (Tahoe)"
          CompilerEndIf
          CompilerIf (Defined(PB_OS_MacOSX_27, #PB_Constant))
          Case #PB_OS_MacOSX_27
            Result = "macOS 27 (Golden Gate)"
          CompilerEndIf
        Default
          If (OSVersion() < #PB_OS_MacOSX_10_5)
            Result = "Mac OS X"
          Else
            Result = "macOS"
          EndIf
      EndSelect
      
    CompilerElseIf (#IsLinuxBuild)
      Select (OSVersion())
        Case #PB_OS_Linux_2_2
          Result = "Linux 2.2"
        Case #PB_OS_Linux_2_4
          Result = "Linux 2.4"
        Case #PB_OS_Linux_2_6
          Result = "Linux 2.6"
        Default
          Result = "Linux"
      EndSelect
      
    CompilerEndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
