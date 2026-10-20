#!/usr/bin/env bash
# verify.sh - read-only automated checks for an Android game project.
# Part of the android-game-creation skill. Item IDs refer to references/checklist.md.
#
# Usage: verify.sh [PROJECT_DIR] [--artifact FILE.aab|FILE.apk] [--flutter]
#                  [--required-target N] [--strict] [--markdown] [--no-color]
#
# This script never writes to PROJECT_DIR. --flutter runs `flutter analyze` and
# `flutter test` in a temporary copy. --artifact is extracted into a temp dir.
# Exit codes: 0 = no FAIL, 1 = at least one FAIL (or WARN with --strict), 2 = usage error.

set -u

PROJECT="."
ARTIFACT=""
RUN_FLUTTER=0
STRICT=0
MARKDOWN=0
COLOR=1
REQ_TARGET="${REQUIRED_TARGET_SDK:-36}"   # dated: re-verify against Play's target API page

usage() { sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --artifact) [ $# -ge 2 ] || { usage; exit 2; }; ARTIFACT="$2"; shift 2 ;;
    --flutter) RUN_FLUTTER=1; shift ;;
    --required-target) [ $# -ge 2 ] || { usage; exit 2; }; REQ_TARGET="$2"; shift 2 ;;
    --strict) STRICT=1; shift ;;
    --markdown) MARKDOWN=1; COLOR=0; shift ;;
    --no-color) COLOR=0; shift ;;
    -*) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *) PROJECT="$1"; shift ;;
  esac
done
[ -t 1 ] || COLOR=0

[ -d "$PROJECT" ] || { echo "Not a directory: $PROJECT" >&2; exit 2; }
PROJECT="$(cd "$PROJECT" && pwd)"
if [ -n "$ARTIFACT" ]; then
  [ -f "$ARTIFACT" ] || { echo "Artifact not found: $ARTIFACT" >&2; exit 2; }
  ARTIFACT="$(cd "$(dirname "$ARTIFACT")" && pwd)/$(basename "$ARTIFACT")"
fi

TMPROOT="$(mktemp -d 2>/dev/null || mktemp -d -t agcverify)"
trap 'rm -rf "$TMPROOT"' EXIT INT TERM

# ---------- result collection ----------
N=0; NPASS=0; NWARN=0; NFAIL=0; NINFO=0; NSKIP=0
R_ID=(); R_ST=(); R_TI=(); R_DE=()
rec() { # id status title detail
  R_ID[$N]="$1"; R_ST[$N]="$2"; R_TI[$N]="$3"; R_DE[$N]="${4:-}"; N=$((N+1))
  case "$2" in PASS) NPASS=$((NPASS+1));; WARN) NWARN=$((NWARN+1));; FAIL) NFAIL=$((NFAIL+1));; INFO) NINFO=$((NINFO+1));; SKIP) NSKIP=$((NSKIP+1));; esac
}

# ---------- helpers ----------
have() { command -v "$1" >/dev/null 2>&1; }
P() { printf '%s/%s' "$PROJECT" "$1"; }
grep_lib() { # pattern -> matching lines (file:line:text) in lib/**/*.dart
  [ -d "$PROJECT/lib" ] || return 1
  grep -rEn --include='*.dart' "$1" "$PROJECT/lib" 2>/dev/null
}
count_lib() { grep_lib "$1" | wc -l | tr -d ' '; }
rel() { sed "s#^$PROJECT/##"; }
md5of() {
  if have md5sum; then md5sum "$1" | awk '{print $1}'
  elif have md5; then md5 -q "$1"
  else echo "?"; fi
}
strip_comments() { # drop // line comments and XML comments (best effort, single line)
  sed -e 's#[[:space:]]//.*$##' -e 's#^//.*$##' -e 's#<!--.*-->##g' "$1"
}

# ---------- locate project files ----------
GRADLE=""
for f in android/app/build.gradle.kts android/app/build.gradle; do [ -f "$(P "$f")" ] && { GRADLE="$(P "$f")"; break; }; done
MANIFEST="$(P android/app/src/main/AndroidManifest.xml)"
PUBSPEC="$(P pubspec.yaml)"
RES="$(P android/app/src/main/res)"

if [ -z "$GRADLE" ] || [ ! -f "$MANIFEST" ]; then
  echo "No Android app module found (android/app/build.gradle[.kts] + src/main/AndroidManifest.xml) in $PROJECT" >&2
  exit 2
fi
IS_FLUTTER=0; IS_FLAME=0
if [ -f "$PUBSPEC" ]; then
  grep -Eq '^[[:space:]]+sdk:[[:space:]]*flutter' "$PUBSPEC" && IS_FLUTTER=1
  grep -Eq '^[[:space:]]+flame:' "$PUBSPEC" && IS_FLAME=1
fi
GRADLE_NC="$TMPROOT/gradle.nc"; strip_comments "$GRADLE" > "$GRADLE_NC"
MANIFEST_NC="$TMPROOT/manifest.nc"; strip_comments "$MANIFEST" > "$MANIFEST_NC"

# ---------- Flutter SDK (for resolving flutter.* defaults) ----------
FLUTTER_ROOT_DIR=""
if [ -n "${FLUTTER_ROOT:-}" ] && [ -d "$FLUTTER_ROOT" ]; then FLUTTER_ROOT_DIR="$FLUTTER_ROOT"
elif have flutter; then
  fb="$(command -v flutter)"
  if have readlink && readlink -f "$fb" >/dev/null 2>&1; then fb="$(readlink -f "$fb")"; fi
  FLUTTER_ROOT_DIR="$(cd "$(dirname "$fb")/.." 2>/dev/null && pwd)"
