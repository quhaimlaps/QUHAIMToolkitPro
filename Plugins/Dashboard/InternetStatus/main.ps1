function Invoke-HtpPluginMain {
    $targets = @("1.1.1.1", "8.8.8.8")
    $results = foreach ($t in $targets) {
        $ok = Test-Connection -ComputerName $t -Count 1 -Quiet -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            "Target" = $t
            "Reachable" = $ok
        }
    }

    $online = ($results | Where-Object { $_.Reachable -eq $true } | Measure-Object).Count -gt 0

    return @(
        [PSCustomObject]@{
            "Tool" = "Internet Status"
            "Internet" = if ($online) { "Online" } else { "Offline or blocked" }
            "Checked At" = (Get-Date)
        }
        $results
    )
}
