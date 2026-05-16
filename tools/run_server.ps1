# tools/run_server.ps1
# Starts the local WebSocket server for Twin Core Blasters.

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ServerDir = Join-Path $ProjectRoot "server"

if (-not (Test-Path (Join-Path $ServerDir "package.json"))) {
    Write-Host "server/package.json was not found." -ForegroundColor Red
    exit 1
}

Set-Location $ServerDir

if (-not (Test-Path ".\node_modules")) {
    Write-Host "Installing server dependencies..." -ForegroundColor Cyan
    npm install
}

Write-Host "Starting WebSocket server..." -ForegroundColor Cyan
Write-Host "URL: ws://localhost:8080" -ForegroundColor Green

npm start
