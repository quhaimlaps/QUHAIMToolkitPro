function Remove-HtpConsoleNoise {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    $clean = $Text

    # Remove ANSI escape sequences.
    $clean = [regex]::Replace($clean, "`e\[[0-9;?]*[A-Za-z]", "")

    # Normalize carriage returns caused by command-line progress animations.
    $clean = $clean -replace "`r", "`n"

    $lines = New-Object System.Collections.Generic.List[string]

    foreach ($line in ($clean -split "`n")) {
        $l = $line.TrimEnd()

        # Remove spinner-only lines: / \ | -
        if ($l.Trim() -match '^[\\/\|\-]+$') { continue }

        # Remove empty fragments created by progress animations.
        if ($l.Trim() -eq "") {
            if ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim() -eq "") {
                continue
            }
        }

        $lines.Add($l)
    }

    return (($lines -join [Environment]::NewLine).Trim())
}

function Convert-HtpResultToText {
    param(
        [Parameter(ValueFromPipeline = $true)]
        $Result
    )

    if ($null -eq $Result) {
        return ""
    }

    if ($Result -is [string]) {
        return Remove-HtpConsoleNoise $Result
    }

    if ($Result -is [System.Collections.IDictionary]) {
        $lines = New-Object System.Collections.Generic.List[string]
        foreach ($key in $Result.Keys) {
            $lines.Add("$key : $($Result[$key])")
        }
        return Remove-HtpConsoleNoise ($lines -join [Environment]::NewLine)
    }

    if ($Result -is [pscustomobject]) {
        $lines = New-Object System.Collections.Generic.List[string]
        foreach ($prop in $Result.PSObject.Properties) {
            $lines.Add("$($prop.Name) : $($prop.Value)")
        }
        return Remove-HtpConsoleNoise ($lines -join [Environment]::NewLine)
    }

    if ($Result -is [System.Array]) {
        return Remove-HtpConsoleNoise (($Result | ForEach-Object { Convert-HtpResultToText $_ }) -join [Environment]::NewLine)
    }

    return Remove-HtpConsoleNoise (($Result | Out-String).Trim())
}
