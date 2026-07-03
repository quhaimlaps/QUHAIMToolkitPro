$ErrorActionPreference = "Stop"

$script:HTP_ROOT = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    [Console]::InputEncoding  = [System.Text.UTF8Encoding]::new()
}
catch {}

. "$script:HTP_ROOT\Engine\Api\GuiBridge.ps1"

$Settings = Get-HtpGuiSettings
$Plugins = @(Get-HtpGuiPlugins)

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="QUHAIM Toolkit Pro"
    Height="690"
    Width="1180"
    MinHeight="620"
    MinWidth="1040"
    ResizeMode="CanResizeWithGrip"
    WindowStartupLocation="CenterScreen"
    Background="#0B1120"
    FlowDirection="RightToLeft"
    FontFamily="Segoe UI"
    FontSize="13">

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="64"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="42"/>
        </Grid.RowDefinitions>

        <!-- Header: Arabic RTL visual order, search stays on the left because the window is RTL -->
        <Border Grid.Row="0" Background="#0F172A" BorderBrush="#1E293B" BorderThickness="0,0,0,1">
            <Grid Margin="14,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="300"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center" FlowDirection="RightToLeft">
                    <Border Width="38" Height="38" CornerRadius="10" Background="#2563EB" Margin="0,0,0,0">
                        <TextBlock Text="H" Foreground="White" FontSize="22" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <StackPanel Margin="12,0,0,0">
                        <TextBlock Text="QUHAIM Toolkit Pro" Foreground="#F8FAFC" FontSize="20" FontWeight="Bold" TextAlignment="Right"/>
                        <TextBlock Name="VersionText" Text="0.4.5.24" Foreground="#93C5FD" FontSize="11" TextAlignment="Right"/>
                    </StackPanel>
                </StackPanel>

                <TextBox Name="SearchBox"
                         Grid.Column="2"
                         Height="34"
                         VerticalAlignment="Center"
                         Background="#111827"
                         Foreground="#E5E7EB"
                         BorderBrush="#334155"
                         Padding="10,0"
                         FlowDirection="RightToLeft"
                         ToolTip="ابحث عن أداة"/>
            </Grid>
        </Border>

        <!-- Main Body -->
        <Grid Grid.Row="1">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="260"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- Right Sidebar -->
            <Border Grid.Column="0" Background="#0F172A" BorderBrush="#1E293B" BorderThickness="1,0,0,0" Padding="12">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <ListBox Name="CategoryList"
                             Grid.Row="0"
                             Background="#0F172A"
                             BorderThickness="0"
                             Foreground="#E5E7EB"
                             FlowDirection="LeftToRight"
                             HorizontalContentAlignment="Stretch"
                             ScrollViewer.VerticalScrollBarVisibility="Auto">
                        <ListBox.ItemContainerStyle>
                            <Style TargetType="{x:Type ListBoxItem}">
                                <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
                                <Setter Property="FlowDirection" Value="LeftToRight"/>
                                <Setter Property="Padding" Value="8,7"/>
                                <Setter Property="Margin" Value="0,2"/>
                                <Setter Property="Template">
                                    <Setter.Value>
                                        <ControlTemplate TargetType="{x:Type ListBoxItem}">
                                            <Border Name="Bd"
                                                    Background="{TemplateBinding Background}"
                                                    BorderBrush="{TemplateBinding BorderBrush}"
                                                    BorderThickness="{TemplateBinding BorderThickness}"
                                                    Padding="{TemplateBinding Padding}">
                                                <ContentPresenter HorizontalAlignment="Stretch"
                                                                  FlowDirection="LeftToRight"
                                                                  VerticalAlignment="Center"
                                                                  RecognizesAccessKey="True"/>
                                            </Border>
                                            <ControlTemplate.Triggers>
                                                <Trigger Property="IsSelected" Value="True">
                                                    <Setter TargetName="Bd" Property="Background" Value="#334155"/>
                                                    <Setter TargetName="Bd" Property="BorderBrush" Value="#CBD5E1"/>
                                                    <Setter Property="Foreground" Value="#FFFFFF"/>
                                                </Trigger>
                                                <Trigger Property="IsMouseOver" Value="True">
                                                    <Setter TargetName="Bd" Property="Background" Value="#1E293B"/>
                                                </Trigger>
                                            </ControlTemplate.Triggers>
                                        </ControlTemplate>
                                    </Setter.Value>
                                </Setter>
                            </Style>
                        </ListBox.ItemContainerStyle>
                    </ListBox>
                </Grid>
            </Border>

            <!-- Workspace -->
            <Grid Grid.Column="1" Margin="14" FlowDirection="LeftToRight">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="190"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0"
                        Background="#111827"
                        CornerRadius="16"
                        Padding="12"
                        Margin="0,0,0,8"
                        BorderBrush="#1F2937"
                        BorderThickness="1">
                    <Grid FlowDirection="LeftToRight">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <Grid Grid.Column="1" HorizontalAlignment="Stretch" VerticalAlignment="Center" Margin="0,0,6,0">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            <TextBlock Name="HeaderTitle" Grid.Row="0" FlowDirection="RightToLeft" HorizontalAlignment="Right"
                                       Text="لوحة التحكم"
                                       Foreground="#F8FAFC"
                                       FontSize="26"
                                       FontWeight="Bold"
                                       TextAlignment="Right"/>
                            <TextBlock Name="HeaderSubtitle" Grid.Row="1" FlowDirection="RightToLeft" HorizontalAlignment="Right"
                                       Text="اختر قسمًا من القائمة أو ابحث عن أداة."
                                       Foreground="#94A3B8"
                                       Margin="0,5,0,0"
                                       TextAlignment="Right"/>
                        </Grid>

                        <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center" HorizontalAlignment="Left" FlowDirection="RightToLeft">
                            <Border Background="#064E3B" CornerRadius="12" Padding="12,7" Margin="6,0,6,0">
                                <TextBlock Name="PluginCountText" Text="الأدوات: 0" Foreground="#A7F3D0" FontWeight="Bold"/>
                            </Border>
                            <Border Background="#1E3A8A" CornerRadius="12" Padding="12,7" Margin="6,0,6,0">
                                <TextBlock Name="AdminStateText" Text="وضع المستخدم" Foreground="#BFDBFE" FontWeight="Bold"/>
                            </Border>
                        </StackPanel>
                    </Grid>
                </Border>

                <Border Grid.Row="1"
                        Background="#111827"
                        CornerRadius="16"
                        Padding="10"
                        Margin="0,0,0,8"
                        BorderBrush="#1F2937"
                        BorderThickness="1"
                        ClipToBounds="True">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <ListBox Name="ToolList"
                                 Grid.Row="1"
                                 Background="#111827"
                                 BorderThickness="0"
                                 Foreground="#E5E7EB"
                                 ScrollViewer.VerticalScrollBarVisibility="Auto"
                                 ScrollViewer.HorizontalScrollBarVisibility="Disabled" FlowDirection="LeftToRight" HorizontalContentAlignment="Right">
                            <ListBox.ItemsPanel>
                                <ItemsPanelTemplate>
                                    <WrapPanel IsItemsHost="True" Orientation="Horizontal" FlowDirection="RightToLeft" HorizontalAlignment="Right"/>
                                </ItemsPanelTemplate>
                            </ListBox.ItemsPanel>
                        </ListBox>
                    </Grid>
                </Border>

                <Border Grid.Row="2"
                        Background="#020617"
                        CornerRadius="16"
                        Padding="10"
                        BorderBrush="#1F2937"
                        BorderThickness="1">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <Grid Grid.Row="0" FlowDirection="LeftToRight">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <StackPanel Grid.Column="0" Orientation="Horizontal" FlowDirection="RightToLeft" HorizontalAlignment="Left">
                                <Button Name="RunButton" Content="تشغيل احتياطي" Width="110" Height="28" Margin="0,0,8,0" Background="#2563EB" Foreground="White" BorderBrush="#1D4ED8"/>
                                <Button Name="CopyButton" Content="نسخ النتيجة" Width="105" Height="28" Margin="0,0,8,0" Background="#1F2937" Foreground="#E5E7EB" BorderBrush="#374151"/>
                                <Button Name="SaveButton" Content="حفظ التقرير" Width="105" Height="28" Margin="0,0,8,0" Background="#1F2937" Foreground="#E5E7EB" BorderBrush="#374151"/>
                                <Button Name="ClearButton" Content="مسح النتائج" Width="105" Height="28" Margin="0,0,8,0" Background="#1F2937" Foreground="#E5E7EB" BorderBrush="#374151"/>
                                <Button Name="ExpandButton" Content="تكبير النتيجة" Width="105" Height="28" Background="#1F2937" Foreground="#E5E7EB" BorderBrush="#374151"/>
                            </StackPanel>

                            <TextBlock Grid.Column="2"
                                       Text="عارض النتائج"
                                       Foreground="#E5E7EB"
                                       FontSize="15"
                                       FontWeight="Bold"
                                       VerticalAlignment="Center"
                                       HorizontalAlignment="Right"
                                       FlowDirection="RightToLeft"
                                       TextAlignment="Right"/>
                        </Grid>

                        <TextBox Name="OutputBox"
                                 Grid.Row="1"
                                 Margin="0,10,0,0"
                                 Background="#0B1120"
                                 Foreground="#D1D5DB"
                                 BorderBrush="#1F2937"
                                 TextWrapping="Wrap"
                                 AcceptsReturn="True"
                                 VerticalScrollBarVisibility="Auto"
                                 HorizontalScrollBarVisibility="Auto"
                                 IsReadOnly="True"
                                 FlowDirection="LeftToRight"
                                 FontFamily="Consolas"
                                 FontSize="12"
                                 Text="جاهز."/>
                    </Grid>
                </Border>
            </Grid>
        </Grid>

        <!-- Footer fixed and always visible -->
        <Border Grid.Row="2" Background="#020617" BorderBrush="#1E293B" BorderThickness="0,1,0,0">
            <Grid Margin="14,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0" Orientation="Horizontal" FlowDirection="RightToLeft" VerticalAlignment="Center">
                    <Button Name="ExitButton" Content="خروج" Width="82" Height="28" Margin="0,0,8,0" Background="#7F1D1D" Foreground="#FEE2E2" BorderBrush="#991B1B"/>
                    <Button Name="ConsoleButton" Content="Console احتياطي" Width="130" Height="28" Background="#1F2937" Foreground="#E5E7EB" BorderBrush="#374151"/>
                </StackPanel>

                <TextBlock Name="StatusText"
                           Grid.Column="1"
                           Text="جاهز."
                           Foreground="#94A3B8"
                           VerticalAlignment="Center"
                           TextAlignment="Right"/>

                <TextBlock Name="FooterVersionText"
                           Grid.Column="2"
                           Text="v0.4.4"
                           Foreground="#64748B"
                           VerticalAlignment="Center"
                           Margin="10,0,0,0"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$Window = [Windows.Markup.XamlReader]::Load($reader)

