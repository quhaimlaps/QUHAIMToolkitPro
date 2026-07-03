function Get-HtpGuiSettings {
    $path = Join-Path $script:HTP_ROOT "Config\settings.json"
    return Get-Content $path -Raw | ConvertFrom-Json
}

. "$script:HTP_ROOT\Engine\Runtime\ResultFormatter.ps1"

function Test-HtpGuiIsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]::new($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}

function Write-HtpDiscoveryLog {
    param([string]$Message)

    try {
        $logDir = Join-Path $script:HTP_ROOT "Logs"
        if (!(Test-Path $logDir)) {
            New-Item -ItemType Directory -Force -Path $logDir | Out-Null
        }

        $file = Join-Path $logDir "plugin-discovery.log"
        $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$time] $Message" | Add-Content $file -Encoding UTF8
    }
    catch {}
}

function Get-HtpGuiPlugins {
    $pluginsPath = Join-Path $script:HTP_ROOT "Plugins"
    $packages = New-Object System.Collections.Generic.List[object]

    Write-HtpDiscoveryLog "Starting plugin discovery. Path: $pluginsPath"

    if (!(Test-Path $pluginsPath)) {
        Write-HtpDiscoveryLog "Plugins path not found."
        return @()
    }

    $manifests = @(Get-ChildItem -Path $pluginsPath -Recurse -Filter "manifest.json" -File -ErrorAction SilentlyContinue)

    Write-HtpDiscoveryLog "Manifest files found: $($manifests.Count)"

    foreach ($manifestFile in $manifests) {
        try {
            $raw = Get-Content $manifestFile.FullName -Raw -Encoding UTF8
            $manifest = $raw | ConvertFrom-Json

            $required = @("id","name","version","category","description","engine","entry","enabled")
            $missing = @()

            foreach ($r in $required) {
                if ($manifest.PSObject.Properties.Name -notcontains $r) {
                    $missing += $r
                }
            }

            if ($missing.Count -gt 0) {
                Write-HtpDiscoveryLog "Skipping manifest missing fields [$($missing -join ', ')]: $($manifestFile.FullName)"
                continue
            }

            $pluginRoot = Split-Path -Parent $manifestFile.FullName
            $entryPath = Join-Path $pluginRoot $manifest.entry

            if (!(Test-Path $entryPath)) {
                Write-HtpDiscoveryLog "Skipping plugin because entry missing: $entryPath"
                continue
            }

            if ([bool]$manifest.enabled -ne $true) {
                Write-HtpDiscoveryLog "Skipping disabled plugin: $($manifest.id)"
                continue
            }

            $runMode = "normal"
            if ($manifest.PSObject.Properties.Name -contains "runMode") {
                $runMode = [string]$manifest.runMode
            }

            $requiresAdmin = $false
            if ($manifest.PSObject.Properties.Name -contains "requiresAdmin") {
                $requiresAdmin = [bool]$manifest.requiresAdmin
            }

            $package = [PSCustomObject]@{
                Id            = [string]$manifest.id
                Name          = [string]$manifest.name
                Version       = [string]$manifest.version
                Category      = [string]$manifest.category
                Description   = [string]$manifest.description
                Engine        = [string]$manifest.engine
                Entry         = $entryPath
                Root          = $pluginRoot
                RunMode       = $runMode
                RequiresAdmin = $requiresAdmin
                Badge         = if ($requiresAdmin -or $runMode -eq "admin") { "🛡️ Admin" } else { "Normal" }
            }

            $packages.Add($package) | Out-Null
            Write-HtpDiscoveryLog "Loaded plugin: $($manifest.id) | Category: $($manifest.category)"
        }
        catch {
            Write-HtpDiscoveryLog "Failed to load manifest: $($manifestFile.FullName) | $($_.Exception.Message)"
        }
    }

    $result = @($packages | Sort-Object Category, Name)
    Write-HtpDiscoveryLog "Plugins loaded: $($result.Count)"
    return $result
}

