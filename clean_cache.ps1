# 設定編碼為 UTF8 以支援中文日誌
$OutputEncoding = [System.Text.Encoding]::UTF8

# 使用變數接收第一個參數，如果沒給就用目前腳本所在目錄
$TargetDir = if ($args[0]) { $args[0] } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }

# 轉換為絕對路徑以確保後續邏輯正確
$TargetDir = Resolve-Path $TargetDir -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
if (-not $TargetDir) {
    Write-Error "Invalid Target Directory."
    exit
}

$LogFile = Join-Path $TargetDir "cleaner.log"
$BaselineFile = Join-Path $TargetDir "pict_baseline.txt"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-Content -Path $LogFile -Value "--- Manual Clean Job Started at $Timestamp ---"
Add-Content -Path $LogFile -Value "Target Directory: $TargetDir"

try {
    # 檢查基準線檔案
    if (Test-Path $BaselineFile) {
        $BaselinePaths = Get-Content $BaselineFile | ForEach-Object { 
            $Trimmed = $_.Trim()
            if ($Trimmed) { Join-Path $TargetDir $Trimmed }
        } | Where-Object { $_ -ne $null }
        
        $PictPath = Join-Path $TargetDir "pict"
        if (Test-Path $PictPath) {
            # 取得所有項目（深到淺）
            $CurrentPictItems = Get-ChildItem -Path $PictPath -Recurse | Sort-Object -Property FullName -Descending

            foreach ($Item in $CurrentPictItems) {
                if ($BaselinePaths -notcontains $Item.FullName) {
                    Add-Content -Path $LogFile -Value "Deleting New Pict Item: $($Item.FullName)"
                    Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        } else {
            Add-Content -Path $LogFile -Value "Warning: pict folder not found."
        }
    } else {
        Add-Content -Path $LogFile -Value "Warning: Baseline file (pict_baseline.txt) not found in $TargetDir. Nothing cleaned."
    }
    Add-Content -Path $LogFile -Value "Clean Job Finished Successfully."
}
catch {
    Add-Content -Path $LogFile -Value "Error occurred: $_"
}

Add-Content -Path $LogFile -Value "--- End of Log ---`n"
