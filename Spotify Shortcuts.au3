#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         nO OnE 910

	Script Function:
	 Provide Thumb Up / Down Hotkey functionality for Spotify on Windows.

	Date:
	 2017-01-19

#ce ----------------------------------------------------------------------------

; Set Hotkeys, for Keycodes see
;  https://www.autoitscript.com/autoit3/docs/functions/Send.htm
HotKeySet("^{pgup}", "_upvote")
HotKeySet("^{pgdn}", "_dnvote")

Func _upvote()
	_clickOnSpotify(False)
EndFunc   ;==>_upvote

Func _dnvote()
	_clickOnSpotify(True)
EndFunc   ;==>_dnvote


Func _clickOnSpotify($downVote = False, $wasMinimized = False)
	Local $window = "[CLASS:SpotifyMainWindow]"  ; Identifier for Spotify window
	Local $control = "[CLASS:Chrome_RenderWidgetHostHWND; INSTANCE:1]"  ; Identifier for main control
	Local $frameHeight = 57, $bottomOffset = 46  ; frameHeight = y-pos of control, $bottomOffset measured manually

	Local $w = WinGetHandle($window)
	Local $p = WinGetPos($w)
	Local $offset = 99  ; Offset from window middle to Thumb Up / Down, measured manually
	Local $wasHidden = BitAND(WinGetState($w), 2) = 0 Or BitAND(WinGetState($w), 16) > 0  ; Minimized or hidden

	If $downVote Then $offset = -$offset

	If $wasHidden Then
		WinSetState($w, "", @SW_SHOWNOACTIVATE)
		WinSetState($w, "", @SW_RESTORE)
		Return _clickOnSpotify($downVote, True)  ; Vars have to be reinitialized
	EndIf
	ControlClick($w, "", $control, "", 1, $p[2] / 2 + $offset, $p[3] - $bottomOffset - $frameHeight)
EndFunc   ;==>_clickOnSpotify

While Sleep(1000)
WEnd