function Invoke-HtpGuiPlugin {
    param(
        [object]$Plugin
    )

    if ($Plugin.Engine -ne "powershell") {
        return "Unsupported plugin engine: $($Plugin.Engine)"
    }

    $needsAdmin = ($Plugin.RequiresAdmin -eq $true -or $Plugin.RunMode -eq "admin")
    $isAdmin = Test-HtpGuiIsAdmin

    if ($needsAdmin -and -not $isAdmin) {
        try {
            $outFile = Join-Path $script:HTP_ROOT "Data\Temp\last_admin_plugin_output.txt"
            if (Test-Path $outFile) {
                Remove-Item $outFile -Force
            }

            $command = @"
`$ErrorActionPreference = 'Stop'
. '$($script:HTP_ROOT)\Engine\Runtime\ResultFormatter.ps1'
try {
    . '$($Plugin.Entry)'
    if (Get-Command Invoke-HtpPluginMain -ErrorAction SilentlyContinue) {
        `$raw = Invoke-HtpPluginMain 2>&1
        `$txt = Convert-HtpResultToText `$raw
        if ([string]::IsNullOrWhiteSpace(`$txt)) { `$txt = 'تم تنفيذ الأداة بنجاح.' }
        `$txt | Out-File -FilePath '$outFile' -Encoding utf8
    } else {
        'Plugin entry must define Invoke-HtpPluginMain' | Out-File -FilePath '$outFile' -Encoding utf8
    }
}
catch {
    "Error: `$(`$_.Exception.Message)" | Out-File -FilePath '$outFile' -Encoding utf8
}
"@

            $encodedEntry = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
            $args = "-NoLogo -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedEntry"

            Start-Process "pwsh.exe" -ArgumentList $args -Verb RunAs -Wait

            if (Test-Path $outFile) {
                $result = Get-Content $outFile -Raw
                if (-not [string]::IsNullOrWhiteSpace($result)) {
                    return $result.Trim()
                }
            }

            return "تم تشغيل الأداة بصلاحية مسؤول، لكن لم يتم إرجاع مخرجات."
        }
        catch {
            return "تم إلغاء التشغيل أو فشل طلب صلاحية المسؤول: $($_.Exception.Message)"
        }
    }

    try {
        . $Plugin.Entry

        if (!(Get-Command Invoke-HtpPluginMain -ErrorAction SilentlyContinue)) {
            return "Plugin entry must define Invoke-HtpPluginMain"
        }

        $rawResult = Invoke-HtpPluginMain 2>&1
        $output = Convert-HtpResultToText $rawResult

        Remove-Item Function:\Invoke-HtpPluginMain -ErrorAction SilentlyContinue

        if ([string]::IsNullOrWhiteSpace($output)) {
            return "تم تنفيذ الأداة بنجاح."
        }

        return $output
    }
    catch {
        return "Error: $($_.Exception.Message)"
    }
}


function Get-HtpDashboardHomeMetrics {
    param(
        [object[]]$Plugins = @()
    )

    $metrics = [ordered]@{
        ComputerName      = $env:COMPUTERNAME
        UserName          = $env:USERNAME
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        AdminMode         = (Test-HtpGuiIsAdmin)
        PluginTotal       = @($Plugins).Count
        DashboardTools    = @($Plugins | Where-Object { $_.Category -like "*Dashboard*" -or $_.Id -like "dashboard.*" }).Count
        UpdateTools       = @($Plugins | Where-Object { $_.Category -like "*Update*" -or $_.Category -like "*تحديث*" -or $_.Id -like "updates.*" }).Count
        SystemTools       = @($Plugins | Where-Object { $_.Category -like "*System*" -or $_.Category -like "*النظام*" -or $_.Id -like "system.*" }).Count
        Categories        = @($Plugins | Select-Object -ExpandProperty Category -Unique).Count
        CpuName           = "Unknown"
        CpuLoad           = "Unknown"
        MemoryTotalGb     = "Unknown"
        MemoryUsedGb      = "Unknown"
        MemoryFreeGb      = "Unknown"
        MemoryPercent     = "Unknown"
        MemoryStatus      = "Unknown"
        DiskSummary       = "Unknown"
        DiskWarningCount  = 0
        InternetStatus    = "Unknown"
        InternetTarget    = "1.1.1.1"
        LatestLog         = "لا توجد سجلات بعد."
        ErrorCount        = 0
        CheckedAt         = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    try {
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        if ($cpu) {
            $metrics.CpuName = [string]$cpu.Name
            if ($null -ne $cpu.LoadPercentage) {
                $metrics.CpuLoad = "$($cpu.LoadPercentage)%"
            }
        }
    }
    catch {}

    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $free  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $used  = [math]::Round($total - $free, 2)
        $pct   = if ($total -gt 0) { [math]::Round(($used / $total) * 100, 1) } else { 0 }

        $metrics.MemoryTotalGb = $total
        $metrics.MemoryUsedGb  = $used
        $metrics.MemoryFreeGb  = $free
        $metrics.MemoryPercent = "$pct%"
        $metrics.MemoryStatus  = if ($pct -lt 75) { "Good" } elseif ($pct -lt 90) { "Warning" } else { "High" }
    }
    catch {}

    try {
        $drives = @(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop | ForEach-Object {
            $size = if ($_.Size) { [math]::Round($_.Size / 1GB, 1) } else { 0 }
            $free = if ($_.FreeSpace) { [math]::Round($_.FreeSpace / 1GB, 1) } else { 0 }
            $used = [math]::Round($size - $free, 1)
            $pct = if ($size -gt 0) { [math]::Round(($used / $size) * 100, 0) } else { 0 }
            [PSCustomObject]@{
                Drive = $_.DeviceID
                SizeGb = $size
                FreeGb = $free
                UsedPercent = $pct
            }
        })

        if ($drives.Count -gt 0) {
            $primary = $drives | Sort-Object Drive | Select-Object -First 1
            $metrics.DiskSummary = "$($primary.Drive) مستخدم $($primary.UsedPercent)% | متاح $($primary.FreeGb) GB"
            $metrics.DiskWarningCount = @($drives | Where-Object { $_.UsedPercent -ge 85 }).Count
        }
    }
    catch {}

    try {
        $ping = [System.Net.NetworkInformation.Ping]::new()
        $reply = $ping.Send("1.1.1.1", 900)
        $metrics.InternetStatus = if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) { "Online" } else { "Offline / Blocked" }
    }
    catch {
        $metrics.InternetStatus = "Offline / Blocked"
    }

    try {
        $logDir = Join-Path $script:HTP_ROOT "Logs"
        if (Test-Path $logDir) {
            $latest = Get-ChildItem $logDir -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($latest) {
                $tail = @(Get-Content $latest.FullName -Tail 40 -ErrorAction SilentlyContinue)
                $lastLine = @($tail | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Last 1)
                if ($lastLine.Count -gt 0) {
                    $metrics.LatestLog = [string]$lastLine[0]
                }
                $metrics.ErrorCount = @($tail | Where-Object { $_ -match "ERROR|Error|Failed|فشل|خطأ" }).Count
            }
        }
    }
    catch {}

    return [PSCustomObject]$metrics
}
