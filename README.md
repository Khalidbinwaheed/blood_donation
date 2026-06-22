# Blood Donation App

Flutter app for donor/recipient coordination, emergency requests, appointments, and location-aware blood center discovery.

## Core Features

- Authentication and role-based flows (donor, recipient, doctor, admin)
- Blood requests and donor discovery
- Appointment booking with doctor availability
- Notifications and news feed modules
- Interactive Google Maps center discovery:
  - Nearby center lookup by current location
  - Search by center name/address/services
  - Open-now, radius, and specialization filters
  - Call, directions, and website actions

## Quick Start

1. Install Flutter and run:

   ```bash
   flutter pub get
   ```

2. Run the app:

   ```bash
   flutter run
   ```

3. For code quality:

   ```bash
   flutter analyze
   ```

## Google Maps API Key Setup

This project supports configurable map keys across platforms.

### Android

Configured in `android/app/build.gradle.kts` through `MAPS_API_KEY` gradle property.

Set your key in `android/gradle.properties`:

```properties
MAPS_API_KEY=YOUR_ANDROID_MAPS_KEY
```

### iOS

Configured through `MAPS_API_KEY` in:

- `ios/Flutter/Debug.xcconfig`
- `ios/Flutter/Release.xcconfig`

Replace with your iOS-restricted key if needed.

### Web

Configured in `web/maps_config.js`:

```js
window.GOOGLE_MAPS_API_KEY = 'YOUR_WEB_MAPS_KEY';
```

## Production Configuration

See `.planning/PRODUCTION-PLAN.md` for the full launch checklist.

1. Copy `config/production.env.example` to `config/production.env`
2. Fill in Google keys and OAuth client ID (never commit `config/production.env`)
3. Set OpenAI on the server (not in the client):

```powershell
npx firebase-tools login
firebase functions:secrets:set OPENAI_API_KEY --project blooddonation-89361
```

4. Deploy rules, functions, and hosting:

```powershell
.\scripts\deploy.ps1
```

Or run locally:

```powershell
flutter run --dart-define-from-file=config/production.env
```

| Variable | Purpose |
|---|---|
| `USE_CLOUD_CHAT` | Use Firebase Cloud Function for AI chat (default `true`) |
| `ALLOW_CLIENT_OPENAI` | Dev-only client OpenAI key (default `false`) |
| `OPENAI_MODEL` | OpenAI model for cloud function (default `gpt-4o-mini`) |
| `GOOGLE_MAPS_API_KEY` | Google Places Nearby Search for hospitals |
| `GOOGLE_WEB_CLIENT_ID` | Google Sign-In OAuth web client ID |
| `APP_SHARE_URL` | Share link used in drawer/deep links |
| `CHATBOT_API_URL` | Custom health chatbot API fallback |
| `NEWS_API_URL` / `NEWS_API_KEY` | External news API (falls back to Firestore `news`) |
| `PLACES_API_URL` | Custom places API (used if Google key is absent) |
| `USE_MOCK_SERVICES` | `true` only for isolated tests |

Service priority:

- **Chat**: Cloud Function → custom `CHATBOT_API_URL` → offline helper
- **Places**: Google Places API → custom `PLACES_API_URL` → Firestore `centers`
- **Maps UI**: OpenStreetMap + satellite (flutter_map)

Android release signing: copy `android/key.properties.example` → `android/key.properties`.

Deploy Firestore rules, Storage rules, Cloud Functions, indexes, and web hosting:

```powershell
npx firebase-tools login
.\scripts\deploy.ps1
```

## Firestore Collections

Map discovery reads from `centers` collection. Messaging uses `conversations` with nested `messages`. Blood offers are stored on `requests.offers`.

Recommended `centers` document fields:

- `name` (string)
- `lat` (number)
- `lng` (number)
- `address` (string)
- `phone` (string)
- `openNow` (bool)
- `hours` (string, optional)
- `website` (string, optional)
- `specializations` (array of strings, optional)
- `accessibility` (array of strings, optional)

If no centers are available yet, the app falls back to seeded mock centers so the map flow remains usable.

## Security Notes

- Restrict all Maps keys in Google Cloud Console by platform:
  - Android package name + SHA-1/SHA-256
  - iOS bundle ID
  - Web HTTP referrers
- Use separate keys for Android, iOS, and Web in production.
