function Invoke-HtpPluginMain {
    $temp = $env:TEMP
    $items = Get-ChildItem $temp -Force -ErrorAction SilentlyContinue
    $count = ($items | Measure-Object).Count

    return [PSCustomObject]@{
        "Tool" = "Temp Folder Info"
        "Temp Path" = $temp
        "Items Count" = $count
        "Action" = "فحص فقط، لم يتم حذف أي ملف."
    }
}
