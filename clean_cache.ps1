# 設定編碼為 UTF8 以支援中文日誌
$OutputEncoding = [System.Text.Encoding]::UTF8

$TargetDir = "d:\googledrive\MyData\antigravity_workspace\clean_eproiamge_pic"
$LogFile = Join-Path $TargetDir "cleaner.log"
$BaselineFile = Join-Path $TargetDir "pict_baseline.txt"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 根目錄要保留的項目 (排除這些不砍，其餘外部檔案都砍)
$KeepRootItems = @("pict", ".git", "clean_cache.ps1", "README.md", "cleaner.log", "agent-logs.md", ".gitignore", "pict_baseline.txt")

Add-Content -Path $LogFile -Value "--- Clean Job Started at $Timestamp ---"

try {
    # 1. 處理根目錄下的雜物
    $RootItems = Get-ChildItem -Path $TargetDir
    foreach ($Item in $RootItems) {
        if ($KeepRootItems -notcontains $Item.Name) {
            Add-Content -Path $LogFile -Value "Deleting External Item: $($Item.FullName)"
            Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # 2. 處理 pict 資料夾內部的變動
    if (Test-Path $BaselineFile) {
        # 讀取基準線路徑（轉為絕對路徑以利比對）
        $BaselinePaths = Get-Content $BaselineFile | ForEach-Object { $_.Trim() }
        
        # 取得目前 pict 下的所有項目（由深到淺，方便刪除檔案後刪除空目錄）
        $CurrentPictItems = Get-ChildItem -Path (Join-Path $TargetDir "pict") -Recurse | Sort-Object -Property FullName -Descending

        foreach ($Item in $CurrentPictItems) {
            if ($BaselinePaths -notcontains $Item.FullName) {
                Add-Content -Path $LogFile -Value "Deleting New Pict Item: $($Item.FullName)"
                Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    } else {
        Add-Content -Path $LogFile -Value "Warning: Baseline file not found. pict folder content was not cleaned."
    }

    Add-Content -Path $LogFile -Value "Clean Job Finished Successfully."
}
catch {
    Add-Content -Path $LogFile -Value "Error occurred: $_"
}

Add-Content -Path $LogFile -Value "--- End of Log ---`n"
