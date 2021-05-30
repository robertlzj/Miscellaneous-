#SingleInstance,Force
#NoEnv
Length:=0
Menu, Tray, Icon, EditFileName.ico
#If WinActive("ahk_exe explorer.exe") and Rename()
F2::
	ControlGetText, OutputVar,Edit1,A
	FileName:=OutputVar
	FileAppend File name: %FileName%`n,*
	FileNameWithoutExt:=RegExReplace(FileName,"(\.[^.]*)?$","")
	TotalLength:=StrLen(FileNameWithoutExt)
	FileAppend File name without extension: %FileNameWithoutExt%`n,*
	NeedleRegEx :="P)��?[^��]+?.{" Length "," Length "}$"
	FoundPos:=RegExMatch(FileNameWithoutExt,NeedleRegEx,Length)
	FileAppend FoundPos: %FoundPos%`, Length: %Length%`n,*
	if FoundPos=1
		Send ^a
		;~ goto Abort
	else if not Length
		SendInput ^{Home}{Right %TotalLength%}
	else{
		SelectionLength:=Length-1
		SendInput  ^{Home}{Right %FoundPos%}+{Right %SelectionLength%}
	}
	return
#If WinActive("ahk_exe explorer.exe")
~F2::
Abort:
	FileNameWithoutExt:=Length:=TotalLength:=""
	return
Rename(){
	ControlGetFocus, OutputVar,A
	return ErrorLevel=0 and OutputVar="Edit1"
}
#IfWinActive EditFileName.ahk  ahk_class SciTEWindow ahk_exe SciTE.exe
F1::Reload
F2::ExitApp
#IfWinActive