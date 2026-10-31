# Windows 11 Optimization Tool - LTR (Fixed version)

# ---------- Intro ASCII Art (CMD Only) ----------
if ($host.Name -eq 'ConsoleHost' -and $PSVersionTable.PSEdition -eq 'Desktop') {
    $asciiIntro = @'
LLLL                     TTTTTTTTTTTTTTT    RRRRRRRRRRRRRRR    
LLLL                         TTT        RRRR        RRRR  
LLLL                         TTT        RRRR        RRRR  
LLLL                         TTT        RRRR        RRRR  
LLLL                         TTT        RRRR        RRRR  
LLLL                         TTT        RRRR        RRRR  
LLLL                         TTT        RRRRRRRRRRRRRRRR  
LLLL                         TTT        RRRR    RRRR      
LLLL                         TTT        RRRR     RRRR     
LLLL                         TTT        RRRR      RRRR    
LLLLLLLLLLLLLLLL             TTT        RRRR       RRRR   
LLLLLLLLLLLLLLLL             TTT        RRRR        RRRR  
'@
    $host.UI.RawUI.WindowTitle = "LTR - Toolbox"
    Clear-Host
    Write-Host -ForegroundColor Cyan $asciiIntro
    Write-Host ""
    Write-Host "=====LTR Optimization====="
    Write-Host "====Windows Toolbox====="
    Write-Host ("[" + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') + "] [INFO] [UI] Starting the interface thread.")
    Start-Sleep -Seconds 1.5
}

# ---------- AUTO-ELEVATION ----------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
# >>> PUT YOUR PUBLIC LINK HERE (raw link of this file on GitHub). Needed for the 'irm ... | iex' launch.
$scriptUrl = 'https://raw.githubusercontent.com/LTR031/LTR-OPTI/refs/heads/main/LTR-Opti.ps1'

if (-not $isAdmin) {
    if ($PSCommandPath) {
        # Launched as a .ps1 file
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
        exit
    } elseif ($scriptUrl) {
        # Launched with: irm <link> | iex  (no file on disk): relaunch the same link as administrator
        $cmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm '$scriptUrl' | iex"
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"$cmd`"" -Verb RunAs
        exit
    } else {
        Write-Host "Please run PowerShell as Administrator, or set `$scriptUrl at the top of the script." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit
    }
}

$OutputEncoding = [System.Text.Encoding]::UTF8

try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()

    # ---------- Configuration File Management (JSON) ----------
    $baseDir = if ($PSScriptRoot) { $PSScriptRoot } else { Join-Path $env:APPDATA 'LTR-Opti' }
    if (-not (Test-Path $baseDir)) { New-Item -ItemType Directory -Path $baseDir -Force | Out-Null }
    $script:configPath = Join-Path $baseDir "config.json"

    function Load-Config {
        if (Test-Path $script:configPath) {
            try {
                return (Get-Content $script:configPath -Raw | ConvertFrom-Json)
            } catch { return $null }
        }
        return $null
    }

    function Save-Config {
        param($theme, $checks)
        $data = [PSCustomObject]@{
            Theme = $theme
            Checks = $checks
        }
        $data | ConvertTo-Json -Depth 5 | Out-File $script:configPath -Encoding utf8 -Force
    }

    $savedConfig = Load-Config

    # ---------- Themes & Colors Management ----------
    $script:themeActif = if ($savedConfig -and $savedConfig.Theme) { $savedConfig.Theme } else { "Neon Green" }

    function Set-ThemeColors($name) {
        $script:themeActif = $name
        switch ($name) {
            "Cyberpunk Blue" {
                $script:cNeon      = [System.Drawing.Color]::FromArgb(0, 200, 255)
                $script:cFonce     = [System.Drawing.Color]::FromArgb(0, 60, 90)
                $script:cMoyen     = [System.Drawing.Color]::FromArgb(0, 40, 60)
                $script:fondSombre = [System.Drawing.Color]::FromArgb(8, 14, 20)
                $script:fondCarte  = [System.Drawing.Color]::FromArgb(14, 24, 36)
            }
            "Synthwave Purple" {
                $script:cNeon      = [System.Drawing.Color]::FromArgb(210, 50, 255)
                $script:cFonce     = [System.Drawing.Color]::FromArgb(80, 0, 100)
                $script:cMoyen     = [System.Drawing.Color]::FromArgb(50, 0, 70)
                $script:fondSombre = [System.Drawing.Color]::FromArgb(14, 8, 18)
                $script:fondCarte  = [System.Drawing.Color]::FromArgb(24, 14, 32)
            }
            "Fire Red" {
                $script:cNeon      = [System.Drawing.Color]::FromArgb(255, 50, 50)
                $script:cFonce     = [System.Drawing.Color]::FromArgb(100, 0, 0)
                $script:cMoyen     = [System.Drawing.Color]::FromArgb(60, 0, 0)
                $script:fondSombre = [System.Drawing.Color]::FromArgb(18, 10, 10)
                $script:fondCarte  = [System.Drawing.Color]::FromArgb(32, 16, 16)
            }
            "Solar Yellow" {
                $script:cNeon      = [System.Drawing.Color]::FromArgb(255, 220, 0)
                $script:cFonce     = [System.Drawing.Color]::FromArgb(100, 80, 0)
                $script:cMoyen     = [System.Drawing.Color]::FromArgb(60, 50, 0)
                $script:fondSombre = [System.Drawing.Color]::FromArgb(18, 16, 8)
                $script:fondCarte  = [System.Drawing.Color]::FromArgb(32, 28, 12)
            }
            "Flash Pink" {
                $script:cNeon      = [System.Drawing.Color]::FromArgb(255, 20, 147)
                $script:cFonce     = [System.Drawing.Color]::FromArgb(110, 0, 60)
                $script:cMoyen     = [System.Drawing.Color]::FromArgb(70, 0, 40)
                $script:fondSombre = [System.Drawing.Color]::FromArgb(18, 8, 14)
                $script:fondCarte  = [System.Drawing.Color]::FromArgb(32, 14, 24)
            }
            default { # Neon Green
                $script:cNeon      = [System.Drawing.Color]::FromArgb(57, 255, 20)
                $script:cFonce     = [System.Drawing.Color]::FromArgb(0, 110, 40)
                $script:cMoyen     = [System.Drawing.Color]::FromArgb(0, 70, 30)
                $script:fondSombre = [System.Drawing.Color]::FromArgb(10, 14, 12)
                $script:fondCarte  = [System.Drawing.Color]::FromArgb(18, 28, 22)
            }
        }
    }
    Set-ThemeColors $script:themeActif

    # ---------- Main Window ----------
    $LARG = 700
    $HAUT = 800
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'LTR'
    $form.ClientSize = New-Object System.Drawing.Size($LARG, $HAUT)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = $script:fondSombre
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false
    $form.Opacity = 0.0

    # Double Buffer
    $prop = [System.Windows.Forms.Control].GetProperty('DoubleBuffered', [System.Reflection.BindingFlags]'Instance,NonPublic')
    $prop.SetValue($form, $true, $null)

    # ---------- Animation State ----------
    $script:rand = New-Object System.Random
    $script:temps = 0
    $script:eclairs = New-Object System.Collections.ArrayList

    # Fonts created ONCE (avoids GDI leak: they used to be recreated every frame)
    $script:fWatermark = New-Object System.Drawing.Font('Impact', 200, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $script:fTitle = New-Object System.Drawing.Font('Impact', 38, [System.Drawing.FontStyle]::Regular)
    $script:fSub = New-Object System.Drawing.Font('Consolas', 10)
    $script:sfCenter = New-Object System.Drawing.StringFormat
    $script:sfCenter.Alignment = 'Center'
    $script:sfCenter.LineAlignment = 'Center'

    function New-GdiPen($list, $color, $width) {
        $p = New-Object System.Drawing.Pen($color, $width)
        [void]$list.Add($p)
        return $p
    }

    function New-GdiBrush($list, $color) {
        $b = New-Object System.Drawing.SolidBrush($color)
        [void]$list.Add($b)
        return $b
    }

    function New-Lightning {
        $x = $script:rand.Next(40, $LARG - 40)
        $points = New-Object System.Collections.ArrayList
        $y = 130
        [void]$points.Add((New-Object System.Drawing.PointF($x, $y)))
        while ($y -lt $HAUT - 150) {
            $y += $script:rand.Next(18, 46)
            $x += $script:rand.Next(-28, 29)
            if ($x -lt 5) { $x = 5 }
            if ($x -gt $LARG - 5) { $x = $LARG - 5 }
            [void]$points.Add((New-Object System.Drawing.PointF($x, $y)))
        }
        return @{ Points = $points.ToArray(); Life = 0; Duration = $script:rand.Next(5, 10) }
    }

    # ---------- Background Painting ----------
    $form.Add_Paint({
        param($sender, $e)
        $g = $e.Graphics
        $g.SmoothingMode = 'AntiAlias'
        $g.TextRenderingHint = 'AntiAliasGridFit'

        $tmp = New-Object System.Collections.ArrayList
        try {
            $nr = $script:cNeon.R
            $ng = $script:cNeon.G
            $nb = $script:cNeon.B
            $pulse = [math]::Sin($script:temps / 8.0)

            # Subtle Grid
            $decal = ($script:temps * 0.6) % 30
            $pen = New-GdiPen $tmp ([System.Drawing.Color]::FromArgb(20, $nr, $ng, $nb)) 1
            for ($x = 0; $x -lt $LARG; $x += 30) { $g.DrawLine($pen, $x, 0, $x, $HAUT) }
            for ($y = -30; $y -lt $HAUT; $y += 30) { $g.DrawLine($pen, 0, ($y + $decal), $LARG, ($y + $decal)) }

            # LTR Watermark
            $alphaWatermark = [int](26 + 14 * $pulse)
            $brush = New-GdiBrush $tmp ([System.Drawing.Color]::FromArgb($alphaWatermark, $nr, $ng, $nb))
            $g.DrawString('LTR', $script:fWatermark, $brush, (New-Object System.Drawing.RectangleF(0, 130, $LARG, 400)), $script:sfCenter)

            # Lightnings
            foreach ($ec in $script:eclairs) {
                $force = 1.0 - ($ec.Life / [double]$ec.Duration)
                if ($force -lt 0) { $force = 0 }
                $a1 = [int](50 * $force)
                $a2 = [int](130 * $force)
                $a3 = [int](255 * $force)
                $penHalo  = New-GdiPen $tmp ([System.Drawing.Color]::FromArgb($a1, $nr, $ng, $nb)) 9
                $penMoyen = New-GdiPen $tmp ([System.Drawing.Color]::FromArgb($a2, $nr, $ng, $nb)) 4
                $penCoeur = New-GdiPen $tmp ([System.Drawing.Color]::FromArgb($a3, 255, 255, 255)) 1.5
                $penHalo.LineJoin = 'Round'; $penMoyen.LineJoin = 'Round'; $penCoeur.LineJoin = 'Round'
                $g.DrawLines($penHalo, $ec.Points)
                $g.DrawLines($penMoyen, $ec.Points)
                $g.DrawLines($penCoeur, $ec.Points)
            }

            # Top Banner
            $rectBanner = New-Object System.Drawing.Rectangle(0, 0, $LARG, 90)
            $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rectBanner, $script:cFonce, $script:fondSombre, 0.0)
            [void]$tmp.Add($gradient)
            $g.FillRectangle($gradient, $rectBanner)

            # Title
            $alphaGlow = [int](70 + 40 * $pulse)
            $glow = New-GdiBrush $tmp ([System.Drawing.Color]::FromArgb($alphaGlow, $nr, $ng, $nb))
            $solid = New-GdiBrush $tmp $script:cNeon
            $g.DrawString('LTR  OPTI', $script:fTitle, $glow, 22, 10)
            $g.DrawString('LTR  OPTI', $script:fTitle, $glow, 18, 6)
            $g.DrawString('LTR  OPTI', $script:fTitle, $solid, 20, 8)

            $subBrush = New-GdiBrush $tmp ([System.Drawing.Color]::FromArgb(200, $nr, $ng, $nb))
            $g.DrawString('Windows 11  //  One-click Optimization', $script:fSub, $subBrush, 24, 66)

            # Glowing Line
            $lineGlow = New-GdiPen $tmp ([System.Drawing.Color]::FromArgb(80, $nr, $ng, $nb)) 6
            $lineSolid = New-GdiPen $tmp $script:cNeon 2
            $g.DrawLine($lineGlow, 0, 90, $LARG, 90)
            $g.DrawLine($lineSolid, 0, 90, $LARG, 90)
            $px = ($script:temps * 9) % ($LARG + 200) - 100
            $dotBrush = New-GdiBrush $tmp ([System.Drawing.Color]::FromArgb(140, $nr, $ng, $nb))
            $g.FillEllipse($dotBrush, ($px - 40), 86, 80, 8)
        } finally {
            foreach ($o in $tmp) { $o.Dispose() }
        }
    })

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 30
    $timer.Add_Tick({
        if ($form.Opacity -lt 1.0) { $form.Opacity += 0.08 }
        $script:temps++
        for ($k = $script:eclairs.Count - 1; $k -ge 0; $k--) {
            $script:eclairs[$k].Life++
            if ($script:eclairs[$k].Life -ge $script:eclairs[$k].Duration) { $script:eclairs.RemoveAt($k) }
        }
        if ($script:eclairs.Count -lt 3 -and $script:rand.Next(0, 100) -lt 14) {
            [void]$script:eclairs.Add((New-Lightning))
        }
        $form.Invalidate()
    })
    $timer.Start()

    # FormClosing (controls are still alive here, unlike FormClosed)
    $form.Add_FormClosing({
        try {
            $checkedList = @()
            foreach ($c in $zoneTw.Controls) {
                if ($c -is [System.Windows.Forms.CheckBox] -and $c.Checked) { $checkedList += [string]$c.Tag }
            }
            Save-Config $script:themeActif $checkedList
        } catch {}
        $timer.Stop()
        $timer.Dispose()
    })

    # ---------- Progress Bar & Console Log ----------
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(18, 620)
    $progressBar.Size = New-Object System.Drawing.Size(($LARG - 36), 18)
    $progressBar.Style = 'Continuous'
    $form.Controls.Add($progressBar)

    $log = New-Object System.Windows.Forms.TextBox
    $log.Multiline = $true
    $log.ReadOnly = $true
    $log.ScrollBars = 'Vertical'
    $log.Font = New-Object System.Drawing.Font('Consolas', 9)
    $log.BackColor = [System.Drawing.Color]::FromArgb(5, 8, 10)
    $log.ForeColor = $script:cNeon
    $log.BorderStyle = 'FixedSingle'
    $log.Location = New-Object System.Drawing.Point(18, 642)
    $log.Size = New-Object System.Drawing.Size(($LARG - 36), 125)
    $form.Controls.Add($log)

    function Write-Log($text, $progVal = $null) {
        $log.AppendText("[" + (Get-Date -Format 'HH:mm:ss') + "] > " + $text + "`r`n")
        if ($progVal -ne $null) {
            if ($progVal -gt 100) { $progVal = 100 }
            if ($progVal -lt 0) { $progVal = 0 }
            $progressBar.Value = $progVal
        }
        [System.Windows.Forms.Application]::DoEvents()
    }

    function Run-Action($name, [scriptblock]$action) {
        Write-Log "Starting: $name" 10
        $form.Cursor = 'WaitCursor'
        try {
            & $action
            Write-Log "Completed: $name" 100
        } catch {
            Write-Log "Error in $name : $($_.Exception.Message)" 100
        }
        $form.Cursor = 'Default'
        Write-Log '----------------------------------------'
    }

    function Clear-Folder($path) {
        if (Test-Path $path) {
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Registry helper: uses reg.exe and THROWS if it fails (so errors are really reported)
    # Path format must be like HKLM\SOFTWARE\... (no colon)
    # If the admin account used for elevation is NOT the logged-in user, HKCU would point to the
    # wrong profile. In that case we redirect HKCU writes to the real user's hive (HKU\<SID>).
    $script:userSid = $null
    try {
        $exp = Get-CimInstance Win32_Process -Filter "Name='explorer.exe'" | Select-Object -First 1
        if ($exp) {
            $owner = Invoke-CimMethod -InputObject $exp -MethodName GetOwner
            if ($owner.User) {
                $acct = New-Object System.Security.Principal.NTAccount($owner.Domain, $owner.User)
                $sidValue = $acct.Translate([System.Security.Principal.SecurityIdentifier]).Value
                $meValue = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
                if ($sidValue -ne $meValue) { $script:userSid = $sidValue }
            }
        }
    } catch {}

    function Set-Reg {
        param([string]$Path, [string]$Name, $Value, [string]$Type = 'REG_DWORD')
        if ($script:userSid -and $Path -like 'HKCU\*') {
            $Path = 'HKU\' + $script:userSid + $Path.Substring(4)
        }
        $out = & reg.exe add $Path /v $Name /t $Type /d "$Value" /f 2>&1
        if ($LASTEXITCODE -ne 0) { throw "reg add failed for '$Name' in '$Path' : $out" }

        # Read the value back: a tweak is only OK if Windows really holds the new value
        $q = & reg.exe query $Path /v $Name 2>&1
        $pattern = '^\s+' + [regex]::Escape($Name) + '\s+REG_\w+\s*'
        $line = $q | Where-Object { "$_" -match $pattern } | Select-Object -First 1
        if (-not $line) { throw "value '$Name' not found after writing in '$Path'" }
        $raw = ("$line" -replace $pattern, '').Trim()
        if ($Type -eq 'REG_DWORD') {
            $ok = ([Convert]::ToInt64($raw.Replace('0x', ''), 16) -eq [int64]$Value)
        } else {
            $ok = ($raw -eq "$Value")
        }
        if (-not $ok) { throw "'$Name' is '$raw' instead of '$Value' in '$Path'" }
        Write-Log "   reg: $Name = $Value (verified)"
    }

    # Reads a registry value (same HKCU redirection as Set-Reg). Returns text or '(not set)'
    function Get-Reg {
        param([string]$Path, [string]$Name)
        if ($script:userSid -and $Path -like 'HKCU\*') {
            $Path = 'HKU\' + $script:userSid + $Path.Substring(4)
        }
        $q = & reg.exe query $Path /v $Name 2>&1
        $pattern = '^\s+' + [regex]::Escape($Name) + '\s+REG_\w+\s*'
        $line = $q | Where-Object { "$_" -match $pattern } | Select-Object -First 1
        if (-not $line) { return '(not set)' }
        $raw = ("$line" -replace $pattern, '').Trim()
        if ("$line" -match '\sREG_DWORD\s') {
            try { return [string][Convert]::ToInt64($raw.Replace('0x', ''), 16) } catch { return $raw }
        }
        return $raw
    }

    function Get-FreeGB {
        $d = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'"
        return [math]::Round($d.FreeSpace / 1GB, 2)
    }

    function Get-FolderMB($p) {
        $s = (Get-ChildItem -Path $p -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $s) { $s = 0 }
        return [math]::Round($s / 1MB, 1)
    }

    # Runs an external program without freezing the window
    function Invoke-External($file, $arguments, [bool]$visible = $false) {
        $style = if ($visible) { 'Normal' } else { 'Hidden' }
        $p = Start-Process -FilePath $file -ArgumentList $arguments -WindowStyle $style -PassThru
        while (-not $p.HasExited) {
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 100
        }
        return $p.ExitCode
    }

    # ---------- Categorized Downloads Dictionary ----------
    # Version-specific links replaced by official pages (they never expire)
    $downloadsCategories = [ordered]@{
        "Browsers" = [ordered]@{
            'Google Chrome'   = 'https://dl.google.com/chrome/install/ChromeStandaloneSetup64.exe'
            'Mozilla Firefox' = 'https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US'
            'Brave Browser'   = 'https://laptop-updates.brave.com/latest/winx64'
            'Opera GX'        = 'https://www.opera.com/gx'
            'Vivaldi'         = 'https://vivaldi.com/download/'
            'Tor Browser'     = 'https://www.torproject.org/download/'
        }
        "Gaming & Launchers" = [ordered]@{
            'Steam'               = 'https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe'
            'Epic Games Launcher' = 'https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi'
            'Battle.net'          = 'https://www.battle.net/download/getInstaller?os=win'
            'EA App'              = 'https://www.ea.com/ea-app'
            'Ubisoft Connect'     = 'https://ubisoftconnect.com/'
            'GOG Galaxy'          = 'https://www.gog.com/galaxy'
            'Riot Client'         = 'https://www.riotgames.com/'
            'Prism Launcher'      = 'https://prismlauncher.org/download/windows/'
        }
        "Communication & Chat" = [ordered]@{
            'Discord'             = 'https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x64'
            'Telegram'            = 'https://telegram.org/dl/desktop/win64'
            'WhatsApp'            = 'https://www.whatsapp.com/download'
            'Signal'              = 'https://signal.org/download/windows/'
            'Zoom'                = 'https://zoom.us/client/latest/ZoomInstaller.exe'
            'Teams'               = 'https://www.microsoft.com/microsoft-teams/download-app'
        }
        "Multimedia & Streaming" = [ordered]@{
            'Spotify'             = 'https://download.scdn.co/SpotifySetup.exe'
            'VLC Media Player'    = 'https://www.videolan.org/vlc/download-windows.html'
            'OBS Studio'          = 'https://obsproject.com/download'
            'Audacity'            = 'https://www.audacityteam.org/download/'
            'Handbrake'           = 'https://handbrake.fr/downloads.php'
            'Stremio'             = 'https://www.stremio.com/downloads'
            'AIMP'                = 'https://www.aimp.ru/?do=download'
        }
        "Utilities & Tools" = [ordered]@{
            'WinRAR'              = 'https://www.win-rar.com/download-winrar.html?L=10'
            '7-Zip'               = 'https://www.7-zip.org/download.html'
            'Revo Uninstaller'    = 'https://www.revouninstaller.com/revo-uninstaller-free-download/'
            'BleachBit'           = 'https://www.bleachbit.org/download/windows'
            'ShareX'              = 'https://getsharex.com/'
            'PowerToys'           = 'https://github.com/microsoft/PowerToys/releases/latest'
            'Rufus'               = 'https://rufus.ie/'
        }
        "Development & Code" = [ordered]@{
            'Visual Studio Code'  = 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user'
            'Notepad++'           = 'https://notepad-plus-plus.org/downloads/'
            'Git'                 = 'https://git-scm.com/download/win'
            'Python'              = 'https://www.python.org/downloads/windows/'
            'Docker Desktop'      = 'https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe'
            'Postman'             = 'https://dl.pstmn.io/download/latest/win64'
            'PuTTY'               = 'https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html'
        }
        "Hardware & Monitoring" = [ordered]@{
            'HWiNFO'              = 'https://www.hwinfo.com/download/'
            'MSI Afterburner'     = 'https://www.msi.com/Landing/afterburner/graphics-cards'
            'CPU-Z'               = 'https://www.cpuid.com/softwares/cpu-z.html'
            'GPU-Z'               = 'https://www.techpowerup.com/download/techpowerup-gpu-z/'
            'CrystalDiskInfo'     = 'https://crystalmark.info/en/software/crystaldiskinfo/'
        }
    }

    # ---------- 5 Tabs ----------
    function New-TabButton($text, $x, $width) {
        $b = New-Object System.Windows.Forms.Button
        $b.Text = $text
        $b.Size = New-Object System.Drawing.Size($width, 34)
        $b.Location = New-Object System.Drawing.Point($x, 98)
        $b.FlatStyle = 'Flat'
        $b.FlatAppearance.BorderSize = 2
        $b.FlatAppearance.BorderColor = $script:cNeon
        $b.FlatAppearance.MouseOverBackColor = $script:cFonce
        $b.BackColor = $script:fondCarte
        $b.ForeColor = $script:cNeon
        $b.Font = New-Object System.Drawing.Font('Segoe UI', 8.5, [System.Drawing.FontStyle]::Bold)
        $b.Cursor = 'Hand'
        return $b
    }

    $ongletTw     = New-TabButton 'TWEAKS' 18 128
    $ongletJeux   = New-TabButton 'GAME-BOOST' 150 128
    $ongletSpecs  = New-TabButton 'PC SPECS' 282 128
    $ongletGuide  = New-TabButton 'GUIDE' 414 128
    $ongletDl     = New-TabButton 'DOWNLOADS' 546 136

    $form.Controls.Add($ongletTw)
    $form.Controls.Add($ongletJeux)
    $form.Controls.Add($ongletSpecs)
    $form.Controls.Add($ongletGuide)
    $form.Controls.Add($ongletDl)

    $script:currentTab = 'tw'

    function Switch-Tab($name) {
        $script:currentTab = $name
        $zoneTw.Visible     = ($name -eq 'tw')
        $zoneJeux.Visible   = ($name -eq 'jeux')
        $zoneSpecs.Visible  = ($name -eq 'specs')
        $zoneGuide.Visible  = ($name -eq 'guide')
        $zoneDl.Visible     = ($name -eq 'dl')
        foreach ($pair in @(@($ongletTw, 'tw'), @($ongletJeux, 'jeux'), @($ongletSpecs, 'specs'), @($ongletGuide, 'guide'), @($ongletDl, 'dl'))) {
            if ($pair[1] -eq $name) {
                $pair[0].BackColor = $script:cFonce; $pair[0].ForeColor = [System.Drawing.Color]::White
            } else {
                $pair[0].BackColor = $script:fondCarte; $pair[0].ForeColor = $script:cNeon
            }
        }
    }

    # ---------- Content Panels ----------
    $zoneTw     = New-Object System.Windows.Forms.Panel
    $zoneJeux   = New-Object System.Windows.Forms.Panel
    $zoneSpecs  = New-Object System.Windows.Forms.Panel
    $zoneGuide  = New-Object System.Windows.Forms.Panel
    $zoneDl     = New-Object System.Windows.Forms.Panel

    foreach ($z in @($zoneTw, $zoneJeux, $zoneSpecs, $zoneGuide, $zoneDl)) {
        $z.Location = New-Object System.Drawing.Point(0, 140)
        $z.Size = New-Object System.Drawing.Size(($LARG), 475)
        $z.AutoScroll = $true
        $z.Visible = $false
        $form.Controls.Add($z)
    }

    $ongletTw.Add_Click({ Switch-Tab 'tw' })
    $ongletJeux.Add_Click({
        Switch-Tab 'jeux'
        Refresh-ProcessList ""
    })
    $ongletSpecs.Add_Click({ Switch-Tab 'specs' })
    $ongletGuide.Add_Click({ Switch-Tab 'guide' })
    $ongletDl.Add_Click({
        Switch-Tab 'dl'
        Refresh-DownloadList $txtSearchDl.Text.Trim()
    })
    Switch-Tab 'tw'

    # Signature
    $sign = New-Object System.Windows.Forms.Label
    $sign.Text = 'made by LTR'
    $sign.ForeColor = $script:cMoyen
    $sign.BackColor = [System.Drawing.Color]::Transparent
    $sign.Font = New-Object System.Drawing.Font('Consolas', 8)
    $sign.AutoSize = $true
    $sign.Location = New-Object System.Drawing.Point(($LARG - 90), ($HAUT - 16))
    $form.Controls.Add($sign)
    $sign.BringToFront()

    # Theme Selector Menu
    $lblTheme = New-Object System.Windows.Forms.Label
    $lblTheme.Text = "Theme:"
    $lblTheme.ForeColor = $script:cNeon
    $lblTheme.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
    $lblTheme.Location = New-Object System.Drawing.Point(475, 12)
    $lblTheme.AutoSize = $true
    $zoneTw.Controls.Add($lblTheme)

    $comboTheme = New-Object System.Windows.Forms.ComboBox
    $comboTheme.Location = New-Object System.Drawing.Point(530, 9)
    $comboTheme.Size = New-Object System.Drawing.Size(135, 24)
    $comboTheme.DropDownStyle = 'DropDownList'
    $comboTheme.Items.AddRange(@("Neon Green", "Cyberpunk Blue", "Synthwave Purple", "Fire Red", "Solar Yellow", "Flash Pink"))
    $comboTheme.SelectedItem = $script:themeActif

    $comboTheme.Add_SelectedIndexChanged({
        Set-ThemeColors $comboTheme.SelectedItem
        $form.BackColor = $script:fondSombre
        $log.ForeColor = $script:cNeon
        $sign.ForeColor = $script:cMoyen
        $lblTheme.ForeColor = $script:cNeon
        $lblPreset.ForeColor = $script:cNeon
        $lblSpecsTitle.ForeColor = $script:cNeon
        $lblGuideTitle.ForeColor = $script:cNeon
        $lblDlTitle.ForeColor = $script:cNeon
        $lblJeuxTitle.ForeColor = $script:cNeon
        $lblSearchDl.ForeColor = $script:cNeon
        $txtSearchDl.ForeColor = $script:cNeon
        $txtSpecsBox.ForeColor = $script:cNeon
        $guideBox.ForeColor = $script:cNeon
        $procListBox.ForeColor = $script:cNeon

        foreach ($ctrl in $zoneTw.Controls) {
            if ($ctrl -is [System.Windows.Forms.CheckBox]) { $ctrl.ForeColor = $script:cNeon }
        }

        foreach ($b in @($btnRec, $btnAll, $btnClr, $btnExp, $btnImp, $btnApplyTw, $btnGetSpecs, $btnRefreshProc, $btnHighPriority, $btnKillProc)) {
            if ($b) {
                $b.BackColor = $script:fondCarte
                $b.FlatAppearance.BorderColor = $script:cNeon
                $b.ForeColor = $script:cNeon
                $b.FlatAppearance.MouseOverBackColor = $script:cFonce
            }
        }
        foreach ($tabBtn in @($ongletTw, $ongletJeux, $ongletSpecs, $ongletGuide, $ongletDl)) {
            if ($tabBtn) {
                $tabBtn.FlatAppearance.BorderColor = $script:cNeon
                $tabBtn.FlatAppearance.MouseOverBackColor = $script:cFonce
            }
        }
        # Re-apply colors of the active tab button + rebuild download list with new colors
        Switch-Tab $script:currentTab
        Refresh-DownloadList $txtSearchDl.Text.Trim()
        $form.Invalidate()
        Write-Log "Theme applied live: $($comboTheme.SelectedItem)"
    })
    $zoneTw.Controls.Add($comboTheme)

    # ---------- TWEAKS Tab ----------
    $lblPreset = New-Object System.Windows.Forms.Label
    $lblPreset.Text = "Presets:"
    $lblPreset.ForeColor = $script:cNeon
    $lblPreset.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
    $lblPreset.Location = New-Object System.Drawing.Point(12, 12)
    $lblPreset.AutoSize = $true
    $zoneTw.Controls.Add($lblPreset)

    function New-PresetButton($text, $x, $width) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $text
        $btn.Size = New-Object System.Drawing.Size($width, 26)
        $btn.Location = New-Object System.Drawing.Point($x, 8)
        $btn.FlatStyle = 'Flat'
        $btn.FlatAppearance.BorderColor = $script:cNeon
        $btn.FlatAppearance.BorderSize = 1
        $btn.BackColor = $script:fondCarte
        $btn.ForeColor = $script:cNeon
        $btn.Font = New-Object System.Drawing.Font('Segoe UI', 7.5, [System.Drawing.FontStyle]::Bold)
        $btn.Cursor = 'Hand'
        return $btn
    }

    # Exact names (BitLocker removed from this preset: it decrypts the whole drive)
    $script:recommendedList = @(
        'Activity History - Disable',
        'ConsumerFeatures - Disable',
        'Delivery Optimization - Disable',
        'Disk Cleanup - Real Clean',
        'End Task With Right Click - Enable',
        'File Explorer Automatic Folder Discovery - Disable',
        'Hibernation - Disable',
        'Location Tracking - Disable',
        'Restore Point - Create',
        'Services - Set to Manual',
        'Telemetry - Disable',
        'Temporary Files - Remove',
        'Widgets - Remove',
        'Microsoft OneDrive - Remove',
        'Dark Theme for Windows',
        'Enable Long Paths',
        'Game Mode',
        'Logon Screen Acrylic Blur - Disable',
        'Start Menu Bing Search - Disable',
        'Start Menu Recommendations - Disable',
        'Window Snapping'
    )

    $btnRec = New-PresetButton "Recommended" 70 95
    $btnRec.Add_Click({
        foreach ($c in $zoneTw.Controls) {
            if ($c -is [System.Windows.Forms.CheckBox]) {
                $c.Checked = ($script:recommendedList -contains [string]$c.Tag)
            }
        }
    })
    $zoneTw.Controls.Add($btnRec)

    $btnAll = New-PresetButton "Select All" 170 70
    $btnAll.Add_Click({
        foreach ($c in $zoneTw.Controls) { if ($c -is [System.Windows.Forms.CheckBox]) { $c.Checked = $true } }
    })
    $zoneTw.Controls.Add($btnAll)

    $btnClr = New-PresetButton "Clear" 245 52
    $btnClr.Add_Click({
        foreach ($c in $zoneTw.Controls) { if ($c -is [System.Windows.Forms.CheckBox]) { $c.Checked = $false } }
    })
    $zoneTw.Controls.Add($btnClr)

    $btnExp = New-PresetButton "Export" 302 48
    $btnExp.Add_Click({
        $dialog = New-Object System.Windows.Forms.SaveFileDialog
        $dialog.Filter = "JSON files (*.json)|*.json"
        if ($dialog.ShowDialog() -eq 'OK') {
            $checkedList = @()
            foreach ($c in $zoneTw.Controls) { if ($c -is [System.Windows.Forms.CheckBox] -and $c.Checked) { $checkedList += [string]$c.Tag } }
            ConvertTo-Json -InputObject $checkedList | Out-File $dialog.FileName -Encoding utf8
            Write-Log "Profile exported successfully!"
        }
    })
    $zoneTw.Controls.Add($btnExp)

    $btnImp = New-PresetButton "Import" 355 48
    $btnImp.Add_Click({
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = "JSON files (*.json)|*.json"
        if ($dialog.ShowDialog() -eq 'OK') {
            try {
                $importData = @(Get-Content $dialog.FileName -Raw | ConvertFrom-Json)
                foreach ($c in $zoneTw.Controls) {
                    if ($c -is [System.Windows.Forms.CheckBox]) { $c.Checked = ($importData -contains [string]$c.Tag) }
                }
                Write-Log "Profile imported successfully!"
            } catch {
                Write-Log "Import failed: invalid file."
            }
        }
    })
    $zoneTw.Controls.Add($btnImp)

    $sep = New-Object System.Windows.Forms.Label
    $sep.BorderStyle = 'Fixed3D'
    $sep.Location = New-Object System.Drawing.Point(18, 40)
    $sep.Size = New-Object System.Drawing.Size(645, 2)
    $zoneTw.Controls.Add($sep)

    # ---------- TWEAKS ENGINE ----------
    $tweaksList = [ordered]@{
        "Activity History - Disable" = {
            Set-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 0
            Set-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities' 0
            Set-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'UploadUserActivities' 0
        }
        "BitLocker - Disable" = {
            if (Get-Command Disable-BitLocker -ErrorAction SilentlyContinue) {
                Disable-BitLocker -MountPoint "$env:SystemDrive" -ErrorAction Stop | Out-Null
            } else {
                Write-Log "BitLocker module not available on this Windows edition."
            }
        }
        "ConsumerFeatures - Disable" = {
            Set-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'ContentDeliveryAllowed' 0
            Set-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
        }
        "Delivery Optimization - Disable" = {
            # Policy method: the service key itself is protected and cannot be edited
            Set-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 0
        }
        "Disk Cleanup - Real Clean" = {
            Clear-Folder "$env:TEMP"
            Clear-Folder "$env:SystemRoot\Temp"
            Write-Log "Opening Windows Disk Cleanup: tick what you want to clean, then click OK..."
            [void](Invoke-External 'cleanmgr.exe' '/sageset:1' $true)
            Write-Log "Running Disk Cleanup (progress window)..."
            [void](Invoke-External 'cleanmgr.exe' '/sagerun:1' $true)
            Write-Log "Running component cleanup (can take a few minutes)..."
            [void](Invoke-External 'dism.exe' '/Online /Cleanup-Image /StartComponentCleanup')
        }
        "End Task With Right Click - Enable" = {
            Set-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' 'TaskbarEndTask' 1
        }
        "File Explorer Automatic Folder Discovery - Disable" = {
            $hk = if ($script:userSid) { "Registry::HKEY_USERS\$($script:userSid)" } else { 'HKCU:' }
            Remove-Item "$hk\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item "$hk\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" -Recurse -Force -ErrorAction SilentlyContinue
            Set-Reg 'HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' 'FolderType' 'NotSpecified' 'REG_SZ'
        }
        "Hibernation - Disable" = {
            [void](Invoke-External 'powercfg.exe' '/hibernate off')
        }
        "Location Tracking - Disable" = {
            Set-Reg 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}' 'SensorPermissionState' 0
        }
        "Restore Point - Create" = {
            # Windows normally refuses a new restore point if one was made in the last 24h
            Set-Reg 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' 'SystemRestorePointCreationFrequency' 0
            Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
            Checkpoint-Computer -Description "LTR_Opti_RestorePoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        }
        "Services - Set to Manual" = {
            Set-Service 'DiagTrack' -StartupType Manual -ErrorAction Stop
        }
        "Telemetry - Disable" = {
            Set-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
            Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
        }
        "Temporary Files - Remove" = {
            Clear-Folder $env:TEMP
            Clear-Folder "$env:SystemRoot\Temp"
        }
        "Widgets - Remove" = {
            Get-AppxPackage -AllUsers *WebExperience* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        }
        "Microsoft OneDrive - Remove" = {
            Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
            $od = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
            if (-not (Test-Path $od)) { $od = "$env:SystemRoot\System32\OneDriveSetup.exe" }
            if (Test-Path $od) {
                [void](Invoke-External $od '/uninstall')
            } else {
                Write-Log "OneDrive setup not found (already removed?)."
            }
        }
        "Background Apps - Disable" = {
            Set-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1
        }
        "Dark Theme for Windows" = {
            Set-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' 0
            Set-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' 0
        }
        "Enable Long Paths" = {
            Set-Reg 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled' 1
        }
        "Game Mode" = {
            Set-Reg 'HKCU\Software\Microsoft\GameBar' 'AutoGameModeEnabled' 1
        }
        "Mouse Acceleration - Disable" = {
            Set-Reg 'HKCU\Control Panel\Mouse' 'MouseSpeed' 0 'REG_SZ'
            Set-Reg 'HKCU\Control Panel\Mouse' 'MouseThreshold1' 0 'REG_SZ'
            Set-Reg 'HKCU\Control Panel\Mouse' 'MouseThreshold2' 0 'REG_SZ'
        }
        "Window Snapping" = {
            Set-Reg 'HKCU\Control Panel\Desktop' 'WindowArrangementActive' 1 'REG_SZ'
        }
        "Logon Screen Acrylic Blur - Disable" = {
            Set-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'DisableAcrylicBackgroundOnLogon' 1
        }
        "Start Menu Bing Search - Disable" = {
            Set-Reg 'HKCU\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
        }
        "Start Menu Recommendations - Disable" = {
            Set-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' 0
        }
    }

    # ---------- STATE CHECKS (read BEFORE and AFTER each tweak to prove it changed) ----------
    $tweaksCheck = @{
        "Activity History - Disable" = { "EnableActivityFeed=" + (Get-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed') }
        "BitLocker - Disable" = {
            try { "Protection: " + (Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction Stop).ProtectionStatus } catch { "BitLocker not available" }
        }
        "ConsumerFeatures - Disable" = { "DisableConsumerFeatures=" + (Get-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures') }
        "Delivery Optimization - Disable" = { "DODownloadMode=" + (Get-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode') }
        "Disk Cleanup - Real Clean" = { "Free: " + (Get-FreeGB) + " GB, TEMP: " + (Get-FolderMB $env:TEMP) + " MB" }
        "End Task With Right Click - Enable" = { "TaskbarEndTask=" + (Get-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' 'TaskbarEndTask') }
        "File Explorer Automatic Folder Discovery - Disable" = { "FolderType=" + (Get-Reg 'HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' 'FolderType') }
        "Hibernation - Disable" = { "HibernateEnabled=" + (Get-Reg 'HKLM\SYSTEM\CurrentControlSet\Control\Power' 'HibernateEnabled') }
        "Location Tracking - Disable" = { "SensorPermissionState=" + (Get-Reg 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}' 'SensorPermissionState') }
        "Restore Point - Create" = {
            try { "Restore points: " + @(Get-ComputerRestorePoint -ErrorAction Stop).Count } catch { "Restore points: 0" }
        }
        "Services - Set to Manual" = { "DiagTrack start type: " + (Get-Service DiagTrack -ErrorAction SilentlyContinue).StartType }
        "Telemetry - Disable" = { "AllowTelemetry=" + (Get-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry') + ", DiagTrack: " + (Get-Service DiagTrack -ErrorAction SilentlyContinue).StartType }
        "Temporary Files - Remove" = { "TEMP folder: " + (Get-FolderMB $env:TEMP) + " MB" }
        "Widgets - Remove" = {
            if (@(Get-AppxPackage -AllUsers *WebExperience* -ErrorAction SilentlyContinue).Count -gt 0) { "Widgets: installed" } else { "Widgets: removed" }
        }
        "Microsoft OneDrive - Remove" = {
            if ((Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe") -or (Test-Path "$env:ProgramFiles\Microsoft OneDrive\OneDrive.exe") -or (Test-Path "${env:ProgramFiles(x86)}\Microsoft OneDrive\OneDrive.exe")) { "OneDrive: installed" } else { "OneDrive: removed" }
        }
        "Background Apps - Disable" = { "GlobalUserDisabled=" + (Get-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled') }
        "Dark Theme for Windows" = { "Apps=" + (Get-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme') + ", System=" + (Get-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme') + " (0 = dark)" }
        "Enable Long Paths" = { "LongPathsEnabled=" + (Get-Reg 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled') }
        "Game Mode" = { "AutoGameModeEnabled=" + (Get-Reg 'HKCU\Software\Microsoft\GameBar' 'AutoGameModeEnabled') }
        "Mouse Acceleration - Disable" = { "Speed=" + (Get-Reg 'HKCU\Control Panel\Mouse' 'MouseSpeed') + ", T1=" + (Get-Reg 'HKCU\Control Panel\Mouse' 'MouseThreshold1') + ", T2=" + (Get-Reg 'HKCU\Control Panel\Mouse' 'MouseThreshold2') }
        "Window Snapping" = { "WindowArrangementActive=" + (Get-Reg 'HKCU\Control Panel\Desktop' 'WindowArrangementActive') }
        "Logon Screen Acrylic Blur - Disable" = { "DisableAcrylicOnLogon=" + (Get-Reg 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'DisableAcrylicBackgroundOnLogon') }
        "Start Menu Bing Search - Disable" = { "DisableSearchBoxSuggestions=" + (Get-Reg 'HKCU\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions') }
        "Start Menu Recommendations - Disable" = { "Start_IrisRecommendations=" + (Get-Reg 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations') }
    }

    # ---------- RESULTS WINDOW (before / after proof) ----------
    function Show-Results($results) {
        $lines = @()
        foreach ($r in $results) {
            $lines += ("[{0}] {1} | before: {2} | after: {3}" -f $r.Status, $r.Tweak, $r.Before, $r.After)
        }
        $script:lastReport = ($lines -join "`r`n")

        $rf = New-Object System.Windows.Forms.Form
        $rf.Text = 'LTR - Tweak results (before / after)'
        $rf.StartPosition = 'CenterParent'
        $rf.ClientSize = New-Object System.Drawing.Size(960, 470)
        $rf.BackColor = $script:fondSombre
        $rf.FormBorderStyle = 'FixedDialog'
        $rf.MaximizeBox = $false
        $rf.MinimizeBox = $false

        $lv = New-Object System.Windows.Forms.ListView
        $lv.View = 'Details'
        $lv.FullRowSelect = $true
        $lv.GridLines = $true
        $lv.HideSelection = $false
        $lv.Location = New-Object System.Drawing.Point(12, 12)
        $lv.Size = New-Object System.Drawing.Size(936, 400)
        $lv.BackColor = [System.Drawing.Color]::FromArgb(5, 8, 10)
        $lv.ForeColor = $script:cNeon
        $lv.Font = New-Object System.Drawing.Font('Consolas', 9)
        [void]$lv.Columns.Add('Tweak', 250)
        [void]$lv.Columns.Add('Before', 280)
        [void]$lv.Columns.Add('After', 280)
        [void]$lv.Columns.Add('Status', 110)

        foreach ($r in $results) {
            $it = New-Object System.Windows.Forms.ListViewItem([string]$r.Tweak)
            [void]$it.SubItems.Add([string]$r.Before)
            [void]$it.SubItems.Add([string]$r.After)
            [void]$it.SubItems.Add([string]$r.Status)
            if ($r.Status -eq 'CHANGED') { $it.ForeColor = [System.Drawing.Color]::FromArgb(80, 255, 80) }
            elseif ($r.Status -eq 'FAILED') { $it.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80) }
            else { $it.ForeColor = [System.Drawing.Color]::FromArgb(255, 220, 0) }
            [void]$lv.Items.Add($it)
        }
        $rf.Controls.Add($lv)

        $btnCopy = New-Object System.Windows.Forms.Button
        $btnCopy.Text = 'Copy report'
        $btnCopy.Location = New-Object System.Drawing.Point(12, 422)
        $btnCopy.Size = New-Object System.Drawing.Size(150, 34)
        $btnCopy.FlatStyle = 'Flat'
        $btnCopy.FlatAppearance.BorderColor = $script:cNeon
        $btnCopy.BackColor = $script:fondCarte
        $btnCopy.ForeColor = $script:cNeon
        $btnCopy.Add_Click({
            try { [System.Windows.Forms.Clipboard]::SetText($script:lastReport) } catch {}
        })
        $rf.Controls.Add($btnCopy)

        $btnClose = New-Object System.Windows.Forms.Button
        $btnClose.Text = 'Close'
        $btnClose.Location = New-Object System.Drawing.Point(798, 422)
        $btnClose.Size = New-Object System.Drawing.Size(150, 34)
        $btnClose.FlatStyle = 'Flat'
        $btnClose.FlatAppearance.BorderColor = $script:cNeon
        $btnClose.BackColor = $script:fondCarte
        $btnClose.ForeColor = $script:cNeon
        $btnClose.Add_Click({ $this.FindForm().Close() })
        $rf.Controls.Add($btnClose)

        [void]$rf.ShowDialog($form)
        $rf.Dispose()
    }

    $posY = 50
    $posX = 20
    foreach ($tName in $tweaksList.Keys) {
        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Text = $tName
        $chk.Tag = $tName
        $chk.ForeColor = $script:cNeon
        $chk.Font = New-Object System.Drawing.Font('Segoe UI', 9)
        $chk.AutoSize = $true
        $chk.Location = New-Object System.Drawing.Point($posX, $posY)
        if ($savedConfig -and ($savedConfig.Checks -contains $tName)) {
            $chk.Checked = $true
        }
        $zoneTw.Controls.Add($chk)

        $posY += 28
        if ($posY -gt 400) {
            $posY = 50
            $posX += 330
        }
    }

    $btnApplyTw = New-Object System.Windows.Forms.Button
    $btnApplyTw.Text = "RUN SELECTED TWEAKS"
    $btnApplyTw.Location = New-Object System.Drawing.Point(18, 430)
    $btnApplyTw.Size = New-Object System.Drawing.Size(646, 32)
    $btnApplyTw.FlatStyle = 'Flat'
    $btnApplyTw.FlatAppearance.BorderColor = $script:cNeon
    $btnApplyTw.BackColor = $script:fondCarte
    $btnApplyTw.ForeColor = $script:cNeon
    $btnApplyTw.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
    $btnApplyTw.Cursor = 'Hand'
    $btnApplyTw.Add_Click({
        $selected = @()
        foreach ($c in $zoneTw.Controls) {
            if ($c -is [System.Windows.Forms.CheckBox] -and $c.Checked) { $selected += [string]$c.Tag }
        }
        if ($selected.Count -eq 0) {
            [void][System.Windows.Forms.MessageBox]::Show("No tweak selected.", "LTR", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            return
        }

        # The restore point must be created BEFORE any other change
        $ordered = @()
        if ($selected -contains 'Restore Point - Create') { $ordered += 'Restore Point - Create' }
        $ordered += @($selected | Where-Object { $_ -ne 'Restore Point - Create' })

        $btnApplyTw.Enabled = $false
        $script:okList = @()
        $script:failList = @()
        Write-Log "Selected tweaks: $($ordered.Count)"
        if ($script:userSid) { Write-Log "Note: elevated account differs from logged-in user, user settings are written to the logged-in profile." }

        $script:results = @()

        Run-Action "Windows Tweaks" {
            $i = 0
            foreach ($tKey in $ordered) {
                $i++
                $before = '-'
                $after = '-'
                $status = 'FAILED'
                $checkBlock = $tweaksCheck[$tKey]
                try {
                    Write-Log "Applying tweak ($i/$($ordered.Count)): $tKey" ([int](($i / $ordered.Count) * 100))
                    $tweakBlock = $tweaksList[$tKey]
                    if (-not $tweakBlock) { throw "tweak not found in list" }

                    if ($checkBlock) { try { $before = [string](& $checkBlock) } catch { $before = '(unreadable)' } }
                    & $tweakBlock
                    if ($checkBlock) { try { $after = [string](& $checkBlock) } catch { $after = '(unreadable)' } }

                    $status = if ($before -ne $after) { 'CHANGED' } else { 'NO CHANGE' }
                    $script:okList += $tKey
                    Write-Log "OK ($status): $tKey"
                    Write-Log "   before: $before"
                    Write-Log "   after : $after"
                } catch {
                    $status = 'FAILED'
                    $after = $_.Exception.Message
                    $script:failList += $tKey
                    Write-Log "FAILED: $tKey -> $($_.Exception.Message)"
                }
                $script:results += [PSCustomObject]@{ Tweak = $tKey; Before = $before; After = $after; Status = $status }
            }
        }

        if (@($script:results).Count -gt 0) { Show-Results $script:results }

        $btnApplyTw.Enabled = $true
        $okN = @($script:okList).Count
        $failN = @($script:failList).Count

        if ($okN -gt 0) {
            $msgText = "Selected: $($ordered.Count)  |  Applied: $okN  |  Failed: $failN"
            if ($failN -gt 0) { $msgText += "`n`nFailed: " + (@($script:failList) -join ', ') }
            $msgText += "`n`nSome changes need a restart to take effect. Restart now?"
            $rebootChoice = [System.Windows.Forms.MessageBox]::Show($msgText, "LTR - Restart", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
            if ($rebootChoice -eq [System.Windows.Forms.DialogResult]::Yes) {
                Write-Log "Restarting in 10 seconds (type 'shutdown /a' in a console to cancel)..."
                Start-Process "shutdown.exe" -ArgumentList "/r /t 10" -WindowStyle Hidden
            } else {
                Write-Log "Restart skipped."
            }
        } else {
            [void][System.Windows.Forms.MessageBox]::Show("No tweak could be applied. Check the log below.", "LTR", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    })
    $zoneTw.Controls.Add($btnApplyTw)

    # ---------- DOWNLOADS Tab ----------
    $lblDlTitle = New-Object System.Windows.Forms.Label
    $lblDlTitle.Text = "Applications Downloader & Installer"
    $lblDlTitle.ForeColor = $script:cNeon
    $lblDlTitle.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
    $lblDlTitle.Location = New-Object System.Drawing.Point(18, 12)
    $lblDlTitle.AutoSize = $true
    $zoneDl.Controls.Add($lblDlTitle)

    $lblSearchDl = New-Object System.Windows.Forms.Label
    $lblSearchDl.Text = "Search:"
    $lblSearchDl.ForeColor = $script:cNeon
    $lblSearchDl.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    $lblSearchDl.Location = New-Object System.Drawing.Point(400, 15)
    $lblSearchDl.AutoSize = $true
    $zoneDl.Controls.Add($lblSearchDl)

    $txtSearchDl = New-Object System.Windows.Forms.TextBox
    $txtSearchDl.Location = New-Object System.Drawing.Point(455, 12)
    $txtSearchDl.Size = New-Object System.Drawing.Size(210, 23)
    $txtSearchDl.BackColor = $script:fondSombre
    $txtSearchDl.ForeColor = $script:cNeon
    $txtSearchDl.Font = New-Object System.Drawing.Font('Consolas', 9)
    $txtSearchDl.Add_TextChanged({
        Refresh-DownloadList $txtSearchDl.Text.Trim()
    })
    $zoneDl.Controls.Add($txtSearchDl)

    $panneauDlConteneur = New-Object System.Windows.Forms.Panel
    $panneauDlConteneur.Location = New-Object System.Drawing.Point(18, 45)
    $panneauDlConteneur.Size = New-Object System.Drawing.Size(650, 415)
    $panneauDlConteneur.AutoScroll = $true
    $zoneDl.Controls.Add($panneauDlConteneur)

    function Refresh-DownloadList($filter) {
        $panneauDlConteneur.Controls.Clear()
        $currentY = 10

        foreach ($catName in $downloadsCategories.Keys) {
            $catApps = $downloadsCategories[$catName]

            # [ordered] keeps the original order (a plain @{} would shuffle the buttons)
            $filteredApps = [ordered]@{}
            foreach ($appName in $catApps.Keys) {
                if ([string]::IsNullOrEmpty($filter) -or
                    $appName.IndexOf($filter, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 -or
                    $catName.IndexOf($filter, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    $filteredApps[$appName] = $catApps[$appName]
                }
            }

            if ($filteredApps.Count -eq 0) { continue }

            $lblCat = New-Object System.Windows.Forms.Label
            $lblCat.Text = "--- $catName ---"
            $lblCat.ForeColor = $script:cNeon
            $lblCat.Font = New-Object System.Drawing.Font('Segoe UI', 9.5, [System.Drawing.FontStyle]::Bold)
            $lblCat.Location = New-Object System.Drawing.Point(10, $currentY)
            $lblCat.AutoSize = $true
            $panneauDlConteneur.Controls.Add($lblCat)
            $currentY += 25

            $btnX = 10
            $btnY = $currentY
            foreach ($appName in $filteredApps.Keys) {
                $url = $filteredApps[$appName]
                $bApp = New-Object System.Windows.Forms.Button
                $bApp.Text = $appName
                $bApp.Tag = $url
                $bApp.Size = New-Object System.Drawing.Size(145, 30)
                $bApp.Location = New-Object System.Drawing.Point($btnX, $btnY)
                $bApp.FlatStyle = 'Flat'
                $bApp.FlatAppearance.BorderColor = $script:cNeon
                $bApp.BackColor = $script:fondCarte
                $bApp.ForeColor = $script:cNeon
                $bApp.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
                $bApp.Cursor = 'Hand'

                $bApp.Add_Click({
                    param($sender, $e)
                    $targetUrl = [string]$sender.Tag
                    $targetName = [string]$sender.Text
                    Run-Action "Get App: $targetName" {
                        Write-Log "Opening download source for $targetName..."
                        Start-Process $targetUrl
                        Write-Log "Download page launched for $targetName."
                    }
                })

                $panneauDlConteneur.Controls.Add($bApp)

                $btnX += 155
                if ($btnX -gt 480) {
                    $btnX = 10
                    $btnY += 38
                }
            }
            if ($btnX -ne 10) { $btnY += 38 }
            $currentY = $btnY + 10
        }
    }

    # ---------- GAME-BOOST Tab ----------
    $lblJeuxTitle = New-Object System.Windows.Forms.Label
    $lblJeuxTitle.Text = "Game Booster & Process Performance"
    $lblJeuxTitle.ForeColor = $script:cNeon
    $lblJeuxTitle.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
    $lblJeuxTitle.Location = New-Object System.Drawing.Point(18, 12)
    $lblJeuxTitle.AutoSize = $true
    $zoneJeux.Controls.Add($lblJeuxTitle)

    $btnRefreshProc = New-Object System.Windows.Forms.Button
    $btnRefreshProc.Text = "Refresh"
    $btnRefreshProc.Location = New-Object System.Drawing.Point(18, 415)
    $btnRefreshProc.Size = New-Object System.Drawing.Size(100, 32)
    $btnRefreshProc.FlatStyle = 'Flat'
    $btnRefreshProc.FlatAppearance.BorderColor = $script:cNeon
    $btnRefreshProc.BackColor = $script:fondCarte
    $btnRefreshProc.ForeColor = $script:cNeon
    $btnRefreshProc.Font = New-Object System.Drawing.Font('Segoe UI', 8.5, [System.Drawing.FontStyle]::Bold)
    $btnRefreshProc.Add_Click({ Refresh-ProcessList "" })
    $zoneJeux.Controls.Add($btnRefreshProc)

    $btnHighPriority = New-Object System.Windows.Forms.Button
    $btnHighPriority.Text = "Set High Priority"
    $btnHighPriority.Location = New-Object System.Drawing.Point(128, 415)
    $btnHighPriority.Size = New-Object System.Drawing.Size(140, 32)
    $btnHighPriority.FlatStyle = 'Flat'
    $btnHighPriority.FlatAppearance.BorderColor = $script:cNeon
    $btnHighPriority.BackColor = $script:fondCarte
    $btnHighPriority.ForeColor = $script:cNeon
    $btnHighPriority.Font = New-Object System.Drawing.Font('Segoe UI', 8.5, [System.Drawing.FontStyle]::Bold)
    $btnHighPriority.Add_Click({
        if ($procListBox.SelectedItem) {
            $selectedText = $procListBox.SelectedItem.ToString()
            if ($selectedText -match '^(.+?)\s+ID:\s+(\d+)') {
                $targetId = [int]$Matches[2]
                try {
                    $proc = Get-Process -Id $targetId -ErrorAction Stop
                    $proc.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High
                    Write-Log "SUCCESS: '$($proc.ProcessName)' (ID: $targetId) set to HIGH priority."
                } catch {
                    Write-Log "Cannot change priority for ID $targetId (protected or closed): $($_.Exception.Message)"
                }
            }
        } else {
            [void][System.Windows.Forms.MessageBox]::Show("Please select a process from the list first.", "Game-Boost", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    })
    $zoneJeux.Controls.Add($btnHighPriority)

    # Processes that must never be killed (would crash or freeze Windows)
    $script:protectedProcs = @('csrss', 'wininit', 'winlogon', 'services', 'lsass', 'smss', 'system', 'registry', 'dwm', 'svchost', 'fontdrvhost', 'Memory Compression')

    $btnKillProc = New-Object System.Windows.Forms.Button
    $btnKillProc.Text = "Kill Process"
    $btnKillProc.Location = New-Object System.Drawing.Point(545, 415)
    $btnKillProc.Size = New-Object System.Drawing.Size(120, 32)
    $btnKillProc.FlatStyle = 'Flat'
    $btnKillProc.FlatAppearance.BorderColor = $script:cNeon
    $btnKillProc.BackColor = $script:fondCarte
    $btnKillProc.ForeColor = $script:cNeon
    $btnKillProc.Font = New-Object System.Drawing.Font('Segoe UI', 8.5, [System.Drawing.FontStyle]::Bold)
    $btnKillProc.Add_Click({
        if ($procListBox.SelectedItem) {
            $selectedText = $procListBox.SelectedItem.ToString()
            if ($selectedText -match '^(.+?)\s+ID:\s+(\d+)') {
                $procName = $Matches[1].Trim()
                $pidToKill = [int]$Matches[2]

                if ($script:protectedProcs -contains $procName) {
                    [void][System.Windows.Forms.MessageBox]::Show("'$procName' is a critical Windows process and cannot be killed from here.", "Game-Boost", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                    return
                }

                $answer = [System.Windows.Forms.MessageBox]::Show("Kill '$procName' (ID: $pidToKill)? Unsaved data in this program will be lost.", "Game-Boost", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
                if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }

                try {
                    Stop-Process -Id $pidToKill -Force -ErrorAction Stop
                    Write-Log "Terminated process '$procName' (ID: $pidToKill)."
                    Refresh-ProcessList ""
                } catch {
                    Write-Log "Failed to kill ID $pidToKill : $($_.Exception.Message)"
                }
            }
        } else {
            [void][System.Windows.Forms.MessageBox]::Show("Please select a process from the list first.", "Game-Boost", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    })
    $zoneJeux.Controls.Add($btnKillProc)

    $procListBox = New-Object System.Windows.Forms.ListBox
    $procListBox.Location = New-Object System.Drawing.Point(18, 45)
    $procListBox.Size = New-Object System.Drawing.Size(647, 360)
    $procListBox.BackColor = [System.Drawing.Color]::FromArgb(5, 8, 10)
    $procListBox.ForeColor = $script:cNeon
    $procListBox.Font = New-Object System.Drawing.Font('Consolas', 9)
    $zoneJeux.Controls.Add($procListBox)

    function Refresh-ProcessList($filter) {
        $procListBox.Items.Clear()
        $procs = Get-Process | Where-Object { $_.Id -ne 0 -and $_.Id -ne 4 } | Sort-Object WorkingSet64 -Descending
        foreach ($p in $procs) {
            $line = "{0,-25} ID: {1,-6} RAM: {2,8} MB" -f $p.ProcessName, $p.Id, [math]::Round($p.WorkingSet64 / 1MB, 2)
            [void]$procListBox.Items.Add($line)
        }
    }

    # ---------- PC SPECS Tab ----------
    $lblSpecsTitle = New-Object System.Windows.Forms.Label
    $lblSpecsTitle.Text = "System Specifications"
    $lblSpecsTitle.ForeColor = $script:cNeon
    $lblSpecsTitle.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
    $lblSpecsTitle.Location = New-Object System.Drawing.Point(18, 12)
    $lblSpecsTitle.AutoSize = $true
    $zoneSpecs.Controls.Add($lblSpecsTitle)

    $txtSpecsBox = New-Object System.Windows.Forms.TextBox
    $txtSpecsBox.Multiline = $true
    $txtSpecsBox.ReadOnly = $true
    $txtSpecsBox.ScrollBars = 'Vertical'
    $txtSpecsBox.Location = New-Object System.Drawing.Point(18, 45)
    $txtSpecsBox.Size = New-Object System.Drawing.Size(647, 360)
    $txtSpecsBox.BackColor = [System.Drawing.Color]::FromArgb(5, 8, 10)
    $txtSpecsBox.ForeColor = $script:cNeon
    $txtSpecsBox.Font = New-Object System.Drawing.Font('Consolas', 9.5)
    $zoneSpecs.Controls.Add($txtSpecsBox)

    # Win32_VideoController.AdapterRAM is capped at 4 GB: read the real VRAM from the registry
    function Get-VramGB($gpuName) {
        try {
            $base = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
            foreach ($k in Get-ChildItem $base -ErrorAction SilentlyContinue) {
                $p = Get-ItemProperty $k.PSPath -ErrorAction SilentlyContinue
                if ($p.DriverDesc -eq $gpuName -and $p.'HardwareInformation.qwMemorySize') {
                    return [math]::Round([double]$p.'HardwareInformation.qwMemorySize' / 1GB, 2)
                }
            }
        } catch {}
        return $null
    }

    $btnGetSpecs = New-Object System.Windows.Forms.Button
    $btnGetSpecs.Text = "Load Hardware Specs"
    $btnGetSpecs.Location = New-Object System.Drawing.Point(18, 415)
    $btnGetSpecs.Size = New-Object System.Drawing.Size(647, 32)
    $btnGetSpecs.FlatStyle = 'Flat'
    $btnGetSpecs.FlatAppearance.BorderColor = $script:cNeon
    $btnGetSpecs.BackColor = $script:fondCarte
    $btnGetSpecs.ForeColor = $script:cNeon
    $btnGetSpecs.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
    $btnGetSpecs.Add_Click({
        $txtSpecsBox.Text = "Gathering system info..."
        [System.Windows.Forms.Application]::DoEvents()
        try {
            $os = Get-CimInstance Win32_OperatingSystem
            $cpu = @(Get-CimInstance Win32_Processor)[0]
            $gpu = @(Get-CimInstance Win32_VideoController)
            $ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
            $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'"

            $sb = New-Object System.Text.StringBuilder
            [void]$sb.AppendLine("=== OPERATING SYSTEM ===")
            [void]$sb.AppendLine("OS: $($os.Caption) ($($os.Version))")
            [void]$sb.AppendLine("Architecture: $($os.OSArchitecture)")
            [void]$sb.AppendLine("Machine: $env:COMPUTERNAME  |  User: $env:USERNAME")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("=== PROCESSOR (CPU) ===")
            [void]$sb.AppendLine("Name: $($cpu.Name)")
            [void]$sb.AppendLine("Cores: $($cpu.NumberOfCores) (Threads: $($cpu.NumberOfLogicalProcessors))")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("=== MEMORY (RAM) ===")
            [void]$sb.AppendLine("Total RAM: $ram GB")
            [void]$sb.AppendLine("")
            [void]$sb.AppendLine("=== GRAPHICS (GPU) ===")
            foreach ($gc in $gpu) {
                [void]$sb.AppendLine("Card: $($gc.Name)")
                $vram = Get-VramGB $gc.Name
                if ($vram) {
                    [void]$sb.AppendLine("VRAM: $vram GB")
                } elseif ($gc.AdapterRAM) {
                    [void]$sb.AppendLine("VRAM: $([math]::Round($gc.AdapterRAM / 1GB, 2)) GB (may be capped at 4 GB by Windows)")
                }
            }
            if ($disk) {
                [void]$sb.AppendLine("")
                [void]$sb.AppendLine("=== STORAGE ($env:SystemDrive) ===")
                [void]$sb.AppendLine("$([math]::Round($disk.FreeSpace / 1GB, 2)) GB free of $([math]::Round($disk.Size / 1GB, 2)) GB")
            }
            $txtSpecsBox.Text = $sb.ToString()
        } catch {
            $txtSpecsBox.Text = "Error while reading specs: $($_.Exception.Message)"
        }
    })
    $zoneSpecs.Controls.Add($btnGetSpecs)

    # ---------- GUIDE Tab ----------
    $lblGuideTitle = New-Object System.Windows.Forms.Label
    $lblGuideTitle.Text = "Optimization Guide & Tips"
    $lblGuideTitle.ForeColor = $script:cNeon
    $lblGuideTitle.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
    $lblGuideTitle.Location = New-Object System.Drawing.Point(18, 12)
    $lblGuideTitle.AutoSize = $true
    $zoneGuide.Controls.Add($lblGuideTitle)

    $guideBox = New-Object System.Windows.Forms.TextBox
    $guideBox.Multiline = $true
    $guideBox.ReadOnly = $true
    $guideBox.ScrollBars = 'Vertical'
    $guideBox.Location = New-Object System.Drawing.Point(18, 45)
    $guideBox.Size = New-Object System.Drawing.Size(647, 410)
    $guideBox.BackColor = [System.Drawing.Color]::FromArgb(5, 8, 10)
    $guideBox.ForeColor = $script:cNeon
    $guideBox.Font = New-Object System.Drawing.Font('Consolas', 9.5)
    $guideBox.Text = @'
==================================================
              LTR OPTIMIZATION GUIDE
==================================================

1. TWEAKS TAB:
   - Use the 'Recommended' preset for a balanced performance boost without breaking core Windows features.
   - Disables telemetry, tracking, and unnecessary background services to free up RAM and CPU.
   - 'Restore Point - Create' always runs first, before any other change.
   - Some tweaks need a restart: the tool offers it when it is done.

2. DOWNLOADS TAB:
   - Select any software you need across categories (Browsers, Gaming, Tools, Dev).
   - Clicking an application will open its official download page safely in your browser.

3. GAME-BOOST TAB:
   - Select any running application or game from the list.
   - Click 'Set High Priority' to give the application maximum CPU priority and boost performance.
   - Click 'Kill Process' to close a heavy background application (critical Windows processes are protected).

4. GENERAL TIPS:
   - Always create a System Restore point before applying aggressive tweaks.
   - Change color themes dynamically using the top-right selector on the Tweaks tab.
'@
    $zoneGuide.Controls.Add($guideBox)

    # Show Form
    [void]$form.ShowDialog()

} catch {
    [void][System.Windows.Forms.MessageBox]::Show("Critical Error: $_", "LTR Opti Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}
