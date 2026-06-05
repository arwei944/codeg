@echo off
if not "%~1"=="get" exit /b 0
"D:\work\opencode-work\codeg-user-modified\src-tauri\target\debug\codeg-server.exe" --credential-helper --data-dir "D:\work\opencode-work\codeg-user-modified\.codeg-data"
