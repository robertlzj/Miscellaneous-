﻿#SingleInstance,Force
#NoEnv
#Include HotKey_WhenEditInSciTE.ahk
/* 20220609_1 TODO
	针对快捷方式的特殊处理
	不完善
	需获取文件名（路径）（需包含扩展名/类型），当前方式不包含扩展名。
	快捷方式路径名不包含扩展名
	当前通过文件名模式（" - 快捷方式[ (n)]"）推测是否为快捷方式，不可靠。
 */
Length:=0
Menu, Tray, Icon, EditFileName.ico
Menu, Tray, Tip, in explorer F2 to switch select section`nin editor F1 reload/F2 exit
#If WinActive("ahk_exe explorer.exe") and Rename()
F2::
	WinGetActiveTitle, OutputVar
	;	eg "C:\Users"
	BaseDirectoryPath:=OutputVar
	FileAppend Base Directory Path: %BaseDirectoryPath%`n,*
	ControlGetText, OutputVar,% fileNameEditor,A
	;	won't contain ".lnk" extension for shortcut
	FileName:=OutputVar
	FileAppend File name: %FileName%`n,*
	Path:=BaseDirectoryPath . "\" . FileName
	;	this concat can't get path of shortcut, for lack of extension.
	FileAppend Path: %Path%`n,*
	;
	;	FileGetShortcut, Path
	;	FileAppend % "is " . (ErrorLevel?"not ":"") . "a shortcut",*
	;	current path can't represent shortcut
	SplitPath, % Path,,, Extension, FileNameWithoutExt
	;	SplitPath can't handle shortcut path
	;
	;	FileNameWithoutExt:=RegExReplace(FileName,"(\.[^.]*)?$","")
	;	see `SplitPath`
	FileAppend File name without extension: %FileNameWithoutExt%`n,*
	FileAppend File extension: %Extension%`n,*
	if(Extension=="lnk" or FileName~=" - 快捷方式( \(\d\))?$"){
		;	FileGetShortcut, FileName, target
		;	;	"FileGetShortcut" based on working directory, not base directory of file selected
		;	FileAppend Target: %target%`n,*
		;	don't know directory path now
		NeedleRegEx:="P)(?<= - )快捷方式( \(\d\))?$"
		FoundPos:=RegExMatch(FileName,NeedleRegEx,Length)
		FileAppend Found Pos: %FoundPos%`, Length: %Length%`n,*
		Send {End}+{Left %Length%}
		;	select "快捷方式" in "filename.extension - 快捷方式"
	}else{
		NeedleRegEx :="P)·?[^·]+?.{" Length "," Length "}$"
		FoundPos:=RegExMatch(FileNameWithoutExt,NeedleRegEx,Length)
		FileAppend FoundPos: %FoundPos%`, Length: %Length%`n,*
		if FoundPos=1
			Send ^a
			;~ goto Abort
		else if not Length{
			TotalLength:=StrLen(FileNameWithoutExt)
			SendInput ^{Home}{Right %TotalLength%}
		}else{
			SelectionLength:=Length-1
			SendInput  ^{Home}{Right %FoundPos%}+{Right %SelectionLength%}
		}
	}
	return
#If WinActive("ahk_exe explorer.exe")
~F2::
Abort:
	FileNameWithoutExt:=Length:=TotalLength:=""
	return
Rename(){
	ControlGetFocus, OutputVar,A
	global fileNameEditor
	fileNameEditor:=OutputVar
	return ErrorLevel=0 and fileNameEditor~="^Edit\d"
	;	Edit1 may be path in address bar, then Edit2 is file name
	;		test in explorer on "C:\Users\RobertLin\Documents"
}
/* 
	#IfWinActive EditFileName.ahk  ahk_class SciTEWindow ahk_exe SciTE.exe
	F3::Reload
	F2::ExitApp
	#IfWinActive
 */