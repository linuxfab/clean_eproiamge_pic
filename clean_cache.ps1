$OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BaselineFile = Join-Path $ScriptDir "clean_pic_cache_baseline.txt"
$RawPath = if ($args[0]) { $args[0] } else { "." }
if (-not (Test-Path $RawPath)) { Write-Error "Path '$RawPath' not found"; exit 1 }
$TargetDir = (Get-Item $RawPath).FullName
$LogFile = Join-Path $TargetDir "cleaner.log"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $LogFile -Value "--- Clean Start $Timestamp ---"
try {
    if (Test-Path $BaselineFile) {
        $Lines = Get-Content $BaselineFile
        $BaselinePaths = @()
        foreach ($L in $Lines) {
            $T = $L.Trim()
            if ($T) { $BaselinePaths += Join-Path $TargetDir $T }
        }
        $PictPath = Join-Path $TargetDir "pict"
        if (Test-Path $PictPath) {
            $CurrentItems = Get-ChildItem -Path $PictPath -Recurse | Sort-Object -Property FullName -Descending
            foreach ($Item in $CurrentItems) {
                if ($BaselinePaths -notcontains $Item.FullName) {
                    Add-Content -Path $LogFile -Value "Deleting: $($Item.FullName)"
                    Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
    } else {
        Add-Content -Path $LogFile -Value "No Baseline found"
    }
} catch {
    Add-Content -Path $LogFile -Value "Error: $($_.Exception.Message)"
} finally {
    Add-Content -Path $LogFile -Value "--- End ---"
}
