; +----------------------------------+
; | PureBasic Standard Library - FTP |
; +----------------------------------+

;-
CompilerIf (Not Defined(_PBSL_Common_Included, #PB_Constant))
  XIncludeFile "common.pbi"
CompilerEndIf
CompilerIf (Not Defined(_PBSL_FTP_Included, #PB_Constant))
  #_PBSL_FTP_Included = #True
  
  ;- - FTP Constants
  
  #DefaultFTPPort  = 21
  #DefaultSFTPPort = 22
  
  #PB_FTP_Passive = 0;1
  #PB_FTP_Debug   = 2
  #PB_FTP_Active  = 4
  
  ;-
  ;- - FTP Procedures
  
  Procedure.s EnsureAbsoluteFTPPath(Path.s, RootDir.s = "", FTP.i = #PB_Ignore)
    Protected Result.s = ""
    If (PeekC(@Path) <> '/')
      If (RootDir = "")
        If (FTP <> #PB_Ignore)
          RootDir = GetFTPDirectory(FTP)
        Else
          RootDir = "/"
        EndIf
      EndIf
      If (PeekC(@RootDir) <> '/')
        RootDir = "/" + RootDir
      EndIf
      Result = EnsureForwardSlash(RootDir) + Path
    Else
      Result = Path
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i SetFTPDirectoryEx(FTP.i, Directory.s, Create.i = #False)
    Protected Result.i = #False
    If (Directory)
      Directory = EnsureForwardSlash(EnsureAbsoluteFTPPath(Directory, "", FTP))
      If (#True)
        Directory = NormalizePathSeparators(NormalizePath(Directory), "/")
      EndIf
      Protected Current.s = GetFTPDirectory(FTP)
      While (Not StartsWith(Directory, Current))
        If (Not SetFTPDirectory(FTP, ".."))
          Break
        EndIf
        Current = GetFTPDirectory(FTP)
      Wend
      If (StartsWith(Directory, Current))
        While (#True)
          If (Current = Directory)
            Result = #True
            Break
          Else
            Protected Sub.s = Before(Mid(Directory, 1 + Len(Current)), "/")
            If (Sub = "")
              Break
            ElseIf (Not SetFTPDirectory(FTP, Sub))
              If (Create)
                If (Not CreateFTPDirectory(FTP, Sub))
                  Break
                EndIf
              Else
                Break
              EndIf
            EndIf
            Current = GetFTPDirectory(FTP)
          EndIf
        Wend
      EndIf
    Else
      Result = #True ; treat "" as current directory, success
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i UploadFTPFile(FTP.i, LocalFile.s, RemoteFile.s = "", CreateRemoteDir.i = #False)
    Protected Result.i = #False
    If (LocalFile And FileExists(LocalFile))
      ; TODO: Automatically detect 'RemoteFile' is a directory, and append a '/' ?
      Protected RemoteFolder.s = GetPathPart(RemoteFile)
      If (RemoteFolder)
        RemoteFolder = EnsureForwardSlash(EnsureAbsoluteFTPPath(RemoteFolder, "", FTP))
      EndIf
      RemoteFile = GetFilePart(RemoteFile)
      If (RemoteFile = "")
        RemoteFile = GetFilePart(LocalFile)
      EndIf
      If (SetFTPDirectoryEx(FTP, RemoteFolder, CreateRemoteDir))
        If (SendFTPFile(FTP, LocalFile, RemoteFile))
          Result = #True
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i DownloadFTPFile(FTP.i, RemoteFile.s, LocalFile.s = "", CreateLocalDir.i = #False)
    Protected Result.i = #False
    If (RemoteFile And (Not EndsWith(RemoteFile, "/")))
      RemoteFile = EnsureAbsoluteFTPPath(RemoteFile, "", FTP)
      Protected RemoteFolder.s = GetPathPart(RemoteFile)
      RemoteFile = GetFilePart(RemoteFile)
      If (SetFTPDirectoryEx(FTP, RemoteFolder, #False))
        If (LocalFile = "")
          LocalFile = RemoteFile
          LocalFile = NormalizePath(EnsureAbsolutePath(LocalFile))
        Else
          LocalFile = NormalizePath(EnsureAbsolutePath(LocalFile))
          If (FolderExists(LocalFile))
            LocalFile = EnsurePathSeparator(LocalFile) + RemoteFile
          Else
            If (EndsWith(LocalFile, "/") Or ((#IsWindowsBuild) And EndsWith(LocalFile, "\")))
              LocalFile + RemoteFile
            EndIf
          EndIf
        EndIf
        Protected LocalFolder.s = GetPathPart(LocalFile)
        If (FolderExists(LocalFolder) Or ((CreateLocalDir) And (CreateDirectoryRecursive(LocalFolder))))
          If (ReceiveFTPFile(FTP, RemoteFile, LocalFile))
            Result = #True
          EndIf
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.s FTPDirectoryContents(FTP.i, Directory.s = "")
    Protected Result.s = ""
    If ((Directory = "") Or (SetFTPDirectoryEx(FTP, Directory)))
      If (ExamineFTPDirectory(FTP))
        While (NextFTPDirectoryEntry(FTP))
          If ((FTPDirectoryEntryName(FTP) <> #CurrentDirectory$) And (FTPDirectoryEntryName(FTP) <> #ParentDirectory$))
            If (Result)
              Result + #LF$
            EndIf
            Result + FTPDirectoryEntryName(FTP)
            If (FTPDirectoryEntryType(0) = #PB_FTP_Directory)
              Result + "/"
            EndIf
          EndIf
        Wend
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
  Procedure.i OpenFTPEx(FTP.i, Server.s, User.s = "", Password.s = "", Flags.i = #PB_Default, Port.i = #PB_Default, InitialDirectory.s = "")
    Protected Result.i = #Null
    If (Server)
      Flags = MapPBDefault(Flags, #PB_FTP_Passive)
      If (Port = #PB_Default)
        If (LCase(Before(Server, "://")) = "sftp")
          Port = #DefaultSFTPPort
        Else
          Port = #DefaultFTPPort
        EndIf
      Else
        CompilerIf (#SFTPSupport)
          If ((Port = #DefaultSFTPPort) And (Not FindString(Server, "://")))
            Server = "sftp://" + Server
          EndIf
        CompilerEndIf
      EndIf
      CompilerIf (PBLT(630)) ; 'Flags' was formerly a 'Passive' bool parameter
        If (Flags & #PB_FTP_Active)
          Flags = #False
        Else
          Flags = #True
        EndIf
      CompilerEndIf
      Result = OpenFTP(FTP, Server, User, Password, Flags, Port)
      If (Result)
        If (InitialDirectory <> "")
          SetFTPDirectoryEx(FTP, InitialDirectory)
        EndIf
      EndIf
    EndIf
    ProcedureReturn (Result)
  EndProcedure
  
CompilerEndIf
;-
