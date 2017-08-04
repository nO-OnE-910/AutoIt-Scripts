#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         nO OnE 910

	Script Function:
	 Reorganizes a directory containing movie files. Works well in the
	 "send to" context menu of Windows.
	 The script contains specific optimizations for file movement, which
	 were useful in the environment it was developed in.
	 This contains replacements for MKLINK directory links, which can be
	 resolved during file movement. This can also be used to resolve virtual
	 disk mounts in Windows. When moving a file from a virtual disk mount
	 X:\, which is the folder Y:\mount_x\, files moved from X:\other\ to
	 X:\new\ will be moved a _lot_ faster when the actual path is resolved
	 beforehand.

	Date:
	 2016-08-13

#ce ----------------------------------------------------------------------------

#include <File.au3>
#include <Array.au3>

$ini_dir = @AppDataDir & "\My Scripts\Movie Arrange"
$ini = $ini_dir & "\ini.ini"

If IniRead($ini, "config", "state", "default") = "default" Then
	DirCreate($ini_dir)
	IniWrite($ini, "config", "state", "1")
	If IniRead($ini, "config", "state", "default") = "default" Then
		MsgBox(0, "", "Error")
		Exit
	EndIf
	IniWrite($ini, "config", "dir_to", InputBox("Movie Arrange", "Default target directory:", "Should end with \"))
	IniWrite($ini, "config", "replace", InputBox("Movie Arrange", "Replacements:" & @CRLF & '(See source for explanation. Separate with "::".)', 'Ex.: "X:\::Y:\mount_x\::Z:\::Y:\mount_z\"'))
EndIf

If $cmdline[0] < 1 Then
	$dir = InputBox("Rearrange Movie", "Directory (From):")
Else
	$dir = $cmdline[1]
EndIf

$file = ""

If StringLeft($dir, 1) = '"' Then $dir = StringTrimLeft($dir, 1)
If StringRight($dir, 1) = '"' Then $dir = StringTrimRight($dir, 1)
If StringRight($dir, 1) = "\" Then $dir = StringTrimRight($dir, 1)

If Not FileExists($dir) Then Exit

If Not StringInStr(FileGetAttrib($dir), "D") Then
	$file = $dir
	While StringInStr($file, "\")
		$file = StringTrimLeft($file, 1)
	WEnd
	While StringRight($dir, 1) <> "\"
		$dir = StringTrimRight($dir, 1)
	WEnd
	$dir = StringTrimRight($dir, 1)
EndIf

If $file = "" Then
	$a = _FileListToArrayMulti($dir, "*.mkv;*.mp4;*.avi;*.divx;*.xvid")
Else
	Dim $a[2] = [1, $file]
EndIf
If Not IsArray($a) Then Exit

For $i = 1 To $a[0]
	While StringInStr($a[$i], ".") And StringRight($a[$i], 1) <> "."
		$a[$i] = StringTrimRight($a[$i], 1)
	WEnd
	If StringRight($a[$i], 1) = "." Then $a[$i] = StringTrimRight($a[$i], 1)
	If $i = $a[0] Then
		$filenew = InputBox("Rearrange Movie", "Change"&@cr&$a[$i]&@cr&"to:")
	Else
		$filenew = InputBox("Rearrange Movie", "Change"&@cr&$a[$i]&@cr&"to: ('Cancel' to see next option)")
	EndIf
	If StringLen($filenew) > 1 Then
		$file = $a[$i]
		$i = $a[0] + 1
	EndIf
Next
If StringLen($filenew) <= 1 Then Exit

$a = _FileListToArrayRec($dir, "*", 1, 1, 0, 2)
For $i = 1 To $a[0]
	$tf = $a[$i]
	$td = $a[$i]
	While StringInStr($tf, "\")
		$tf = StringTrimLeft($tf, 1)
	WEnd
	While StringRight($td, 1) <> "\"
		$td = StringTrimRight($td, 1)
	WEnd
	FileMove($a[$i], $td&StringReplace($tf, $file, $filenew))
Next
$td = $dir
While StringRight($td, 1) <> "\"
	$td = StringTrimRight($td, 1)
WEnd
DirMove($dir, $td&$filenew)

;###### Section SendTo ######
; The next line calls an external program for moving the files.
; This may be useful if you have that program anyway, to add a
; different entry to "send to" for example, which does only move.
;~ RunWait(@ScriptDir & '\SendToMovies.exe "'&$td&$filenew&'"')

$send_from = $td&$filenew
$send_to = IniRead($ini, "config", "dir_to", "none")

If $send_to <> "none" Then
	$replacements = StringSplit(IniRead($ini, "config", "replace", ""), "::", 1)
	$i = 1
	While $i < UBound($replacements)
		$repl_before = $replacements[$i]
		$repl_after = $replacements[$i + 1]
		send_from = StringReplace(send_from, $repl_before, $repl_after)
		$i += 2
	WEnd

	DirMove($send_from, $send_to & _getName($send_from))
EndIf

Func _getName($s)
	If StringRight($s, 1) = '"' Then $s = StringTrimRight($s, 1)
	If StringRight($s, 1) = "\" Then $s = StringTrimRight($s, 1)
	While StringInStr($s, "\")
		$s = StringTrimLeft($s, 1)
	WEnd
	Return $s
EndFunc
;#### End Section SendTo ####

; Now we clean up empty parent directories. If this is not needed uncomment next line.
;~ Exit
Local $parent = $dir
Do
	While StringRight($parent, 1) <> "\"
		$parent = StringTrimRight($parent, 1)
	WEnd
	$parent = StringTrimRight($parent, 1)

	$a = _FileListToArrayRec($parent, "*", 0, 1)

	If Not (IsArray($a) And $a[0] > 0) Then DirRemove($parent)
	Sleep(100)
Until (IsArray($a) And $a[0] > 0)

Func _FileListToArrayMulti($pPath = @WorkingDir, $pFilter = "*", $pFlag = 0, $pFullPath = False, $pDelimiter = ";")
	$pFilter = StringSplit($pFilter, $pDelimiter)
	Local $r[1] = [0]
	For $i = 1 To $pFilter[0]
		Local $t = _FileListToArray($pPath, $pFilter[$i], $pFlag, $pFullPath)
		If IsArray($t) Then
			For $j = 1 To $t[0]
				_ArrayAdd($r, $t[$j])
			Next
		EndIf
	Next
	$r[0] = UBound($r) - 1
	If Not IsArray($r) Then Return -1
	Return $r
EndFunc

; For debugging, replace all occurrences of DirMove with _DirMove.
; This will result in a dry run.
Func _DirMove($f, $t)
	_FileMove($f, $t, "Dir")
EndFunc
; For debugging, replace all occurrences of FileMove with _FileMove.
; This will result in a dry run.
Func _FileMove($f, $t, $m = "File")
	MsgBox(0, "", 'Moving '&$m&' "'&$f&'" to "'&$t&'"')
EndFunc