$VersionText       = $Window.FindName("VersionText")
$FooterVersionText = $Window.FindName("FooterVersionText")
$CategoryList      = $Window.FindName("CategoryList")
# v0.4.5.24 CategoryList runtime alignment
if ($null -ne $CategoryList) {
    try { $CategoryList.FlowDirection = "LeftToRight" } catch {}
    try { $CategoryList.HorizontalContentAlignment = "Stretch" } catch {}
}
$ToolList          = $Window.FindName("ToolList")
$OutputBox         = $Window.FindName("OutputBox")
$RunButton         = $Window.FindName("RunButton")
$CopyButton        = $Window.FindName("CopyButton")
$SaveButton        = $Window.FindName("SaveButton")
$ClearButton       = $Window.FindName("ClearButton")
$ExpandButton      = $Window.FindName("ExpandButton")
$ExitButton        = $Window.FindName("ExitButton")
$ConsoleButton     = $Window.FindName("ConsoleButton")
$HeaderTitle       = $Window.FindName("HeaderTitle")
$HeaderSubtitle    = $Window.FindName("HeaderSubtitle")
$SearchBox         = $Window.FindName("SearchBox")
$StatusText        = $Window.FindName("StatusText")
$PluginCountText   = $Window.FindName("PluginCountText")
$AdminStateText    = $Window.FindName("AdminStateText")

