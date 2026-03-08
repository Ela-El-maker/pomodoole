# Petal Focus

Flutter mobile app for focus sessions, breaks, tasks, and session insights.

## Architecture

- State management: Riverpod (`flutter_riverpod`)
- Navigation: `go_router` with tab shell navigation
- Local data: Drift + SQLite
- Observability: Firebase Crashlytics + Analytics + Performance (optional-safe bootstrap)

## Prerequisites

- Flutter `3.38.x` (Dart `3.10.x`)
- Android Studio + Android SDK (for Android builds)
- Xcode 15+ (for iOS builds on macOS)

## Project Setup

```bash
flutter pub get
flutter analyze
```

## Run The App

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

## Useful Commands

```bash
# Static checks
flutter analyze

# Tests
flutter test

# Integration smoke
flutter test integration_test

# Android debug APK
flutter build apk --debug

# iOS debug build (macOS only)
flutter build ios --debug --no-codesign
```

## CI

GitHub Actions pipeline (`.github/workflows/ci.yml`) runs:

- dependency install
- build_runner code generation
- strict analyze (`--fatal-infos --fatal-warnings`)
- unit/widget tests
- integration smoke tests

## App IDs / Bundle IDs

- Android application ID: `io.petalfocus.app`
- iOS bundle ID: `io.petalfocus.app`

Update these in:

- `android/app/build.gradle.kts`
- `ios/Runner.xcodeproj/project.pbxproj`

## Structure

Key folders:

- `lib/presentation`: screens and UI widgets
- `lib/services`: timer, notifications, app state, haptics
- `lib/routes`: app route definitions
- `lib/theme`: app theming
- `lib/widgets`: shared widgets
- `assets/`: image and static assets
