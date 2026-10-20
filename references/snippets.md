# Snippets

Copy-ready code referenced by `checklist.md` (`Snippet S-xx`). Adapt names and colors; keep the semantics.

| ID | Item | Topic |
|---|---|---|
| S-01 | P1-10 | Dark launch/splash background (no white flash) |
| S-02 | P2-01 | Manifest: game category + predictive back |
| S-03 | P2-03 | Explicit edge-to-edge with transparent bars |
| S-04 | P2-07 | Font-size policy: clamp instead of disabling |
| S-05 | P3-01 | Flame game: lifecycle override that keeps the automatic pause |
| S-06 | P3-03 | Gameplay screen: WidgetsBindingObserver adopting the current state |
| S-07 | P4-02 | Audio focus (audioplayers) |
| S-08 | P5-02 | PopScope: pause + confirm + save before leaving a run |
| S-09 | P7-02 | Accessibility guideline tests |
| S-10 | P8-01 | Global error handlers (local logging, no network) |
| S-11 | P9-07 | GitHub Actions CI running verify |
| S-12 | P10-01 | Create the upload key |
| S-13 | P10-02 | Release signing from key.properties (tolerant when missing) |
| S-14 | P10-02 | Keep secrets out of git |

## S-01 · Dark launch/splash background (no white flash) (P1-10)

```xml
<!-- values/colors.xml -->
<color name="splash_background">#FF0A0A14</color>
<!-- drawable/launch_background.xml -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_background" />
</layer-list>
```

## S-02 · Manifest: game category + predictive back (P2-01)

Put both attributes on `<application>` in `android/app/src/main/AndroidManifest.xml`. `appCategory="game"` keeps orientation/resizability locks honored on ≥600dp screens when targeting API 36 (⚠ dated). `enableOnBackInvokedCallback="true"` opts into predictive back on API 33–35 (default on API 36).

```xml
<application
    android:label="MyGame"
    android:appCategory="game"
    android:enableOnBackInvokedCallback="true"
    ...>
```

## S-03 · Explicit edge-to-edge with transparent bars (P2-03)

With targetSdk 36, Flutter documents that modes other than `edgeToEdge` have no effect — design for insets instead of relying on `immersiveSticky` (⚠ dated).

```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  systemNavigationBarColor: Colors.transparent,
));
```

## S-04 · Font-size policy: clamp instead of disabling (P2-07)

Prefer clamping in `MaterialApp.builder`. Use `withNoTextScaling` only around a fixed HUD that genuinely cannot reflow.

```dart
MaterialApp(
  builder: (context, child) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
      ),
      child: child!,
    );
  },
);
// For the in-game HUD (only if essential): MediaQuery.withNoTextScaling(child: hud)
```

## S-05 · Flame game: lifecycle override that keeps the automatic pause (P3-01)

Flame pauses automatically when backgrounded (`pauseWhenBackgrounded = true`). If you override `lifecycleStateChange`, call `super` first.

```dart
@override
void lifecycleStateChange(AppLifecycleState state) {
  super.lifecycleStateChange(state); // keeps Flame's automatic pause
  switch (state) {
    case AppLifecycleState.paused:
    case AppLifecycleState.hidden:
    case AppLifecycleState.detached:
      audio.pauseAll();
    case AppLifecycleState.resumed:
      if (session.isPlaying) { session.pause(); overlays.add('pause'); }
    case AppLifecycleState.inactive:
      break;
  }
}
```

## S-06 · Gameplay screen: WidgetsBindingObserver adopting the current state (P3-03)

```dart
class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sync(WidgetsBinding.instance.lifecycleState); // adopt the current state
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) => _sync(s);
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }
}
```

## S-07 · Audio focus (audioplayers) (P4-02)

```dart
// audioplayers
await AudioPlayer.global.setAudioContext(AudioContext(
  android: const AudioContextAndroid(
    usageType: AndroidUsageType.game,
    contentType: AndroidContentType.music,
    audioFocus: AndroidAudioFocus.gain,
  ),
));
```

## S-08 · PopScope: pause + confirm + save before leaving a run (P5-02)

`canPop` must be known before the gesture starts (predictive back). Save the attempt before popping.

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, _) async {
    if (didPop) return;
    game.pause();
    final leave = await showExitDialog(context);
    if (leave && context.mounted) {
      await saveAttempt();
      Navigator.of(context).pop();
    }
  },
  child: GameWidget(game: game),
)
```

## S-09 · Accessibility guideline tests (P7-02)

```dart
testWidgets('a11y', (tester) async {
  final handle = tester.ensureSemantics();
  await tester.pumpWidget(const MyApp());
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
});
```

## S-10 · Global error handlers (local logging, no network) (P8-01)

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (d) { FlutterError.presentError(d); localLog(d.exceptionAsString(), d.stack); };
  PlatformDispatcher.instance.onError = (e, s) { localLog('$e', s); return true; };
  runApp(const MyApp());
}
```

## S-11 · GitHub Actions CI running verify (P9-07)

Save as `.github/workflows/ci.yml`. If the project has no `verify.sh`, replace the last step with `flutter analyze && flutter test`. Keep Pages/site deployment in a separate workflow.

```yaml
name: ci
on: [pull_request, push]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: ./verify.sh --no-apk
```

## S-12 · Create the upload key (P10-01)

Run on the owner's machine, never in a shared/agent box. Back up the keystore encrypted, outside the repo.

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload
```

## S-13 · Release signing from key.properties (tolerant when missing) (P10-02)

File: `android/app/build.gradle.kts`. `rootProject.file("key.properties")` resolves to `android/key.properties`. Never fall back to the debug signing config for release.

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }
    buildTypes {
        release { signingConfig = signingConfigs.getByName("release") }
    }
}
```

## S-14 · Keep secrets out of git (P10-02)

Add to `android/.gitignore`.

```gitignore
# android/.gitignore
key.properties
**/*.keystore
**/*.jks
```
