function Invoke-HtpPluginMain {
    $os = Get-CimInstance Win32_OperatingSystem
    $total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $free = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $used = [math]::Round($total - $free, 2)
    $percent = if ($total -gt 0) { [math]::Round(($used / $total) * 100, 1) } else { 0 }

    return [PSCustomObject]@{
        "Tool" = "Memory Status"
        "Total RAM GB" = $total
        "Used RAM GB" = $used
        "Free RAM GB" = $free
        "Usage %" = "$percent%"
        "Status" = if ($percent -lt 75) { "Good" } elseif ($percent -lt 90) { "Warning" } else { "High" }
    }
}
