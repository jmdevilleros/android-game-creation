# Official sources

Last reviewed: **2026-10-19**. Rows marked ⚠ hold dated requirements. **Before you report them as facts, fetch the source again during the run.** If the live page disagrees with this file, the live page wins. Note the change in the report.

## Google Play requirements and policy

| Source | Covers | Items | Re-verify |
|---|---|---|---|
| [Target API level requirements (Play Console Help)](https://support.google.com/googleplay/android-developer/answer/11926878) | Minimum targetSdk for new apps and updates, and to stay visible to new users | P1-02, P12-01 | ⚠ As of 2026-10-19: since **2026-08-31** new apps and updates must target **API 36**. Existing apps need API ≥ 35 to stay visible on newer devices. A one-time extension ran to 2026-11-01. Play raises the bar yearly, usually at the end of August. |
| [Meet Google Play's target API level requirement (Android Developers)](https://developer.android.com/google/play/requirements/target-sdk) | The same requirement, developer-facing | P1-02 | ⚠ Same as above. |
| [Data safety section](https://support.google.com/googleplay/android-developer/answer/10787469) | Mandatory data-collection declaration, even when the app collects nothing | P11-02, P8-03 | Form fields change from time to time. |
| [Content rating requirements](https://support.google.com/googleplay/android-developer/answer/9859655) | IARC questionnaire, and when to redo it | P11-03 | Stable. |
| [Policy announcement: July 15, 2026 (Play Console Help)](https://support.google.com/googleplay/android-developer/answer/17134731) | Example of the periodic policy updates: new rules on minors and anonymous chat, unrated apps not allowed, guidance on location disclosures in Data safety, and **registering apps in Play Console** for developer verification | P11-03, P11-04, P11-09 | ⚠ Each update gives at least 30 days to comply. Read the latest announcement before every release. |
| [Android developer verification](https://developer.android.com/developer-verification) | Developer identity and package registration for installs on certified devices | P11-09 | ⚠ As of 2026-10-19: enforced in some countries, global rollout planned for 2027. |

## Android platform and quality

| Source | Covers | Items | Re-verify |
|---|---|---|---|
| [Core app quality guidelines](https://developer.android.com/docs/quality-guidelines/core-app-quality) | Baseline quality criteria: lifecycle (App_Switcher, Sleep_Resume, Lock_Resume), State_Preservation, Back_Gesture_Nav, accessibility (48 dp, contrast, descriptions), audio focus, performance (60 fps, under 2 s startup), stability, backup, permissions, Play listing assets, test environment (foldable and tablet emulators) | P2-06, P2-09, P3-05, P3-07, P4-02, P5-03, P6-01, P6-04, P7-01, P7-02, P7-06, P8-05, P9-08, P11-05, P12-03 | The page is versioned and its criteria IDs can change; check the "last updated" date. |
| [Behavior changes: apps targeting Android 16](https://developer.android.com/about/versions/16/behavior-changes-16) | On screens ≥ 600 dp, orientation, resizability and aspect-ratio locks are ignored **except for games** (`android:appCategory`). Edge-to-edge opt-out removed. Predictive back on by default. | P2-01, P2-03, P5-01, P12-02 | ⚠ Each new Android version adds a page like this; read the one for the current target. |
| [App orientation, aspect ratio and resizability](https://developer.android.com/develop/adaptive-apps/guides/app-orientation-aspect-ratio-resizability) | Details and exceptions for the Android 16 large-screen change; the temporary opt-out property is going away | P2-01, P2-09 | ⚠ The docs say the opt-out will be removed in a future release. Check whether it still works for your target. |
| [Support 16 KB page sizes](https://developer.android.com/guide/practices/page-sizes) | Native libraries must be 16 KB-aligned; how to check (APK Analyzer, readelf, Play App bundle explorer) | P1-03, P10-05 | ⚠ As of 2026-10-19: required for apps targeting 35+, and updates that fail are blocked from **2027-02-01**. |
| [Add support for the predictive back gesture](https://developer.android.com/guide/navigation/custom-back/predictive-back-gesture) | `enableOnBackInvokedCallback`, opt-out, and the end of KEYCODE_BACK interception | P5-01 | ⚠ The defaults change with the target API. |
| [Sign your app / Play App Signing](https://developer.android.com/studio/publish/app-signing) | Upload key vs. app signing key, enrollment, upload-key reset | P10-01, P10-03 | |
| [`<application>` manifest element](https://developer.android.com/guide/topics/manifest/application-element) | The `android:appCategory` values (`game`); `isGame` is deprecated | P2-01 | Stable. |

## Flutter

| Source | Covers | Items | Re-verify |
|---|---|---|---|
| [Build and release an Android app](https://docs.flutter.dev/deployment/android) | Launcher icon, signing with `key.properties` (null-safe `storeFile`), R8 on by default, SDK defaults, versioning from `pubspec.yaml`, AAB vs. APK, obfuscation and split-debug-info | P0-06, P1-01, P1-05, P1-09, P8-02, P10-02, P10-04 | The default SDK values move with each Flutter release. Read `FlutterExtension.kt` in the SDK you build with. |
| [SystemChrome.setEnabledSystemUIMode (API)](https://api.flutter.dev/flutter/services/SystemChrome/setEnabledSystemUIMode.html) | With targetSdk 36, modes other than `edgeToEdge` "will NOT work"; there is no opt-out | P2-03 | ⚠ Confirm on a physical Android 16 device whether immersive hiding behaves as documented. |
| [Default SystemUiMode is edge-to-edge (breaking change)](https://docs.flutter.dev/release/breaking-changes/default-systemuimode-edge-to-edge) | Migration; `windowOptOutEdgeToEdgeEnforcement` can crash on Android 16 | P2-03 | ⚠ Dated. |
| [Predictive back (Flutter)](https://docs.flutter.dev/platform-integration/android/predictive-back) | Manifest flag; `PopScope` with declarative `canPop` | P5-01, P5-02 | Stable. |
| [Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility) | Semantics, TalkBack, accessibility guideline tests | P7-01, P7-02 | Stable. |
| [Accessibility: UI design and styling](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling) | Large-text support, `TextScaler` | P2-07 | Stable. |
| [Internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) | `flutter_localizations`, ARB, `gen-l10n` | P7-04, P7-05 | Stable. |

## Flame and plugins

| Source | Covers | Items | Re-verify |
|---|---|---|---|
| [Flame: Game (pause, resume, backgrounding)](https://docs.flame-engine.org/latest/flame/game.html) | `pauseWhenBackgrounded` (default true); call `super` when overriding `lifecycleStateChange` | P3-01 | Confirm against the Flame version you use. |
| [flutter_soloud CHANGELOG](https://github.com/alnitak/flutter_soloud/blob/main/CHANGELOG.md) | Example of a native-code plugin with a 16 KB fix (3.2.7) | P1-03 | Check the changelog of every native plugin you depend on. |

## How to re-verify during a run

1. Fetch every ⚠ source used in the report. Quote the current date or version and the requirement text.
2. If a requirement has changed, update the item's status and say so in the report's "Dated requirements" section.
3. If a source can't be fetched, mark the item "not verified (source unreachable)". Don't guess.
