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
    Write-Error "Path '$RawPath' not found"; exit 1
}

$TargetDir = (Get-Item $RawPath).FullName
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-Content -Path $LogFile -Value "--- Clean Start $Timestamp ---"
Add-Content -Path $LogFile -Value "Target: $TargetDir"

if ($WhatIf) { Write-Host "--- Dry Run Mode Enabled ---" -ForegroundColor Cyan }

try {
    $JavaProcs = Get-CimInstance Win32_Process -Filter "Name = 'javaw.exe'"
    foreach ($P in $JavaProcs) {
        $C = ""
        if ($P.CommandLine) { $C = $P.CommandLine }
        $E = ""
        if ($P.ExecutablePath) { $E = $P.ExecutablePath }

        $Match = $false
        if ($C -like "*eProImage*" -or $C -like "*YOUSING*" -or $C -like "*北極星*" -or $C -like "*光遠*") { $Match = $true }
        if ($E -like "*eProImage*" -or $E -like "*YOUSING*") { $Match = $true }

        if ($Match) {
            $Msg = "Warning: eProImage / 北極星系統正在執行中！請先關閉程式再清理。"
            Add-Content -Path $LogFile -Value "ABORT: $Msg"
            Write-Host $Msg -ForegroundColor Red
            exit 1
        }
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
                    $Txt = "Deleting: $($I.FullName)"
                    Add-Content -Path $LogFile -Value $Txt
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
                Write-Host "Total items: $Count" -ForegroundColor White
            }
        }
    }
} catch {
    $Err = "Error: " + $_.Exception.Message
    Add-Content -Path $LogFile -Value $Err
    Write-Host $Err -ForegroundColor Red
} finally {
    Add-Content -Path $LogFile -Value "--- End ---"
}
