@echo off
title Daily Tracker — Auto Sync Watcher
color 04
echo.
echo  =======================================
echo   Daily Tracker — Auto Sync Active
echo  =======================================
echo   Keep this window OPEN in background
echo   Close it to STOP auto-sync
echo  =======================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0auto-push.ps1"
pause
