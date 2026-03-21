# 設定編碼為 UTF8 以支援中文日誌
$OutputEncoding = [System.Text.Encoding]::UTF8

# 取得腳本所在目錄的絕對路徑
$TargetDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogFile = Join-Path $TargetDir "cleaner.log"
$BaselineFile = Join-Path $TargetDir "pict_baseline.txt"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-Content -Path $LogFile -Value "--- Manual Clean Job Started at $Timestamp ---"

try {
    # 僅處理 pict 資料夾內部的變動，根據使用者的要求，不刪除同層的其他檔案或資料夾
    if (Test-Path $BaselineFile) {
        # 讀取基準線相對路徑並轉為絕對路徑以利比對
        $BaselinePaths = Get-Content $BaselineFile | ForEach-Object { 
            $RelPath = $_.Trim()
            if ($RelPath) { Join-Path $TargetDir $RelPath }
        } | Where-Object { $_ -ne $null }
        
        # 取得目前 pict 下的所有項目（由深到淺，處理刪除）
        $PictPath = Join-Path $TargetDir "pict"
        if (Test-Path $PictPath) {
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
        Add-Content -Path $LogFile -Value "Warning: Baseline file (pict_baseline.txt) not found. Nothing cleaned."
    }

    Add-Content -Path $LogFile -Value "Clean Job Finished Successfully."
}
catch {
    Add-Content -Path $LogFile -Value "Error occurred: $_"
}

Add-Content -Path $LogFile -Value "--- End of Log ---`n"
