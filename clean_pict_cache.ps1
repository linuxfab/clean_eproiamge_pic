param (
    [Parameter(Position=0)][string]$RawPath = "C:\YOUSING\eProImage",
    [Switch]$WhatIf
)

$OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BaselineFile = Join-Path $ScriptDir "clean_pict_cache_baseline.txt"
$LogFile = Join-Path $ScriptDir "clean_pict_cache.log"

if (Test-Path $LogFile) {
    if ((Get-Item $LogFile).Length -gt 1MB) { Remove-Item $LogFile -Force }
}

if (-not (Test-Path $RawPath)) {
    Write-Error "Path '$RawPath' not found"
    exit 1
}

$TargetDir = (Get-Item $RawPath).FullName
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$Logs = @()
$Logs += "--- Clean Start $Timestamp ---"
$Logs += "Target: $TargetDir"

if ($WhatIf) { Write-Host "--- Dry Run Mode Enabled ---" -ForegroundColor Cyan }

# Keywords for Window Title and Command Line
$K1 = "*eProImage*"

try {
    $IsRunning = $false

    # Check 1: Window Titles (Only check javaw to avoid matching the Code Editor's window title!)
    $JavaProcs = Get-Process javaw -ErrorAction SilentlyContinue
    if ($JavaProcs) {
        foreach ($P in $JavaProcs) {
            $Title = ""
            if ($P.MainWindowTitle) { $Title = $P.MainWindowTitle }
            if ($Title -like $K1) {
                $IsRunning = $true
            }
        }
    }

    # Check 2: WMI CommandLine (Works for background services if Admin)
    $JavaWmi = Get-CimInstance Win32_Process -Filter "Name = 'javaw.exe'" -ErrorAction SilentlyContinue
    if ($JavaWmi) {
        foreach ($P in $JavaWmi) {
            $C = ""
            if ($P.CommandLine) { $C = $P.CommandLine }
            $E = ""
            if ($P.ExecutablePath) { $E = $P.ExecutablePath }
            $Combined = "$C $E"
            if ($Combined -like $K1) {
                $IsRunning = $true
            }
        }
    }

    if ($IsRunning) {
        $Msg = "ABORT: eProImage (Java) is running! Please close it."
        $Logs += $Msg
        Write-Host $Msg -ForegroundColor Red
        $Logs | Add-Content -Path $LogFile -ErrorAction SilentlyContinue
        exit 1
    }

    if (Test-Path $BaselineFile) {
        $Lines = Get-Content $BaselineFile
        $BaselinePaths = @()
        foreach ($L in $Lines) {
            $Trimmed = $L.Trim()
            if ($Trimmed) { 
                $BaselinePaths += Join-Path $TargetDir $Trimmed 
            }
        }
        
        $PictPath = Join-Path $TargetDir "pict"
        if (Test-Path $PictPath) {
            $Items = Get-ChildItem -Path $PictPath -Recurse | Sort-Object -Property FullName -Descending
            $Count = 0
            foreach ($I in $Items) {
                if ($BaselinePaths -notcontains $I.FullName) {
                    $Count++
                    $Txt = "Deleting: " + $I.FullName
                    $Logs += $Txt
                    if ($WhatIf) {
                        Write-Host "What-If: $Txt" -ForegroundColor Yellow
                    } else {
                        Write-Host "Action: $Txt" -ForegroundColor Gray
                        Remove-Item -Path $I.FullName -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            if ($Count -eq 0) {
                Write-Host "No files need to be deleted." -ForegroundColor Green
            } else {
                $TotalTxt = "Total items: " + $Count
                Write-Host $TotalTxt -ForegroundColor White
            }
        }
    }
} catch {
    $Err = "Error: " + $_.Exception.Message
    $Logs += $Err
    Write-Host $Err -ForegroundColor Red
} finally {
    $Logs += "--- End ---"
    $Logs | Add-Content -Path $LogFile -ErrorAction SilentlyContinue
}
