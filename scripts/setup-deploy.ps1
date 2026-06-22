# One-time cloud deploy setup for Lifeline
# Run: .\scripts\setup-deploy.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ProjectId = "blooddonation-89361"

Write-Host "`n=== Lifeline Deploy Setup ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectId"
Write-Host "Web URL: https://${ProjectId}.web.app`n"

# 1. Git push
Write-Host "[1/4] GitHub push" -ForegroundColor Yellow
Push-Location $ProjectRoot
$status = git status -sb
Write-Host $status
Write-Host @"

If push fails with 'permission denied':
  A) Log in to GitHub with access to codecraftitsolution/blood_donation
  B) Or push to your fork:
       git remote set-url origin https://github.com/YOUR_USER/blood_donation.git
       git push -u origin main
  C) Then add secrets in GitHub → Settings → Secrets → Actions

Required GitHub secrets:
  FIREBASE_SERVICE_ACCOUNT   (Firebase service account JSON)
  GOOGLE_MAPS_API_KEY        (optional)
  GOOGLE_WEB_CLIENT_ID       (optional)
  ANDROID_KEYSTORE_BASE64    (optional, for signed APK)
  ANDROID_KEYSTORE_PASSWORD
  ANDROID_KEY_ALIAS
  ANDROID_KEY_PASSWORD
"@ -ForegroundColor Gray

# 2. Firebase login check
Write-Host "[2/4] Firebase CLI" -ForegroundColor Yellow
try {
    npx --yes firebase-tools projects:list --project $ProjectId 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Firebase: logged in" -ForegroundColor Green
        Write-Host "Running set-function-secrets.ps1..." -ForegroundColor Cyan
        & (Join-Path $PSScriptRoot "set-function-secrets.ps1") -ProjectId $ProjectId
    } else { throw "not logged in" }
} catch {
    Write-Host "Firebase: not logged in. Run:" -ForegroundColor Yellow
    Write-Host "  npx firebase-tools login" -ForegroundColor White
    Write-Host "  .\scripts\set-function-secrets.ps1" -ForegroundColor White
}

# 3. GitHub Actions
Write-Host "`n[3/4] Cloud build (no local APK needed)" -ForegroundColor Yellow
Write-Host @"
After push succeeds, open:
  https://github.com/codecraftitsolution/blood_donation/actions

Run workflows:
  • Build APK      → download lifeline-apk from Artifacts
  • Deploy Firebase → web goes live at https://${ProjectId}.web.app
"@ -ForegroundColor Gray

# 4. Firebase service account
Write-Host "[4/4] Firebase service account for GitHub" -ForegroundColor Yellow
Write-Host @"
1. Open: https://console.firebase.google.com/project/$ProjectId/settings/serviceaccounts/adminsdk
2. Generate new private key → save JSON
3. GitHub repo → Settings → Secrets → New secret
   Name:  FIREBASE_SERVICE_ACCOUNT
   Value: paste entire JSON file
"@ -ForegroundColor Gray

Write-Host "`nSetup guide also in docs/DEPLOY-AND-APK.md`n" -ForegroundColor Green
Pop-Location