elif [ -x "$HOME/flutter/bin/flutter" ]; then FLUTTER_ROOT_DIR="$HOME/flutter"
fi
FLUTTER_BIN=""; [ -n "$FLUTTER_ROOT_DIR" ] && [ -x "$FLUTTER_ROOT_DIR/bin/flutter" ] && FLUTTER_BIN="$FLUTTER_ROOT_DIR/bin/flutter"
FLUTTER_VER="unknown"
if [ -n "$FLUTTER_ROOT_DIR" ]; then
  if [ -f "$FLUTTER_ROOT_DIR/bin/cache/flutter.version.json" ]; then
    FLUTTER_VER="$(grep -Eo '"frameworkVersion"[^,]*' "$FLUTTER_ROOT_DIR/bin/cache/flutter.version.json" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  elif [ -f "$FLUTTER_ROOT_DIR/version" ]; then FLUTTER_VER="$(head -1 "$FLUTTER_ROOT_DIR/version")"; fi
  [ -n "$FLUTTER_VER" ] || FLUTTER_VER="unknown"
fi
flutter_default() { # key (targetSdkVersion|minSdkVersion|compileSdkVersion|ndkVersion)
  [ -n "$FLUTTER_ROOT_DIR" ] || return 1
  local f
  for f in "$FLUTTER_ROOT_DIR/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt" \
           "$FLUTTER_ROOT_DIR/packages/flutter_tools/gradle/src/main/groovy/flutter.groovy"; do
    [ -f "$f" ] || continue
    grep -E "(val|static (final )?(int|String|def)) +$1\b[^=]*=" "$f" | head -1 | sed -E 's/.*= *"?([^"]+)"?.*/\1/' | tr -d ' ;'
    return 0
  done
  return 1
}
gradle_val() { # key -> raw expression (first match)
  grep -E "^[[:space:]]*$1[[:space:]]*(=|[[:space:]])" "$GRADLE_NC" | head -1 | sed -E "s/^[[:space:]]*$1[[:space:]]*=?[[:space:]]*//; s/[[:space:]]*$//"
}
resolve_sdk() { # expr defaultKey -> number or empty
  case "$1" in
    ''|*[!0-9]*)
      case "$1" in flutter.*) flutter_default "$2" ;; *) echo "" ;; esac ;;
    *) echo "$1" ;;
  esac
}

# ======================= CHECKS =======================

# P0-01 docs / spec
docs_found="$(cd "$PROJECT" && ls docs/*spec*.md docs/*plan*.md docs/*intent*.md docs/*decision*.md 2>/dev/null | tr '\n' ' ')"
if [ -n "$docs_found" ]; then rec P0-01 PASS "Spec/plan docs present" "$docs_found"
else rec P0-01 INFO "Spec/plan docs" "no docs/*spec|plan|intent|decision*.md found"; fi

# P0-04 verification harness
harness="$(cd "$PROJECT" && ls verify.sh scripts/verify.sh tool/verify.sh Makefile 2>/dev/null | tr '\n' ' ')"
if [ -n "$harness" ]; then rec P0-04 PASS "Single verification harness" "$harness"
else rec P0-04 INFO "Single verification harness" "no verify.sh/Makefile at repo root"; fi

# P0-06 applicationId
APPID="$(gradle_val applicationId | tr -d '"'"'")"
NS="$(gradle_val namespace | tr -d '"'"'")"
if [ -z "$APPID" ]; then rec P0-06 WARN "applicationId" "not found in $(basename "$GRADLE")"
else
  case "$APPID" in
    com.example.*) rec P0-06 FAIL "applicationId" "$APPID (template placeholder; cannot be changed after first Play upload)" ;;
    *) d="$APPID"; [ -n "$NS" ] && [ "$NS" != "$APPID" ] && d="$d (namespace differs: $NS)"
       rec P0-06 PASS "applicationId set (confirm it is final before first upload)" "$d" ;;
  esac
fi

# P1-01 / P1-02 SDK levels
T_EXPR="$(gradle_val targetSdk)"; [ -n "$T_EXPR" ] || T_EXPR="$(gradle_val targetSdkVersion)"
M_EXPR="$(gradle_val minSdk)"; [ -n "$M_EXPR" ] || M_EXPR="$(gradle_val minSdkVersion)"
C_EXPR="$(gradle_val compileSdk)"; [ -n "$C_EXPR" ] || C_EXPR="$(gradle_val compileSdkVersion)"
TGT="$(resolve_sdk "$T_EXPR" targetSdkVersion)"
MIN="$(resolve_sdk "$M_EXPR" minSdkVersion)"
CMP="$(resolve_sdk "$C_EXPR" compileSdkVersion)"
src_note="local Flutter $FLUTTER_VER"; [ -n "$FLUTTER_ROOT_DIR" ] || src_note="no local Flutter SDK"
case "$T_EXPR" in
  flutter.*) rec P1-01 PASS "SDK levels follow Flutter defaults" "target=$T_EXPR→${TGT:-?} min=$M_EXPR→${MIN:-?} compile=$C_EXPR→${CMP:-?} ($src_note; the SDK you release with decides)" ;;
  '') rec P1-01 WARN "SDK levels" "targetSdk not found in $(basename "$GRADLE")" ;;
  *) rec P1-01 WARN "SDK levels pinned (review every year)" "target=$T_EXPR min=$M_EXPR compile=$C_EXPR" ;;
