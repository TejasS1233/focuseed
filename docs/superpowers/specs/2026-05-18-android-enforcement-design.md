# Android Enforcement Layer Design

**Goal:** Make hard lock sessions unskippable on Android using Accessibility Service, foreground service, and system overlay.

## Architecture

Three native Android components work together during hard lock mode:

**FocusAccessibilityService** - Extends `AccessibilityService`. Listens for `TYPE_WINDOW_STATE_CHANGED` events to detect foreground app changes. Extracts the package name and sends it to Dart via the method channel.

**FocusForegroundService** - Extends `Service` with a persistent notification. Keeps the process alive even if the user swipes the app from recents. Starts/stops with hard lock.

**OverlayManager** - Uses `WindowManager` with `SYSTEM_ALERT_WINDOW` permission. When a blacklisted app is detected in the foreground, draws a full-screen overlay intercepting all touch events. Shows a message redirecting the user back to their session.

## Data Flow

```
Hard lock start -> LockService.startLock()
  -> Start FocusForegroundService (persistent notification)
  -> Check if AccessibilityService is enabled
  -> If not enabled, show dialog with Settings intent
  -> Pass blacklist package names via method channel arguments

User opens blacklisted app -> AccessibilityService triggers
  -> OverlayManager.show() renders lock overlay
  -> User presses "Return to focus" -> OverlayManager.hide()
  -> Focus screen resumes

Hard lock end -> LockService.stopLock()
  -> Stop ForegroundService
  -> Stop OverlayManager (hide overlay)
```

Note: Accessibility Services cannot be started programmatically. The user must enable it once in system settings. The app can only open the Settings page and request the user to toggle it on. If the service is not enabled, hard lock falls back to the current grayscale-only behavior.

## App Blacklist

A dedicated screen lists all installed apps with toggle switches. The blacklist is stored in a new Drift table with a single column: `package_name`. The list is loaded at app start and passed to native code when a hard lock session begins.

New drift table:
- `BlacklistEntry` - `packageName: String` (primary key)

New screens:
- `BlacklistScreen` - shows installed apps with toggles

New state:
- `BlacklistProvider` wraps the Drift DAO and exposes the list

## Native Files

- `FocusAccessibilityService.kt` - Accessibility service to detect foreground app switches
- `FocusForegroundService.kt` - Foreground service to keep process alive
- `OverlayManager.kt` - System overlay for blocking apps

Modified files:
- `MainActivity.kt` - Initialize and coordinate native components
- `AndroidManifest.xml` - Declare permissions and services
- `lib/core/services/lock_service.dart` - Enhanced platform channel calls

## Permissions Required

- `SYSTEM_ALERT_WINDOW` - For drawing overlay on top of other apps. User must grant via a system dialog. If denied, overlay is skipped (grayscale only)
- `FOREGROUND_SERVICE` - For persistent background service. Declared in manifest, no runtime prompt
- `POST_NOTIFICATIONS` (Android 13+) - For foreground service notification. Can be requested at runtime
- `BIND_ACCESSIBILITY_SERVICE` - For foreground app detection. User must enable in system Settings > Accessibility. If not enabled, hard lock falls back to grayscale only

## Testing

- Unit tests for blacklist DAO and provider
- Manual testing on Android device/emulator for Accessibility Service and overlay behavior
- Edge cases: user denies overlay permission, accessibility not enabled, foreground service killed by system
