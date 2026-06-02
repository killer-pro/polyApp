# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PolyApp** — A Flutter mobile app for a French engineering school (EPT) student club (PIC), managing sports competitions (interclasse), announcements, a shop, lost-and-found, and user profiles.

- **Package**: `sn.ept.pic.app`
- **Locale**: French (`fr`)
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter test             # Run all tests
flutter build apk        # Android release APK
flutter build ios        # iOS build (macOS only)
flutter analyze          # Lint/static analysis
```

## Architecture

### Entry Point & Auth Flow
`lib/main.dart` — Initializes Firebase, sets portrait orientation, and uses `AuthHandler` (a `StreamBuilder` on `FirebaseAuth.instance.authStateChanges()`) to route between login and home.

### Layer Structure
```
lib/
├── models/        # Data models with Firestore serialization (fromMap/toMap)
│   └── enums/     # Dart enums: SportType, RoleType, JeuType, etc.
├── services/      # Firebase/API calls (no state management package)
├── pages/         # Feature screens organized by domain
│   ├── home/      # Main home + navbar
│   ├── drawer/    # Side-nav screens (admin, compte, famille, xoss)
│   ├── annonce/   # Announcements
│   ├── interclasse/ # Sports competitions (football/, basket/, volley/)
│   ├── object_perdus/ # Lost and found
│   └── shop/      # E-commerce
├── widgets/       # Reusable UI components
└── utils/         # app_colors.dart, fonctions.dart
```

### State Management
No external state management library. Uses:
- `StatefulWidget` + `setState` for local UI state
- `StreamBuilder` / `FutureBuilder` for Firebase reactive data
- `SharedPreferences` for persisted local state (user role, token, prefs)

### Navigation
Manual `Navigator.push()` with `PageTransition` package for custom transitions. No named routes or router package.

### Key Services
| Service | Responsibility |
|---|---|
| `user_service.dart` | Auth, profile, SharedPreferences |
| `sport_service.dart` | Football, basketball, volleyball CRUD |
| `shop_service.dart` | Shop articles, categories, orders |
| `annonce_service.dart` | Announcements |
| `notification_service.dart` | FCM + local notifications |
| `xoss_service.dart` / `lost_found_service.dart` | Lost & found |

### Environment
Secrets are loaded via `flutter_dotenv` from a `.env` file (not committed). Firebase config is in `lib/firebase_options.dart`.

### CI/CD
Three GitHub Actions workflows in `.github/workflows/`: `flutter_ci.yaml` (main), `dart.yml`, `main.yaml`. They run `flutter pub get`, `flutter test`, and build APK/IPA on push.