esac
if [ -z "$TGT" ]; then
  rec P1-02 WARN "targetSdk vs Play requirement (API $REQ_TARGET)" "cannot resolve '$T_EXPR'; check merged manifest or Play Console"
elif [ "$TGT" -lt "$REQ_TARGET" ] 2>/dev/null; then
  rec P1-02 FAIL "targetSdk vs Play requirement (API $REQ_TARGET)" "targetSdk=$TGT < $REQ_TARGET: Play rejects new apps/updates (dated, re-verify)"
else
  d="targetSdk=$TGT ≥ $REQ_TARGET (dated, re-verify)"
  if [ -n "$CMP" ] && [ "$CMP" -lt "$TGT" ] 2>/dev/null; then rec P1-02 WARN "targetSdk vs Play requirement (API $REQ_TARGET)" "$d; compileSdk=$CMP < targetSdk"
  else rec P1-02 PASS "targetSdk vs Play requirement (API $REQ_TARGET)" "$d"; fi
fi

# P1-03 16 KB page size (artifact) / toolchain hint
elf_align() { # file -> min LOAD p_align (decimal) or empty
  if have readelf; then
    readelf -lW "$1" 2>/dev/null | awk '$1=="LOAD"{print $NF}' | while read -r a; do printf '%d\n' "$a"; done | sort -n | head -1
  elif have llvm-readelf; then
    llvm-readelf -lW "$1" 2>/dev/null | awk '$1=="LOAD"{print $NF}' | while read -r a; do printf '%d\n' "$a"; done | sort -n | head -1
  elif have python3; then
    python3 - "$1" <<'PY'
import struct,sys
d=open(sys.argv[1],'rb').read()
if d[:4]!=b'\x7fELF' or d[4]!=2: sys.exit(0)
e='<' if d[5]==1 else '>'
phoff=struct.unpack(e+'Q',d[0x20:0x28])[0]; phes,phn=struct.unpack(e+'HH',d[0x36:0x3a])
al=[struct.unpack(e+'Q',d[phoff+i*phes+0x30:phoff+i*phes+0x38])[0] for i in range(phn) if struct.unpack(e+'I',d[phoff+i*phes:phoff+i*phes+4])[0]==1]
print(min(al) if al else '')
PY
  fi
}
if [ -n "$ARTIFACT" ]; then
  X="$TMPROOT/artifact"; mkdir -p "$X"
  if have unzip; then unzip -qq -o "$ARTIFACT" 'lib/*' 'base/lib/*' -d "$X" >/dev/null 2>&1
  elif have python3; then python3 -c "import zipfile,sys;z=zipfile.ZipFile(sys.argv[1]);[z.extract(n,sys.argv[2]) for n in z.namelist() if '/lib/' in '/'+n and n.endswith('.so')]" "$ARTIFACT" "$X"
  fi
  bad=""; ok=0; total=0
  while IFS= read -r -d '' so; do
    total=$((total+1)); a="$(elf_align "$so")"
    if [ -z "$a" ]; then bad="$bad $(basename "$so")(?)"
    elif [ "$a" -lt 16384 ]; then bad="$bad $(echo "$so" | sed "s#$X/##")($a)"
    else ok=$((ok+1)); fi
  done < <(find "$X" \( -path '*arm64-v8a*' -o -path '*x86_64*' \) -name '*.so' -print0 2>/dev/null)
  if [ "$total" -eq 0 ]; then rec P1-03 PASS "16 KB page size (artifact)" "no 64-bit native libraries in $(basename "$ARTIFACT")"
  elif [ -z "$bad" ]; then rec P1-03 PASS "16 KB page size (artifact)" "$ok/$total 64-bit .so with LOAD alignment ≥ 16 KB (dated, re-verify)"
  else rec P1-03 FAIL "16 KB page size (artifact)" "misaligned:$bad"; fi
  case "$ARTIFACT" in *.apk)
    if have zipalign; then
      if zipalign -c -P 16 4 "$ARTIFACT" >/dev/null 2>&1; then rec P10-05 PASS "APK zip alignment (16 KB)" "zipalign -c -P 16 ok"
      else rec P10-05 WARN "APK zip alignment (16 KB)" "zipalign -c -P 16 failed (uncompressed .so must be 16 KB-aligned)"; fi
    fi ;;
  esac
else
  ndk="$(gradle_val ndkVersion)"; nres="$ndk"
  case "$ndk" in flutter.*) nres="$(flutter_default ndkVersion)";; esac
  rec P1-03 SKIP "16 KB page size" "no --artifact given; ndkVersion=${ndk:-default}→${nres:-?} (NDK ≥ r28 aligns by default). Build an AAB and rerun with --artifact"
fi

