$TaskName = "WeeklyCacheCleaner_CleanEproimage"
$ScriptPath = "d:\googledrive\MyData\antigravity_workspace\clean_eproiamge_pic\clean_cache.ps1"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 4am

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

# 改為使用目前的執行使用者，並設定在登入時執行或有最高權限
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName $TaskName -Description "Weekly cache cleaning script" -RunLevel Highest

Write-Host "Done"
