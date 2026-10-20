---
name: android-game-creation
description: >-
  Checklist-driven workflow for building Android games and getting them ready for release.
  Use it to scaffold a new Android game project, or to audit and complete an existing
  Android game repository before a Google Play release or update. It covers 94 items
  across 13 phases (spec, project setup, SDK/target API, 16 KB pages, display and
  font scale, edge-to-edge, orientation on large screens, lifecycle, audio focus,
  predictive back, performance, accessibility, stability, tests/CI, signing, Play
  compliance, maintenance), a read-only verify.sh, a findings report, and branch-only fixes
  applied after the user confirms. Flutter + Flame is the primary stack, and most items
  don't depend on the engine.
when-to-use: >-
  "create an Android game", "new Flutter game", "new Flame game", "audit my Android
  game", "is my game ready for Google Play", "pre-release checklist Android",
  "review signing / targetSdk / 16 KB / edge-to-edge / predictive back", "prepare
  game for Play Store", "Play Console requirements for my game".
argument-hint: "new|audit [path]"
user-invocable: true
metadata:
  author: jmdevilleros
  short-description: Create or audit an Android game (Flutter/Flame first) against a 94-item release checklist.
---

# Android game creation and audit

Use this skill to create a new Android game, or to audit an existing game repo against a 94-item checklist covering phases 0 to 12. The skill directory holds:

| File | Use |
|---|---|
| `references/checklist.md` | The items, with stable IDs (`P0-01` … `P12-06`), priority, scope, ⚠ dated flags, `[auto]` marks and snippet links |
| `references/snippets.md` | Code snippets `S-01` … `S-14` (manifest, edge-to-edge, TextScaler, lifecycle, audio focus, PopScope, CI, signing) |
| `references/official-sources.md` | Official links: what each one covers and what to re-verify |
| `scripts/verify.sh` | Read-only automated checks; PASS/WARN/FAIL/INFO/SKIP per item ID |
| `templates/audit-report.md` | Report skeleton for the findings |

Paths below are relative to this skill's directory. Resolve them before you use them.

## Non-negotiable rules

1. **Read-only until the user confirms.** In audit mode, don't modify, commit or delete anything in the user's repo until the user has seen the report and approved specific changes.
2. **Fixes only on a branch.** Create a new local branch (`audit/android-game-YYYYMMDD` or similar) and keep each change small: one item or a related group per commit. Never rewrite history or commit to the main branch.
3. **Never commit secrets.** Keystores (`*.jks`, `*.keystore`, `*.p12`), `key.properties`, passwords and service-account JSON stay out of git. Don't print their contents, and don't generate a release keystore unless the user asks. If you generate one, keep it outside the repo and tell the user to back it up.
4. **Never push, publish, upload to Play, or create PRs/tags/releases** without explicit approval for that specific action.
5. **Evidence or "not verified".** Every status needs a `file:line`, command output or URL. If you can't confirm an item, mark it `not verified` and give the reason. Never guess.
6. **Re-verify dated requirements.** Items flagged ⚠ (target API level, 16 KB page size, Android 16 large-screen and edge-to-edge behavior, predictive back defaults, developer verification) change over time. Fetch the official page listed in `references/official-sources.md` during the run, and report the value you found and the date you fetched it. If the live doc disagrees with the checklist, the live doc wins.
7. **Play Console steps are manual.** List them separately. Never claim they are done because the repo looks fine.

## Modes

Parse the arguments as `<mode> [path]`.

- `audit [path]` (default when the target already has an `android/` folder or a Gradle project): examine an existing repo, defaulting to `.`, and produce the findings report.
- `new [path]`: scaffold a new game project, or bring a nearly empty repo up to the checklist from the start.

If the mode is ambiguous, look at the target directory. Ask only if it's still unclear.

## Step 1: Gather the 9 inputs

Ask for whatever you can't infer from the repo (README, docs, `pubspec.yaml`, Gradle, manifest), and confirm what you inferred. In audit mode, fill in what you can and ask only about the gaps.

