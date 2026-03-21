# Pict Cache Cleaner (v2.0)
作者: [linuxfab](https://github.com/linuxfab) [https://github.com/linuxfab/clean_eproiamge_pic](https://github.com/linuxfab/clean_eproiamge_pic)
最後更新時間: 2026-03-21 11:05

## 專案介紹
這是一個專為 Windows 環境設計的快取清理工具，特別針對 `pict` 資料夾設計。透過讀取基準線檔案 (`clean_pict_cache_baseline.txt`)，腳本能精確地將目標目錄下的 `pict` 資料夾還原至初始狀態，刪除所有後來產生的多餘檔案與子目錄。

## 核心功能
- **精確還原 (Baseline-based)**: 僅保留基準線中定義的檔案結構，其餘全數刪除。
- **模擬執行 (Dry Run)**: 提供 `-WhatIf` 參數，可在不實際刪檔的情況下預覽結果。
- **日誌滾動 (Log Rotation)**: 當日誌檔超過 1MB 時自動重置，避免佔用硬碟空間。
- **進程保護 (Process Protection)**: 執行前會檢查相關程式（預設為 `eProImage`）是否正在執行，防止檔案鎖定衝突。
- **預設路徑**: 預設處理 `C:\YOUSING\eProImage`，亦可手動指定其他路徑。

## 目錄結構
- `clean_pict_cache.ps1`: 核心清理腳本 (PowerShell)。
- `clean_pict_cache_baseline.txt`: 還原基準線檔案 (存放各檔案/目錄的相對路徑)。
- `clean_pict_cache.log`: 操作紀錄。
- `agent-logs.md`: 開發與維護日誌。

## 使用說明

### 1. 手動執行
可以直接執行腳本，程式會預設處理 `C:\YOUSING\eProImage`：
```powershell
.\clean_pict_cache.ps1
```

若要處理其他路徑，直接在後面接參數即可：
```powershell
.\clean_pict_cache.ps1 D:\Backup\ProjectA
```

### 2. 安全預覽 (What-If)
強烈建議在處理重要目錄前先執行模擬模式：
```powershell
.\clean_pict_cache.ps1 -WhatIf
```
畫面上會以 **黃色文字** 標示出「預計被刪除」的項目，但不會實際執行刪除。

### 3. 自動化排程 (每週一自動執行)
若要設定為每週一凌晨自動背景清理，請以 **系統管理員** 權限執行。
**(內含防漏機制：若排定時間電腦未開機，下次開機會自動補執行)**

```powershell
# 請先進入腳本所在目錄，再執行以下指令
$ScriptPath = (Get-Item '.\clean_pict_cache.ps1').FullName
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""$ScriptPath"""
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 00:00
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName "Weekly_Pict_Cache_Cleaner" -Description "每週一自動清理 Pict 快取" -RunLevel Highest -Force
```

## 注意事項
- 基準線檔案 `clean_pict_cache_baseline.txt` 必須與腳本放在同一個資料夾。
- 執行清理前請確保沒有程式正在佔用 `pict` 資料夾內的檔案。
