# 2026-03-21 09:49
# 重點: 修正 PowerShell 語法錯誤，並將基準線檔案位置固定在腳本旁邊。
# 影響: 使用者可以清理任意目標目錄，基準線檔案 (`pict_baseline.txt`) 統一讀取腳本同層的檔案。
# 結果: 增加了靈活性，且解決了 Try/Catch 造成的 Parser Error。
# 更新者: antigravity agent.