# P1-04 versioning
if [ -f "$PUBSPEC" ]; then
  PV="$(grep -E '^version:' "$PUBSPEC" | head -1 | sed -E 's/^version:[[:space:]]*//; s/[[:space:]#].*$//')"
  VNAME="${PV%%+*}"; VCODE=""; case "$PV" in *+*) VCODE="${PV##*+}";; esac
  vc_expr="$(gradle_val versionCode)"; vn_expr="$(gradle_val versionName)"
  issues=""
  [ -n "$PV" ] || issues="$issues no 'version:' in pubspec;"
  [ -n "$VCODE" ] || issues="$issues no +build number (versionCode);"
  case "$vc_expr" in flutter.*|'') ;; *) issues="$issues versionCode hard-coded in gradle ($vc_expr);";; esac
  case "$vn_expr" in flutter.*|'') ;; *) issues="$issues versionName hard-coded in gradle ($vn_expr);";; esac
  docver=""
  for doc in README.md docs/*.md; do
    [ -f "$PROJECT/$doc" ] || continue
    vv="$(grep -Ei '(version|versión|pubspec)' "$PROJECT/$doc" | grep -Eiv 'flutter|dart|flame|sdk|gradle|kotlin|agp|ndk|java|node|python|api level|minsdk|targetsdk' \
          | grep -Eo '\b[0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?\b' | sed 's/+.*//' | sort -u)"
    for v in $vv; do [ "$v" != "$VNAME" ] && docver="$docver $doc:$v"; done
  done
  docver="$(echo "$docver" | tr ' ' '\n' | sort -u | head -6 | tr '\n' ' ')"
  if [ -n "$issues" ]; then rec P1-04 WARN "Versioning from pubspec" "pubspec=$PV;$issues"
  elif [ -n "$(echo "$docver" | tr -d ' ')" ]; then rec P1-04 WARN "Version consistency (pubspec vs docs)" "pubspec=$PV; other versions mentioned:$docver(bump versionCode for every upload)"
  else rec P1-04 PASS "Versioning from pubspec" "pubspec=$PV → versionName=$VNAME versionCode=$VCODE"; fi
else
  vc="$(gradle_val versionCode)"; vn="$(gradle_val versionName)"
  rec P1-04 INFO "Versioning" "versionName=$vn versionCode=$vc (non-Flutter project)"
fi

# P1-06 permissions
PERMS="$(grep -Eo 'uses-permission[^>]*android:name="[^"]+"' "$MANIFEST_NC" | sed -E 's/.*android:name="([^"]+)"/\1/' | sed 's/android.permission.//' | tr '\n' ' ')"
if [ -z "$(echo "$PERMS" | tr -d ' ')" ]; then rec P1-06 PASS "Minimal permissions" "no <uses-permission> in main manifest"
else
  pw=""
  case " $PERMS " in *" WAKE_LOCK "*)
    if ! grep -qiE 'wakelock' "$PUBSPEC" 2>/dev/null && ! grep -rqE 'KEEP_SCREEN_ON|keepScreenOn|WakeLock|wakelock' "$PROJECT/lib" "$PROJECT/android/app/src" --include='*.dart' --include='*.kt' --include='*.java' 2>/dev/null; then
      pw="$pw WAKE_LOCK declared but no wakelock usage found;"; fi ;; esac
  case " $PERMS " in *" INTERNET "*) pw="$pw INTERNET declared: privacy policy and Data safety must cover network use;";; esac
  if [ -n "$pw" ]; then rec P1-06 WARN "Minimal permissions" "declared: $PERMS|$pw"
  else rec P1-06 PASS "Minimal permissions" "declared: $PERMS"; fi
fi

# P1-07 unused dependencies
if [ -f "$PUBSPEC" ] && [ -d "$PROJECT/lib" ]; then
  DEPS="$(awk '/^dependencies:/{f=1;next} /^[^[:space:]#]/{f=0} f && /^  [a-zA-Z0-9_]+:/{sub(/^  /,""); sub(/:.*/,""); print}' "$PUBSPEC")"
  unused=""
  for d in $DEPS; do
    case "$d" in flutter|flutter_localizations|cupertino_icons|flutter_web_plugins|intl) continue;; esac
    grep -rqE "package:$d/" "$PROJECT/lib" --include='*.dart' 2>/dev/null || unused="$unused $d"
  done
  if [ -n "$unused" ]; then rec P1-07 WARN "Unused dependencies" "not imported in lib/:$unused (may be transitive/platform-only; confirm before removing)"
  else rec P1-07 PASS "Unused dependencies" "every direct dependency is imported in lib/"; fi
fi