$VersionText.Text = "الإصدار $($Settings.Version)"
$FooterVersionText.Text = "v$($Settings.Version)"
$PluginCountText.Text = "الأدوات: $($Plugins.Count)"

try {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $AdminStateText.Text = if ($isAdmin) { "وضع المسؤول" } else { "وضع المستخدم" }
}
catch {
    $AdminStateText.Text = "وضع المستخدم"
}

function Get-HtpDisplayCategory {
    param([string]$Category)
    if ([string]::IsNullOrWhiteSpace($Category)) { return "System Tools" }
    if ($Category -match "Dashboard" -or $Category -match "لوحة التحكم") { return "🏠 لوحة التحكم" }
    return $Category.Trim()
}

# v0.4.5.24 menu helper functions must be defined before category population
function New-HtpCategoryListItem {
    param([string]$Text)

    $item = New-Object System.Windows.Controls.ListBoxItem
    $item.Tag = $Text
    $item.HorizontalContentAlignment = "Stretch"
    $item.HorizontalAlignment = "Stretch"
    $item.FlowDirection = "LeftToRight"
    $item.Padding = "8,7"
    $item.Margin = "0,2,0,2"

    $container = New-Object System.Windows.Controls.Grid
    $container.HorizontalAlignment = "Stretch"
    $container.FlowDirection = "LeftToRight"

    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text = $Text
    $tb.HorizontalAlignment = "Right"
    $tb.TextAlignment = "Right"
    $tb.FlowDirection = "RightToLeft"
    $tb.FontWeight = "SemiBold"

    $container.Children.Add($tb) | Out-Null
    $item.Content = $container
    return $item
}

