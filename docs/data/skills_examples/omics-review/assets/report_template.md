# Review: `<script name>`

<!--
Fill in every section. Delete these comments. If a section has nothing in it,
write "None" rather than deleting the heading — an empty section tells the
reader it was checked.
-->

## Verdict

**<PASS | PASS WITH CONCERNS | FAIL>** — <one sentence on the main reason>

| Severity | Count |
|---|---|
| High | <n> |
| Medium | <n> |
| Low | <n> |

## Scope

- **Script(s):** `<path>` (<n> lines)
- **Tier:** <quick | standard | independent>
- **Assay identified:** <assay> — from <the signals that identified it>
- **References loaded:** `generic_code_quality.md`, `<assay file>.md`
- **Execution:** static analysis only — no code was run.

## Findings

<!-- Most severe first. One row per finding; details below. -->

| # | Severity | Type | Location | Finding |
|---|---|---|---|---|
| 1 | <High/Med/Low> | <Bug / Judgment call> | `<file>:<line>` | <short title> |

### 1. <short title>

- **Location:** `<file>:<line>`
- **Source:** <checklist: section name | general knowledge — not in the checklist yet>
- **Evidence:** <the code, quoted, and why it's wrong — or a worked example>
- **Suggested fix:** <code or approach> <!-- for judgment calls: "needs your decision" and the options -->

<!-- Repeat for each finding. -->

## Design and statistics questions

<!-- Questions only the user can answer, e.g. "Was batch confounded with condition?" -->

- <question>

## Not checked

<!-- What you could not verify and why. Never leave this empty without saying so. -->

- <item> — <reason, e.g. "needs execution against the data">
