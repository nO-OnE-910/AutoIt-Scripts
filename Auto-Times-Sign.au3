#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         nO OnE 910

	Script Function:
	 Provide the option to replace number-times-x with the actual unicode char
	 for 'times' on Windows. Detects "123 x" and replaces with "123 ×".

	Date:
	 2017-06-23

#ce ----------------------------------------------------------------------------

#NoTrayIcon
#include <Misc.au3>


;= Settings ===============
Global $timeout = 4000  ; After $timeout milliseconds the popup disappears.
Global $looptime = 5  ; Sleep $looptime milliseconds between two loops.
Global $char = "×"
Global $info = "Did you mean × instead of x ? [Ctrl+Enter/Esc]"
Global $tmp_replace = "$TMP_REPLACE$"
;= Globals ================
Global $num_last = False
Global $show_time = 0
Global $showing = False
Global $was_showing = False
Global $x_down = False
Global $x_off = 0
Global $clip = ""
;= Author: nO_OnE_910 =====

Func _ex()
	Exit
EndFunc   ;==>_ex

Func _pressed($i)
	If ($i >= 0x30 And $i <= 0x39) Or ($i >= 0x60 And $i <= 0x69) Then  ; 0-9
		$num_last = True
	Else
		If $i = 0x58 And Not _IsPressed("11") Then  ; X without Ctrl
			If Not $x_down And Not $showing And $num_last Then
				$showing = True
			ElseIf Not $x_down And $showing And Not $num_last Then
				$x_off += 1
			EndIf
			$x_down = True
		EndIf
		$num_last = False
	EndIf
EndFunc   ;==>_pressed

Func _not_pressed($i)
	If $i = 0x58 Then
		$x_down = False
	EndIf
EndFunc   ;==>_not_pressed


Func _push_clip()
	$clip = ClipGet()
EndFunc   ;==>_push_clip
Func _pop_clip()
	ClipPut($clip)
EndFunc   ;==>_pop_clip

Func _accept()
	_push_clip()

	Send("{end}")
	Sleep(5)
	Send("{lshift down}")
	Sleep(5)
	Send("{home}")
	Sleep(5)
	Send("{lshift up}")
	Sleep(5)
	Send("^{c}")
	Sleep(10)
	$s = ClipGet()
	If $x_off > 0 Then
		$s = StringReplace($s, "x", $tmp_replace, -1 * $x_off)
	EndIf
	$s = StringReplace($s, "x", $char, -1)
	If $x_off > 0 Then
		$s = StringReplace($s, $tmp_replace, "x")
	EndIf
	ClipPut($s)
	Sleep(10)
	Send("^{v}")

	_pop_clip()
	_decline()
EndFunc   ;==>_accept

Func _decline()
	$showing = False
EndFunc   ;==>_decline

Func _loop()
	If $showing And Not $was_showing Then
		ToolTip($info)
		$show_time = TimerInit()
		$x_off = 0
		HotKeySet("{esc}", "_decline")
		HotKeySet("^{enter}", "_accept")
	ElseIf $showing <> $was_showing Then
		ToolTip("")
		HotKeySet("{esc}")
		HotKeySet("^{enter}")
	EndIf
	$was_showing = $showing
	If $showing And TimerDiff($show_time) > $timeout Then
		$showing = False
	EndIf
EndFunc   ;==>_loop

; For debugging:
; HotKeySet("+{esc}", "_ex")
While True
	_loop()
	For $i = 0x30 To 0x69
		If _IsPressed(Hex($i, 2)) Then
			_pressed($i)
		Else
			_not_pressed($i)
		EndIf
	Next
	Sleep($looptime)
WEnd
