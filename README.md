# Focus Garden

A focus timer app that turns your consistency into a living garden. Complete deep work sessions to plant and grow trees. Skip too many days and they wilt.

**Two focus modes.** Soft Focus for everyday work. Hard Lock for deep work -- screen goes grayscale, notifications are suppressed (Android), and the timer cannot be stopped early. Hard lock sessions earn a 1.5x growth bonus.

**Your garden grows with you.** Each session plants a tree. Growth scales with duration (5 stages from 15 minutes to 4+ hours). Trees need daily watering or they die after 48 hours.

**Streaks and achievements.** Consecutive daily sessions build your streak. Unlock achievements at milestones along the way.

**Privacy first.** Everything stays on device. Local SQLite database. No accounts, no cloud, no tracking.

## Getting Started

```bash
cd focus_app
flutter pub get
dart run build_runner build
flutter run
```

Build a release APK:

```bash
flutter build apk --release
```

## Architecture

```
lib/
  core/
    db/          Drift database (SQLite) -- tables and DAOs
    services/    Session logic, tree lifecycle, streaks, audio, lock
  state/         Riverpod providers
  screens/       UI screens
  theme/         Theme configuration (light/dark)
  components/    Reusable UI widgets
```

**State management:** Riverpod. `SessionNotifier` drives the focus timer and coordinates lock/audio services. `GardenNotifier` loads trees from the database. Simple `StateProvider` values for user identity and theme.

**Database:** Drift with SQLite. Four tables: Users, Sessions, Trees, Achievements. DAO classes encapsulate queries. Code generation via `dart run build_runner build`.

**Android integration:** Platform channel (`focus_garden/lock`) for grayscale overlay and notification suppression during hard lock mode.

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

MIT
