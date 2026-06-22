# Push AI secrets from config/production.env to Firebase Functions.
# Usage: .\scripts\set-function-secrets.ps1

param(
    [string]$ProjectId = "blooddonation-89361"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$EnvPath = Join-Path $ProjectRoot "config/production.env"
$FunctionsEnvPath = Join-Path $ProjectRoot "functions/.env"

function Read-EnvValue {
    param([string]$Key)
    if (-not (Test-Path $EnvPath)) {
        return ""
    }
    foreach ($line in Get-Content $EnvPath) {
        if ($line -match "^\s*$Key\s*=\s*(.+)\s*$") {
            return $Matches[1].Trim()
        }
    }
    return ""
}

$model = Read-EnvValue "GITHUB_MODELS_MODEL"
if (-not $model) { $model = "openai/gpt-4.1-mini" }
$apiVersion = Read-EnvValue "GITHUB_API_VERSION"
if (-not $apiVersion) { $apiVersion = "2022-11-28" }

@"
GITHUB_MODELS_MODEL=$model
GITHUB_API_VERSION=$apiVersion
"@ | Set-Content -Path $FunctionsEnvPath -Encoding UTF8
Write-Host "Wrote functions/.env (model + API version)" -ForegroundColor Cyan

$githubToken = Read-EnvValue "GITHUB_MODELS_TOKEN"
if ($githubToken) {
    Write-Host "Setting GITHUB_MODELS_TOKEN secret..." -ForegroundColor Cyan
    $githubToken | npx --yes firebase-tools functions:secrets:set GITHUB_MODELS_TOKEN --project $ProjectId
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} else {
    Write-Host "GITHUB_MODELS_TOKEN not in config/production.env — add it and re-run." -ForegroundColor Yellow
}

$openAiKey = Read-EnvValue "OPENAI_API_KEY"
if ($openAiKey) {
    Write-Host "Setting OPENAI_API_KEY secret (optional fallback)..." -ForegroundColor Cyan
    $openAiKey | npx --yes firebase-tools functions:secrets:set OPENAI_API_KEY --project $ProjectId
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "Function secrets configured." -ForegroundColor Green