function Get-HtpSelectedCategoryText {
    if ($null -eq $CategoryList.SelectedItem) { return $null }

    $selected = $CategoryList.SelectedItem

    if ($selected -is [System.Windows.Controls.ListBoxItem]) {
        return [string]$selected.Tag
    }

    try {
        if (-not [string]::IsNullOrWhiteSpace([string]$selected.Tag)) {
            return [string]$selected.Tag
        }
    }
    catch {}

    return [string]$selected
}

function Get-HtpCleanHeaderTitle {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    return ($Text -replace "^[^\p{L}\p{N}]+\s*", "").Trim()
}

$PreferredCategories = @(
    "🏠 لوحة التحكم",
    "⚙️ الإعدادات",
    "🐍 أدوات بايثون",
    "📝 السجلات",
    "📦 التحديثات",
    "📦 إدارة البرامج",
    "🖥️ أدوات النظام",
    "💻 أدوات التطوير",
    "🛠️ أدوات الصيانة",
    "🌐 أدوات الشبكة",
    "🤖 أدوات الذكاء الاصطناعي"
)
$discovered = @($Plugins | ForEach-Object { Get-HtpDisplayCategory $_.Category } | Select-Object -Unique)
$Categories = New-Object System.Collections.Generic.List[string]
foreach ($pc in $PreferredCategories) {
    if ($discovered -contains $pc) { [void]$Categories.Add($pc) }
}
foreach ($cat in ($discovered | Sort-Object)) {
    if (-not $Categories.Contains($cat)) { [void]$Categories.Add($cat) }
}

foreach ($cat in $Categories) {
    [void]$CategoryList.Items.Add((New-HtpCategoryListItem -Text $cat))
}

if ($Categories.Count -gt 0) {
    $CategoryList.SelectedIndex = 0
}

