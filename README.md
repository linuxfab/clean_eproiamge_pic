# Pict Cache Cleaner (v2.0)
作者: [linuxfab](https://github.com/linuxfab) [https://github.com/linuxfab/clean_eproiamge_pic](https://github.com/linuxfab/clean_eproiamge_pic)  
最後更新時間: 2026-10-28 00:55

## 專案介紹
這是一個專為 Windows 環境設計的快取清理工具，特別針對 `pict` 資料夾設計。透過讀取基準線檔案 (`clean_pict_cache_baseline.txt`)，腳本能精確地將目標目錄下的 `pict` 資料夾還原至初始狀態，刪除所有後來產生的多餘檔案與子目錄。

本專案將程式原始碼與建置發布檔分離，預先打包好的離線壓縮包 (`clean_cache.zip`) 透過 [GitHub Releases](https://github.com/linuxfab/clean_eproiamge_pic/releases) 發行下載，Git 儲存庫僅保留核心原始碼與基準線設定檔。

## 核心功能
- **精確還原 (Baseline-based)**: 僅保留基準線中定義的檔案結構，其餘全數刪除。
- **模擬執行 (Dry Run)**: 提供 `-WhatIf` 參數，可在不實際刪檔的情況下預覽結果。
- **日誌滾動 (Log Rotation)**: 當日誌檔超過 1MB 時自動輪替為 `.log.old`，避免無限制佔用硬碟空間。
- **安全防呆機制 (Safety Lock)**: 嚴格驗證目標路徑是否包含 `\eProImage` 或 `\pict`，避免誤指定路徑損及系統根目錄。
- **自動清空空夾**: 清理非基準線檔案後，遞迴移除多餘空白殘存子目錄。
- **預設路徑**: 預設處理 `C:\YOUSING\eProImage`，亦可手動傳入自訂目標路徑。

## 目錄結構
- `clean_pict_cache.ps1`: 核心清理腳本 (PowerShell)。
- `clean_pict_cache_baseline.txt`: 還原基準線檔案 (UTF-8 編碼，定義白名單相對路徑)。
- `clean_pict_cache.log`: 操作紀錄檔 (超過 1MB 自動滾動為 `.old`)。
- `agent-logs.md`: 開發與維護歷程記錄。
- `README.md`: 專案工程說明文件。

> **註**：部署用離線打包檔 `clean_cache.zip` 可直接由 [GitHub Releases 頁面](https://github.com/linuxfab/clean_eproiamge_pic/releases) 下載最新版本。

## 基準線結構說明 (Baseline Structure)
基準線檔案 `clean_pict_cache_baseline.txt` 採用純文字 UTF-8 編碼儲存，每行代表允許保留的相對路徑：
```text
pict\null_0
pict\tmb
pict\null_0\null
pict\tmb\l
pict\tmb\m
pict\tmb\s
pict\tmb\l\null_0
pict\tmb\l\null_0\null
pict\tmb\m\null_0
pict\tmb\m\null_0\null
pict\tmb\s\null_0
pict\tmb\s\null_0\null
```
比對邏輯：腳本掃描目標目錄下 `pict` 之所有項目，將目標絕對路徑與基準線相對路徑拼接展開，不在白名單內的項目即視為快取垃圾並執行清除。

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
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 02:00
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName "Weekly_Pict_Cache_Cleaner" -Description "每週一自動清理 Pict 快取" -RunLevel Highest -Force
```

#### 3.1 修改排程參數
若需要更改清理路徑、時間或增加 `-WhatIf` 模擬模式，只需**修改對應變數並重新執行**上述指令即可。由於使用了 `-Force` 參數，系統會自動覆蓋舊的排程。

**常用修改範例：**
- **更改目標路徑或模式**: 修改 `$Action` 中的 `-Argument`。
  ```powershell
  # 範例：指定清理 d:\YOUSING\eProImage 並開啟模擬模式
  $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""$ScriptPath"" ""d:\YOUSING\eProImage"" -WhatIf"
  ```
- **更改執行時間**: 修改 `$Trigger` 參數。
  ```powershell
  # 範例：改為每天凌晨 02:00 執行
  $Trigger = New-ScheduledTaskTrigger -Daily -At 02:00
  ```

#### 3.2 檢視排程說明
若要確認排程工作是否正確註冊或查看其功能說明，有以下兩種方式：

**1. 使用工作排程器 (GUI)**
- 按下 `Win + R` 輸入 `taskschd.msc` 並確認。
- 在左側選單中，點選「工作排程器程式庫」。
- 在中間列表中找到 `Weekly_Pict_Cache_Cleaner`。
- 對其點選右鍵 ->「內容」，即可在「一般」頁籤看到「描述」。

**2. 使用 PowerShell (推薦)**
- 以管理員權限執行以下指令：
  ```powershell
  # 快速查看特定排程的說明
  (Get-ScheduledTask -TaskName "Weekly_Pict_Cache_Cleaner").Description
  
  # 查看該排程的所有細節 (包含名稱、狀態、說明等)
  Get-ScheduledTask -TaskName "Weekly_Pict_Cache_Cleaner" | Format-List *
  ```

## 注意事項
- 基準線檔案 `clean_pict_cache_baseline.txt` 必須與腳本放在同一個資料夾。
- 執行清理前請確保沒有程式正在佔用 `pict` 資料夾內部的特定檔案。

## 📌 跨電腦執行與移轉常見問題 (Troubleshooting)
當您將本工具拷貝到其他電腦執行時，常見會遇到以下問題與解決方案：

### 1. 執行原則 (Execution Policy) 限制
- **狀況**：出現「因為在此系統上禁止執行指令碼...」的紅字錯誤。
- **原因**：Windows 預設基於安全考量會關閉 PowerShell 執行權限。
- **解法**：請使用**系統管理員**開啟 PowerShell，並執行以下指令來解除鎖定：
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Force
  ```

### 2. 檔案編碼 (Encoding) 導致路徑比對失敗
- **狀況**：腳本順利執行，但跳出黃字說 **全數刪除** 或找不到檔案。
- **原因**：`clean_pict_cache_baseline.txt` 在其他電腦若使用了舊式 `ANSI` 或 `UTF-16` 格式儲存，會造成 PowerShell 抓取路徑亂碼。
- **解法**：儲存庫內基準線檔案已採用標準 UTF-8 編碼。若自行編輯，請務必使用 VS Code 或 Notepad 另存為 **「UTF-8 (無 BOM)」** 格式。

### 3. 排程與系統管理員權限 (Admin Privileges)
- **狀況**：執行排程註冊語法時，發生 `Access denied` 錯誤。
- **解法**：設定自動排程（工作排程器）需要極高的系統控制級別。請務必按右鍵選擇 **「以系統管理員身分執行」** 開啟 PowerShell 視窗進行排程綁定。
