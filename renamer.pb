; 2017-04-14
; Felix Caffier www.trisymphony.com

; STDIO ONE EXPORT RENAMER
; changes base/number/name.ext to base/number_name.ext


Structure audiofile
  oldpath.s
  filename.s
  parentfolder.s
EndStructure


OpenConsole()
ConsoleTitle("Studio One renamer")

PrintN("Studio One Export Folder renamer - 20170414")
PrintN("changes base/number/name.ext to base/number_name.ext")
PrintN("")
PrintN("Startup parameters:")

paramsPassed.i = CountProgramParameters()

count.i = 0
While count < paramsPassed
  PrintN (Str(count) + ". " + ProgramParameter(count))
  count+1
Wend

If paramsPassed = 0
  MessageRequester("ERROR", "Not enough startup parameters.", #PB_MessageRequester_Ok)
  End
EndIf

basepath.s = RTrim(Trim(ProgramParameter(0)), "\")

If Not FileSize(basepath) = -2
  MessageRequester("ERROR", basepath + " does not appear to exist.", #PB_MessageRequester_Ok)
  End
EndIf


PrintN("")
PrintN("--------------------------------------------------------------------")
PrintN("Scanning folders:")
PrintN("")

;-- finding child directories

NewList folderlist.s()

If ExamineDirectory(0, basepath, "*.*")  
  While NextDirectoryEntry(0)
    If DirectoryEntryType(0) = #PB_DirectoryEntry_Directory
      AddElement(folderlist())
      folderlist() = DirectoryEntryName(0)
      PrintN("ADD  " + DirectoryEntryName(0))
    Else
      PrintN("SKIP " + DirectoryEntryName(0))
    EndIf
  Wend
Else
  MessageRequester("ERROR", basepath + " could not be opened.", #PB_MessageRequester_Ok)
  End
EndIf

PrintN("")
PrintN("--------------------------------------------------------------------")
PrintN("Scanning files:")
PrintN("")

;-- finding audio files

NewList filelist.audiofile()

ForEach folderlist()
  If ExamineDirectory(1, basepath + "\" + folderlist(), "*.*")  
    While NextDirectoryEntry(1)
      If DirectoryEntryType(1) = #PB_DirectoryEntry_File
        Ext.s = UCase(GetExtensionPart(DirectoryEntryName(1)))
        Select Ext
          Case "MP3", "FLAC", "WAV", "OGG", "AIFF", "CAF"
            AddElement(filelist())
            filelist()\oldpath = basepath + "\" + folderlist() + "\" + DirectoryEntryName(1)
            filelist()\filename = DirectoryEntryName(1)
            filelist()\parentfolder = Trim(ReplaceString(ReplaceString(folderlist(), "Start", ""), "End", ""))
            PrintN("AUDIOFILE  " + DirectoryEntryName(1))
            Break
          Default
            PrintN("SKIP (ext) " + DirectoryEntryName(1))
        EndSelect
      EndIf
    Wend
  Else
    MessageRequester("ERROR", basepath + "\" + folderlist() + " could not be opened.", #PB_MessageRequester_Ok)
    End
  EndIf
Next

PrintN("")
PrintN("--------------------------------------------------------------------")
PrintN("Moving and renaming files:")
PrintN("")

;-- moving files

ForEach filelist()
  target.s = basepath + "\" + filelist()\parentfolder + "-" + filelist()\filename
  RenameFile(filelist()\oldpath, target)
  PrintN("MOVED " + target)
Next


PrintN("")
PrintN("Closing in 5 seconds...")
Delay(5000)
End

; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 13
; EnableUnicode
; EnableXP
; Executable = so2renamer.exe