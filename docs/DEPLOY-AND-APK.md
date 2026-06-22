# Deploy & APK Build Guide (Cloud — No Local Build Required)

## Where to deploy

| What | Where | URL / Console |
|------|--------|----------------|
| **Web app** | Firebase Hosting | https://blooddonation-89361.web.app |
| **Backend** | Firebase (same project) | https://console.firebase.google.com/project/blooddonation-89361 |
| **APK download** | GitHub Actions artifacts | Your repo → **Actions** → **Build APK** → **Artifacts** |
| **Play Store** (production) | Google Play Console | https://play.google.com/console |

Firebase project ID: **`blooddonation-89361`**

---

## Option A — GitHub Actions (recommended, free)

### 1. Push code to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USER/blood_donation.git
git push -u origin main
```

### 2. Build APK in the cloud (no local Android SDK)

Workflow: `.github/workflows/build-apk.yml`

1. Open **GitHub → your repo → Actions**
2. Select **Build APK** → **Run workflow**
3. When finished, open the run → **Artifacts** → download **`lifeline-apk`**

**Optional — signed release APK:** add repo secrets (Settings → Secrets → Actions):

| Secret | Value |
|--------|--------|
| `ANDROID_KEYSTORE_BASE64` | Base64 of your `.jks` keystore |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias (e.g. `upload`) |
| `ANDROID_KEY_PASSWORD` | Key password |
| `GOOGLE_MAPS_API_KEY` | Google Maps/Places key |
| `GOOGLE_WEB_CLIENT_ID` | Google OAuth web client ID |

Generate base64 (PowerShell):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\upload-keystore.jks"))
```

Without keystore secrets, GitHub builds a **debug APK** (fine for testing, not for Play Store).

### 3. Deploy web + backend in the cloud

Workflow: `.github/workflows/deploy-firebase.yml`

1. Firebase Console → **Project settings** → **Service accounts** → **Generate new private key**
2. GitHub → **Settings → Secrets → Actions** → add:
   - `FIREBASE_SERVICE_ACCOUNT` = entire JSON file contents
   - `GOOGLE_MAPS_API_KEY` (optional)
   - `GOOGLE_WEB_CLIENT_ID` (optional)
3. GitHub → **Actions** → **Deploy Firebase** → **Run workflow**

Live web URL: **https://blooddonation-89361.web.app**

**AI chat secret (one-time, Firebase CLI or Console):**

```powershell
firebase functions:secrets:set GITHUB_MODELS_TOKEN --project blooddonation-89361
```

---

## Option B — Codemagic (Flutter-focused CI)

- Sign up: https://codemagic.io
- Connect GitHub repo
- Use **Flutter App** template → builds APK/AAB in cloud
- Can publish to Google Play automatically

Good if you want a UI instead of YAML workflows.

---

## Option C — Firebase App Distribution (test APK to phones)

After APK is built (GitHub Actions or Codemagic):

1. https://console.firebase.google.com/project/blooddonation-89361/appdistribution
2. Upload APK
3. Add tester emails — they install via link (no Play Store)

---

## Option D — Google Play Store (production)

1. Build **AAB** (not APK) in cloud:

   ```yaml
   flutter build appbundle --release
   ```

2. Upload at https://play.google.com/console
3. Package name: `com.example.blood_donation`

---

## Quick comparison

| Goal | Best platform |
|------|----------------|
| Web app live | **Firebase Hosting** (via GitHub Actions or `firebase deploy`) |
| Download APK without local build | **GitHub Actions** → Artifacts |
| Share APK with testers | **Firebase App Distribution** |
| Public Android release | **Google Play Console** |
| iOS (later) | **Codemagic** or **GitHub Actions** + App Store Connect |

---

## One-time Firebase AI setup (required for chat)

Secrets are **not** in the APK. Set on Firebase:

```powershell
npx firebase-tools login
firebase functions:secrets:set GITHUB_MODELS_TOKEN --project blooddonation-89361
```

Model config is in `functions/.env`:

```
GITHUB_MODELS_MODEL=openai/gpt-4.1-mini
GITHUB_API_VERSION=2022-11-28
```
