# Focuseed

A focus timer app that turns your consistency into a living garden. Complete deep work sessions to plant and grow trees. Skip too many days and they wilt.

## Features

- **Focus Timer** — Soft Focus & Hard Lock (grayscale, notification suppression)
- **Growing Garden** — Trees grow with focus sessions, wilt without care
- **Analytics Dashboard** — Charts, streaks, tags, focus score
- **Sound Mixer** — 5-track ambient audio mixing
- **Session Journal** — Reflection prompts with history
- **Home Screen Widget** — Streak & minutes (Android)
- **App Blacklist** — Block distractions during hard lock (Android)
- **Privacy First** — All data stays on device. No accounts, no cloud.

## Getting Started

```bash
cd focus_app
flutter pub get
dart run build_runner build
flutter run
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
