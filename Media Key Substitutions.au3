#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         nO OnE 910

	Script Function:
	 Adds media shortcuts to Windows PCs which do not have designated media
	 keys. Defaults are Ctrl + {down, left, right} for Play/Pause, Previous
	 and Next Track.

	Date:
	 2016-06-03

#ce ----------------------------------------------------------------------------

#NoTrayIcon
#include <String.au3>

; Uncomment this line to create a start-up link to this file (for this user)
;~ _autostart()
HotKeySet("!{down}", "p")
HotKeySet("!{left}", "l")
HotKeySet("!{right}", "n")

While Sleep(2000)
WEnd

Func _autostart()
   Local $name = _StringProper(StringLeft(@ScriptName, StringinStr(@scriptname, ".", 0, -1) - 1)) & " Autorun"
   If Not FileExists(@AppDataDir & "\Microsoft\Windows\Start Menu\Programs\Startup\"&$name&".lnk") Then
	   If StringRight(@ScriptName, 4) = ".exe" Then
		   FileCreateShortcut(@ScriptFullPath, @AppDataDir & "\Microsoft\Windows\Start Menu\Programs\Startup\"&$name&".lnk")
	   Else
		   FileCreateShortcut(@AutoItExe, @AppDataDir & "\Microsoft\Windows\Start Menu\Programs\Startup\"&$name&".lnk", "", '"' & @ScriptFullPath & '"')
	   EndIf
   EndIf
EndFunc
Func p()
   Send("{Media_Play_Pause}")
EndFunc
Func n()
   Send("{Media_Next}")
EndFunc
Func l()
   Send("{Media_Prev}")
EndFunc
