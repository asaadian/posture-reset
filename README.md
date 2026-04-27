# Posture Reset

**Posture Reset** is a premium posture, mobility, and recovery app for programmers, remote workers, desk-heavy professionals, and busy parents.

The app helps users recover from long sitting sessions, posture fatigue, stiffness, and work-related tension through short guided recovery routines, body-zone-based recommendations, Quick Fix flows, and a modern dark-mode mobile experience.

Posture Reset is not a generic yoga app. It is designed as a focused desk recovery system with personalized actions, access-aware premium features, and a production-oriented Flutter + Supabase architecture.

---

## Current Release Status

**Current version:** `1.2.0`  
**Platform:** Android  
**Release track:** Google Play Closed Testing  
**Repository visibility:** Private

Version `1.2.0` is currently published on the Google Play Closed Testing track.

---

## What the App Does

Posture Reset provides:

- Guided posture reset and recovery sessions
- Short Quick Fix routines for specific body zones
- Interactive body-zone selection
- Personalized next-action recommendations
- Dashboard-first recovery experience
- Premium access model based on Core Unlock
- Google Play Billing integration
- Supabase-backed entitlement system
- Dark-mode, premium health-tech UI

The app is built around practical recovery for people who sit, code, work remotely, commute, or handle daily desk-related physical stress.

---

## Version History

### Version 1.2.0

**Status:** Published to Google Play Closed Testing

Main changes and current state:

- Published Android build to Google Play Closed Testing.
- Real Google Play Billing flow connected.
- Purchase verification flow implemented through Supabase Edge Function.
- Successful purchases are registered in Supabase.
- `user_entitlements` is used as the entitlement source of truth.
- `core_access` is the canonical premium entitlement.
- Premium access gating is active across the main app surfaces.
- Dashboard, Sessions, Quick Fix, Body Map, Premium page, and Session Player are connected to the access system.
- Session recommendations are access-aware.
- Quick Fix recommendations are access-aware.
- Body map recommendations are access-aware.
- Session detail and session player include premium access guards.
- Premium page redesigned around the Core Unlock model.
- UI polish continued across dashboard, session cards, player controls, and feedback sheets.
- App icon and Play Store preparation work completed for testing.
- Debug/testing backend helpers still need to be removed or restricted before full production release.

---

### Version 1.1.0

**Status:** Internal development / pre-Closed Testing

Main changes:

- Core premium access foundation added.
- Access policy layer introduced.
- Main entitlement models added:
  - `AccessTier`
  - `Entitlement`
  - `LockedFeature`
  - `AccessDecision`
  - `AccessSnapshot`
  - `AccessPolicy`
- Access providers added:
  - `accessSnapshotProvider`
  - `hasCoreAccessProvider`
- `PremiumLockBadge` added.
- Sessions library became access-aware.
- Session detail screen became access-aware.
- Session player access guard added.
- Dashboard next-action logic became access-aware.
- Saved, history, and continuity surfaces prepared for access-aware behavior.
- Premium page direction shifted from generic upgrade UI to Core Unlock.
- Supabase entitlement table became the source of truth for premium access.

---

### Version 1.0.0

**Status:** First production-oriented MVP baseline

Main changes:

- Initial app foundation completed.
- Flutter project architecture established.
- Dashboard-first product direction established.
- Sessions library added.
- Session detail flow added.
- Session player foundation added.
- Quick Fix flow added.
- Interactive body-zone concept added.
- User recovery journey structured around short guided sessions.
- Dark-mode premium UI direction established.
- Localization-ready text approach introduced.
- Responsive layout rules introduced.
- Supabase foundation added.
- Authentication/backend direction prepared.
- Project moved away from prototype-only implementation toward end-to-end feature completion.

---

## Product Direction

The app should remain focused on:

- Desk recovery
- Posture reset
- Short, practical mobility routines
- Pain-aware and body-zone-aware recommendations
- Premium, focused UX
- No intrusive ads
- Real billing and entitlement-based access
- Production-quality implementation instead of placeholder features

---

## Notes for Future Development

Before wider production release:

- Remove or restrict debug-only backend helpers.
- Review all entitlement and restore-purchase flows.
- Continue UI polish on dashboard and player surfaces.
- Keep all new text localization-ready.
- Avoid hardcoded UI text.
- Avoid bottom overflow on small devices.
- Keep the premium model based on entitlement state, not hardcoded product names.