function Invoke-HtpPluginMain {
    $cmd = Get-Command winget.exe -ErrorAction SilentlyContinue

    if ($null -eq $cmd) {
        return [PSCustomObject]@{
            "Tool" = "Updates Summary"
            "Winget" = "Not Found"
            "Updates" = "Unknown"
        }
    }

    $output = & winget upgrade --accept-source-agreements 2>&1 | Out-String

    $lines = @($output -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $availableLine = $lines | Where-Object { $_ -match "upgrades available|upgrade available|تحديث" } | Select-Object -Last 1

    return @"
Updates Summary
---------------
Winget Path:
$($cmd.Source)

Raw Winget Result:
$output
"@
}
