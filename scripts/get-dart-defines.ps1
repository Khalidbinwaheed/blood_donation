param(
    [string]$EnvFile = "config/production.env"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Path = Join-Path $ProjectRoot $EnvFile

if (-not (Test-Path $Path)) {
    Write-Host "No env file at $Path — using defaults only." -ForegroundColor Yellow
    return @()
}

$defines = @()
Get-Content $Path | ForEach-Object {
    $line = $_.Trim()
    if ($line.Length -eq 0 -or $line.StartsWith('#')) {
        return
    }
    $parts = $line.Split('=', 2)
    if ($parts.Length -ne 2) {
        return
    }
    $key = $parts[0].Trim()
    $value = $parts[1].Trim()
    if ($value.Length -eq 0) {
        return
    }
    if ($key -eq 'OPENAI_API_KEY' -or $key -eq 'GITHUB_MODELS_TOKEN') {
        return
    }
    $escaped = $value.Replace('"', '\"')
    $defines += "--dart-define=${key}=$escaped"
}

return $defines