1. Game name / working title
2. `applicationId` (reverse domain the user owns), and whether it's already on Play (if so it can't change)
3. Engine/stack and versions (Flutter + Flame by default; otherwise native, Unity, Godot…)
4. Orientation(s) and form factors (phone, tablet, foldable, ChromeOS)
5. Monetization: free, paid, IAP or ads
6. Data collected, network use, third-party SDKs (analytics, crash, ads, login)
7. Target audience and age range (drives content rating, Families policy and ads rules)
8. Languages
9. Release stage (MVP, closed test, production, update) and target date

Record the answers in section 1 of the report.

## Step 2 (audit): Run the automated checks

```bash
bash <skill>/scripts/verify.sh <path> --markdown            # always
bash <skill>/scripts/verify.sh <path> --artifact <aab|apk>  # if a release artifact exists (16 KB check)
bash <skill>/scripts/verify.sh <path> --flutter --markdown  # if Flutter is installed: analyze + test in a temp copy
```

- The script is read-only. It resolves `flutter.*` SDK defaults from the local Flutter SDK (`FLUTTER_ROOT`, `flutter` on PATH, or `~/flutter`).
- `REQUIRED_TARGET_SDK` (default 36) is a dated value. Set it to whatever the Play target-API page says today.
- Exit code 1 means at least one FAIL. Treat FAIL rows as candidate blockers, then confirm each one by reading the code. The script uses heuristics, so it can produce false positives, e.g. a dependency reported unused because it's only used transitively.
- Don't build a release artifact in the user's repo just to run the 16 KB check. If none exists, mark P1-03 `not verified` and suggest the build command.

## Step 3 (audit): Walk the checklist phase by phase

For each phase, open its section in `references/checklist.md` and judge every item. Use `meets`, `partial`, `missing`, `n/a` (with a reason) or `not verified`, and cite the evidence.

| Phase | Focus | Where to look first |
|---|---|---|
| 0 Concept, spec, methodology | spec/intent, state file, agent rules, single verify harness, acceptance, applicationId, pure logic | `docs/`, `AGENTS.md`, README, `lib/` structure |
| 1 Project setup | SDK levels, target API ⚠, 16 KB ⚠, versioning, R8, permissions, deps, assets, adaptive icon, splash | `android/app/build.gradle*`, `AndroidManifest.xml`, `pubspec.yaml`, `res/` |
| 2 Display and layout | `appCategory="game"` ⚠, orientation in two places, edge-to-edge ⚠, insets, HUD vs playfield, scaling, font policy, display size, large screens | manifest, `main.dart`, HUD widgets, `MediaQuery`/`TextScaler` usage |
| 3 Lifecycle and persistence | pause loop, pause menu, observers, atomic saves, process death, clear data, backup rules | Game class, screens, storage layer, manifest |
| 4 Audio | fail-soft init, audio focus, silence in background, release players, settings, preload | audio service, lifecycle hooks |
| 5 Input and navigation | predictive back ⚠, `PopScope` on gameplay, standard nav, multitouch, gesture areas, haptics | manifest, game screen, input components |
| 6 Performance | frame budget, allocations, assets, startup, battery, profiling | game loop, components, `flutter run --profile` (manual) |
| 7 Accessibility and l10n | Semantics, 48 dp targets and contrast, color alone, externalized strings, per-app language, line length | widgets, strings layer, `l10n.yaml` |
| 8 Stability | global error handlers, symbols, crash SDK decision, no PII/print, vitals | `main.dart`, build flags, logging |
| 9 Testing and CI | analyze, unit and widget tests, levels solvable, shader parity, E2E, CI, device matrix | `test/`, `integration_test/`, `.github/workflows/` |
| 10 Signing and build | upload key, signing config (no debug key in release), Play App Signing, AAB, final artifact check, release notes | Gradle signing block, `.gitignore`, `git ls-files` |
| 11 Play and compliance | privacy policy, Data safety, rating, audience, listing, category, IAP, tracks, developer verification ⚠, promo site | repo docs/site; the rest is manual in Play Console |
| 12 Maintenance | yearly target API ⚠, behavior changes, dependency updates, vitals/reviews, doc sync, lessons | docs, CHANGELOG, dependency age |

While you walk the phases:
- Start from the verify.sh rows (`[auto]` items), then do the manual items.
- Match the tone to the stack. Items scoped `flutter/flame` become `n/a` or get adapted for other engines; mention the equivalent.
- When you propose a fix, cite the snippet ID (`S-xx`) from `references/snippets.md` and adapt it to the project's names and structure.

