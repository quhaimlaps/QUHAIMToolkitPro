Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
projectRoot = fso.GetParentFolderName(WScript.ScriptFullName)
guiScript = projectRoot & "\Gui\Shell\QUHAIMToolkitPro.Gui.ps1"

checkPwsh = shell.Run("%ComSpec% /c where pwsh.exe >nul 2>nul", 0, True)
If checkPwsh <> 0 Then
    MsgBox "QUHAIM Toolkit Pro requires PowerShell 7." & vbCrLf & "Install it using: winget install Microsoft.PowerShell", vbCritical, "QUHAIM Toolkit Pro"
    WScript.Quit 1
End If

cmd = "pwsh.exe -STA -NoLogo -NoProfile -ExecutionPolicy Bypass -File " & Chr(34) & guiScript & Chr(34)
shell.Run cmd, 0, False
