<#
.SYNOPSIS
    Opens the Finance PBIP in Power BI Desktop, navigates to each report page,
    and captures a screenshot of the PBI window for each page.

.DESCRIPTION
    Designed to be called by an AI agent after PBIP edits so screenshots can be
    reviewed without manual intervention.

    Requirements:
      - Power BI Desktop installed
      - An active Windows GUI session (RDP or console)
      - The PBIP file must be loadable

.PARAMETER PbipPath
    Path to the .pbip file. Defaults to the Finance report.

.PARAMETER OutputDir
    Folder where page screenshots are saved. Defaults to Records/screenshots.

.PARAMETER PageCount
    Number of report pages to cycle through. Use -1 (default) to read the count from the
    report's definition/pages/pages.json next to the PBIP (fallback: 10).

.PARAMETER LoadWaitSeconds
    Seconds to wait for PBI Desktop to fully load the report. Defaults to 45.

.PARAMETER PageWaitSeconds
    Seconds to wait after switching each page before capturing. Defaults to 4.

.PARAMETER ClosePbi
    If set, closes Power BI Desktop after capture.
#>

param(
    [string]$PbipPath  = "C:\Work\reporting-hub\Reports\Finance\Financial Report\Financial Report.pbip",
    [string]$OutputDir = "C:\Work\reporting-hub\Reports\Finance\Records\screenshots",
    [int]$PageCount    = -1,
    [int]$LoadWaitSeconds = 45,
    [int]$PageWaitSeconds = 4,
    [switch]$ClosePbi
)

$ErrorActionPreference = "Stop"

$pbipParent = Split-Path -LiteralPath $PbipPath
$pbipBaseName = [System.IO.Path]::GetFileNameWithoutExtension($PbipPath)
$pagesJsonPath = Join-Path $pbipParent ("{0}.Report\definition\pages\pages.json" -f $pbipBaseName)
if ($PageCount -lt 0) {
    if (Test-Path -LiteralPath $pagesJsonPath) {
        try {
            $pagesMeta = Get-Content -LiteralPath $pagesJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
            $n = @($pagesMeta.pageOrder).Count
            if ($n -gt 0) { $PageCount = $n }
        } catch {
            Write-Warning "Could not read page count from $pagesJsonPath : $($_.Exception.Message)"
        }
    }
    if ($PageCount -lt 0) {
        $PageCount = 10
        Write-Host "Using fallback PageCount=$PageCount (pages.json missing or empty)."
    } else {
        Write-Host "PageCount from pages.json: $PageCount ($pagesJsonPath)"
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class Win32 {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll", SetLastError=true)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    public struct RECT { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);

    public struct POINT { public int X, Y; }
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hWnd, ref POINT pt);

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, UIntPtr dwExtraInfo);

    public const byte VK_CONTROL = 0x11;
    public const byte VK_PRIOR   = 0x21;  // Page Up
    public const byte VK_NEXT    = 0x22;  // Page Down
    public const byte VK_ESCAPE  = 0x1B;
    public const uint KEYEVENTF_KEYUP = 0x0002;
    public const uint MOUSEEVENTF_LEFTDOWN  = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP    = 0x0004;

    public static void PressKey(byte vk) {
        keybd_event(vk, 0, 0, UIntPtr.Zero);
        System.Threading.Thread.Sleep(50);
        keybd_event(vk, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
    }

    public static void CtrlPageDown() {
        keybd_event(VK_CONTROL, 0, 0, UIntPtr.Zero);
        System.Threading.Thread.Sleep(30);
        keybd_event(VK_NEXT, 0, 0, UIntPtr.Zero);
        System.Threading.Thread.Sleep(30);
        keybd_event(VK_NEXT, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
        System.Threading.Thread.Sleep(30);
        keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
    }

    public static void CtrlPageUp() {
        keybd_event(VK_CONTROL, 0, 0, UIntPtr.Zero);
        System.Threading.Thread.Sleep(30);
        keybd_event(VK_PRIOR, 0, 0, UIntPtr.Zero);
        System.Threading.Thread.Sleep(30);
        keybd_event(VK_PRIOR, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
        System.Threading.Thread.Sleep(30);
        keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
    }

    public static void ClickAt(int screenX, int screenY) {
        System.Windows.Forms.Cursor.Position = new System.Drawing.Point(screenX, screenY);
        System.Threading.Thread.Sleep(100);
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, UIntPtr.Zero);
        System.Threading.Thread.Sleep(50);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, UIntPtr.Zero);
    }
}
"@ -ReferencedAssemblies System.Windows.Forms, System.Drawing -ErrorAction SilentlyContinue

$pbiExe = "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"

if (!(Test-Path $pbiExe)) {
    Write-Error "Power BI Desktop not found at $pbiExe"
    exit 1
}
if (!(Test-Path $PbipPath)) {
    Write-Error "PBIP file not found at $PbipPath"
    exit 1
}
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

function Get-PbiWindow {
    $proc = Get-Process -Name "PBIDesktop" -ErrorAction SilentlyContinue |
            Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } |
            Select-Object -First 1
    if ($proc) { return $proc.MainWindowHandle }
    return [IntPtr]::Zero
}