function New-HtpCategoryListItem {
    param([string]$Text)

    $item = New-Object System.Windows.Controls.ListBoxItem
    $item.Tag = $Text
    $item.HorizontalContentAlignment = "Stretch"
    $item.HorizontalAlignment = "Stretch"
    $item.FlowDirection = "LeftToRight"
    $item.Padding = "8,7"
    $item.Margin = "0,2,0,2"

    $container = New-Object System.Windows.Controls.Grid
    $container.HorizontalAlignment = "Stretch"
    $container.FlowDirection = "LeftToRight"

    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text = $Text
    $tb.HorizontalAlignment = "Right"
    $tb.TextAlignment = "Right"
    $tb.FlowDirection = "RightToLeft"
    $tb.FontWeight = "SemiBold"

    $container.Children.Add($tb) | Out-Null
    $item.Content = $container
    return $item
}

function Get-HtpSelectedCategoryText {
    if ($null -eq $CategoryList.SelectedItem) { return $null }

    $selected = $CategoryList.SelectedItem

    if ($selected -is [System.Windows.Controls.ListBoxItem]) {
        return [string]$selected.Tag
    }

    if ($selected.PSObject.Properties.Name -contains "Tag" -and -not [string]::IsNullOrWhiteSpace([string]$selected.Tag)) {
        return [string]$selected.Tag
    }

    return [string]$selected
}

function Get-HtpCleanHeaderTitle {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    return ($Text -replace "^[^\p{L}\p{N}]+\s*", "").Trim()
}

function Get-HtpToolIcon {
    param($p)

    $text = "$($p.Name) $($p.Category) $($p.Description) $($p.Id)"

    if ($text -match "Disk|Drive|قرص|مساحة") { return "💾" }
    if ($text -match "Memory|RAM|ذاكرة") { return "🧠" }
    if ($text -match "Internet|Network|شبكة|Ping") { return "🌐" }
    if ($text -match "Log|سجل|Logs") { return "🧾" }
    if ($text -match "Update|Winget|تحديث") { return "📦" }
    if ($text -match "Python") { return "🐍" }
    if ($text -match "AI|ذكاء") { return "🤖" }
    if ($text -match "Settings|إعدادات") { return "⚙️" }
    if ($text -match "Program|Software|برامج") { return "📋" }
    if ($text -match "Admin|Permission|مسؤول") { return "🛡️" }
    if ($text -match "Quick|Guide|Start") { return "🚀" }
    if ($text -match "System|Windows|Status|Snapshot|النظام") { return "🖥️" }

    return "🧩"
}

