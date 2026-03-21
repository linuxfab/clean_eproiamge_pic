param (
    [Parameter(Position=0)][string]$RawPath = "C:\YOUSING\eProImage",
    [string[]]$MonitorProcess = @("eProImage"), # 可監控多個進程
    [Switch]$WhatIf
)

$OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BaselineFile = Join-Path $ScriptDir "clean_pict_cache_baseline.txt"
$LogFile = Join-Path $ScriptDir "clean_pict_cache.log"

# 1. 日誌自動滾動 (超過 1MB 則重置)
if (Test-Path $LogFile) {
    if ((Get-Item $LogFile).Length -gt 1MB) { Remove-Item $LogFile -Force }
}

# 2. 路徑解析
if (-not (Test-Path $RawPath)) {
    Write-Error "Path '$RawPath' not found"; exit 1
}
$TargetDir = (Get-Item $RawPath).FullName
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ModePrefix = if ($WhatIf) { "[DRY RUN] " } else { "" }

Add-Content -Path $LogFile -Value "--- ${ModePrefix}Clean Start $Timestamp ---"
Add-Content -Path $LogFile -Value "Target: $TargetDir"

if ($WhatIf) { Write-Host "--- Dry Run Mode Enabled ---" -ForegroundColor Cyan }

try {
    # 3. 進程檢查 (Process Protection)
    if ($MonitorProcess) {
        foreach ($ProcName in $MonitorProcess) {
            $RunningProc = Get-Process -Name $ProcName -ErrorAction SilentlyContinue
            if ($RunningProc) {
                $WaitMsg = "Warning: Process '$ProcName' is currently running. Please close it before cleaning."
                Add-Content -Path $LogFile -Value "[ABORT] $WaitMsg"
                Write-Host $WaitMsg -ForegroundColor Red
                exit 1
            }
        }
    }

    if (Test-Path $BaselineFile) {
        $Lines = Get-Content $BaselineFile
        $BaselinePaths = @()
        foreach ($L in $Lines) {
            $T = $L.Trim()
            if ($T) { $BaselinePaths += Join-Path $TargetDir $T }
        }
        
        $PictPath = Join-Path $TargetDir "pict"
        if (Test-Path $PictPath) {
            $CurrentItems = Get-ChildItem -Path $PictPath -Recurse | Sort-Object -Property FullName -Descending
            $DeleteCount = 0
            foreach ($Item in $CurrentItems) {
                if ($BaselinePaths -notcontains $Item.FullName) {
                    $DeleteCount++
                    $Msg = "Deleting: $($Item.FullName)"
                    Add-Content -Path $LogFile -Value $Msg
                    if ($WhatIf) {
                        Write-Host "[What-If] $Msg" -ForegroundColor Yellow
                    } else {
                        Write-Host "[Action] $Msg" -ForegroundColor Gray
                        Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            if ($DeleteCount -eq 0) {
                Write-Host "No files need to be deleted." -ForegroundColor Green
            } else {
                $Summary = if ($WhatIf) { "Total items to delete: $DeleteCount" } else { "Total items deleted: $DeleteCount" }
                Write-Host $Summary -ForegroundColor White
            }
        }
    }
} catch {
    $Err = "Error: " + $_.Exception.Message
    Add-Content -Path $LogFile -Value $Err
    Write-Host $Err -ForegroundColor Red
} finally {
    Add-Content -Path $LogFile -Value "--- End ---`n"
}
