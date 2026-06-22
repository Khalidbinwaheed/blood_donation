# Deploy Lifeline to Firebase (Firestore + Web Hosting)
# Prerequisites: Node.js, Flutter SDK, Firebase project access
#
# First-time setup:
#   1. Copy config/production.env.example -> config/production.env
#   2. Fill OPENAI_API_KEY, GOOGLE_MAPS_API_KEY, GOOGLE_WEB_CLIENT_ID
#   3. npx firebase-tools login
#
# Usage:
#   .\scripts\deploy.ps1
#   .\scripts\deploy.ps1 -FirestoreOnly
#   .\scripts\deploy.ps1 -HostingOnly

param(
    [switch]$FirestoreOnly,
    [switch]$HostingOnly
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$ProjectId = "blooddonation-89361"

function Invoke-Firebase {
    param([string[]]$Args)
    & npx --yes firebase-tools @Args
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

function Read-EnvValue {
    param([string]$Key)
    $envPath = Join-Path $ProjectRoot "config/production.env"
    if (-not (Test-Path $envPath)) {
        return ""
    }
    foreach ($line in Get-Content $envPath) {
        if ($line -match "^\s*$Key\s*=\s*(.+)\s*$") {
            return $Matches[1].Trim()
        }
    }
    return ""
}

if (-not $HostingOnly) {
    Write-Host "Configuring Cloud Function secrets..." -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot "set-function-secrets.ps1") -ProjectId $ProjectId

    Write-Host "Deploying Firestore rules, indexes, and Storage rules..." -ForegroundColor Cyan
    Invoke-Firebase @("deploy", "--only", "firestore:rules,firestore:indexes,storage", "--project", $ProjectId)

    Write-Host "Deploying Cloud Functions..." -ForegroundColor Cyan
    Push-Location (Join-Path $ProjectRoot "functions")
    if (-not (Test-Path "node_modules")) {
        npm install
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    Pop-Location
    Invoke-Firebase @("deploy", "--only", "functions", "--project", $ProjectId)
}

if (-not $FirestoreOnly) {
    $defines = & (Join-Path $PSScriptRoot "get-dart-defines.ps1")
    $mapsKey = Read-EnvValue "GOOGLE_MAPS_API_KEY"
    & (Join-Path $PSScriptRoot "inject-web-maps-key.ps1") -MapsApiKey $mapsKey

    Write-Host "Building Flutter web release..." -ForegroundColor Cyan
    $buildArgs = @("build", "web", "--release") + $defines
    & flutter @buildArgs
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "Deploying Firebase Hosting..." -ForegroundColor Cyan
    Invoke-Firebase @("deploy", "--only", "hosting", "--project", $ProjectId)
}

Write-Host "Deploy complete." -ForegroundColor Green
Write-Host "Web: https://blooddonation-89361.web.app" -ForegroundColor Green
