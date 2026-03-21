# Cache Cleaner for clean_eproiamge_pic
作者: [linuxfab](https://github.com/linuxfab)  
最後更新時間: 2026-03-21 09:32

## 專案介紹
這是一個用於 Windows 的自動清理腳本，旨在每週一凌晨將工作目錄還原至初始狀態，僅保留 `pict` 資料夾及其內容，其餘快取或臨時檔案將被刪除。

## 功能
- **自動清理**: 刪除除了 `pict` 資料夾、`.git` 目錄及腳本本身以外的所有檔案。
- **定期執行**: 透過 Windows 工作排程器設定每週一自動執行。

## 使用說明
1. 以管理員權限執行 `setup_schedule.ps1` 來設定排程。
2. 手動測試可執行 `.\clean_cache.ps1`。

## 目錄結構
- `pict/`: 保留此資料夾及其下所有子目錄。
- `clean_cache.ps1`: 核心清理腳本。
- `setup_schedule.ps1`: 排程設定腳本。
- `agent-logs.md`: 更新日誌。
