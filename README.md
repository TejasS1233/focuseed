# Focuseed

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)

A focus timer app that turns your consistency into a living garden. Complete deep work sessions to plant and grow trees. Skip too many days and they wilt.

## Features

- **Focus Timer** — Soft Focus for everyday work. Hard Lock for deep work: screen goes grayscale, notifications suppressed (Android), timer cannot be stopped early. Hard lock sessions earn 1.5x growth bonus.
- **Growing Garden** — Each session plants a tree. Growth scales with session duration (5 stages from 15 min to 4+ hours). Trees wilt after 48 hours without watering. Species include oak, cherry, pine, and more with emoji icons.
- **Focus Tags** — Tag your sessions (e.g., coding, reading, writing) and track time breakdowns on the analytics page.
- **Sound Mixer** — 5-track multi-layer ambient audio mixing. Mix and match rain, wind, fire, birds, and waves.
- **Analytics Dashboard** — Bar chart (daily totals), 30-day trend line chart, tag distribution pie chart, focus score, completion rate, streak counter, total hours.
- **Session Journal** — Reflection prompts and a history timeline with searchable entries.
- **Daily Focus Goal** — Set a daily target and track progress with a ring indicator.
- **Achievements & Challenges** — Unlock milestones for streaks, sessions completed, and growth milestones.
- **Home Screen Widget (Android)** — Shows current streak and today's focused minutes.
- **App Blacklist (Android)** — Block distracting apps during Hard Lock mode. Requires Accessibility Service permission.
- **Notifications** — Session reminders and break alerts.
- **Dark & Light Theme** — Toggle between modes. Persisted across sessions.
- **Onboarding** — First-launch setup flow for permissions and preferences.
- **Privacy First** — Everything stays on device. Local SQLite database via Drift. No accounts, no cloud, no tracking.

## Getting Started

```bash
cd focus_app
flutter pub get
dart run build_runner build
flutter run
```

Build a release APK:

```bash
flutter build apk --release --split-per-abi
```

## Architecture

```
lib/
  core/
    db/          Drift database (SQLite) — tables and DAOs
    services/    Session logic, tree lifecycle, streaks, audio, lock, notifications
  state/         Riverpod providers
  screens/       UI screens (home, focus, garden, analytics, journal, profile, etc.)
  theme/         Theme configuration (light/dark)
  components/    Reusable UI widgets
android/app/src/main/kotlin/com/focusapp/focus_app/
  FocusWidgetProvider.kt      Home screen widget
  FocusAccessibilityService.kt  Blacklist enforcement
  FocusForegroundService.kt     Hard lock foreground service
  OverlayManager.kt             Grayscale overlay
```

**State management:** Riverpod. `SessionNotifier` drives the focus timer and coordinates lock/audio services. `GardenNotifier` loads trees from the database.

**Database:** Drift with SQLite. Tables: Users, Sessions, Trees, Achievements, JournalEntries, BlacklistEntries, Decorations, Challenges, Schedules.

## Development

```bash
flutter test                         # Run tests
dart run build_runner build          # Regenerate Drift code
flutter analyze                       # Should show 0 errors, 0 warnings
```

Configuration points:
- Ambient sound URLs: `lib/core/services/audio_service.dart`
- Tree species and colors: `lib/screens/garden_screen.dart`
- Wilting duration: `lib/core/services/tree_lifecycle_service.dart`

## License

MIT — see [LICENSE](LICENSE.md) for details.

## Contributing

Contributions are welcome! See [CONTRIBUTING](CONTRIBUTING.md) for guidelines.
