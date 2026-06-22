param(
    [string]$MapsApiKey = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Target = Join-Path $ProjectRoot "web/maps_config.js"

if ([string]::IsNullOrWhiteSpace($MapsApiKey)) {
    Write-Host "Skipping maps_config.js injection (no GOOGLE_MAPS_API_KEY)." -ForegroundColor Yellow
    return
}

$content = @"
// Generated during deploy — do not commit real keys to source control.
window.GOOGLE_MAPS_API_KEY = '$MapsApiKey';
"@

Set-Content -Path $Target -Value $content -Encoding UTF8
Write-Host "Updated web/maps_config.js for hosting build." -ForegroundColor Green
