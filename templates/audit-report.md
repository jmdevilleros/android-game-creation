# Android game audit: {{project_name}}

- **Date:** {{YYYY-MM-DD}} ({{timezone}})
- **Mode:** {{audit | new}}
- **Repository:** {{path}} @ {{branch}} / {{commit}}
- **Auditor:** android-game-creation skill
- **Status values:** `meets` · `partial` · `missing` · `n/a` · `not verified`

## 1. Inputs

| # | Input | Value |
|---|---|---|
| 1 | Game name / working title | |
| 2 | applicationId (final?) | |
| 3 | Engine / stack and versions | |
| 4 | Orientation(s) and target form factors (phone / tablet / foldable / ChromeOS) | |
| 5 | Monetization (free / paid / IAP / ads) | |
| 6 | Data collected, network use, third-party SDKs | |
| 7 | Target audience and ages | |
| 8 | Languages | |
| 9 | Release stage (MVP / closed test / production / update) and target date | |

## 2. Automated checks (`scripts/verify.sh`)

Command: `{{command line}}`. Exit code: `{{n}}`.
**Summary:** PASS {{n}} · WARN {{n}} · FAIL {{n}} · INFO {{n}} · SKIP {{n}}

{{paste the --markdown output, or a summary of the FAIL/WARN rows}}

## 3. Findings by phase

Give every checklist item a row. Evidence is a `file:line`, a command output or a URL. Never write "meets" without evidence; if you can't confirm an item, write `not verified` and say why.

### Phase 0: Concept, spec and methodology
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|
| P0-01 | | | | |

### Phase 1: Project setup
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 2: Display, orientation, font scale and layout
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 3: Lifecycle and persistence
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 4: Audio
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 5: Input, back and navigation
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 6: Performance
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 7: Accessibility and localization
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 8: Stability and observability
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 9: Testing and CI
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 10: Signing and release build
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 11: Play Store and compliance
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

### Phase 12: Post-launch maintenance
| ID | Item | Status | Evidence | Proposed fix |
|---|---|---|---|---|

## 4. Top priorities

1. **Critical blockers** (stop release): {{IDs + one line each}}
2. **Important** (fix before production): {{...}}
3. **Nice-to-have**: {{...}}

## 5. Dated requirements re-verified

| ID | Requirement | Value in skill | Value today (source + date fetched) | Changed? |
|---|---|---|---|---|
| P1-02 | Play target API | API 36 since 2026-08-31 | | |
| P1-03 | 16 KB page size | updates blocked from 2027-02-01 | | |
| P2-01 | Large-screen orientation exemption for games | Android 16 / API 36 | | |
| P2-03 | Edge-to-edge enforcement | targetSdk 35/36 | | |
| P11-09 | Android developer verification | global 2027 | | |

## 6. Play Console manual steps (cannot be done from the repo)

- [ ] Play App Signing enrolled; upload key registered (P10-03)
- [ ] Privacy policy URL set (P11-01)
- [ ] Data safety form submitted and consistent with the code (P11-02)
- [ ] Content rating questionnaire (IARC) completed (P11-03)
- [ ] Target audience and content declarations (P11-04)
- [ ] Store listing: icon 512, feature graphic, screenshots per form factor, descriptions (P11-05)
- [ ] Category = Game / subcategory, tags (P11-06)
- [ ] Pricing / IAP products / countries (P11-07)
- [ ] Internal → closed → production tracks; closed-test requirement for new personal accounts (P11-08)
- [ ] Developer and package verification (P11-09)
- [ ] Pre-launch report and Android vitals reviewed (P8-05)

## 7. Proposed changes

- **Branch:** `{{audit/android-game-YYYYMMDD}}` (not created until the user confirms)
- **Changes** (one commit per item; ask before applying):

| # | IDs | Files | Change | Risk |
|---|---|---|---|---|

- **Not done, needs the user:** pushing, publishing, Play Console actions, generating or moving keystores.

## 8. Not verified / open questions

- {{item}}: {{why it could not be verified; what is needed}}
