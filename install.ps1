# codeg-server v0.15.0 Installer
# Run: iex (irm https://raw.githubusercontent.com/arwei944/codeg/main/install.ps1)

$ErrorActionPreference = "Stop"
$repo = "arwei944/codeg"
$version = "v0.15.0"
$installDir = "$env:LOCALAPPDATA\codeg"

Write-Host ">>> codeg-server $version Installer" -ForegroundColor Cyan
Write-Host ""

# Create install directory
New-Item -ItemType Directory -Path "$installDir\bin" -Force | Out-Null
New-Item -ItemType Directory -Path "$installDir\web" -Force | Out-Null
New-Item -ItemType Directory -Path "$installDir\data" -Force | Out-Null

# Download server binary
Write-Host "Downloading codeg-server.exe..." -ForegroundColor Yellow
$binUrl = "https://github.com/$repo/releases/download/$version/codeg-server.exe"
$binPath = "$installDir\bin\codeg-server.exe"
Invoke-WebRequest -Uri $binUrl -OutFile $binPath -UseBasicParsing
Write-Host "  OK ($((Get-Item $binPath).Length/1MB) MB)" -ForegroundColor Green

# Download web frontend
Write-Host "Downloading web frontend..." -ForegroundColor Yellow
$webUrl = "https://github.com/$repo/releases/download/$version/codeg-web-v0.15.0.zip"
$webZip = "$env:TEMP\codeg-web.zip"
Invoke-WebRequest -Uri $webUrl -OutFile $webZip -UseBasicParsing
Expand-Archive -Path $webZip -DestinationPath "$installDir\web" -Force
Write-Host "  OK" -ForegroundColor Green

# Create config file
$token = [System.Guid]::NewGuid().ToString("N").Substring(0, 16)
@"
CODEG_TOKEN=$token
CODEG_PORT=3080
CODEG_STATIC_DIR=$installDir\web
CODEG_DATA_DIR=$installDir\data
"@ | Set-Content "$installDir\.env" -Encoding ASCII

# Create run script
@"
@echo off
setlocal
for /f "tokens=*" %%%%a in (%LOCALAPPDATA%\codeg\.env) do set %%%%a
start "" "http://localhost:%CODEG_PORT%"
"%LOCALAPPDATA%\codeg\bin\codeg-server.exe"
pause
"@ | Set-Content "$installDir\run-codeg.bat" -Encoding ASCII

# Create desktop shortcut via PowerShell
$shortcutPath = "$env:USERPROFILE\Desktop\codeg-server.lnk"
$wshell = New-Object -ComObject WScript.Shell
$shortcut = $wshell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "$installDir\run-codeg.bat"
$shortcut.Description = "codeg-server v0.15.0"
$shortcut.IconLocation = "$installDir\bin\codeg-server.exe,0"
$shortcut.WorkingDirectory = "$installDir"
$shortcut.Save()

Write-Host ""
Write-Host ">>> Installation complete!" -ForegroundColor Green
Write-Host "Install dir: $installDir" -ForegroundColor Cyan
Write-Host "Desktop shortcut created" -ForegroundColor Cyan
Write-Host "Token: $token" -ForegroundColor Cyan
Write-Host ""
Write-Host "Double-click the desktop icon to start." -ForegroundColor Yellow
