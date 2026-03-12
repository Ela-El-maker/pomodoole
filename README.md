# Petal Focus

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/Ela-El-maker/pomodoole/ci.yml?branch=main)
![GitHub License](https://img.shields.io/github/license/Ela-El-maker/pomodoole)
![GitHub last commit](https://img.shields.io/github/last-commit/Ela-El-maker/pomodoole)
![GitHub contributors](https://img.shields.io/github/contributors/Ela-El-maker/pomodoole)
![GitHub issues](https://img.shields.io/github/issues/Ela-El-maker/pomodoole)

## Project Overview

**Petal Focus** is a modern, distraction-free productivity app designed to help you maximize your focus and manage your work sessions effectively. Inspired by the Pomodoro Technique, Petal Focus lets you break your work into focused intervals, track your progress, and reflect on your productivity.

### Key Features

- **Focus Sessions & Breaks:** Start, pause, and complete focus sessions with customizable durations. Take short or long breaks to recharge.
- **Task Management:** Organize your tasks, set estimates, and track completed Pomodoros for each task.
- **Session Insights:** Visualize your productivity with statistics and charts. Review your session history and identify trends.
- **Reflections:** After each session, reflect on what went well and what you can improve next time.
- **Custom Sound Mixer:** Personalize your focus environment with ambient sound mixes.
- **Notifications & Haptics:** Stay on track with reminders, notifications, and gentle haptic feedback.
- **Cross-Platform:** Runs on both Android and iOS, with a consistent, beautiful UI.

Petal Focus is built for anyone who wants to work with intention, reduce distractions, and build better habits—whether you're a student, professional, or creative.

## Screenshots

<div align="center">
	<img src="docs/screenshots/photo_1_2026-03-12_21-43-16.jpg" alt="Onboarding - Focus Duration" width="220" />
	<img src="docs/screenshots/photo_2_2026-03-12_21-43-16.jpg" alt="Onboarding - Weekly Goal" width="220" />
	<img src="docs/screenshots/photo_3_2026-03-12_21-43-16.jpg" alt="Onboarding - Ready" width="220" />
	<img src="docs/screenshots/photo_4_2026-03-12_21-43-16.jpg" alt="Today's Tasks" width="220" />
	<img src="docs/screenshots/photo_5_2026-03-12_21-43-16.jpg" alt="Statistics" width="220" />
	<img src="docs/screenshots/photo_6_2026-03-12_21-43-16.jpg" alt="Settings" width="220" />
</div>

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

Optional local secrets template:

```bash
cp env.example.json env.json
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

# Android release APK (recommended on this machine)
cd android && ./gradlew assembleRelease

# Android release build with full Gradle deprecation output
cd android && ./gradlew assembleRelease --warning-mode all

# iOS debug build (macOS only)
flutter build ios --debug --no-codesign

# iOS release validation (macOS only)
flutter build ios --release --no-codesign
flutter test integration_test -d ios
```

## Release Notes

- Android release builds on this machine should prefer `cd android && ./gradlew assembleRelease`.
- `flutter build apk --release` can intermittently hit a local Flutter file-watcher issue (`Already watching path`), while direct Gradle release builds complete successfully.
- To audit Gradle deprecations before upgrading toolchains, run `./gradlew assembleRelease --warning-mode all`.

## CI

GitHub Actions pipeline (`.github/workflows/ci.yml`) runs:

- dependency install
- build_runner code generation
- strict analyze (`--fatal-infos --fatal-warnings`)
- unit/widget tests
- integration smoke tests

Additional security pipeline:

- `.github/workflows/secrets-scan.yml` runs gitleaks on push/PR.

If a key is ever exposed, follow [docs/security-key-incident-response.md](docs/security-key-incident-response.md).

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
