#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         nO OnE 910

	Script Function:
	 Launches Steam in offline mode directly. Tested and works in August 2017
	 with newest Steam version on Windows.

	Date:
	 2015-09-19

#ce ----------------------------------------------------------------------------

#NoTrayIcon
#include <Array.au3>

$dir = StringReplace(RegRead("HKEY_CURRENT_USER\Software\Valve\Steam", "SteamPath"), "/", "\")
$cfg = $dir & "\config\loginusers.vdf"

ProcessClose("Steam.exe")

writeSteamCfg($cfg, 1)

Run($dir & "\Steam.exe")
Sleep(50000)  ; Give Steam time to start

writeSteamCfg($cfg, 0)


Func writeSteamCfg($file, $mode)
	Local $a = StringSplit(FileRead($file), @CRLF)

	Dim $users[0]
	Dim $cur[0]
	For $i = 3 To $a[0] - 2
		Local $t = StringTrim($a[$i])
		_ArrayAdd($cur, $a[$i])
		If $t = "}" Then
			ReDim $users[UBound($users) + 1]
			$users[UBound($users) - 1] = $cur
			$cur = " "
			Dim $cur[0]
		EndIf
	Next

	writeFlag($users, '"WantsOfflineMode"', '"'&$mode&'"')
	writeFlag($users, '"SkipOfflineModeWarning"', '"'&$mode&'"')


	Local $s = '"users"' & @LF & '{'
	For $i = 0 To UBound($users) - 1
		Local $t = $users[$i]
		For $j = 0 To UBound($t) - 1
			If $s <> "" Then
				$s &= @LF
			EndIf
			$s &= $t[$j]
		Next
	Next
	$s &= @LF & '}' & @LF

	FileWriteUTF8($file, $s)
EndFunc

Func writeFlag(ByRef $array, $key, $value)
	For $i = 0 To UBound($array) - 1
		Local $t = $array[$i]
		Local $flag = False
		For $j = 0 To UBound($t) - 1
			If StringInStr($t[$j], $key) > 0 Then
				$flag = True
				$t[$j] = @TAB & @TAB & $key & @TAB & @TAB & $value
			EndIf
		Next
		If Not $flag Then
			_ArrayAdd($t, $t[UBound($t) - 1])
			$t[UBound($t) - 2] = @TAB & @TAB & $key & @TAB & @TAB & $value
		EndIf
		$array[$i] = $t
	Next
EndFunc

Func StringTrim($s)
	While (StringLeft($s, 1) = " " Or StringLeft($s, 1) = @TAB) And StringLen($s) > 1
		$s = StringTrimLeft($s, 1)
	WEnd
	While (StringRight($s, 1) = " " Or StringRight($s, 1) = @TAB) And StringLen($s) > 1
		$s = StringTrimRight($s, 1)
	WEnd
	Return $s
EndFunc

Func FileWriteUTF8($file, $text, $doOverwrite = True)
	Local $flag = 256 + 1
	If $doOverwrite Then
		$flag += 1
	EndIf
	Local $h = FileOpen($file, $flag)
	FileWrite($h, $text)
	FileClose($h)
EndFunc
