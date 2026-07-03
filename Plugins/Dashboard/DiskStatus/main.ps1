function Invoke-HtpPluginMain {
    $drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $size = if ($_.Size) { [math]::Round($_.Size / 1GB, 2) } else { 0 }
        $free = if ($_.FreeSpace) { [math]::Round($_.FreeSpace / 1GB, 2) } else { 0 }
        $used = [math]::Round($size - $free, 2)
        $percent = if ($size -gt 0) { [math]::Round(($used / $size) * 100, 1) } else { 0 }

        [PSCustomObject]@{
            "Drive" = $_.DeviceID
            "Size GB" = $size
            "Used GB" = $used
            "Free GB" = $free
            "Used %" = "$percent%"
            "Status" = if ($percent -lt 80) { "Good" } elseif ($percent -lt 92) { "Warning" } else { "Critical" }
        }
    }

    return $drives
}