function Add-ToolCard {
    param($p)

    $item = New-Object System.Windows.Controls.ListBoxItem
    $item.Tag = $p
    $item.Margin = "4"
    $item.Padding = "0"
    
# v0.4.5.24 Compact Dashboard Layout
# Smaller cards targeting up to 5 cards per row when screen width allows.
$item.Width = 205
    # v0.4.5.24 RTL card alignment
    $item.HorizontalContentAlignment = "Right"
    $item.FlowDirection = "LeftToRight"
    $item.MinHeight = 118
    $item.Background = "#1F2937"
    $item.Foreground = "#E5E7EB"
    $item.HorizontalContentAlignment = "Stretch"
    $item.VerticalContentAlignment = "Stretch"
    $item.FlowDirection = "LeftToRight"

    $border = New-Object System.Windows.Controls.Border
    $border.CornerRadius = "9"
    $border.BorderThickness = "1"
    $border.BorderBrush = "#334155"
    $border.Background = "#1F2937"
    $border.Padding = "10"

    $grid = New-Object System.Windows.Controls.Grid
    $grid.FlowDirection = "LeftToRight"

    $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = [System.Windows.GridLength]::Auto })) | Out-Null
    $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = [System.Windows.GridLength]::Auto })) | Out-Null
    $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = [System.Windows.GridLength]::Auto })) | Out-Null

    $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star) })) | Out-Null
    $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = [System.Windows.GridLength]::Auto })) | Out-Null

    $iconBox = New-Object System.Windows.Controls.Border
    $iconBox.Width = 28
    $iconBox.Height = 28
    $iconBox.CornerRadius = "7"
    $iconBox.Background = "#0F172A"
    $iconBox.BorderBrush = "#334155"
    $iconBox.BorderThickness = "1"
    $iconBox.Margin = "8,0,0,0"
    [System.Windows.Controls.Grid]::SetColumn($iconBox, 1)
    [System.Windows.Controls.Grid]::SetRow($iconBox, 0)

    $icon = New-Object System.Windows.Controls.TextBlock
    $icon.Text = Get-HtpToolIcon $p
    $icon.FontSize = 16
    $icon.HorizontalAlignment = "Center"
    $icon.VerticalAlignment = "Center"
    $iconBox.Child = $icon

    $nameStack = New-Object System.Windows.Controls.StackPanel
    $nameStack.FlowDirection = "RightToLeft"
    $nameStack.HorizontalAlignment = "Right"
    [System.Windows.Controls.Grid]::SetColumn($nameStack, 0)
    [System.Windows.Controls.Grid]::SetRow($nameStack, 0)

    $name = New-Object System.Windows.Controls.TextBlock
    $name.Text = $p.Name
    $name.FontSize = 12
    $name.FontWeight = "Bold"
    $name.Foreground = "#F9FAFB"
    $name.TextAlignment = "Right"
    $name.HorizontalAlignment = "Right"
    $name.FlowDirection = "RightToLeft"
    $name.TextWrapping = "Wrap"
    $name.MaxHeight = 42

    $badge = New-Object System.Windows.Controls.TextBlock
    $badge.Text = if ($p.RequiresAdmin -or $p.RunMode -eq "admin") { "مسؤول 🛡" } else { "عادي" }
    $badge.FontSize = 10
    $badge.Foreground = if ($p.RequiresAdmin -or $p.RunMode -eq "admin") { "#FBBF24" } else { "#93C5FD" }
    $badge.Margin = "0,1,0,0"
    $badge.TextAlignment = "Right"
    $badge.HorizontalAlignment = "Right"
    $badge.FlowDirection = "RightToLeft"

    $nameStack.Children.Add($name) | Out-Null
    $nameStack.Children.Add($badge) | Out-Null

    $desc = New-Object System.Windows.Controls.TextBlock
    $desc.Margin = "0,2,0,0"
    $desc.Foreground = "#CBD5E1"
    $desc.FontSize = 11
    $desc.TextWrapping = "Wrap"
    $desc.TextAlignment = "Right"
    $desc.HorizontalAlignment = "Stretch"
    $desc.FlowDirection = "RightToLeft"
    foreach ($part in [regex]::Matches([string]$p.Description, '[A-Za-z0-9][A-Za-z0-9 ._/+#-]*|[^A-Za-z0-9]+')) {
        if ([string]::IsNullOrEmpty($part.Value)) { continue }
        $run = New-Object System.Windows.Documents.Run
        $run.Text = $part.Value
        $run.FlowDirection = if ($part.Value -match '[A-Za-z0-9]') { "LeftToRight" } else { "RightToLeft" }
        $desc.Inlines.Add($run) | Out-Null
    }
    [System.Windows.Controls.Grid]::SetRow($desc, 1)
    [System.Windows.Controls.Grid]::SetColumnSpan($desc, 2)

    $category = New-Object System.Windows.Controls.TextBlock
    $category.Text = Get-HtpDisplayCategory $p.Category
    $category.FontSize = 10
    $category.Foreground = "#64748B"
    $category.Margin = "0,4,0,0"
    $category.TextAlignment = "Right"
    [System.Windows.Controls.Grid]::SetRow($category, 2)
    [System.Windows.Controls.Grid]::SetColumnSpan($category, 2)

    $grid.Children.Add($iconBox) | Out-Null
    $grid.Children.Add($nameStack) | Out-Null
    $grid.Children.Add($desc) | Out-Null
    $grid.Children.Add($category) | Out-Null

    $border.Child = $grid
    $item.Content = $border

    [void]$ToolList.Items.Add($item)
}

