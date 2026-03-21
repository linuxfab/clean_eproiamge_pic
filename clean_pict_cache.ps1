# 設定編碼為 UTF8 以支援中文日誌
$OutputEncoding = [System.Text.Encoding]::UTF8

# 支援位置參數與 -WhatIf開關
param (
    [Parameter(Position=0)][string]$RawPath = ".",
    [Switch]$WhatIf
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BaselineFile = Join-Path $ScriptDir "clean_pict_cache_baseline.txt"
$LogFile = Join-Path $ScriptDir "clean_pict_cache.log"

# 1. 日誌自動滾動 (超過 1MB 則更換)
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

try {
    if (Test-Path $BaselineFile) {
        $BaselinePaths = Get-Content $BaselineFile | ForEach-Object { 
            $Trimmed = $_.Trim()
            if ($Trimmed) { Join-Path $TargetDir $Trimmed }
        } | Where-Object { $_ -ne $null }
        
        $PictPath = Join-Path $TargetDir "pict"
        if (Test-Path $PictPath) {
            # 取得所有項目（由深到淺）
            $CurrentItems = Get-ChildItem -Path $PictPath -Recurse | Sort-Object -Property FullName -Descending
            foreach ($Item in $CurrentItems) {
                if ($BaselinePaths -notcontains $Item.FullName) {
                    $Msg = "Deleting: $($Item.FullName)"
                    Add-Content -Path $LogFile -Value $Msg
                    
                    if ($WhatIf) {
                        Write-Host "[What-If] $Msg" -ForegroundColor Yellow
                    } else {
                        Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            }
        } else {
            Add-Content -Path $LogFile -Value "Warning: 'pict' folder not found."
        }
    } else {
        Add-Content -Path $LogFile -Value "Error: Baseline file not found at $BaselineFile"
    }
    Add-Content -Path $LogFile -Value "${ModePrefix}Clean Job Finished Successfully."
} catch {
    Add-Content -Path $LogFile -Value "Error: $($_.Exception.Message)"
} finally {
    Add-Content -Path $LogFile -Value "--- End ---`n"
}