function Capture-Window([IntPtr]$hWnd, [string]$filePath) {
    $rect = New-Object Win32+RECT
    [Win32]::GetWindowRect($hWnd, [ref]$rect) | Out-Null
    $w = $rect.Right  - $rect.Left
    $h = $rect.Bottom - $rect.Top
    if ($w -lt 100 -or $h -lt 100) {
        Write-Warning "Window too small ($w x $h), skipping capture."
        return $false
    }
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.CopyFromScreen($rect.Left, $rect.Top, 0, 0, (New-Object System.Drawing.Size($w, $h)))
    $gfx.Dispose()
    $bmp.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    return $true
}

# --- Check if PBI Desktop is already running ---
$existingProc = Get-Process -Name "PBIDesktop" -ErrorAction SilentlyContinue
$launched = $false

if (-not $existingProc) {
    Write-Host "Launching Power BI Desktop with $PbipPath ..."
    Start-Process -FilePath $pbiExe -ArgumentList "`"$PbipPath`""
    $launched = $true
    Write-Host "Waiting $LoadWaitSeconds seconds for report to load..."
    Start-Sleep -Seconds $LoadWaitSeconds
} else {
    Write-Host "Power BI Desktop already running. Will capture current state."
    Start-Sleep -Seconds 3
}

# --- Get PBI window handle ---
$hWnd = Get-PbiWindow
if ($hWnd -eq [IntPtr]::Zero) {
    Write-Error "Could not find Power BI Desktop window after launch."
    exit 1
}

[Win32]::ShowWindow($hWnd, 3) | Out-Null   # SW_MAXIMIZE
Start-Sleep -Seconds 2
[Win32]::SetForegroundWindow($hWnd) | Out-Null
Start-Sleep -Seconds 1

# --- Get window geometry for click targeting ---
$winRect = New-Object Win32+RECT
[Win32]::GetWindowRect($hWnd, [ref]$winRect) | Out-Null
$clientRect = New-Object Win32+RECT
[Win32]::GetClientRect($hWnd, [ref]$clientRect) | Out-Null
$origin = New-Object Win32+POINT
$origin.X = 0; $origin.Y = 0
[Win32]::ClientToScreen($hWnd, [ref]$origin) | Out-Null

$clientW = $clientRect.Right
$clientH = $clientRect.Bottom
Write-Host "Client area: ${clientW}x${clientH}, origin at ($($origin.X),$($origin.Y))"

# --- Compute page tab click coordinates ---
# PBI Desktop page tabs are custom-rendered at the bottom of the report canvas.
# Keyboard shortcuts (Ctrl+PageDown) do not work in authoring view.
# Tab Y: approximately clientBottom - 28 (center of the tab strip above the status bar).
# Tab X: estimated center of each tab text based on known page names and measured proportions.

$ox = [int]$origin.X
$oy = [int]$origin.Y
$tabY = $oy + $clientH - 28

# Page tab center-X positions (screen coords) for Finance pages at ~1470px client width.
# Re-measure in Desktop if tab layout changes (font scaling, page rename width).
$tabCentersX = @(
    ($ox + 201),   # 1  Executive Overview
    ($ox + 327),   # 2  Income Statement
    ($ox + 452),   # 3  Revenue Insights
    ($ox + 571),   # 4  Cost Structure
    ($ox + 680),   # 5  Balance Sheet
    ($ox + 824),   # 6  Working Capital Health
    ($ox + 987),   # 7  Profitability Drivers
    ($ox + 1125),  # 8  Receivables
    ($ox + 1245),  # 9  Collections
    ($ox + 1365)   # 10 Cash Position
)

Write-Host "Page tab Y=$tabY"
Write-Host "Tab X centers: $($tabCentersX -join ', ')"

if ($PageCount -gt $tabCentersX.Count) {
    Write-Warning "PageCount ($PageCount) exceeds calibrated tab positions ($($tabCentersX.Count)); clipping to avoid bad clicks."
    $PageCount = $tabCentersX.Count
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# --- Click each page tab and capture ---
for ($i = 0; $i -lt $PageCount; $i++) {
    $pageNum = $i + 1
    $outFile = Join-Path $OutputDir "page${pageNum}_${timestamp}.png"
    $tabX = $tabCentersX[$i]

    [Win32]::SetForegroundWindow($hWnd) | Out-Null
    Start-Sleep -Milliseconds 500

    Write-Host "Clicking page tab $pageNum at ($tabX, $tabY)..."
    [Win32]::ClickAt($tabX, $tabY)
    Start-Sleep -Seconds $PageWaitSeconds

    # Press Escape twice to deselect any visual the click may have selected
    [Win32]::PressKey([Win32]::VK_ESCAPE)
    Start-Sleep -Milliseconds 200
    [Win32]::PressKey([Win32]::VK_ESCAPE)
    Start-Sleep -Milliseconds 500

    $captured = Capture-Window $hWnd $outFile
    if ($captured) {
        Write-Host "Captured page $pageNum -> $outFile"
    } else {
        Write-Host "SKIP page $pageNum (capture failed)"
    }
}

if ($ClosePbi) {
    Write-Host "Closing Power BI Desktop..."
    Get-Process -Name "PBIDesktop" -ErrorAction SilentlyContinue | ForEach-Object {
        $_.CloseMainWindow() | Out-Null
    }
    Start-Sleep -Seconds 3
    Get-Process -Name "PBIDesktop" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Done. Screenshots saved to: $OutputDir"
Get-ChildItem $OutputDir -Filter "*_${timestamp}.png" | ForEach-Object {
    Write-Host "  $($_.Name)  ($([math]::Round($_.Length/1024))KB)"
}
