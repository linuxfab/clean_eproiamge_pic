# 2026-10-28 00:58
# 重點: 全面重構 README.md 為工程級技術架構與維運指南。
# 影響: 
#   1. 新增 Mermaid 執行生命週期狀態機流程圖。
#   2. 深入剖析逆序刪除演算法 (Descending Path Traversal)、安全防爆鎖機制與日誌自動滾動原理。
#   3. 詳細圖解白名單樹狀目錄結構映射 (Directory Structure Map)。
#   4. 補充 Windows 工作排程器 (Task Scheduler) 完整 CLI 指令集（建立、手動觸發、查詢、移除）。
#   5. 建立系統診斷與故障排除矩陣 (Troubleshooting Matrix)。
# 結果: 技術文件完整度達到生產系統標準，提供工程師清晰的架構認知與維運指引。
# 更新者: antigravity agent.

# 2026-10-28 00:55
# 重點: 移除追蹤建置產物 clean_cache.zip，並將 baseline 轉存為標準 UTF-8。
# 影響: 
#   1. 從 git 追蹤中移除 `clean_cache.zip`（`git rm --cached`），由 GitHub Releases 託管發布產物。
#   2. 將 `clean_pict_cache_baseline.txt` 編碼由 UTF-16LE 轉為 UTF-8 (無 BOM)，避免 Git 將其誤認為 Binary 檔案與 PowerShell 比對亂碼。
#   3. 更新 `README.md` 說明 Release 下載方式與專案結構。
# 結果: 儲存庫保持輕量純淨，建置產物與程式碼追蹤職責分離，跨平台與排程比對更穩定。
# 更新者: antigravity agent.

# 2026-03-22 13:05
# 重點: 新增如何檢視 Windows 排程工作說明的指引。
# 影響: 更新 `README.md` 加入「3.2 檢視排程說明」章節，包含 GUI 與 PowerShell 指令。
# 結果: 用戶可更輕易地確認排程註冊狀態與功能描述。
# 更新者: antigravity agent.

# 2026-03-22 11:23
# 重點: 專案發布至 GitHub 倉庫。
# 影響: 更新 `README.md` 之 GitHub 連結與更新時間，並同步推送至遠端倉庫。
# 結果: 專案已建立遠端備份，便於版本控管與跨環境部署。
# 更新者: antigravity agent.

# 2026-03-21 21:32
# 重點: 載入路徑安全錨定、清理空殼目錄與 .log.old 滾動防脹優化。
# 影響: 
#   1. 新增 $TargetDir 僅限匹配 *\eProImage* 或 *\pict* 的防爆碟鎖定。
#   2. 在檔案刪除終點加入 `$EmptyDirs` 遞迴篩選與空夾 Remove。
#   3. 將日誌 1MB 原地摧毀改為 `.log.old` 輪替追溯。
# 結果: 行維運腳本邁入極致安全與完全潔淨。
# 更新者: antigravity agent.

# 2026-03-21 21:30
# 重點: 移除所有 javaw/IsRunning 的軟體級別安全鎖。
# 影響: 更新 `clean_pict_cache.ps1` 與 `README.md`，拔除 WindowTitles 與 WMI 進程掃描。
# 結果: 腳本純粹化為檔案快取刪除器，即便系統有相關 eProImage 客戶端在運作，清理也將硬性嘗試執行，不再中止。
# 更新者: antigravity agent.

# 2026-03-21 21:26
# 重點: 額外移除「YOUSING」進程關鍵字審查。
# 影響: 更新 `clean_pict_cache.ps1` 中移除 $K2，連帶簡化 WMI 偵測時的比對。專注於 `eProImage` 識別防除。
# 結果: 全面移除可能導致腳本非預期暫停執行（誤鎖定）的寬鬆關鍵字檢查。
# 更新者: antigravity agent.

# 2026-03-21 21:25
# 重點: 移除特定進程名稱「北極星」與「光遠」的審查機制。
# 影響: 更新 `clean_pict_cache.ps1` 中的配對關鍵字 $K3 和 $K4，並在迴圈邏輯中連帶拔除相關的比對。
# 結果: 用戶不再因為非目標軟體遭到腳本誤判而無故終止清理流程，系統防撞鎖定回復專注在 eProImage 內部程序。
# 更新者: antigravity agent.

# 2026-03-21 12:55
# 重點: 支援排程參數自定義說明。
# 影響: 更新 `README.md` 加入「3.1 修改排程參數」章節，說明如何透過修改 `$Action` 與 `$Trigger` 並搭配 `-Force` 覆蓋現有工作排程。
# 結果: 用戶可靈活調整自動清理的目標路徑、時間與執行模式（如加裝 `-WhatIf`）。
# 更新者: antigravity agent.

# 2026-03-21 11:05
# 重點: 修正 Task Scheduler 註冊指令中腳本路徑抓取失敗的問題。
# 影響: 更新 `README.md` 中的自動化排程指令，改用更強健的絕對路徑抓取邏輯 (`$PSScriptRoot` 或明確提示先 `cd` 進入目錄)；加入 GitHub 倉庫連結紀錄。
# 結果: 用戶現在可以更簡單、更無誤地完成每週一的自動化排程設定。
# 更新者: antigravity agent.

# 2026-03-21 11:00
# 重點: 發布 v2.6.x 終極穩定版，解決進程攔截誤判與日誌寫入衝突。
# 影響: 更新 `clean_pict_cache.ps1` 加入緩衝日誌寫入與 javaw 精準攔截；更新 `README.md` 加入排程補執行指令。
# 結果: 完美解決 Java 程式偵測失敗與標題誤判問題，排程自動化更加強健。
# 更新者: antigravity agent.

# 2026-03-21 10:15
# 重點: 發布 v2.0 版本，優化 README 並設定預設參數。
# 影響: 更新 `clean_pict_cache.ps1` 的預設路徑為 `C:\YOUSING\eProImage`；全面重寫 `README.md`。
# 結果: 工具進入穩定階段，支援自動化、安全性預覽與預設路徑執行。
# 更新者: antigravity agent.
