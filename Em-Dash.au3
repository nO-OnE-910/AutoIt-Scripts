#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         nO OnE 910

	Script Function:
	 Adds a shortcut for the em-dash (–) to Windows.
	 Default shortcut is {Ctrl} + {Alt} + {-}.

	Date:
	 2015-08-13

#ce ----------------------------------------------------------------------------

#NoTrayIcon
#include <Misc.au3>

While True
	If _IsPressed("12") And _IsPressed("A4") And _IsPressed("BD") Then
		Do
			Sleep(50)
		Until Not (_IsPressed("12") Or _IsPressed("A4") Or _IsPressed("BD"))
		Send("–")
	EndIf
	Sleep(50)
WEnd
