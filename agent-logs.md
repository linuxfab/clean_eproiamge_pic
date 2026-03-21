# 2026-03-21 09:44
# 重點: 增加 `clean_cache.ps1` 的參數化支援，允許清理不同位置的 `pict`。
# 影響: 更新腳本以接受 `$TargetDir` 參數；基準線路徑解析邏輯優化。
# 結果: 使用者可以透過 `.\clean_cache.ps1 -TargetDir "C:\path\to\your\folder"` 來清理任意位置（需附帶 `pict_baseline.txt`）。
# 更新者: antigravity agent.
