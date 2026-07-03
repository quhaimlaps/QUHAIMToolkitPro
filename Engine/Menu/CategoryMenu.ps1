function Start-HtpMenu {
    param(
        [array]$Plugins,
        [object]$Settings
    )

    while ($true) {
        Show-HtpHeader -Settings $Settings

        $categories = @($Plugins |
            Select-Object -ExpandProperty Category -Unique |
            Sort-Object)

        Write-Host "Main Menu / Main Menu" -ForegroundColor Yellow
        Write-Host ""

        if ($categories.Count -eq 0) {
            Write-Host "No enabled plugins found." -ForegroundColor Yellow
        }
        else {
            for ($i = 0; $i -lt $categories.Count; $i++) {
                $n = $i + 1
                Write-Host "$n) $($categories[$i])"
            }
        }

        Write-Host ""
        Write-Host "0) Exit / Exit"
        Write-Host ""

        $choice = Read-Host "Choose category / Choose category"

        if ($choice -eq "0") {
            Write-HtpLog "Application exited"
            break
        }

        if ($choice -notmatch '^\d+$') {
            continue
        }

        $catIndex = [int]$choice - 1
        if ($catIndex -lt 0 -or $catIndex -ge $categories.Count) {
            continue
        }

        $selectedCategory = $categories[$catIndex]
        Show-HtpCategoryMenu -Category $selectedCategory -Plugins $Plugins -Settings $Settings
    }
}

function Show-HtpCategoryMenu {
    param(
        [string]$Category,
        [array]$Plugins,
        [object]$Settings
    )

    while ($true) {
        Show-HtpHeader -Settings $Settings

        $items = @($Plugins |
            Where-Object { $_.Category -eq $Category } |
            Sort-Object Name)

        Write-Host "Category / القسم: $Category" -ForegroundColor Yellow
        Write-Host ""

        for ($i = 0; $i -lt $items.Count; $i++) {
            $n = $i + 1
            Write-Host "$n) $($items[$i].Name)"
            Write-Host "   $($items[$i].Description)" -ForegroundColor DarkGray
        }

        Write-Host ""
        Write-Host "0) Back / رجوع"
        Write-Host ""

        $choice = Read-Host "Choose tool / اختر الأداة"

        if ($choice -eq "0") {
            break
        }

        if ($choice -notmatch '^\d+$') {
            continue
        }

        $itemIndex = [int]$choice - 1
        if ($itemIndex -lt 0 -or $itemIndex -ge $items.Count) {
            continue
        }

        Show-HtpHeader -Settings $Settings

        try {
            Write-HtpLog "Executing plugin: $($items[$itemIndex].Id)"
            Invoke-HtpPlugin -Plugin $items[$itemIndex]
        }
        catch {
            Write-Host "Tool execution error:" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            Write-HtpLog $_.Exception.Message "ERROR"
        }

        Pause-Htp
    }
}