function Set-HtpVisibleScrollbars {
    param([System.Windows.DependencyObject]$Root)

    if ($null -eq $Root) { return }

    try {
        $Root.ApplyTemplate() | Out-Null
    }
    catch {}

    $count = 0
    try { $count = [System.Windows.Media.VisualTreeHelper]::GetChildrenCount($Root) }
    catch { $count = 0 }

    for ($i = 0; $i -lt $count; $i++) {
        $child = [System.Windows.Media.VisualTreeHelper]::GetChild($Root, $i)

        if ($child -is [System.Windows.Controls.Primitives.ScrollBar]) {
            $child.Width = 16
            $child.MinWidth = 16
            $child.Opacity = 1
            $child.Background = [System.Windows.Media.Brushes]::White
            $child.Foreground = [System.Windows.Media.Brushes]::DodgerBlue
        }

        if ($child -is [System.Windows.Controls.Primitives.Thumb]) {
            $child.Background = [System.Windows.Media.Brushes]::DodgerBlue
            $child.BorderBrush = [System.Windows.Media.Brushes]::MidnightBlue
            $child.BorderThickness = [System.Windows.Thickness]::new(1)
        }

        Set-HtpVisibleScrollbars -Root $child
    }
}


function Invoke-HtpSelectedToolDirect {
    param($Plugin)

    try {
        if ($null -eq $Plugin) { return }

        $script:SelectedPlugin = $Plugin

        if ($null -ne $StatusText) {
            $StatusText.Text = "جاري تشغيل: $($Plugin.name)"
        }

        if ($null -ne $RunButton) {
            $RunButton.RaiseEvent(
                [System.Windows.RoutedEventArgs]::new(
                    [System.Windows.Controls.Button]::ClickEvent
                )
            )
            return
        }

        Invoke-HtpGuiPlugin -Plugin $Plugin
    }
    catch {
        if ($null -ne $ResultBox) {
            $ResultBox.Text = "تعذر تشغيل الأداة مباشرة:`r`n$($_.Exception.Message)"
        }
    }
}

function Refresh-Tools {
    $ToolList.Items.Clear()

    $query = $SearchBox.Text

    if (-not [string]::IsNullOrWhiteSpace($query)) {
        $items = @($Plugins | Where-Object {
            $_.Name -like "*$query*" -or
            $_.Description -like "*$query*" -or
            $_.Category -like "*$query*" -or
            $_.Id -like "*$query*"
        } | Sort-Object Category, Name)

        $HeaderTitle.Text = "البحث"
        $HeaderSubtitle.Text = "نتائج البحث عن: $query"
    }
    else {
        $selectedCategory = Get-HtpSelectedCategoryText
        if ([string]::IsNullOrWhiteSpace($selectedCategory)) {
            return
        }

        $items = @($Plugins | Where-Object { (Get-HtpDisplayCategory $_.Category) -eq $selectedCategory } | Sort-Object Name)
        $HeaderTitle.Text = Get-HtpCleanHeaderTitle $selectedCategory
        if ($selectedCategory -eq "🏠 لوحة التحكم") {
            $HeaderSubtitle.Text = "لوحة واحدة تضم أدوات المراقبة والاختصارات السريعة."
        }
        else {
            $HeaderSubtitle.Text = "الأدوات المتاحة داخل هذا القسم."
        }
    }

    foreach ($p in $items) {
        Add-ToolCard $p
    }

    if ($ToolList.Items.Count -gt 0) {
        $ToolList.SelectedIndex = 0
    }

    $StatusText.Text = "الأدوات: $($ToolList.Items.Count)"
}