# P1-08 declared assets exist
if [ -f "$PUBSPEC" ]; then
  ASSETS="$(awk '
    /^[[:space:]]*#/{next}
    /^flutter:/{fl=1;next} /^[^[:space:]#]/{fl=0}
    fl && /^  (assets|shaders):/{m=1;next}
    fl && m && /^    - /{x=$0; sub(/^    - */,"",x); sub(/[[:space:]]*#.*/,"",x); gsub(/["'"'"']/,"",x); print x; next}
    fl && /^  [a-z]/{m=0}
    fl && /asset:[[:space:]]/{x=$0; sub(/.*asset:[[:space:]]*/,"",x); gsub(/["'"'"']/,"",x); print x}
  ' "$PUBSPEC")"
  missing=""; cnt=0
  for a in $ASSETS; do cnt=$((cnt+1)); [ -e "$PROJECT/$a" ] || missing="$missing $a"; done
  if [ -n "$missing" ]; then rec P1-08 FAIL "Declared assets exist" "missing:$missing"
  else rec P1-08 PASS "Declared assets exist" "$cnt entries checked"; fi
fi

# P1-09 launcher icon
# md5 of the Flutter template ic_launcher.png (mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi), fallback when no SDK is present
TPL_MD5=" 6270344430679711b81476e29878caa7 13e9c72ec37fac220397aa819fa1ef2d a0a8db5985280b3679d99a820ae2db79 afe1b655b9f32da22f9a4301bb8e6ba8 57838d52c318faff743130c3fcfae0c6 "
if [ -n "$FLUTTER_ROOT_DIR" ]; then
  while IFS= read -r -d '' t; do TPL_MD5="$TPL_MD5$(md5of "$t") "; done < <(find "$FLUTTER_ROOT_DIR/packages/flutter_tools/templates" -path '*mipmap-*' -name 'ic_launcher.png' -print0 2>/dev/null)
fi
icons="$(find "$RES" -path '*mipmap-*' -name 'ic_launcher.png' 2>/dev/null)"
if [ -z "$icons" ]; then rec P1-09 WARN "Custom launcher icon" "no mipmap-*/ic_launcher.png"
else
  def=""; for i in $icons; do case "$TPL_MD5" in *" $(md5of "$i") "*) def="$def $(basename "$(dirname "$i")")";; esac; done
  if [ -n "$def" ]; then rec P1-09 FAIL "Custom launcher icon" "default Flutter template icon in:$def"
  else rec P1-09 PASS "Custom launcher icon" "$(echo "$icons" | wc -l | tr -d ' ') densities, none is the template icon"; fi
fi
ADAPT="$(ls "$RES"/mipmap-anydpi*/ic_launcher.xml 2>/dev/null | head -1)"
if [ -z "$ADAPT" ]; then rec P1-09 WARN "Adaptive icon" "no mipmap-anydpi-v26/ic_launcher.xml"
elif grep -q '<monochrome' "$ADAPT"; then rec P1-09 PASS "Adaptive icon + monochrome" "$(echo "$ADAPT" | rel)"
else rec P1-09 INFO "Adaptive icon (no monochrome layer)" "$(echo "$ADAPT" | rel): add <monochrome> for themed icons"; fi

# P1-10 launch theme / splash
ST="$RES/values/styles.xml"
if [ -f "$ST" ]; then
  lparent="$(grep -E 'name="LaunchTheme"' "$ST" | grep -Eo 'parent="[^"]+"' | head -1)"
  lb="$(cat "$RES"/drawable*/launch_background.xml 2>/dev/null | sed 's#<!--.*-->##g' | tr '\n' ' ' | sed 's#<!--[^>]*-->##g')"
  if echo "$lparent" | grep -q 'Light' && echo "$lb" | grep -q '?android:colorBackground'; then
    rec P1-10 WARN "Launch/splash background" "LaunchTheme $lparent with default background: white flash before first frame if the game is dark"
  else rec P1-10 PASS "Launch/splash background" "LaunchTheme $lparent; launch_background customized or dark"; fi
fi

# P2-01 appCategory=game
if grep -q 'android:appCategory="game"' "$MANIFEST_NC"; then rec P2-01 PASS 'android:appCategory="game"' "declared"
elif [ -z "$TGT" ] || [ "$TGT" -ge 36 ] 2>/dev/null; then rec P2-01 FAIL 'android:appCategory="game"' "missing: with targetSdk ≥ 36 orientation/resizability locks are ignored on ≥600dp screens (dated)"
else rec P2-01 WARN 'android:appCategory="game"' "missing (becomes critical when targeting API 36)"; fi

# P2-02 orientation locked in two places
mo="$(grep -Eo 'android:screenOrientation="[^"]+"' "$MANIFEST_NC" | head -1 | sed 's/.*="//; s/"//')"
do_="$(count_lib 'setPreferredOrientations')"
if [ -n "$mo" ] && [ "$do_" -gt 0 ]; then rec P2-02 PASS "Orientation locked (manifest + SystemChrome)" "manifest=$mo"
elif [ -n "$mo" ] || [ "$do_" -gt 0 ]; then rec P2-02 WARN "Orientation locked in only one place" "manifest=${mo:-none}; setPreferredOrientations calls=$do_"
else rec P2-02 INFO "Orientation" "not locked (fine only if every screen supports rotation)"; fi

# P2-03 edge-to-edge
optout="$(grep -rl 'windowOptOutEdgeToEdgeEnforcement' "$RES" 2>/dev/null | rel | tr '\n' ' ')"
imm="$(grep_lib 'SystemUiMode\.(immersiveSticky|immersive|leanBack)' | rel | cut -d: -f1,2 | tr '\n' ' ')"
e2e="$(count_lib 'SystemUiMode\.edgeToEdge')"
if [ -n "$optout" ] && { [ -z "$TGT" ] || [ "$TGT" -ge 36 ] 2>/dev/null; }; then rec P2-03 FAIL "Edge-to-edge" "windowOptOutEdgeToEdgeEnforcement in $optout (ignored/may crash on Android 16)"
elif [ -n "$imm" ]; then rec P2-03 WARN "Edge-to-edge" "immersive mode requested at $imm; Flutter docs: no effect at targetSdk 36. Verify on Android 16 and handle insets"
elif [ "$e2e" -gt 0 ]; then rec P2-03 PASS "Edge-to-edge" "SystemUiMode.edgeToEdge set explicitly"
else rec P2-03 INFO "Edge-to-edge" "system default (edge-to-edge at target ≥35); verify insets"; fi

# P2-04 insets
ins="$(count_lib 'SafeArea|MediaQuery\.(paddingOf|viewPaddingOf|of\([^)]*\)\.(padding|viewPadding))|systemGestureInsets')"
if [ "$ins" -gt 0 ]; then rec P2-04 PASS "Insets handled (SafeArea/MediaQuery padding)" "$ins occurrences"
else rec P2-04 WARN "Insets handled" "no SafeArea or MediaQuery padding usage in lib/"; fi

# P2-07 text scaling policy
noscale="$(grep_lib 'withNoTextScaling|TextScaler\.noScaling|textScaleFactor:[[:space:]]*1(\.0)?[^0-9.]' | rel | cut -d: -f1,2 | tr '\n' ' ')"
clamp="$(count_lib 'textScaler[^;]*\.clamp\(|\.clamp\([^)]*maxScaleFactor')"
if [ -n "$noscale" ]; then rec P2-07 WARN "Font-size policy" "system text scaling disabled at $noscale; prefer TextScaler.clamp (accessibility)"
elif [ "$clamp" -gt 0 ]; then rec P2-07 PASS "Font-size policy" "TextScaler clamped"
else rec P2-07 INFO "Font-size policy" "follows system font size unchecked; test at 1.3 and 2.0"; fi

# P3-01 game loop pause on background
lcs="$(grep_lib 'void[[:space:]]+lifecycleStateChange\(' | cut -d: -f1 | sort -u)"
if [ -n "$lcs" ]; then
  nosuper=""; for f in $lcs; do grep -q 'super\.lifecycleStateChange' "$f" || nosuper="$nosuper $(echo "$f" | rel)"; done
  if [ -n "$nosuper" ]; then rec P3-01 FAIL "Game loop pauses in background" "lifecycleStateChange overridden without super call in:$nosuper"
  else rec P3-01 PASS "Game loop pauses in background" "lifecycleStateChange overridden and calls super"; fi
elif [ "$(count_lib 'pauseWhenBackgrounded[[:space:]]*=[[:space:]]*false')" -gt 0 ]; then
  rec P3-01 WARN "Game loop pauses in background" "pauseWhenBackgrounded = false: make sure the game pauses itself"
elif [ "$IS_FLAME" -eq 1 ]; then rec P3-01 PASS "Game loop pauses in background" "Flame default (pauseWhenBackgrounded = true)"
elif [ "$(count_lib 'WidgetsBindingObserver')" -gt 0 ]; then rec P3-01 PASS "Game loop pauses in background" "WidgetsBindingObserver present (verify manually)"
else rec P3-01 WARN "Game loop pauses in background" "no lifecycle handling found"; fi

# P3-03 lifecycle observer for audio/timers
AUDIO_DEP=0; [ -f "$PUBSPEC" ] && grep -Eq '^[[:space:]]+(flame_audio|audioplayers|flutter_soloud|just_audio|soundpool|video_player):' "$PUBSPEC" && AUDIO_DEP=1
obs="$(count_lib 'WidgetsBindingObserver|AppLifecycleListener|lifecycleStateChange')"
if [ "$AUDIO_DEP" -eq 1 ] && [ "$obs" -eq 0 ]; then rec P3-03 WARN "Lifecycle observer for audio/timers" "audio/video dependency but no WidgetsBindingObserver/AppLifecycleListener/lifecycleStateChange"
elif [ "$obs" -gt 0 ]; then rec P3-03 PASS "Lifecycle observer for audio/timers" "$obs occurrences"
else rec P3-03 INFO "Lifecycle observer" "none (no audio dependency detected)"; fi

# P3-07 backup rules
if grep -Eq 'android:(dataExtractionRules|fullBackupContent)=' "$MANIFEST_NC"; then rec P3-07 PASS "Auto Backup rules declared" ""
else rec P3-07 WARN "Auto Backup rules" "no dataExtractionRules/fullBackupContent (defaults apply; declare and test restore)"; fi

# P5-01 predictive back
if grep -q 'android:enableOnBackInvokedCallback="true"' "$MANIFEST_NC"; then rec P5-01 PASS "Predictive back opt-in" "enableOnBackInvokedCallback=true"
elif grep -q 'android:enableOnBackInvokedCallback="false"' "$MANIFEST_NC"; then rec P5-01 WARN "Predictive back" "explicitly opted out (temporary measure)"
else rec P5-01 WARN "Predictive back opt-in" 'android:enableOnBackInvokedCallback="true" missing'; fi

# P5-02 PopScope on the gameplay screen
gfiles="$(grep_lib 'GameWidget' | cut -d: -f1 | sort -u)"
if [ -n "$gfiles" ]; then
  unprot=""; for f in $gfiles; do grep -q 'PopScope' "$f" || unprot="$unprot $(echo "$f" | rel)"; done
  if [ -z "$unprot" ]; then rec P5-02 PASS "Gameplay screen protected by PopScope" ""
  else rec P5-02 WARN "Gameplay screen protected by PopScope" "no PopScope in:$unprot (back gesture may drop the run)"; fi
else rec P5-02 INFO "Gameplay back handling" "no GameWidget found; check manually"; fi

# P7-01 semantics
sem="$(count_lib 'Semantics\(|semanticsLabel|semanticLabel')"
if [ "$sem" -gt 0 ]; then rec P7-01 PASS "Semantics labels" "$sem occurrences"
else rec P7-01 WARN "Semantics labels" "no Semantics/semanticsLabel in lib/ (TalkBack)"; fi

# P7-04 externalized strings
lit="$(grep_lib "Text\([[:space:]]*['\"][A-Za-z]" | grep -Eiv '/(l10n|i18n|strings?|app_strings)[^/]*\.dart:' | wc -l | tr -d ' ')"
l10n=0; { [ -f "$PROJECT/l10n.yaml" ] || grep -q 'flutter_localizations' "$PUBSPEC" 2>/dev/null || ls "$PROJECT"/lib/**/*strings*.dart "$PROJECT"/lib/*/*strings*.dart >/dev/null 2>&1; } && l10n=1
if [ "$lit" -le 5 ] && [ "$l10n" -eq 1 ]; then rec P7-04 PASS "Strings externalized" "strings layer found; $lit inline Text literals"
elif [ "$lit" -le 5 ]; then rec P7-04 INFO "Strings externalized" "$lit inline Text literals; no l10n setup"
else rec P7-04 WARN "Strings externalized" "$lit inline Text('...') literals in lib/"; fi

# P8-01 global error handlers
fe="$(count_lib 'FlutterError\.onError')"; pe="$(count_lib 'PlatformDispatcher\.instance\.onError|runZonedGuarded')"
if [ "$fe" -gt 0 ] && [ "$pe" -gt 0 ]; then rec P8-01 PASS "Global error handlers" ""
else rec P8-01 WARN "Global error handlers" "FlutterError.onError=$fe, PlatformDispatcher.onError/runZonedGuarded=$pe"; fi

# P8-04 print in production code
pr="$(grep_lib '(^|[^A-Za-z0-9_.])print\(' | grep -v 'debugPrint' | wc -l | tr -d ' ')"
if [ "$pr" -gt 0 ]; then rec P8-04 WARN "No print() in production code" "$pr print( calls in lib/"
else rec P8-04 PASS "No print() in production code" ""; fi

# P9-01 analysis_options / flutter analyze
if [ -f "$PROJECT/analysis_options.yaml" ]; then
  if grep -Eq 'include:.*(flutter_lints|lints|very_good|lint)' "$PROJECT/analysis_options.yaml"; then rec P9-01 PASS "Lint config" "analysis_options.yaml with lint set"
  else rec P9-01 WARN "Lint config" "analysis_options.yaml without include of a lint set"; fi
else rec P9-01 WARN "Lint config" "no analysis_options.yaml"; fi

# P9-02 tests present
nt="$( [ -d "$PROJECT/test" ] && find "$PROJECT/test" -name '*_test.dart' | wc -l | tr -d ' ' || echo 0)"
if [ "$nt" -gt 0 ]; then rec P9-02 PASS "Automated tests present" "$nt *_test.dart files"
else rec P9-02 WARN "Automated tests present" "no test/*_test.dart"; fi

# --flutter: analyze + test in a temporary copy (never in PROJECT)
if [ "$RUN_FLUTTER" -eq 1 ]; then
  if [ -z "$FLUTTER_BIN" ] || [ "$IS_FLUTTER" -eq 0 ]; then rec P9-01 SKIP "flutter analyze/test" "Flutter SDK or Flutter project not found"
  else
    W="$TMPROOT/work"; mkdir -p "$W"
    (cd "$PROJECT" && tar --exclude='./build' --exclude='./.dart_tool' --exclude='./node_modules' --exclude='*/build' -cf - .) | (cd "$W" && tar -xf -)
    if (cd "$W" && "$FLUTTER_BIN" pub get >"$TMPROOT/pub.log" 2>&1); then
      if (cd "$W" && "$FLUTTER_BIN" analyze --no-pub >"$TMPROOT/analyze.log" 2>&1); then rec P9-01 PASS "flutter analyze (temp copy)" "no issues"
      else rec P9-01 FAIL "flutter analyze (temp copy)" "$(grep -Eo '[0-9]+ issues? found' "$TMPROOT/analyze.log" | head -1)"; fi
      if [ "$nt" -gt 0 ]; then
        if (cd "$W" && "$FLUTTER_BIN" test --no-pub >"$TMPROOT/test.log" 2>&1); then rec P9-02 PASS "flutter test (temp copy)" "$(grep -Eo '\+[0-9]+.*All tests passed!' "$TMPROOT/test.log" | tail -1 | grep -Eo '^\+[0-9]+') passed"
        else rec P9-02 FAIL "flutter test (temp copy)" "$(grep -Eo '\+[0-9]+ -[0-9]+' "$TMPROOT/test.log" | tail -1) (pass/fail)"; fi
      fi
    else rec P9-01 FAIL "flutter pub get (temp copy)" "$(tail -2 "$TMPROOT/pub.log" | tr '\n' ' ')"; fi
  fi
fi

# P9-07 CI runs analyze/test
WF="$(ls "$PROJECT"/.github/workflows/*.y*ml 2>/dev/null)"
if [ -z "$WF" ]; then rec P9-07 WARN "CI runs analyze/test" "no .github/workflows"
elif grep -Eqs 'flutter (analyze|test)|verify\.sh|dart (analyze|test)|gradlew.*(test|lint)' $WF; then rec P9-07 PASS "CI runs analyze/test" "$(echo "$WF" | rel | tr '\n' ' ')"
else rec P9-07 WARN "CI runs analyze/test" "workflows exist but none runs analyze/test: $(echo "$WF" | rel | tr '\n' ' ')"; fi

# P10-01 secrets not committed / ignored
if git -C "$PROJECT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tracked="$(git -C "$PROJECT" ls-files | grep -E '(^|/)key\.properties$|\.jks$|\.keystore$|\.p12$' | tr '\n' ' ')"
  if [ -n "$tracked" ]; then rec P10-01 FAIL "No keystore/key.properties in git" "tracked: $tracked"
  else rec P10-01 PASS "No keystore/key.properties in git" "none tracked"; fi
  notign=""
  for p in android/key.properties android/app/key.properties android/app/upload-keystore.jks; do
    git -C "$PROJECT" check-ignore -q "$p" 2>/dev/null || notign="$notign $p"
  done
  if [ -n "$notign" ]; then rec P10-01 WARN "Secrets ignored by .gitignore" "not ignored:$notign"
  else rec P10-01 PASS "Secrets ignored by .gitignore" "key.properties and *.jks ignored"; fi
else
  found="$(find "$PROJECT" -name 'key.properties' -o -name '*.jks' -o -name '*.keystore' 2>/dev/null | rel | tr '\n' ' ')"
  if [ -n "$found" ]; then rec P10-01 WARN "Secrets in tree (not a git repo)" "$found"
  else rec P10-01 INFO "Secrets" "not a git repo; no keystore files found"; fi
fi

# P10-02 release signing config
REL_DEBUG="$(awk '/release[[:space:]]*\{|getByName\("release"\)[[:space:]]*\{/{r=1} r&&/signingConfig/{print; r=0}' "$GRADLE_NC" | grep -E 'debug' )"
if grep -Eq 'signingConfig[[:space:]]*=?[[:space:]]*signingConfigs\.(getByName\("debug"\)|debug)' "$GRADLE_NC" && [ -n "$REL_DEBUG" ]; then
  rec P10-02 FAIL "Release not signed with debug key" "release buildType uses the debug signingConfig"
elif grep -Eq 'signingConfigs\.(getByName\("release"\)|release)' "$GRADLE_NC"; then
  if grep -Eq 'keystoreProperties\[[^]]+\]\.toString\(\)|\.toString\(\)' "$GRADLE_NC" && grep -q 'keystoreProperties' "$GRADLE_NC"; then
    rec P10-02 WARN "Release signing config" "uses key.properties but .toString() turns a missing value into \"null\" (builds without the key fail; use getProperty(...)?.let { file(it) })"
  else rec P10-02 PASS "Release signing config" "release signingConfig from key.properties"; fi
else rec P10-02 WARN "Release signing config" "no release signingConfig found"; fi

# P11-01 privacy policy
pp="$(find "$PROJECT" \( -path '*/node_modules' -o -path '*/build' -o -path '*/.git' \) -prune -o -type f \( -iname '*privacy*.html' -o -iname '*privacy*.md' -o -iname 'privacidad*' \) -print 2>/dev/null | rel | head -3 | tr '\n' ' ')"
if [ -n "$pp" ]; then rec P11-01 PASS "Privacy policy in repo" "$pp(must be published at a stable URL)"
else rec P11-01 WARN "Privacy policy" "none found in repo (required by Play; may be hosted elsewhere)"; fi

# ======================= REPORT =======================
st_col() {
  [ "$COLOR" -eq 1 ] || { printf '%s' "$1"; return; }
  case "$1" in PASS) printf '\033[32m%s\033[0m' "$1";; WARN) printf '\033[33m%s\033[0m' "$1";; FAIL) printf '\033[31m%s\033[0m' "$1";; *) printf '\033[2m%s\033[0m' "$1";; esac
}
NAME="$(basename "$PROJECT")"
if [ "$MARKDOWN" -eq 1 ]; then
  echo "### verify.sh: $NAME"
  echo
  echo "Flutter: $FLUTTER_VER · required targetSdk: $REQ_TARGET (dated) · artifact: ${ARTIFACT:+$(basename "$ARTIFACT")}${ARTIFACT:-none}"
  echo
  echo "| ID | Status | Check | Detail |"
  echo "|---|---|---|---|"
  i=0; while [ $i -lt $N ]; do
    printf '| %s | %s | %s | %s |\n' "${R_ID[$i]}" "${R_ST[$i]}" "${R_TI[$i]}" "$(printf '%s' "${R_DE[$i]}" | sed 's/|/\\|/g')"
    i=$((i+1)); done
  echo
  echo "**Summary:** PASS $NPASS · WARN $NWARN · FAIL $NFAIL · INFO $NINFO · SKIP $NSKIP"
else
  echo "android-game-creation verify: $NAME"
  echo "Project: $PROJECT"
  echo "Flutter: $FLUTTER_VER | required targetSdk: $REQ_TARGET (dated) | artifact: ${ARTIFACT:-none}"
  printf '%-7s %-5s %-46s %s\n' "ID" "STAT" "CHECK" "DETAIL"
  printf '%-7s %-5s %-46s %s\n' "-------" "-----" "----------------------------------------------" "------"
  i=0; while [ $i -lt $N ]; do
    t="${R_TI[$i]}"; [ ${#t} -gt 46 ] && t="${t:0:45}…"
    printf '%-7s %s %-46s %s\n' "${R_ID[$i]}" "$(st_col "$(printf '%-5s' "${R_ST[$i]}")")" "$t" "${R_DE[$i]}"
    i=$((i+1)); done
  echo
  echo "Summary: PASS $NPASS | WARN $NWARN | FAIL $NFAIL | INFO $NINFO | SKIP $NSKIP"
  echo "Manual/Play Console items are not covered here: see references/checklist.md."
fi

if [ "$NFAIL" -gt 0 ]; then exit 1; fi
if [ "$STRICT" -eq 1 ] && [ "$NWARN" -gt 0 ]; then exit 1; fi
exit 0
