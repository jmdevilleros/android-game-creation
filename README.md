# android-game-creation

Agent skill + generic release checklists for Android games.

A checklist-driven skill for **creating a new Android game** or **auditing an existing Android game repo before release**. It is written for Flutter + Flame first; most of its items don't depend on the engine.

It has 94 items across phases 0 to 12 (concept → maintenance), stable item IDs (`P2-01`), a read-only `verify.sh` with about 35 automated checks, a report template, code snippets, and official sources with notes on what to re-verify.

## Layout

```
android-game-creation/
├── SKILL.md                     # entry point (frontmatter + workflow)
├── README.md
├── references/
│   ├── checklist.md             # 94 items, IDs P0-01 … P12-06
│   ├── snippets.md              # S-01 … S-14 code snippets
│   └── official-sources.md      # links, what they cover, dated notes
├── scripts/
│   └── verify.sh                # read-only automated checks
└── templates/
    └── audit-report.md          # findings report template
```

## Install

Copy (or symlink) the `android-game-creation/` folder into a skills directory.

| Agent | Personal (all projects) | Project (commit with the repo) |
|---|---|---|
| Grok Build | `~/.grok/skills/` | `<repo>/.grok/skills/` |
| Claude Code | `~/.claude/skills/` | `<repo>/.claude/skills/` |
| Cursor | `~/.cursor/skills/` | `<repo>/.cursor/skills/` |
| Generic (`.agents`) | `~/.agents/skills/` | `<repo>/.agents/skills/` |

The repo root is the skill folder, so you can clone it straight into place:

```bash
git clone git@github.com:jmdevilleros/android-game-creation.git ~/.grok/skills/android-game-creation
# Claude Code: ~/.claude/skills/android-game-creation
# Cursor:      ~/.cursor/skills/android-game-creation
# .agents:     ~/.agents/skills/android-game-creation
```

Update later with `git -C ~/.grok/skills/android-game-creation pull`. The `checklists/` folder is ignored by the agents and is harmless there.

Restart the agent session, or reload skills, so the new skill is picked up.

## Usage

```text
/android-game-creation audit .                 # audit the current repo
/android-game-creation audit ../my-game        # audit another path
/android-game-creation new                     # scaffold a new game project
```

You can also just ask: "audit this Android game before I publish it" or "help me start a new Flutter/Flame game for Android".

### Running the script directly

```bash
scripts/verify.sh /path/to/project                       # table output
scripts/verify.sh /path/to/project --markdown            # Markdown table for reports
scripts/verify.sh . --artifact build/app/outputs/bundle/release/app-release.aab   # + 16 KB check
scripts/verify.sh . --flutter                            # + flutter analyze/test in a temp copy
REQUIRED_TARGET_SDK=37 scripts/verify.sh .               # when Play raises the bar
```

Exit codes: `0` means no FAIL, `1` means at least one FAIL (or a WARN when `--strict` is set), and `2` means a usage error. It needs bash, grep, sed, awk and find. `unzip`/`readelf` are optional; python3 is the fallback for the 16 KB check.

## Checklists

`checklists/` holds the same release checklist as standalone documents, independent of any agent:

| Language | Markdown | PDF | Rebuild |
|---|---|---|---|
| English | `checklists/en/android_game_checklist_generic_en.md` | `…_en.pdf` | `cd checklists/en && python3 build_pdf_generic_en.py` |
| Spanish | `checklists/es/checklist_generico_juegos_android.md` | `….pdf` | `cd checklists/es && python3 build_pdf_generic.py` |

## Safety

- `verify.sh` never writes to the project. `--flutter` works in a temporary copy.
- The skill applies fixes only on a new branch, and only after you confirm. It never commits keystores or `key.properties`, and it never pushes or publishes without your explicit approval.
- Requirements with dates (target API, 16 KB, Android 16 behavior, developer verification) are marked ⚠. They are re-checked against the official docs on every run.

## License

[MIT](LICENSE)

## Author

jmdevilleros · Last reviewed 2026-10-19