function Invoke-SelectedTool {
    if ($ToolList.SelectedItem -eq $null) {
        $OutputBox.Text = "اختر أداة أولاً."
        return
    }

    $plugin = $ToolList.SelectedItem.Tag

    if ($plugin.RequiresAdmin -or $plugin.RunMode -eq "admin") {
        $OutputBox.Text = "هذه الأداة تحتاج تشغيل كمسؤول. قد تظهر نافذة موافقة UAC..."
    }
    else {
        $OutputBox.Text = "جاري تشغيل: $($plugin.Name) ..."
    }

    try {
        $result = Invoke-HtpGuiPlugin -Plugin $plugin
        if (Get-Command Remove-HtpConsoleNoise -ErrorAction SilentlyContinue) { $result = Remove-HtpConsoleNoise $result }; $OutputBox.Text = $result
        $StatusText.Text = "تم تشغيل: $($plugin.Name)"
        $OutputBox.ScrollToEnd()
    }
    catch {
        $OutputBox.Text = "Error: $($_.Exception.Message)"
        $StatusText.Text = "حدث خطأ أثناء التشغيل."
    }
}

$CategoryList.Add_SelectionChanged({
    $SearchBox.Text = ""
    Refresh-Tools
})

$SearchBox.Add_TextChanged({
    Refresh-Tools
})

$RunButton.Add_Click({ Invoke-SelectedTool })
$ToolList.Add_MouseDoubleClick({ Invoke-SelectedTool })

$CopyButton.Add_Click({
    try {
        [System.Windows.Clipboard]::SetText($OutputBox.Text)
        $StatusText.Text = "تم نسخ النتيجة."
    }
    catch {
        $StatusText.Text = "تعذر نسخ النتيجة."
    }
})

$SaveButton.Add_Click({
    try {
        $outDir = Join-Path $script:HTP_ROOT "Reports\Results"
        if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
        $file = Join-Path $outDir ("result_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")
        $OutputBox.Text | Set-Content $file -Encoding UTF8
        $StatusText.Text = "تم حفظ النتيجة: $file"
    }
    catch {
        $StatusText.Text = "تعذر حفظ النتيجة: $($_.Exception.Message)"
    }
})

$ClearButton.Add_Click({
    $OutputBox.Text = ""
    $StatusText.Text = "تم مسح النتيجة."
})

$ExpandButton.Add_Click({
    $resultWindow = New-Object System.Windows.Window
    $resultWindow.Title = "عارض النتائج - QUHAIM Toolkit Pro"
    $resultWindow.Width = 900
    $resultWindow.Height = 620
    $resultWindow.MinWidth = 700
    $resultWindow.MinHeight = 420
    $resultWindow.WindowStartupLocation = "CenterOwner"
    $resultWindow.Owner = $Window
    $resultWindow.Background = "#0B1120"
    $resultWindow.FlowDirection = "RightToLeft"
    $resultWindow.FontFamily = "Segoe UI"

    $box = New-Object System.Windows.Controls.TextBox
    $box.Margin = "12"
    $box.Background = "#020617"
    $box.Foreground = "#D1D5DB"
    $box.BorderBrush = "#1F2937"
    $box.TextWrapping = "Wrap"
    $box.AcceptsReturn = $true
    $box.VerticalScrollBarVisibility = "Auto"
    $box.HorizontalScrollBarVisibility = "Auto"
    $box.IsReadOnly = $true
    $box.FlowDirection = "LeftToRight"
    $box.FontFamily = "Consolas"
    $box.FontSize = 12
    $box.Text = $OutputBox.Text
    $resultWindow.Content = $box
    [void]$resultWindow.ShowDialog()
})

$ExitButton.Add_Click({
    $Window.Close()
})

$ConsoleButton.Add_Click({
    $cmd = Join-Path $script:HTP_ROOT "QUHAIMToolkitPro.Console.cmd"
    if (Test-Path $cmd) {
        Start-Process -FilePath $cmd -WorkingDirectory $script:HTP_ROOT
    }
    else {
        $OutputBox.Text = "Console fallback launcher not found."
    }
})

Refresh-Tools

$Window.Add_Loaded({
    try {
        $Window.Dispatcher.InvokeAsync([Action]{
            Set-HtpVisibleScrollbars -Root $Window
        }, [System.Windows.Threading.DispatcherPriority]::ApplicationIdle) | Out-Null
    }
    catch {}
})

[void]$Window.ShowDialog()

# v0.4.5.24 Direct Card Run: automatic insertion marker not found.











