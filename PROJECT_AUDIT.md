# Desk Workout project audit

## Applied fixes

- Replaced browser-based Supabase Google OAuth on Android/iOS with native `google_sign_in` authentication and Supabase `signInWithIdToken`.
- Added `GOOGLE_WEB_CLIENT_ID` as a required build-time setting.
- Added native Google sign-out cleanup.
- Upgraded Android build tooling:
  - Gradle 8.14
  - Android Gradle Plugin 8.11.1
  - Kotlin Gradle Plugin 2.2.20
- Migrated the Android Kotlin JVM target from deprecated `kotlinOptions` to `compilerOptions`.
- Added `google_sign_in: ^7.2.0`.
- Removed the unused `app_loading.webp` asset declaration.
- Added all 32 missing German translations.
- Extended `.gitignore` for local crash dumps and explicit credential filenames.

## Google Sign-In setup still required

1. In Google Cloud, use the same project as the Google provider configured in Supabase.
2. Create/verify a Web OAuth client. Use its client ID as `GOOGLE_WEB_CLIENT_ID`.
3. Create an Android OAuth client with:
   - Package: `com.weglabs.posturereset`
   - Debug SHA-1 for local builds
   - Play App Signing SHA-1 for Play Store builds
4. In Supabase Authentication > Providers > Google, keep the Web client ID and secret configured. If multiple client IDs are accepted, include the Android client ID as documented by Supabase.
5. Run with:

```bash
flutter clean
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_KEY \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

## Security findings

The uploaded project archive contained local credentials/artifacts:

- `android/key.properties`
- `android/app/posture-reset-release.jks`
- `posture-reset-aab67c909e50.json`
- `android/hs_err_pid1928.log`

Do not commit or share these files. If the service-account JSON has ever been exposed outside a trusted private environment, revoke/rotate that key in Google Cloud. If the release keystore or its passwords were exposed publicly, assess key rotation through Play App Signing.

## Files that can be deleted locally

- `assets/images/app_loading.webp` — no longer declared or used.
- `android/hs_err_pid1928.log` — JVM crash dump.
- generated caches such as `.dart_tool/`, `.gradle/`, `build/`, and `.flutter-plugins-dependencies` before sharing archives.

Do not delete the release keystore or `key.properties` from your private development machine; only exclude them from repositories and shared ZIP files.
