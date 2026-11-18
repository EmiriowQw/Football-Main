@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0frontend\tool\run_demo.ps1"
if errorlevel 1 pause
