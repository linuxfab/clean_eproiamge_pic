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
