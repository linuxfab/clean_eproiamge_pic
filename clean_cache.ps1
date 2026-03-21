# 設定編碼為 UTF8 以支援中文日誌
$OutputEncoding = [System.Text.Encoding]::UTF8

$TargetDir = "d:\googledrive\MyData\antigravity_workspace\clean_eproiamge_pic"
$LogFile = Join-Path $TargetDir "cleaner.log"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 要保留的項目列表 (資料夾名稱或檔案名稱)
$KeepItems = @("pict", ".git", "clean_cache.ps1", "setup_schedule.ps1", "README.md", "cleaner.log", "agent-logs.md", ".gitignore")

Add-Content -Path $LogFile -Value "--- Clean Job Started at $Timestamp ---"

try {
    # 取得目錄下所有項目
    $Items = Get-ChildItem -Path $TargetDir

    foreach ($Item in $Items) {
        if ($KeepItems -notcontains $Item.Name) {
            Add-Content -Path $LogFile -Value "Deleting: $($Item.FullName)"
            Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Add-Content -Path $LogFile -Value "Clean Job Finished Successfully."
}
catch {
    Add-Content -Path $LogFile -Value "Error occurred: $_"
}

Add-Content -Path $LogFile -Value "--- End of Log ---`n"
