# kranchios_web

A GitHub template repo for bootstrapping new Flutter apps: splash → login →
home → profile → change-password, fully wired to
[`core_package`](https://github.com/your-org/core-package) (theming,
networking, validators, common widgets, `Result`/`UseCase` base classes).

## What's here

- `lib/app/` — `main.dart`, `StarterApp` (theme + router wiring, plus
  `UpdateRequiredGate`/`BiometricLockGate`/`AppIdleTimeoutGuard` — each
  toggled via `featureFlagsProvider`), `router.dart` (GoRouter with
  auth-driven redirects)
- `lib/theme/starter_theme.dart` — **the one file you change to re-brand a
  new app** — nothing else hardcodes a color
- `lib/shell/app_shell.dart` — common app bar + navigation drawer wrapping
  every authenticated screen
- `lib/features/auth/` — full Clean Architecture slice (domain / data /
  presentation) for login, logout, change password, and session persistence.
  **`AuthRepositoryImpl` is a demo/mock** — it doesn't call a real backend
  (any well-formed email + 8-character password "succeeds"). Swap in a real
  implementation using `ApiClient` from `core_package` once your app has an
  actual API; nothing in the domain or presentation layers needs to change.
- `lib/features/home/`, `lib/features/profile/` — starter screens to replace
  with your app's real dashboard/profile content
- `lib/features/settings/` — the Settings screen (`/settings`): profile
  link, change password, theme mode, font size, notifications toggle,
  contact/about us, and log out. Reached via `AppCommonBar`'s overflow
  menu or the navigation drawer — both point at the same actions.
- `lib/constants/` — `AppConstants` (app name, support email, policy URLs)
  and `ApiConstants` (base URL, timeouts, endpoint paths — placeholders
  until real API integration)
- `lib/features/settings/data/demo_update_check_service.dart` — **also a
  demo/stub**, same pattern as `AuthRepositoryImpl`: always reports the
  app is up to date. Replace once a real backend/remote-config source
  exists.

## Using this template for a new app

1. On GitHub: **"Use this template"** → create your new repo (e.g. `sales-crm-app`)
2. Rename the package: `pubspec.yaml`'s `name:`, any
   `import 'package:flutter_starter/...'` → your new package name,
   `applicationId` (Android), bundle identifier (iOS), and the app's display
   name
3. In `pubspec.yaml`, pin `core_package`'s `ref:` to a specific tagged
   version (not `main`)
4. Replace `lib/theme/starter_theme.dart`'s colors with your app's real brand
   palette
5. Replace `AuthRepositoryImpl` with a real, API-backed implementation once
   you have a backend
6. Build your app's actual feature modules under `lib/features/`

## Running it

```bash
flutter pub get
flutter run
```

The demo login accepts any well-formed email with a password of 8+
characters — there's no real backend behind it yet.

## Testing

```bash
flutter test
```

`AuthController` is covered with a mocked `AuthRepository` (login
success/failure, logout, change-password success/failure).
`AuthLocalDataSource` is covered with a fake in-memory
`SecureStorageService` (no platform channel involved, since it depends on
`core_package`'s storage abstraction rather than `flutter_secure_storage`
directly). Full app-level widget tests (tapping through splash → login →
home) aren't included yet — worth adding once this app has real screens
built on top of the starter.