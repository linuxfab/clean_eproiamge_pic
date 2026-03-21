param (
    [Parameter(Position=0)][string]$RawPath = "C:\YOUSING\eProImage",
    [Switch]$WhatIf
)

$OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BaselineFile = Join-Path $ScriptDir "clean_pict_cache_baseline.txt"
$LogFile = Join-Path $ScriptDir "clean_pict_cache.log"

if (Test-Path $LogFile) {
    $LogItem = Get-Item $LogFile
    if ($LogItem.Length -gt 1MB) { Remove-Item $LogFile -Force }
}

if (-not (Test-Path $RawPath)) {
    Write-Error "Path '$RawPath' not found"; exit 1
}

$GetItem = Get-Item $RawPath
$TargetDir = $GetItem.FullName
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ModePrefix = if ($WhatIf) { "[DRY RUN] " } else { "" }

Add-Content -Path $LogFile -Value "--- ${ModePrefix}Clean Start $Timestamp ---"
Add-Content -Path $LogFile -Value "Target: $TargetDir"

if ($WhatIf) { 
    Write-Host "--- Dry Run Mode Enabled ---" -ForegroundColor Cyan 
} else {
    Write-Host "--- Starting Clean Job ---" -ForegroundColor Green
}

try {
    if (Test-Path $BaselineFile) {
        $Lines = Get-Content $BaselineFile
        $BaselinePaths = @()
        foreach ($L in $Lines) {
            $T = $L.Trim()
            if ($T) { 
                $BaselinePaths += Join-Path $TargetDir $T
            }
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
                $FinalMsg = if ($WhatIf) { "Total items to delete: $DeleteCount" } else { "Total items deleted: $DeleteCount" }
                Write-Host $FinalMsg -ForegroundColor White
            }
        } else {
            $Warn = "Warning: 'pict' folder not found in $TargetDir"
            Add-Content -Path $LogFile -Value $Warn
            Write-Host $Warn -ForegroundColor Red
        }
    } else {
        $ErrorMsg = "Error: Baseline file not found at $BaselineFile"
        Add-Content -Path $LogFile -Value $ErrorMsg
        Write-Host $ErrorMsg -ForegroundColor Red
    }
} catch {
    $ErrMessage = "Error: " + $_.Exception.Message
    Add-Content -Path $LogFile -Value $ErrMessage
    Write-Host $ErrMessage -ForegroundColor Red
} finally {
    Add-Content -Path $LogFile -Value "--- End ---`n"
}
