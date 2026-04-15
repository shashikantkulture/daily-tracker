# =====================================================
#  AUTO-PUSH WATCHER — Daily Task App
#  Watches index.html for changes → auto git push
#  Run this once and leave it open in background
# =====================================================

$watchFolder = "e:\daily task app"
$indexFile   = "index.html"
$gitPath     = "e:\daily task app"
$debounceMs  = 3000   # wait 3s after change before pushing

Write-Host ""
Write-Host "=======================================" -ForegroundColor Red
Write-Host "  Daily Tracker — Auto Sync Watcher" -ForegroundColor White
Write-Host "=======================================" -ForegroundColor Red
Write-Host "  Watching: $watchFolder\$indexFile" -ForegroundColor Gray
Write-Host "  Auto-push to GitHub on every save" -ForegroundColor Gray
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host "=======================================" -ForegroundColor Red
Write-Host ""

# Setup FileSystemWatcher
$watcher                  = New-Object System.IO.FileSystemWatcher
$watcher.Path             = $watchFolder
$watcher.Filter           = $indexFile
$watcher.NotifyFilter     = [System.IO.NotifyFilters]::LastWrite
$watcher.EnableRaisingEvents = $true

$lastPushTime = [DateTime]::MinValue

$action = {
    $now = [DateTime]::Now
    $elapsed = ($now - $lastPushTime).TotalMilliseconds

    # Debounce — only push if last push was >3s ago
    if ($elapsed -gt $debounceMs) {
        $script:lastPushTime = $now
        $timestamp = $now.ToString("yyyy-MM-dd HH:mm:ss")

        Write-Host ""
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Change detected in index.html" -ForegroundColor Yellow
        Write-Host "  Pushing to GitHub..." -ForegroundColor Cyan

        Set-Location $gitPath

        git add index.html 2>&1 | Out-Null
        $commitMsg = "Auto sync: $timestamp"
        git commit -m $commitMsg 2>&1
        $pushResult = git push 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  SUCCESS! Site updated on GitHub" -ForegroundColor Green
            Write-Host "  Netlify will auto-deploy in ~30 seconds" -ForegroundColor Green
        } else {
            Write-Host "  Push failed: $pushResult" -ForegroundColor Red
        }
        Write-Host ""
    }
}

# Register the event
Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null

Write-Host "Watcher is running... (waiting for file changes)" -ForegroundColor Green
Write-Host ""

# Keep script alive
while ($true) {
    Start-Sleep -Seconds 1
}
