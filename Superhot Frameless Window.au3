#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         nO OnE 910

	Script Function:
	 Adds a frameless window mode to SUPERHOT on Windows.
	 https://superhotgame.com/
	 May work with other programs as well. Dimensions measured for Windows 10.
	 (Not tested recently, SUPERHOT version unknown)

	Date:
	 2016-02-29

#ce ----------------------------------------------------------------------------

#include <WinAPI.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>
;~ #RequireAdmin

If $cmdline[0] < 1 Or $cmdline[1] <> "-s" Then
	Run (@AutoItExe & " " & @ScriptFullPath & " -s")
	Exit
EndIf

$c = 0
Do
	WinWait("SUPERHOT")
	$h = WinGetHandle("SUPERHOT")
	$p = WinGetPos($h)
	Sleep(200)
	If IsArray($p) And $p[2] > 500 Then
		$c += 1
	Else
		$c = 0
	EndIf
Until $c = 2

$iOldStyle = _WinAPI_GetWindowLong($h, $GWL_STYLE)
ConsoleWrite("+ old style: " & $iOldStyle & @CR)
;~ $iNewStyle = BitXOr($iOldStyle, $WS_MINIMIZEBOX, $WS_MAXIMIZEBOX)
$iNewStyle = BitXOr($iOldStyle, $WS_SYSMENU, $WS_POPUP)

_WinAPI_SetWindowLong($h, $GWL_STYLE, $iNewStyle)
_WinAPI_SetWindowPos($h, 0, 0, 0, 0, 0, BitOR($SWP_FRAMECHANGED, $SWP_NOMOVE, $SWP_NOSIZE))

WinMove($h, "", -3, -26)
