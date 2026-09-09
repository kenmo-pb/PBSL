; +--------------------------------------+
; | PureBasic Standard Library - Network |
; +--------------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Network_Included, #PB_Constant))
  #_PBSL_Network_Included = #True
  
  CompilerIf (#PB_Compiler_IsMainFile)
    EnableExplicit
  CompilerEndIf
  
  ;XIncludeFile "common.pbi"
  XIncludeFile "date-time.pbi"
  
  ;- - Network Constants
  
  #DefaultUserAgent$ = "Mozilla/5.0 Gecko/41.0 Firefox/41.0" ; as of PB 6.40
  
  ;-
  ;- - Network Procedures
  
  CompilerIf (Not Defined(GetHTTPHeader, #PB_Function))
    CompilerIf (Not Defined(GetHTTPHeader, #PB_Procedure))
      Procedure.s GetHTTPHeader(URL.s, Flags.i = #Null, UserAgent.s = "")
        Protected Result.s = ""
        
        NewMap Headers.s()
        Headers("User-Agent") = MapEmptyString(UserAgent, #DefaultUserAgent$)
        
        Protected *Request = HTTPRequest(#PB_HTTP_Get, URL, #Null$, Flags | #PB_HTTP_HeadersOnly, Headers())
        If (*Request)
          Result = HTTPInfo(*Request, #PB_HTTP_Headers)
          FinishHTTP(*Request)
        EndIf
        ProcedureReturn (Result)
      EndProcedure
    CompilerEndIf
  CompilerEndIf
  
  Procedure.s ExtractHTTPHeader(RawHeaders.s, HeaderName.s)
    Protected Result.s = ""
    HeaderName = Trim(HeaderName)
    If (RawHeaders And HeaderName)
      ReplaceStringInPlace(RawHeaders, #CR$, #LF$)
      HeaderName = #LF$ + HeaderName + ":"
      Protected HeaderLen.i = Len(HeaderName)
      Protected i.i = FindStringNoCase(RawHeaders, HeaderName)
      If (i > 0)
        Protected j.i = FindString(RawHeaders, #LF$, i + HeaderLen)
        If (j > 0)
          Result = Mid(RawHeaders, i + HeaderLen, j - i - HeaderLen)
          Result = Trim(Result)
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i GetHTTPContentLength(URL.s, Flags.i = #Null, UserAgent.s = "")
    Protected Result.i = -1
    Protected Text.s = ExtractHTTPHeader(GetHTTPHeader(URL, Flags, UserAgent), "Content-Length")
    If (Text)
      Result = Val(Text)
      If (Result < -1)
        Result = -1
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s ReceiveHTTPString(URL.s, Flags.i = #Null, UserAgent.s = "") ; assumes UTF-8 response!
    Protected Result.s = ""
    
    If (UserAgent = "")
      UserAgent = #DefaultUserAgent$
    EndIf
    
    Flags = Flags & (~#PB_HTTP_Asynchronous) ; (don't allow here)
    Protected *Buffer = ReceiveHTTPMemory(URL, Flags, UserAgent)
    If (*Buffer)
      Result = PeekS(*Buffer, MemorySize(*Buffer), #PB_UTF8 | #PB_ByteLength)
      FreeMemory(*Buffer)
    EndIf
    
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i InitNetworkTimeout(TimeoutMS.i)
    CompilerIf (PBGTE(600))
      ProcedureReturn (#True)
    CompilerElse
      Protected Result.i = InitNetwork()
      If (Not Result)
        If (TimeoutMS > 0)
          Protected DelayMS.i = 1000
          If (TimeoutMS < 1500)
            TimeoutMS = 100
          EndIf
          Protected EndTime.q = ElapsedMilliseconds() + TimeoutMS
          While ((Not Result) And (ElapsedMilliseconds() < EndTime))
            Delay(DelayMS)
            Result = InitNetwork()
          Wend
        EndIf
      EndIf
      ProcedureReturn (Result)
    CompilerEndIf
  EndProcedure
  
  Procedure.i InitNetworkVerify(TimeoutMS.i, VerifyURL.s = "http://captive.apple.com", VerifyStringToFind.s = "Success")
    Protected Result.i = #False
    If ((TimeoutMS >= 0) And (VerifyURL) And (VerifyStringToFind))
      Protected EndTime.q = ElapsedMilliseconds() + TimeoutMS
      If (InitNetworkTimeout(TimeoutMS))
        Protected DelayMS.i = 5 * 1000
        If (TimeoutMS < 5 * 1000)
          TimeoutMS = 500
        EndIf
        While ((Not Result) And (ElapsedMilliseconds() < EndTime))
          Protected Text.s = ReceiveHTTPString(VerifyURL)
          If (Text And FindString(Text, VerifyStringToFind))
            Result = #True
          Else
            Delay(DelayMS)
          EndIf
        Wend
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s GetLocalIPAddress(Format.i = #PB_Network_IPv4)
    Protected Result.s = ""
    If (InitNetwork())
      Protected IP.i, ThisIPString.s, LocalIPString.s
      If (ExamineIPAddresses(Format))
        IP = NextIPAddress()
        While (IP)
          ThisIPString = IPString(IP, Format)
          If (Format = #PB_Network_IPv6)
            FreeIP(IP)
            LocalIPString = #LocalIPv6
          Else
            LocalIPString = #LocalIPv4
          EndIf
          If (ThisIPString)
            Result = ThisIPString
            If (ThisIPString <> LocalIPString)
              Break
            EndIf
          EndIf
          IP = NextIPAddress()
        Wend
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
