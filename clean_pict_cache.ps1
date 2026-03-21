# 設定編碼為 UTF8 以支援中文日誌
$OutputEncoding = [System.Text.Encoding]::UTF8

# 支援位置參數與 -WhatIf 開關
param (
    [Parameter(Position=0)][string]$RawPath = "C:\YOUSING\eProImage", # 預設位置
    [Switch]$WhatIf
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BaselineFile = Join-Path $ScriptDir "clean_pict_cache_baseline.txt"
$LogFile = Join-Path $ScriptDir "clean_pict_cache.log"

# 1. 日誌自動滾動 (超過 1MB 則清空重置)
if (Test-Path $LogFile) {
    if ((Get-Item $LogFile).Length -gt 1MB) {
        Remove-Item $LogFile -Force
    }
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
    if (Test-Path $BaselineFile) {
        # 讀取基準線並生成絕對路徑清單
        $BaselinePaths = Get-Content $BaselineFile | ForEach-Object { 
            $Trimmed = $_.Trim()
            if ($Trimmed) { Join-Path $TargetDir $Trimmed }
        } | Where-Object { $_ -ne $null }
        
        $PictPath = Join-Path $TargetDir "pict"
        if (Test-Path $PictPath) {
            # 取得所有項目（由深到淺排序，確保先刪除檔案再刪除目錄）
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
                        Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            if ($DeleteCount -eq 0) {
                Write-Host "No files need to be deleted." -ForegroundColor Green
            } else {
                Write-Host "Total items deleted: $DeleteCount" -ForegroundColor White
            }
        } else {
            $Msg = "Warning: 'pict' folder not found in $TargetDir"
            Add-Content -Path $LogFile -Value $Msg
            Write-Host $Msg -ForegroundColor Red
        }
    } else {
        $Msg = "Error: Baseline file not found at $BaselineFile"
        Add-Content -Path $LogFile -Value $Msg
        Write-Host $Msg -ForegroundColor Red
    }
} catch {
    $ErrMsg = "Error: $($_.Exception.Message)"
    Add-Content -Path $LogFile -Value $ErrMsg
    Write-Host $ErrMsg -ForegroundColor Red
} finally {
    Add-Content -Path $LogFile -Value "--- End ---`n"
}
