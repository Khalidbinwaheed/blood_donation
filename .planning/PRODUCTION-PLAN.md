# Lifeline — 100% Production Plan

**Target:** Public launch on Firebase Hosting + Play Store + App Store  
**Current baseline:** ~52% → **Target:** 100%  
**Project:** `blooddonation-89361`

---

## Phase 1 — Security (P0) ✅ In progress

| Task | Acceptance criteria |
|------|---------------------|
| Firebase Storage rules | `storage.rules` — users can only write own profile photos |
| Firestore PII lockdown | `requests` / `blood_requests` read requires auth |
| Ambulance dispatch rules | Only admin updates `driverLocation` / dispatch status |
| OpenAI server proxy | Cloud Function `chatWithOpenAI` — key never in client |
| Remove hardcoded API keys | Android/iOS maps keys from env only, no committed fallbacks |
| Release signing template | `android/key.properties.example` + conditional release config |

## Phase 2 — Feature completion (P1)

| Task | Acceptance criteria |
|------|---------------------|
| Password reset flow | Email reset → success screen (no fake OTP) |
| Remove Facebook stub | Hidden until OAuth app configured |
| Ambulance tracking | Read-only Firestore stream (no client simulation) |
| IoT vitals | Persist readings to `health_data` collection |
| Digital ID QR | Real QR code via `qr_flutter` |
| Availability repository | Firestore implementation wired |
| Events Firestore index | `startsAt` index added |

## Phase 3 — Quality & ops (P1)

| Task | Acceptance criteria |
|------|---------------------|
| Firebase Analytics | Replace `NoOpAnalyticsService` |
| Flutter CI | `analyze` + `test` + web build on push |
| Integration tests | Auth, donation repo, health data unit tests |
| Remove dead deps | Drop unused `google_maps_flutter`, `mailer` |
| Deploy script | Firestore + Functions + Hosting |

## Phase 4 — Store release (P2)

| Task | Acceptance criteria |
|------|---------------------|
| Package ID | Keep `com.example.blood_donation` until Firebase re-register (documented) |
| Privacy policy URL | Linked in settings |
| App icons & splash | Already present |
| Play Store listing | Manual — see `docs/STORE-RELEASE.md` |

---

## Service priority (production)

```
Chat:    Cloud Function → Custom API → Offline helper
         (Client OpenAI only if ALLOW_CLIENT_OPENAI=true)

Places:  Google Places API → Custom API → Firestore centers

Maps UI: OpenStreetMap + Satellite (flutter_map)
```

## Environment variables

See `config/production.env.example`. **Never commit** `config/production.env`.

Set OpenAI key via Firebase Functions secrets:
```bash
firebase functions:secrets:set OPENAI_API_KEY
```

---

## Verification checklist (100%)

- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — all pass
- [ ] CI green on GitHub
- [ ] `firebase deploy` — rules, indexes, functions, hosting
- [ ] No PII readable without auth
- [ ] No secrets in client bundle (web build inspect)
- [ ] All stub screens removed or functional
- [ ] Manual UAT: auth, request blood, offer donate, book appointment, chat, map, admin
