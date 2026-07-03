function Start-HtpEngine {
    param(
        [array]$Plugins,
        [object]$Settings
    )

    while ($true) {
        Show-HtpHeader

        Write-Host "Version: $($Settings.Version)"
        Write-Host ""
        Write-Host "Main Menu:"
        Write-Host ""

        if ($Plugins.Count -eq 0) {
            Write-Host "No plugins found." -ForegroundColor Yellow
        }
        else {
            for ($i = 0; $i -lt $Plugins.Count; $i++) {
                $num = $i + 1
                Write-Host "$num) $($Plugins[$i].Name) - $($Plugins[$i].Description)"
            }
        }

        Write-Host ""
        Write-Host "0) Exit"
        Write-Host ""

        $choice = Read-Host "Choose option"

        if ($choice -eq "0") {
            Write-HtpLog "Application exited"
            break
        }

        if ($choice -match '^\d+$') {
            $index = [int]$choice - 1

            if ($index -ge 0 -and $index -lt $Plugins.Count) {
                Show-HtpHeader
                Write-HtpLog "Executing plugin: $($Plugins[$index].Name)"

                try {
                    & $Plugins[$index].Action
                }
                catch {
                    Write-Host "Error while running plugin:" -ForegroundColor Red
                    Write-Host $_.Exception.Message -ForegroundColor Red
                    Write-HtpLog $_.Exception.Message "ERROR"
                }

                Pause-Htp
            }
        }
    }
}
