#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         nO OnE 910

	Script Function:
	 Toggles between to different audio output devices when run on Windows.
	 nircmd executable required. Stores settings in AppData.
	 http://www.nirsoft.net/utils/nircmd.html

	Date:
	 2016-03-13

#ce ----------------------------------------------------------------------------

$dir = @AppDataDir & "\My Scripts\Audio Device Toggle"
$ini = $dir & "\ini.ini"

If IniRead($ini, "config", "state", "default") = "default" Then
	DirCreate($dir)
	IniWrite($ini, "config", "state", "1")
	If IniRead($ini, "config", "state", "default") = "default" Then
		MsgBox(0, "", "Error")
		Exit
	EndIf
EndIf

$nircmdc = IniRead($ini, "config", "nircmdc", "default")
If $nircmdc = "default" Then
	$nircmdc = InputBox("Audio Device Toggle", "nircmd.exe path:", "F:\Installer\NirCmd\nircmdc.exe")
	IniWrite($ini, "config", "nircmdc", $nircmdc)
	IniWrite($ini, "config", "dev1", InputBox("Audio Device Toggle", "First device name:", "Loudspeaker"))
	IniWrite($ini, "config", "dev2", InputBox("Audio Device Toggle", "Second device name:", "Headset"))
EndIf

$dev1 = IniRead($ini, "config", "dev1", "Loudspeaker")
$dev2 = IniRead($ini, "config", "dev2", "Headset")


If IniRead($ini, "config", "state", "default") = 1 Then
	Run('"'&$nircmdc&'" setdefaultsounddevice ' & $dev2, "", @SW_HIDE)
Else
	Run('"'&$nircmdc&'" setdefaultsounddevice ' & $dev1, "", @SW_HIDE)
EndIf
IniWrite($ini, "config", "state", 3-IniRead($ini, "config", "state", "default"))
