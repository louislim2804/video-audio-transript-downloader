@echo off
REM ── PowerShell version launcher (uses ytget.ps1) ──
chcp 65001 > nul
powershell.exe -ExecutionPolicy Bypass -File "%~dp0ytget.ps1"
