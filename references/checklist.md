# Android game checklist (agent edition)

Stable item IDs: `P<phase>-<nn>`. Cite them in reports (e.g. `P2-01 missing`).

Legend: priority `critical` | `important` | `nice-to-have` · scope `agnostic` | `flutter/flame` · ⚠ = dated requirement, re-verify against `official-sources.md` at run time · `[auto]` = covered (fully or partly) by `scripts/verify.sh` · `Snippet S-xx` = see `snippets.md`.

## Index

| ID | Item | Priority | Scope | Auto |
|---|---|---|---|---|
| P0-01 | Write the intent and the spec before the code (intent → spec → plan → decisions). | important | agnostic | yes |
| P0-02 | Keep a resumable state file (current phase, last green checkpoint, blockers, next step). | important | agnostic |  |
| P0-03 | Define agent rules and stop rules: Play, payments, secrets or keystore, merges to main … | important | agnostic |  |
| P0-04 | Create a single verification harness (verify.sh) used the same way by the agent and by … | important | agnostic | yes |
| P0-05 | Write a human acceptance script containing only what a machine can't judge (feel, diffi… | nice-to-have | agnostic |  |
| P0-06 | Lock in the final applicationId before the first upload to Play (your own reverse domai… | critical | agnostic | yes |
| P0-07 | Check that the game's name is available (Play, domain, trademarks). | nice-to-have | agnostic |  |
| P0-08 | Centralize game constants and strings (game_config.dart, app_strings.dart). | important | flutter/flame |  |
| P0-09 | Separate pure logic (no Flame or Flutter) from components. | important | flutter/flame |  |
| P1-01 | Use Flutter's default SDK values, or pin them deliberately (compileSdk, targetSdk, minS… | critical | flutter/flame | yes |
| P1-02 | Target the API level Play requires: since Aug 31, 2026, API 36 for new apps and updates… | critical | agnostic | yes |
| P1-03 | Use a 16 KB-compatible toolchain (AGP 8.5.1 or newer, NDK r28 or newer, Flutter 3.35 or… | critical | agnostic | yes |
| P1-04 | Version from pubspec.yaml (version: X.Y.Z+N), bump N (versionCode) for every AAB, and k… | critical | flutter/flame | yes |
| P1-05 | Rely on R8 (on by default in release) and add proguard-rules.pro only if a plugin asks … | important | flutter/flame |  |
| P1-06 | Declare only the permissions the code actually uses; don't add INTERNET if the game is … | important | agnostic | yes |
| P1-07 | Remove unused dependencies and bundle fonts instead of downloading them (with their lic… | nice-to-have | flutter/flame | yes |
| P1-08 | Declare every asset in pubspec.yaml and check that it makes it into the build. | important | flutter/flame | yes |
| P1-09 | Create your own adaptive icon: legacy, mipmap-anydpi-v26/ic_launcher.xml with foregroun… | critical | agnostic | yes |
| P1-10 | Give LaunchTheme and NormalTheme the game's background color (not Theme.Light if the ga… | important | flutter/flame | yes |
| P2-01 | Declare the app as a game: android:appCategory="game" on <application>. | critical | agnostic | yes |
| P2-02 | Lock orientation in two places: the manifest (portrait or sensorLandscape) and SystemCh… | important | flutter/flame | yes |
| P2-03 | Design for edge-to-edge: it's mandatory when targeting 35/36, and in Flutter, when targ… | critical | flutter/flame | yes |
| P2-04 | Respect insets (bars, notch, cutouts, gesture areas) in the HUD, menus and touch contro… | important | flutter/flame | yes |
| P2-05 | Separate the playfield from the HUD by construction: no touch-absorbing panel sits on t… | important | agnostic |  |
| P2-06 | Scale the game world proportionally (camera or FixedResolutionViewport, FittedBox for f… | important | flutter/flame |  |
| P2-07 | Decide the font-size policy explicitly: honor it by default; if the HUD can't take it, … | important | flutter/flame | yes |
| P2-08 | Test the system "Display size" setting (it changes density, not the font); if it breaks… | nice-to-have | agnostic |  |
| P2-09 | Test on large screens, foldables and multi-window (7.6" foldable emulator, Pixel C-clas… | important | agnostic |  |
| P3-01 | Pause the game loop in the background: Flame does it by default (pauseWhenBackgrounded … | critical | flutter/flame | yes |
| P3-02 | When returning from the background, show a pause menu instead of resuming hot. | important | agnostic |  |
| P3-03 | Observe the lifecycle from the gameplay screen too (WidgetsBindingObserver) for audio a… | important | flutter/flame | yes |
| P3-04 | Save progress and stats at safe moments (level end, pause, exit) with fail-soft writes. | important | agnostic |  |
| P3-05 | Decide what happens to the current run if the system kills the process (restore it, or … | nice-to-have | agnostic |  |
| P3-06 | Offer "Clear data / stats" with confirmation. | nice-to-have | agnostic |  |
| P3-07 | Configure Auto Backup (android:dataExtractionRules and android:fullBackupContent) to in… | important | agnostic | yes |
| P4-01 | Make audio fail-soft: if init or an asset fails, the game keeps going and only that voi… | important | agnostic |  |
| P4-02 | Request and release audio focus, and react to calls or other apps. | important | agnostic |  |
| P4-03 | Silence everything in the background and don't use a foreground service (games don't pl… | critical | agnostic |  |
| P4-04 | Release players in order (await pause() then dispose(); never stop and dispose without … | important | flutter/flame |  |
| P4-05 | Add sound settings (master, separate music and SFX, mute) and persist them. | nice-to-have | agnostic |  |
| P4-06 | Preload SFX and loops and pick suitable formats (short OGG or MP3; procedural audio whe… | nice-to-have | agnostic |  |
| P5-01 | Enable predictive back: android:enableOnBackInvokedCallback="true" on <application>; wh… | important | agnostic | yes |
| P5-02 | Protect the current run with PopScope (declarative canPop): a back gesture pauses, asks… | important | flutter/flame | yes |
| P5-03 | Follow standard navigation: back returns to the previous screen and exits from the main… | important | agnostic |  |
| P5-04 | Make multi-touch robust: track pointers by id, always forward move and up, and never le… | important | flutter/flame |  |
| P5-05 | Keep touch controls out of the system gesture areas (edges), or make them configurable … | nice-to-have | agnostic |  |
| P5-06 | Offer optional haptics behind an injectable interface (so tests can use a fake). | nice-to-have | flutter/flame |  |
| P6-01 | Target 60 FPS on mid-range devices (16.7 ms per frame) and measure it on a real device … | important | agnostic |  |
| P6-02 | Don't allocate memory in update() or render(): cache Paint, Path, TextPainter and shade… | important | flutter/flame |  |
| P6-03 | Bound the cost of heavy computations (similarity, AI, generation): run them at a bounde… | important | agnostic |  |
| P6-04 | Show feedback if startup takes more than 2 s and preload assets outside of gameplay. | important | agnostic |  |
| P6-05 | Watch the AAB size (compress videos and large images; if it grows a lot, use Play Asset… | nice-to-have | agnostic |  |
| P6-06 | Check temperature and battery drain in 5–10 minute sessions. | nice-to-have | agnostic |  |
| P7-01 | Label controls with Semantics or semanticsLabel (menu buttons, settings, icons). | important | flutter/flame | yes |
| P7-02 | Use touch targets of 48 dp or more and contrast of 4.5:1 or more (3:1 for large text). | important | agnostic |  |
| P7-03 | Don't convey information through color alone (shape, icon or supporting text); consider… | nice-to-have | agnostic |  |
| P7-04 | Externalize all strings and choose the i18n mechanism: flutter_localizations with ARB (… | important | flutter/flame | yes |
| P7-05 | Declare per-app language (localeConfig or supportedLocales) and test long strings (Germ… | nice-to-have | agnostic |  |
| P7-06 | Limit line length in long texts (45 to 75 characters) in story or help screens. | nice-to-have | agnostic |  |
| P8-01 | Install global error handlers (FlutterError.onError and PlatformDispatcher.instance.onE… | important | flutter/flame | yes |
| P8-02 | If you obfuscate Dart, keep the symbols for every version (--obfuscate --split-debug-in… | important | flutter/flame |  |
| P8-03 | Decide whether to use a crash SDK (Crashlytics, Sentry) or only Android vitals, and ref… | important | agnostic |  |
| P8-04 | Don't log personal data; debugPrint only for diagnostics; no print in production. | important | agnostic | yes |
| P8-05 | Review the pre-launch report and Android vitals (crashes, ANRs, slow frames) before goi… | important | agnostic |  |
| P9-01 | Keep flutter analyze warning-free (with flutter_lints or stricter). | important | flutter/flame | yes |
| P9-02 | Write unit tests for the pure logic (rules, scoring, seeded procedural generation, leve… | important | agnostic | yes |
| P9-03 | Prove every level is solvable with an automated headless player or a validator. | important | agnostic |  |
| P9-04 | Write widget tests for layout and flow (several sizes, font at 1.3 and 2.0, simulated i… | important | flutter/flame |  |
| P9-05 | If there are shaders, add a parity test between the Dart model and the shader (with a d… | nice-to-have | flutter/flame |  |
| P9-06 | Generate E2E screenshots automatically (Playwright on the release web build, or integra… | nice-to-have | flutter/flame |  |
| P9-07 | Add CI on every PR that runs verify.sh (or at least analyze and tests); site publishing… | important | agnostic | yes |
| P9-08 | Test on representative devices and emulators: a physical mid-range device, the latest A… | important | agnostic |  |
| P10-01 | Create the upload key (RSA 2048 bits or more, alias upload) and keep it out of git and … | critical | agnostic | yes |
| P10-02 | Configure release signing with key.properties, tolerant of the file being missing (for … | critical | flutter/flame | yes |
| P10-03 | Enable Play App Signing (mandatory for new apps with AAB). | critical | agnostic |  |
| P10-04 | Always publish an AAB (flutter build appbundle --release); APKs only for testing outsid… | critical | agnostic |  |
| P10-05 | Check the final AAB: target and min SDK, permissions, versionCode, 16 KB and no debug l… | critical | agnostic | yes |
| P10-06 | Write per-language release notes in the repo (release_notes/<version>-<lang>.txt). | nice-to-have | agnostic |  |
| P11-01 | Publish the privacy policy at a stable URL (e.g. https://<domain>/privacy.html with Git… | critical | agnostic | yes |
| P11-02 | Fill in Data safety according to what the game really does (even if it collects nothing). | critical | agnostic |  |
| P11-03 | Complete the content rating questionnaire (IARC) and redo it if the content changes. | critical | agnostic |  |
| P11-04 | Declare target audience, ads and access; if minors are in the audience, review Families… | critical | agnostic |  |
| P11-05 | Prepare the listing: title, short and full description (per language), 512 px icon, 102… | critical | agnostic |  |
| P11-06 | Choose the "Game" category and its subcategory on Play (in addition to appCategory in t… | important | agnostic |  |
| P11-07 | If the game is paid or has IAP, set up the payments profile, per-country prices and tax… | critical | agnostic |  |
| P11-08 | Go through internal testing and, if the account requires it, closed testing before prod… | important | agnostic |  |
| P11-09 | Confirm Android developer verification (identity and package registration). | important | agnostic |  |
| P11-10 | Publish a minimal promo site (page, video, Play link and policy) deployed by CI. | nice-to-have | agnostic |  |
| P12-01 | Review the target API requirement every year (Play usually raises it in August, with an… | critical | agnostic |  |
| P12-02 | Read the behavior changes of every new Android release (edge-to-edge, orientation, back… | important | agnostic |  |
| P12-03 | Keep dependencies up to date (flutter pub outdated), prioritizing those that ship nativ… | important | flutter/flame |  |
| P12-04 | Watch Android vitals and reviews and respond to bugs that reproduce. | important | agnostic |  |
| P12-05 | Keep the docs in sync with the published version (roadmap checked off, README without c… | nice-to-have | agnostic |  |
| P12-06 | Feed each game's lessons back into this template or skill (what was solved, what was mi… | nice-to-have | agnostic |  |

## Phase 0 · Kickoff, template and methodology

### P0-01 · **Write the intent and the spec before the code** (intent → spec → plan → decisions).
`important` · `agnostic` · `[auto]`
- Why: an agent or developer without a spec produces rework; the spec is the "done" contract.
- Verify: `docs/00_intent.md`, `docs/00_spec.md`, `docs/01_plan.md` and `docs/02_decisions.md` (ADRs) exist.

### P0-02 · **Keep a resumable state file** (current phase, last green checkpoint, blockers, next step).
`important` · `agnostic`
- Why: lets human or agent sessions resume without losing context.
- Verify: `docs/03_state.md` updated at the close of each phase.

### P0-03 · **Define agent rules and stop rules**: Play, payments, secrets or keystore, merges to `main` and public releases are always the owner's call.
`important` · `agnostic`
- Why: prevents irreversible actions taken by automation.
- Verify: `AGENTS.md` with prohibitions, autonomy level and budgets.

### P0-04 · **Create a single verification harness** (`verify.sh`) used the same way by the agent and by CI.
`important` · `agnostic` · `[auto]`
- Why: one definition of "green" keeps any check from being left out.
- Verify: `./verify.sh` exits 0; `./verify.sh --no-apk` for fast iteration.

### P0-05 · **Write a human acceptance script** containing only what a machine can't judge (feel, difficulty curve, legibility).
`nice-to-have` · `agnostic`
- Why: separates automated validation from taste and makes the demo repeatable.
- Verify: `docs/04_acceptance.md` with checkboxes and a verdict.

### P0-06 · **Lock in the final `applicationId` before the first upload to Play** (your own reverse domain).
`critical` · `agnostic` · `[auto]`
- Why: it can't be changed once uploaded.
- Verify: `applicationId` and `namespace` in `android/app/build.gradle.kts`, plus the package of `MainActivity.kt`.
- Source: <https://docs.flutter.dev/deployment/android>

### P0-07 · **Check that the game's name is available** (Play, domain, trademarks).
`nice-to-have` · `agnostic`
- Why: renaming later costs the listing, icon, domain and policy.
- Verify: search Play and the web; domain for the privacy policy.

### P0-08 · **Centralize game constants and strings** (`game_config.dart`, `app_strings.dart`).
`important` · `flutter/flame`
- Why: makes balance tuning, tests and later translation easier.
- Verify: `rg "fontSize:|Duration\(" lib` shows no scattered magic numbers in the logic.

### P0-09 · **Separate pure logic (no Flame or Flutter) from components**.
`important` · `flutter/flame`
- Why: pure logic is tested with fast tests that need no platform.
- Verify: `lib/logic` or `lib/managers` don't import `package:flame` and have tests.

## Phase 1 · Project setup and build

### P1-01 · **Use Flutter's default SDK values, or pin them deliberately** (`compileSdk`, `targetSdk`, `minSdk`).
`critical` · `flutter/flame` · ⚠ dated · `[auto]`
- Why: `flutter.targetSdkVersion` follows the Play requirement as Flutter is updated. A pinned number must be reviewed every year.
- Verify: `android/app/build.gradle.kts`; effective value in `build/app/intermediates/merged_manifests/release/.../AndroidManifest.xml` (`<uses-sdk>`).
- Source: <https://docs.flutter.dev/deployment/android>

### P1-02 · **Target the API level Play requires**: since **Aug 31, 2026, API 36** for new apps and updates; existing apps need **API 35 or higher** to stay visible.
`critical` · `agnostic` · ⚠ dated · `[auto]`
- Why: Play rejects the upload if it isn't met.
- Verify: merged manifest (`targetSdkVersion="36"`); Play Console › App bundle explorer.
- Source: <https://support.google.com/googleplay/android-developer/answer/11926878> · <https://developer.android.com/google/play/requirements/target-sdk>

### P1-03 · **Use a 16 KB-compatible toolchain** (AGP 8.5.1 or newer, NDK r28 or newer, Flutter 3.35 or newer) and update plugins that ship native code.
`critical` · `agnostic` · ⚠ dated · `[auto]`
- Why: Play requires 16 KB support for apps targeting 35+; non-compliant updates are blocked starting Feb 1, 2027.
- Verify: `unzip` the AAB and run `readelf -lW base/lib/arm64-v8a/*.so | grep LOAD` (alignment 0x4000 or higher); Play Console › App bundle explorer.
- Source: <https://developer.android.com/guide/practices/page-sizes>

### P1-04 · **Version from `pubspec.yaml`** (`version: X.Y.Z+N`), bump `N` (versionCode) for every AAB, and keep a single version source in the docs.
`critical` · `flutter/flame` · `[auto]`
- Why: Play rejects a repeated versionCode, and contradictory versions in the docs cause confusion.
- Verify: `grep ^version pubspec.yaml`; the README and plan don't cite another version.

### P1-05 · **Rely on R8 (on by default in release) and add `proguard-rules.pro` only if a plugin asks for it**.
`important` · `flutter/flame`
- Why: shrinks the build; unnecessary rules hide problems.
- Verify: `flutter build appbundle` with no R8 errors; the app launches in release.
- Source: <https://docs.flutter.dev/deployment/android>

### P1-06 · **Declare only the permissions the code actually uses**; don't add `INTERNET` if the game is offline.
`important` · `agnostic` · `[auto]`
- Why: Minimize_Permissions in the quality guidelines; the privacy policy and Data safety must also match.
- Verify: `grep uses-permission` in the merged manifest; search `lib/` for real use of each permission (for example, `WAKE_LOCK` without a wakelock plugin is unneeded).
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

### P1-07 · **Remove unused dependencies and bundle fonts instead of downloading them** (with their license, e.g. OFL).
`nice-to-have` · `flutter/flame` · `[auto]`
- Why: a font downloaded at runtime needs network access and changes the privacy surface.
- Verify: `rg "import 'package:<dep>" lib` for each dependency; `flutter pub deps`; fonts in `assets/fonts/`.

### P1-08 · **Declare every asset in `pubspec.yaml`** and check that it makes it into the build.
`important` · `flutter/flame` · `[auto]`
- Why: an undeclared asset only fails at runtime.
- Verify: `unzip -l build/app/outputs/flutter-apk/app-release.apk | grep flutter_assets`.

### P1-09 · **Create your own adaptive icon**: legacy, `mipmap-anydpi-v26/ic_launcher.xml` with foreground and background, and a `<monochrome>` layer.
`critical` · `agnostic` · `[auto]`
- Why: the template's default icon isn't publishable, and Android 13+ uses the monochrome layer for themed icons.
- Verify: `md5sum` of `mipmap-*/ic_launcher.png` differs from the Flutter template's; the adaptive XML exists.
- Priority: critical (own icon) / nice-to-have (monochrome).
- Source: <https://docs.flutter.dev/deployment/android>

### P1-10 · **Give `LaunchTheme` and `NormalTheme` the game's background color** (not `Theme.Light` if the game is dark).
`important` · `flutter/flame` · `[auto]`
- Why: avoids the white flash before the first frame.
- Verify: `values/styles.xml`, `values-night/styles.xml` and `drawable*/launch_background.xml` use `@color/splash_background`; cold start in light mode.
- Snippet: S-01 (`snippets.md`)

## Phase 2 · Screen, scaling, orientation, edge-to-edge and large screens

### P2-01 · **Declare the app as a game**: `android:appCategory="game"` on `<application>`.
`critical` · `agnostic` · ⚠ dated · `[auto]`
- Why: when targeting 36, Android 16 ignores `screenOrientation`, `resizeableActivity` and aspect-ratio limits on screens of 600 dp or more, **except for games**.
- Verify: merged manifest; a tablet or foldable emulator on API 36 honors the orientation.
- Source: <https://developer.android.com/about/versions/16/behavior-changes-16> · <https://developer.android.com/develop/adaptive-apps/guides/app-orientation-aspect-ratio-resizability>
- Snippet: S-02 (`snippets.md`)

### P2-02 · **Lock orientation in two places**: the manifest (`portrait` or `sensorLandscape`) and `SystemChrome.setPreferredOrientations`.
`important` · `flutter/flame` · `[auto]`
- Why: the manifest prevents the initial rotation and Dart enforces it at runtime.
- Verify: rotate the device on every screen.

### P2-03 · **Design for edge-to-edge**: it's mandatory when targeting 35/36, and in Flutter, when targeting 36, modes other than `edgeToEdge` have no effect. Use `SystemUiMode.edgeToEdge` with transparent bars and don't use `windowOptOutEdgeToEdgeEnforcement`.
`critical` · `flutter/flame` · ⚠ dated · `[auto]`
- Why: if you assume `immersiveSticky`, the HUD can end up under the bars or the notch.
- Verify: `rg "setEnabledSystemUIMode|windowOptOutEdgeToEdge" lib android`; test on a physical Android 16 device with both gesture and button navigation.
- Source: <https://api.flutter.dev/flutter/services/SystemChrome/setEnabledSystemUIMode.html> · <https://docs.flutter.dev/release/breaking-changes/default-systemuimode-edge-to-edge>
- Snippet: S-03 (`snippets.md`)

### P2-04 · **Respect insets** (bars, notch, cutouts, gesture areas) in the HUD, menus and touch controls: `SafeArea` or `MediaQuery.paddingOf`, with symmetric horizontal margins.
`important` · `flutter/flame` · `[auto]`
- Why: a joystick or button under the notch or the gesture area stops working.
- Verify: emulator with a cutout (Settings › Developer options › Display cutout); widget test with simulated `padding`.

### P2-05 · **Separate the playfield from the HUD by construction**: no touch-absorbing panel sits on top of the play area.
`important` · `agnostic`
- Why: playable elements under the HUD can't be touched; it's a typical failure of full-bleed mockups.
- Verify: widget test at 3 or 4 sizes (e.g. 360×640, 412×915, 800×360, tablet): playfield ∩ HUD = ∅ and the hit test reaches the game's `Listener`.

### P2-06 · **Scale the game world proportionally** (camera or `FixedResolutionViewport`, `FittedBox` for fixed boards, scale by the short side) and test several aspect ratios (16:9 to 21:9, tablet).
`important` · `flutter/flame`
- Why: Fullscreen_Display (no letterboxing) and parity across devices.
- Verify: layout tests at several `Size` values; E2E screenshots.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

### P2-07 · **Decide the font-size policy explicitly**: honor it by default; if the HUD can't take it, clamp it instead of disabling it app-wide.
`important` · `flutter/flame` · `[auto]`
- Why: accessibility asks for large-text support; disabling it in menus and settings hurts the people who need it.
- Verify: test with `TextScaler.linear(1.3)` and `2.0` without overflow; `rg "textScaler|withNoTextScaling" lib`.
- Source: <https://docs.flutter.dev/ui/accessibility/ui-design-and-styling>
- Snippet: S-04 (`snippets.md`)

### P2-08 · **Test the system "Display size" setting** (it changes density, not the font); if it breaks proportions, normalize with the stable density (`DisplayMetrics.DENSITY_DEVICE_STABLE`).
`nice-to-have` · `agnostic`
- Why: with Display size enlarged, controls with a fixed logical size no longer line up with the world.
- Verify: Settings › Display › Display size at minimum and maximum; proportion test.

### P2-09 · **Test on large screens, foldables and multi-window** (7.6" foldable emulator, Pixel C-class tablet, desktop window).
`important` · `agnostic`
- Why: the quality guidelines name these emulators as a minimum; adaptive quality also improves Play ranking.
- Verify: AVD Manager; Play Console › Quality › large screens.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

## Phase 3 · Lifecycle, state and saving

### P3-01 · **Pause the game loop in the background**: Flame does it by default (`pauseWhenBackgrounded = true`); if you override `lifecycleStateChange`, always call `super`.
`critical` · `flutter/flame` · `[auto]`
- Why: avoids huge `dt` jumps on return and battery drain (Sleep_Resume, Lock_Resume).
- Verify: lock and unlock, go to Recents and back; `rg "lifecycleStateChange|pauseWhenBackgrounded" lib`.
- Source: <https://docs.flame-engine.org/latest/flame/game.html>
- Snippet: S-05 (`snippets.md`)

### P3-02 · **When returning from the background, show a pause menu instead of resuming hot**.
`important` · `agnostic`
- Why: the player doesn't lose the run to a notification or a phone call.
- Verify: mid-run, pull down the notification shade and go Home; the pause menu appears on return.

### P3-03 · **Observe the lifecycle from the gameplay screen too** (`WidgetsBindingObserver`) for audio and timers, and adopt the current state when the screen opens.
`important` · `flutter/flame` · `[auto]`
- Why: an audio hold "stuck" from a previous run leaves the game mute; `Timer.periodic` keeps running in the background.
- Verify: widget test with `tester.binding.handleAppLifecycleStateChanged(...)`.
- Snippet: S-06 (`snippets.md`)

### P3-04 · **Save progress and stats at safe moments** (level end, pause, exit) with fail-soft writes.
`important` · `agnostic`
- Why: State_Preservation; a storage exception must not crash the run.
- Verify: kill the app from Recents mid-level and reopen it; test the persistence layer with `SharedPreferences.setMockInitialValues`.

### P3-05 · **Decide what happens to the current run if the system kills the process** (restore it, or explicitly return to the menu).
`nice-to-have` · `agnostic`
- Why: the quality guidelines ask to restore state if only a few minutes have passed.
- Verify: `adb shell am kill <package>` with the app in the background, then return.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

### P3-06 · **Offer "Clear data / stats" with confirmation**.
`nice-to-have` · `agnostic`
- Why: user control; the privacy policy must explain how to delete data.
- Verify: flow in Settings; reset test.

### P3-07 · **Configure Auto Backup** (`android:dataExtractionRules` and `android:fullBackupContent`) to include preferences.
`important` · `agnostic` · `[auto]`
- Why: App_Data_Backup; progress survives a phone change.
- Verify: `adb shell bmgr backupnow <package>`, uninstall, reinstall and check.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

## Phase 4 · Audio

### P4-01 · **Make audio fail-soft**: if init or an asset fails, the game keeps going and only that voice goes mute.
`important` · `agnostic`
- Why: codec or device failures must not cause a crash.
- Verify: test with a missing asset; `try/catch` in `AudioManager`.

### P4-02 · **Request and release audio focus, and react to calls or other apps**.
`important` · `agnostic`
- Why: Audio_Focus_Request and Audio_Focus_Change.
- Verify: play music in another app or take a call during a run.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>
- Snippet: S-07 (`snippets.md`)

### P4-03 · **Silence everything in the background and don't use a foreground service** (games don't play audio in the background).
`critical` · `agnostic`
- Why: Background_Service_Optimization; nobody wants to hear the game with the screen locked.
- Verify: go Home and lock the device; silence is immediate.

### P4-04 · **Release players in order** (`await pause()` then `dispose()`; never `stop` and `dispose` without awaiting).
`important` · `flutter/flame`
- Why: avoids race conditions and native crashes when leaving a run.
- Verify: enter and leave a run 20 times in a row; logcat shows no exceptions.

### P4-05 · **Add sound settings** (master, separate music and SFX, mute) and persist them.
`nice-to-have` · `agnostic`
- Why: a basic player expectation; many people play muted.
- Verify: test of the settings layer; restarting the app keeps the mix.

### P4-06 · **Preload SFX and loops** and pick suitable formats (short OGG or MP3; procedural audio where it fits).
`nice-to-have` · `agnostic`
- Why: Audio_Playback_Start (under 1 s) and no stutter on the first shot.
- Verify: profile the first sound event.

## Phase 5 · Input and predictive back

### P5-01 · **Enable predictive back**: `android:enableOnBackInvokedCallback="true"` on `<application>`; when targeting 36 the animation is on by default and `onBackPressed` is no longer called.
`important` · `agnostic` · ⚠ dated · `[auto]`
- Why: legacy BACK interception stops working on Android 16.
- Verify: merged manifest; back gesture on Android 14+ (the preview of the menu or Home appears).
- Source: <https://docs.flutter.dev/platform-integration/android/predictive-back> · <https://developer.android.com/guide/navigation/custom-back/predictive-back-gesture>

### P5-02 · **Protect the current run with `PopScope`** (declarative `canPop`): a back gesture pauses, asks for confirmation and saves the attempt before leaving.
`important` · `flutter/flame` · `[auto]`
- Why: State_Preservation asks to prevent accidental loss through back navigation; edge gestures collide with joysticks.
- Verify: back gesture mid-run, with both gesture and button navigation; widget test with `tester.binding.handlePopRoute()`.
- Snippet: S-08 (`snippets.md`)

### P5-03 · **Follow standard navigation**: back returns to the previous screen and exits from the main menu; no custom "back" buttons as the only way out.
`important` · `agnostic`
- Why: Back_Button_Nav and Back_Gesture_Nav.
- Verify: walk through every screen pressing back.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

### P5-04 · **Make multi-touch robust**: track pointers by id, always forward `move` and `up`, and never leave "stuck" pointers in pinches or with two joysticks.
`important` · `flutter/flame`
- Why: a lost `up` leaves a control pinned or a ghost pinch.
- Verify: gesture tests with several pointers and different release orders; manual tests releasing in reverse order.

### P5-05 · **Keep touch controls out of the system gesture areas** (edges), or make them configurable (position and swappable side).
`nice-to-have` · `agnostic`
- Why: the edges trigger the back or Home gesture.
- Verify: `MediaQuery.systemGestureInsetsOf`; control customizer.

### P5-06 · **Offer optional haptics** behind an injectable interface (so tests can use a fake).
`nice-to-have` · `flutter/flame`
- Why: improves the feel; some players turn it off.
- Verify: test with a fake `Haptics`; on/off setting.

## Phase 6 · Performance

### P6-01 · **Target 60 FPS on mid-range devices** (16.7 ms per frame) and measure it on a real device in `--profile` mode.
`important` · `agnostic`
- Why: Rendering_Performance.
- Verify: `flutter run --profile` with DevTools › Performance; your own benchmark (`--dart-define=BENCH=true`) that prints p50 and p95.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

### P6-02 · **Don't allocate memory in `update()` or `render()`**: cache `Paint`, `Path`, `TextPainter` and shaders, and reuse segments or particles with pools.
`important` · `flutter/flame`
- Why: GC pressure causes stutter.
- Verify: code review; DevTools › Memory shows no GC spikes during play.

### P6-03 · **Bound the cost of heavy computations** (similarity, AI, generation): run them at a bounded rate, off the frame or in an `Isolate`.
`important` · `agnostic`
- Why: avoids ANRs and long frames.
- Verify: benchmark of the function; timings in the log.

### P6-04 · **Show feedback if startup takes more than 2 s** and preload assets outside of gameplay.
`important` · `agnostic`
- Why: App_Startup_Time.
- Verify: timed cold start; Play Console › Android vitals › Startup.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

### P6-05 · **Watch the AAB size** (compress videos and large images; if it grows a lot, use Play Asset Delivery).
`nice-to-have` · `agnostic`
- Why: download size affects conversion and has per-module limits on Play.
- Verify: `ls -la build/app/outputs/bundle/release/`; Play Console › App bundle explorer › download size.

### P6-06 · **Check temperature and battery drain** in 5–10 minute sessions.
`nice-to-have` · `agnostic`
- Why: Power_Management; long play sessions heat up the device.
- Verify: manual test; Android Studio › Power Profiler.

## Phase 7 · Accessibility and internationalization

### P7-01 · **Label controls with `Semantics` or `semanticsLabel`** (menu buttons, settings, icons).
`important` · `flutter/flame` · `[auto]`
- Why: Content_Description; TalkBack reads the menus.
- Verify: TalkBack on; `rg "Semantics|semanticsLabel" lib`; `meetsGuideline(labeledTapTargetGuideline)` in tests.
- Source: <https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility>

### P7-02 · **Use touch targets of 48 dp or more and contrast of 4.5:1 or more** (3:1 for large text).
`important` · `agnostic`
- Why: Touch_Target_Size and Visual_Contrast.
- Verify: Accessibility Scanner; `meetsGuideline(androidTapTargetGuideline)` and `textContrastGuideline`.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>
- Snippet: S-09 (`snippets.md`)

### P7-03 · **Don't convey information through color alone** (shape, icon or supporting text); consider a color-blind mode.
`nice-to-have` · `agnostic`
- Why: in color games or games with treasure types, about 8 % of men have a color vision deficiency.
- Verify: color-blindness simulation in Developer options.

### P7-04 · **Externalize all strings** and choose the i18n mechanism: `flutter_localizations` with ARB (recommended) or a per-locale strings class for an MVP.
`important` · `flutter/flame` · `[auto]`
- Why: translate later without touching the UI; strings scattered through widgets make the change harder.
- Verify: `rg "Text\('" lib` returns nothing outside the strings layer; `l10n.yaml` and `lib/l10n/*.arb`.
- Source: <https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization>

### P7-05 · **Declare per-app language** (`localeConfig` or `supportedLocales`) and test long strings (German, Spanish).
`nice-to-have` · `agnostic`
- Why: Android 13+ lets users choose the language per app; long strings break buttons.
- Verify: Settings › Apps › Language; screenshots in each language.

### P7-06 · **Limit line length in long texts** (45 to 75 characters) in story or help screens.
`nice-to-have` · `agnostic`
- Why: Line_Length.
- Verify: visual review on a tablet.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

## Phase 8 · Errors, crashes and symbols

### P8-01 · **Install global error handlers** (`FlutterError.onError` and `PlatformDispatcher.instance.onError`) with local logging; no network if the policy says "offline".
`important` · `flutter/flame` · `[auto]`
- Why: Dart exceptions don't bring the app down, so they go unnoticed.
- Verify: `rg "FlutterError.onError|PlatformDispatcher.instance.onError" lib`; force an exception in debug.
- Snippet: S-10 (`snippets.md`)

### P8-02 · **If you obfuscate Dart, keep the symbols for every version** (`--obfuscate --split-debug-info=symbols/<version>`) outside git, and upload native debug symbols to Play.
`important` · `flutter/flame`
- Why: without symbols, Android vitals stack traces can't be read.
- Verify: one symbols folder per versionCode; Play Console › App bundle › native debug symbols.
- Source: <https://docs.flutter.dev/deployment/android>

### P8-03 · **Decide whether to use a crash SDK** (Crashlytics, Sentry) **or only Android vitals**, and reflect it in the policy and in Data safety.
`important` · `agnostic`
- Why: a crash SDK collects data, and declaring it wrong in Data safety is grounds for rejection.
- Verify: dependencies vs. privacy policy vs. Data safety.

### P8-04 · **Don't log personal data**; `debugPrint` only for diagnostics; no `print` in production.
`important` · `agnostic` · `[auto]`
- Why: Sensitive_Data_Logging; lint rules catch it.
- Verify: `rg "print\(" lib`; `avoid_print` in `analysis_options.yaml`.

### P8-05 · **Review the pre-launch report and Android vitals** (crashes, ANRs, slow frames) before going to production.
`important` · `agnostic`
- Why: Stability_ANR.
- Verify: Play Console › Testing › Pre-launch report; Quality › Android vitals.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

## Phase 9 · Testing and CI

### P9-01 · **Keep `flutter analyze` warning-free** (with `flutter_lints` or stricter).
`important` · `flutter/flame` · `[auto]`
- Why: catches cheap mistakes before the device does.
- Verify: `flutter analyze` finishes with no issues.

### P9-02 · **Write unit tests for the pure logic** (rules, scoring, seeded procedural generation, level validator) that call the shipped code without reimplementing formulas.
`important` · `agnostic` · `[auto]`
- Why: protects balance and rules against regressions.
- Verify: `flutter test`; requirement → test matrix in the spec.

### P9-03 · **Prove every level is solvable** with an automated headless player or a validator.
`important` · `agnostic`
- Why: avoids shipping impossible levels.
- Verify: a level-validation test that prints a report.

### P9-04 · **Write widget tests for layout and flow** (several sizes, font at 1.3 and 2.0, simulated insets, navigation and back).
`important` · `flutter/flame`
- Why: locks in the guarantees from phases 2 and 5.
- Verify: `tester.view.physicalSize = ...`, `MediaQueryData(textScaler: ...)` and `handlePopRoute()`.

### P9-05 · **If there are shaders, add a parity test** between the Dart model and the shader (with a defined tolerance).
`nice-to-have` · `flutter/flame`
- Why: logic must not read GPU pixels; the model is the source of truth.
- Verify: a test that loads `FragmentProgram` headless and compares.

### P9-06 · **Generate E2E screenshots automatically** (Playwright on the release web build, or integration_test on Android).
`nice-to-have` · `flutter/flame`
- Why: catches visual regressions and produces gameplay screenshots.
- Verify: `npm test` in `e2e/` inside `verify.sh`.

### P9-07 · **Add CI on every PR** that runs `verify.sh` (or at least analyze and tests); site publishing goes in a separate workflow.
`important` · `agnostic` · `[auto]`
- Why: a Pages-only workflow doesn't protect the code.
- Verify: `.github/workflows/ci.yml` green on the PR; `main` protected.
- Snippet: S-11 (`snippets.md`)

### P9-08 · **Test on representative devices and emulators**: a physical mid-range device, the latest Android, a foldable, a tablet and a 16 KB emulator.
`important` · `agnostic`
- Why: this is the test environment the quality guidelines ask for.
- Verify: matrix recorded in the acceptance script.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

## Phase 10 · Signing and release

### P10-01 · **Create the upload key** (RSA 2048 bits or more, alias `upload`) and keep it **out of git and off the shared machine**, with an encrypted backup.
`critical` · `agnostic` · `[auto]`
- Why: losing the key means requesting a reset; if it leaks, someone can sign in your name.
- Verify: `git check-ignore android/key.properties *.jks`; backup checked.
- Source: <https://developer.android.com/studio/publish/app-signing>
- Snippet: S-12 (`snippets.md`)

### P10-02 · **Configure release signing with `key.properties`**, tolerant of the file being missing (for CI and test builds) and **without the debug key in release**.
`critical` · `flutter/flame` · `[auto]`
- Why: `.toString()` on a null value produces `"null"` and breaks the build without the key; a release signed with the debug key can't be published.
- Verify: `android/app/build.gradle.kts`; `apksigner verify --print-certs` on the APK generated from the AAB.
- Source: <https://docs.flutter.dev/deployment/android>
- Snippet: S-13, S-14 (`snippets.md`)

### P10-03 · **Enable Play App Signing** (mandatory for new apps with AAB).
`critical` · `agnostic`
- Why: Google holds the app signing key; if the upload key is lost it can be reset. The future hybrid PQC signing (Android 17) will be offered by Play.
- Verify: Play Console › Setup › App integrity › App signing.
- Source: <https://developer.android.com/studio/publish/app-signing>

### P10-04 · **Always publish an AAB** (`flutter build appbundle --release`); APKs only for testing outside Play (`--split-per-abi`).
`critical` · `agnostic`
- Why: AAB is mandatory on Play for new apps.
- Verify: `build/app/outputs/bundle/release/app-release.aab`; test it with `bundletool` or on internal testing.
- Source: <https://docs.flutter.dev/deployment/android>

### P10-05 · **Check the final AAB**: target and min SDK, permissions, versionCode, 16 KB and no debug libraries.
`critical` · `agnostic` · ⚠ dated · `[auto]`
- Why: Production_Build_Quality; the last check before uploading.
- Verify: release merged manifest; `readelf -lW` on the `.so` files; Play Console › App bundle explorer.

### P10-06 · **Write per-language release notes** in the repo (`release_notes/<version>-<lang>.txt`).
`nice-to-have` · `agnostic`
- Why: traceability and direct copy-paste into the console.
- Verify: one file per version and language.

## Phase 11 · Google Play publishing and policies

### P11-01 · **Publish the privacy policy at a stable URL** (e.g. `https://<domain>/privacy.html` with GitHub Pages), bilingual and consistent with permissions, SDKs and local storage.
`critical` · `agnostic` · `[auto]`
- Why: Play requires it; a policy that doesn't match real behavior gets rejected.
- Verify: URL reachable; compare permissions and dependencies against the text.

### P11-02 · **Fill in Data safety** according to what the game really does (even if it collects nothing).
`critical` · `agnostic`
- Why: mandatory for every published app.
- Verify: Play Console › App content › Data safety.
- Source: <https://support.google.com/googleplay/android-developer/answer/10787469>

### P11-03 · **Complete the content rating questionnaire** (IARC) and redo it if the content changes.
`critical` · `agnostic`
- Why: an app can't be published without a rating.
- Verify: Play Console › App content › Content rating.
- Source: <https://support.google.com/googleplay/android-developer/answer/9859655>

### P11-04 · **Declare target audience, ads and access**; if minors are in the audience, review Families and the minors policies.
`critical` · `agnostic` · ⚠ dated
- Why: these declarations are mandatory; the minors policies were tightened in 2026.
- Verify: Play Console › App content (every section green).

### P11-05 · **Prepare the listing**: title, short and full description (per language), 512 px icon, 1024×500 feature graphic (no small text or screenshots), screenshots in the game's real orientation, and an optional video.
`critical` · `agnostic`
- Why: Play_Feature_Graphic and Play_Misleading_Content.
- Verify: Play Console › Main store listing; screenshots stay legible when scaled down.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

### P11-06 · **Choose the "Game" category and its subcategory** on Play (in addition to `appCategory` in the manifest).
`important` · `agnostic`
- Why: discoverability, and Play can manage the game flag with an AAB.
- Verify: Play Console › Store settings.

### P11-07 · **If the game is paid or has IAP**, set up the payments profile, per-country prices and taxes; for IAP, use Play Billing.
`critical` · `agnostic`
- Why: without a payments profile you can't set prices; IAP outside Play Billing violates policy.
- Verify: Play Console › Setup › Payments profile; Monetize › Products.
- Priority: critical (if applicable).

### P11-08 · **Go through internal testing and, if the account requires it, closed testing** before production (new personal accounts need testers for several days before production).
`important` · `agnostic` · ⚠ dated
- Why: the pre-launch report and real feedback arrive before every user gets the build.
- Verify: Play Console › Testing › Internal or closed testing.

### P11-09 · **Confirm Android developer verification** (identity and package registration).
`important` · `agnostic` · ⚠ dated
- Why: already required in some countries; the global rollout is planned for 2027.
- Verify: Play Console › Settings › Developer account.
- Source: <https://developer.android.com/developer-verification>

### P11-10 · **Publish a minimal promo site** (page, video, Play link and policy) deployed by CI.
`nice-to-have` · `agnostic`
- Why: it serves as the privacy URL and as a marketing destination.
- Verify: Pages workflow green; your own domain with HTTPS.

## Phase 12 · Post-launch maintenance

### P12-01 · **Review the target API requirement every year** (Play usually raises it in August, with an extension until November) and update Flutter, AGP and NDK.
`critical` · `agnostic` · ⚠ dated
- Why: below the required level you can't publish updates, and existing apps stop being visible to new users.
- Verify: <https://support.google.com/googleplay/android-developer/answer/11926878>; Play Console › Dashboard (policy notices).

### P12-02 · **Read the behavior changes of every new Android release** (edge-to-edge, orientation, back, 16 KB…) and test with the compatibility toggles.
`important` · `agnostic`
- Why: Android_Platform_Compatibility.
- Verify: emulator on the latest API; Developer options › App Compatibility Changes.
- Source: <https://developer.android.com/about/versions/16/behavior-changes-16>

### P12-03 · **Keep dependencies up to date** (`flutter pub outdated`), prioritizing those that ship native code.
`important` · `flutter/flame`
- Why: SDK_Maintenance; native plugins are the usual source of 16 KB problems and crashes.
- Verify: `flutter pub outdated`; each native plugin's changelog.
- Source: <https://developer.android.com/docs/quality-guidelines/core-app-quality>

### P12-04 · **Watch Android vitals and reviews** and respond to bugs that reproduce.
`important` · `agnostic`
- Why: Play_User_Reviews and Stability_ANR; vitals thresholds affect visibility.
- Verify: Play Console › Quality › Android vitals, and Ratings and reviews.

### P12-05 · **Keep the docs in sync with the published version** (roadmap checked off, README without contradictory versions, state up to date).
`nice-to-have` · `agnostic`
- Why: stale docs mislead agents, and the author too, months later.
- Verify: the version in the README, the plan and `pubspec.yaml` match; the release-phase roadmap is closed.

### P12-06 · **Feed each game's lessons back into this template or skill** (what was solved, what was missing).
`nice-to-have` · `agnostic`
- Why: continuous improvement across projects.
- Verify: an entry in the skill's changelog.
