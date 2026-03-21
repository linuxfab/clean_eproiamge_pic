# 設定編碼為 UTF8 以支援中文日誌
$OutputEncoding = [System.Text.Encoding]::UTF8

# 1. 取得腳本所在的目錄 (基準線檔案 pict_baseline.txt 會放在這裡)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BaselineFile = Join-Path $ScriptDir "pict_baseline.txt"

# 2. 取得要處理的目標路徑 (第一個參數)，若無則預設為目前目錄
$RawPath = if ($args[0]) { $args[0] } else { "." }

# 3. 轉換為絕對路徑
if (-not (Test-Path $RawPath)) {
    Write-Error "Error: Path '$RawPath' does not exist."
    exit 1
}
$TargetDir = (Get-Item $RawPath).FullName

$LogFile = Join-Path $TargetDir "cleaner.log"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-Content -Path $LogFile -Value "--- Manual Clean Job Started at $Timestamp ---"
Add-Content -Path $LogFile -Value "Target Directory: $TargetDir"
Add-Content -Path $LogFile -Value "Baseline File: $BaselineFile"

try {
    if (Test-Path $BaselineFile) {
        # 讀取基準線相對路徑並轉為絕對路徑
        $BaselinePaths = Get-Content $BaselineFile | ForEach-Object { 
            $Trimmed = $_.Trim()
            if ($Trimmed) { Join-Path $TargetDir $Trimmed }
        } | Where-Object { $_ -ne $null }
        
        $PictPath = Join-Path $TargetDir "pict"
        if (Test-Path $PictPath) {
            # 取得所有項目（由深到淺，處理刪除）
            $CurrentPictItems = Get-ChildItem -Path $PictPath -Recurse | Sort-Object -Property FullName -Descending

            foreach ($Item in $CurrentPictItems) {
                if ($BaselinePaths -notcontains $Item.FullName) {
                    Add-Content -Path $LogFile -Value "Deleting New Pict Item: $($Item.FullName)"
                    Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        } else {
            Add-Content -Path $LogFile -Value "Warning: 'pict' folder not found in target directory."
        }
    } else {
        Add-Content -Path $LogFile -Value "Warning: Baseline file (pict_baseline.txt) not found in $ScriptDir."
    }
    Add-Content -Path $LogFile -Value "Clean Job Finished Successfully."
}
catch {
    $ErrMsg = "Critical Error: " + $_.Exception.Message
    Add-Content -Path $LogFile -Value $ErrMsg
    Write-Error $ErrMsg
}
finally {
    Add-Content -Path $LogFile -Value "--- End of Log ---`n"
}
