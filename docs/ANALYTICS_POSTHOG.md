# Desk Workout — PostHog analytics & offline legal release checklist

## Scope
- Branch: `feature/posthog-consent-offline-legal`.
- PostHog EU ingestion: `https://eu.i.posthog.com`, Product Analytics only.
- Flutter SDK pinned: `posthog_flutter: 5.24.0`.
- PostHog initializes **only after explicit opt-in**, and Android / iOS auto-init is disabled.
- Session Replay and automatic lifecycle events are disabled; no PosthogObserver is installed.
- The user's decision is stored on-device in SharedPreferences and can be changed from Settings.
- Existing Supabase analytics_events tracking is also disabled before/without consent.
- The server-side operational records used for sessions, progress, purchases and account functionality remain independent of optional analytics.
- No user ID, email, name, session ID, program ID, health symptom, body-area selection or free-text metadata is explicitly sent in analytics events.

## Event taxonomy (PostHog)
| Event | Trigger | Allowed metadata |
|---|---|---|
| `app_opened` | After opted-in PostHog initialisation (new app run) | none |
| `tab_selected` | Main bottom navigation tap | allowlisted surface |
| `session_started` | Database session run created | none |
| `session_completed` | Database session run completed | none |
| `session_abandoned` | Database session run abandoned | none |
| `quick_fix_recommendation_viewed` | Quick Fix suggestions revealed | none |
| `program_started` | Program start saved | none |
| `program_day_started` | Program day started | none |
| `program_day_completed` | Program day completed | none |
| `paywall_viewed`, `unlock_tapped`, `purchase_started`, `purchase_success`, `purchase_cancelled`, `purchase_failed`, `restore_tapped`, `restore_success`, `restore_failed`, `locked_feature_viewed`, `locked_feature_cta_tapped` | Existing premium funnel; mirrored from consent-aware Supabase service | allowlisted surface only |

Events are intentionally aggregate and anonymous. Device-level distinct IDs are managed by PostHog; no `identify()` call or cross-device account linking is made. Analytics undercounts users who decline.

## Suggested PostHog dashboards
1. **Growth**: unique persons performing `app_opened` daily / weekly / monthly.
2. **Engagement**: `session_started`, `session_completed`, `session_abandoned` trends. Completion ratio is approximate without run IDs; it is not a strict same-run funnel.
3. **Quick Fix**: daily `quick_fix_recommendation_viewed` and repeat usage.
4. **Programs**: `program_started` and `program_day_completed` by date; this is not yet a cohort-level per-program completion metric.
5. **Premium**: `paywall_viewed` -> `purchase_started` -> `purchase_success` funnel (PostHog distinct person funnel, not raw event-count ratios).
6. **Retention**: weekly return on `app_opened`.

For consent and lower cost, screen recordings, automatic screen tracking, surveys, group analytics and automatic error capture are not activated. Avoid pay-as-you-go upgrades.

## Offline legal pages
- `/legal/privacy`
- `/legal/terms`
- `/legal/deletion`

These are app-specific bilingual English/German notices, embedded as Dart content and accessible from both sign-in/sign-up and Settings. They are **not a byte-for-byte copy of the website policies**. Before publishing, compare and approve the app text and website policies; update the web policy to name PostHog and provide the same withdrawal instructions. The legacy Data Deletion website URL was not retrievable during authoring, so confirm account-deletion wording and Google Play Console public URLs separately. In-app pages remain accessible offline, but Google Play's public privacy and account-deletion URLs must still remain available.

## Device acceptance tests
1. On a new install (or after clearing app data), sign in. Read all three legal pages **with airplane mode on** (existing logged-in app functionality may need network; test the legal pages separately).
2. Decline Analytics. Tap navigation, open Quick Fix, start/finish a session: there must be no new matching PostHog Live Events on that device.
3. Settings > Optional product analytics > enable. Check `app_opened`, `tab_selected`, `quick_fix_recommendation_viewed`, and test the session/program/purchase flows where safe.
4. Turn Analytics off in Settings. Repeat navigation; no subsequent events should arrive from this device. Check persistence across a restart.
5. Check login and signup legal links; all must return correctly without opening a web browser.
6. Confirm the main navigation, signed-in redirect, Settings and Premium checkout are unchanged.
7. Run `flutter pub get`, `flutter analyze`, tests, debug device flow, and `flutter build appbundle --release` before uploading.
8. **Do not use the old GitHub branch pubspec version as a release number.** On the release working tree explicitly ensure `version: 1.5.3+9`, since that build is prepared locally and the remote branch has older version metadata.
9. Do not update `public.app_runtime_config` to build 9 until that build is live on Google Play.

## Operational safeguards
- Live PostHog dashboards are configured in PostHog (or using a connected PostHog integration), not by Flutter source changes alone.
- Avoid sending PostHog personal, health or diagnosis data, even in dynamically-added properties.
- Opt-out prevents new collection but does not retroactively erase processed data; handle deletion requests separately.
- Verify the DPA / processor notice and Google Play Data safety declaration with your actual deployed data flows.
- Keep the PostHog Free plan without adding billing details and monitor the monthly ingestion allowance.
