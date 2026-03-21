param (
    [Parameter(Position=0)][string]$RawPath = "C:\YOUSING\eProImage",
    [Switch]$WhatIf
)

$OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BaselineFile = Join-Path $ScriptDir "clean_pict_cache_baseline.txt"
$LogFile = Join-Path $ScriptDir "clean_pict_cache.log"

if (Test-Path $LogFile) {
    if ((Get-Item $LogFile).Length -gt 1MB) { 
        $OldLog = $LogFile + ".old"
        if (Test-Path $OldLog) { Remove-Item $OldLog -Force }
        Rename-Item -Path $LogFile -NewName (Split-Path $OldLog -Leaf) -Force
    }
}

if (-not (Test-Path $RawPath)) {
    Write-Error "Path '$RawPath' not found"
    exit 1
}

$TargetDir = (Get-Item $RawPath).FullName
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 安全防呆：避免誤指定為根目錄 (防爆全硬碟)
if ($TargetDir -notlike "*\eProImage*" -and $TargetDir -notlike "*\pict*") {
    Write-Error "ABORT: Target path '$TargetDir' does not look like an eProImage or pict folder! Safety lock enabled."
    exit 1
}

$Logs = @()
$Logs += "--- Clean Start $Timestamp ---"
$Logs += "Target: $TargetDir"

if ($WhatIf) { Write-Host "--- Dry Run Mode Enabled ---" -ForegroundColor Cyan }



try {
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

            # 🟡 2. 清理空白資料夾 (純淨化)
            $EmptyDirs = Get-ChildItem -Path $PictPath -Directory -Recurse | Where-Object { (Get-ChildItem -Path $_.FullName -Force).Count -eq 0 } | Sort-Object -Property FullName -Descending
            foreach ($Ed in $EmptyDirs) {
                if ($WhatIf) {
                    Write-Host "What-If (EmptyDir): Delete " + $Ed.FullName -ForegroundColor Yellow
                } else {
                    Remove-Item -Path $Ed.FullName -Force -ErrorAction SilentlyContinue
                }
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