## Step 4: Produce the findings report

Fill in `templates/audit-report.md` and save it outside tracked source, e.g. `./android-game-audit-YYYYMMDD.md` at the repo root, left uncommitted, or wherever the user prefers. Include:

1. The inputs
2. The verify.sh summary and its FAIL/WARN rows
3. Per-phase tables with ID, status, evidence and proposed fix
4. **Top priorities**: critical blockers first, then important, then nice-to-have
5. **Dated requirements re-verified**: the current value, the source URL and the date fetched
6. **Play Console manual steps** as a separate checklist
7. Proposed changes, grouped into commits
8. Items not verified and open questions

In chat, give a short summary: counts per status, the top blockers, and what needs the user.

## Step 5: Apply fixes (only after confirmation)

1. Show the list of proposed changes (files and a diff outline) and ask which ones to apply.
2. Check that the working tree is clean. If it isn't, stop and ask.
3. Create the branch, then apply each approved change in a small commit. Reference the item ID in the message, e.g. `P2-01: declare appCategory=game`.
4. After each group, run `verify.sh` again (plus `flutter analyze` and `flutter test` when available) and report the delta.
5. Never stage keystores or `key.properties` (check `git status` before every commit). Don't push. Tell the user which branch to review.

Typical safe automated fixes: the manifest attributes (S-02), a dark launch theme (S-01), TextScaler clamp (S-04), the `super` call in lifecycle overrides (S-05), PopScope on the gameplay screen (S-08), global error handlers (S-10), a CI workflow (S-11), null-safe signing config (S-13) and `.gitignore` entries (S-14).
Things that need a human: icon art, store assets, privacy-policy wording, the content rating, Data safety answers, and keystore creation and custody.

## Step 2 (new): Scaffold a new game

1. Confirm the 9 inputs. `applicationId` and the orientation are the decisions you can't easily undo.
2. Create the project (`flutter create --org <reverse-domain> --project-name <name> --platforms android[,web] <dir>`, then add `flame`). Don't run it inside an existing repo without asking.
3. Write Phase 0 docs first: intent/spec, plan, decisions, a state file, acceptance criteria, agent rules (`AGENTS.md`) and a `verify.sh` harness at the repo root (P0-01 … P0-05).
4. Apply the Phase 1–2 baseline from the start:
   - Flutter SDK defaults (P1-01)
   - versioning in pubspec (P1-04)
   - a minimal permissions list (P1-06)
   - adaptive icon placeholder and a TODO (P1-09)
   - dark splash (S-01)
   - `appCategory="game"` and `enableOnBackInvokedCallback="true"` (S-02)
   - orientation locked in both places (P2-02)
   - edge-to-edge with insets (S-03)
   - TextScaler clamp (S-04)
5. Add Phase 3–5 skeletons: lifecycle (S-05/S-06), the audio service with focus handling (S-07), and PopScope on gameplay (S-08).
6. Add Phase 7–9 skeletons: externalized strings, global error handlers (S-10), `analysis_options.yaml`, a first unit test and CI (S-11).
7. Signing: add the `key.properties` pattern (S-13) and `.gitignore` (S-14). Explain how to create the upload key (S-12), but let the user run `keytool`.
8. Run `scripts/verify.sh` on the new project. The target is zero FAIL; any remaining WARN gets an explanation. Then `git init` and make a local first commit only if the user agrees.
9. Hand over the Phase 10–12 list as the roadmap toward release, including the Play Console manual steps.

## Interpreting verify.sh statuses

| Script | Report status (default) |
|---|---|
| PASS | `meets` (spot-check the evidence) |
| WARN | `partial` or `missing`, depending on what you find in the code |
| FAIL | `missing`, a critical candidate (confirm in the code) |
| INFO | Judge it manually |
| SKIP | `not verified` unless you check it another way |

## Stop rules

- The target isn't an Android/Gradle project and the user didn't ask for `new` → stop and ask.
- A command would modify the repo before confirmation, or would push or publish → don't run it.
- A dated requirement can't be re-verified (offline) → keep the item, mark it `not verified (source unreachable)`, and show the value from the checklist with its review date.
