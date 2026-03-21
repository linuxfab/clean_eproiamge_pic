# Cache Cleaner for clean_eproiamge_pic
作者: [linuxfab](https://github.com/linuxfab)  
最後更新時間: 2026-03-21 09:32

## 專案介紹
這是一個用於 Windows 的自動清理腳本，旨在每週一凌晨將工作目錄還原至初始狀態，僅保留 `pict` 資料夾及其內容，其餘快取或臨時檔案將被刪除。

## 功能
- **手動清理**: 執行此腳本後，會刪除除了 `pict` 資料夾（還原至基準線）、`.git` 目錄及腳本本身以外的所有檔案。

## 使用說明
1. **手動執行**: 在 PowerShell 執行 `.\clean_pict_cache.ps1`。
2. **自動排程 (每週一開機自動執行)**:
   若要讓 Windows 在每週一開機時自動執行清理且不跳出視窗，請以 **管理員權限** 執行以下 PowerShell 指令：

   ```powershell
   $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""$((Get-Item '.\clean_pict_cache.ps1').FullName)"""
   $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 00:00 # 設定時間，若開機時已過此時間會補執行
   Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "Weekly_Pict_Cache_Cleaner" -Description "每週一自動清理 Pict 快取" -RunLevel Highest -Force
   ```

## 目錄結構
- `pict/`: 保留此資料夾及其下所有子目錄。
- `clean_pict_cache.ps1`: 核心清理腳本。
- `clean_pict_cache_baseline.txt`: 基準線範本。
- `agent-logs.md`: 更新日誌。
