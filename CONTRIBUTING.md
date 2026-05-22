# Contributing to Focuseed

Thank you for considering contributing to Focuseed! This document outlines the guidelines for contributing to this project.

## How to Contribute

### Reporting Bugs

1. Check the [issues](../../issues) to see if the bug has already been reported.
2. If not, open a new issue with a clear title and description.
3. Include steps to reproduce the bug, expected behavior, and actual behavior.
4. If possible, include screenshots or error logs.

### Suggesting Features

1. Open a new issue with the **feature request** label.
2. Describe the feature and the problem it solves.
3. Explain how the feature should work.

### Pull Requests

1. **Fork** the repository and create your branch from `master`.
2. **Write tests** for any new functionality.
3. **Ensure tests pass** by running `flutter test` in the `focus_app` directory.
4. **Run the analyzer** with `flutter analyze` — ensure 0 errors and 0 warnings.
5. **Update documentation** if your changes affect the API or architecture.
6. Submit the pull request with a clear description of the changes.

## Development Setup

```bash
cd focus_app
flutter pub get
dart run build_runner build
flutter run
```

## Code Style

- Follow the existing code conventions in the project.
- Use Dart's standard formatting — run `dart format` before committing.
- Write meaningful commit messages.
- Keep changes focused — one pull request per feature or fix.

## Architecture Notes

- **State management:** Riverpod — use `Notifier`/`AsyncNotifier` for complex state.
- **Database:** Drift with SQLite — add tables/DAOs under `lib/core/db/`.
- **UI:** Keep screens in `lib/screens/`, reusable widgets in `lib/components/`.

## Code of Conduct

Be respectful, constructive, and inclusive. Everyone is welcome to contribute.

---

Thanks for helping make Focuseed better! 🌱
