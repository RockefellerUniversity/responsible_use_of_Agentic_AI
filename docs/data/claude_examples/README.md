# Example CLAUDE.md, rules, settings and memory files

Worked examples for the *What Happens With a Query* and *Customizing Your LLM* sessions.
They follow one imaginary project: a biologist using Claude Code to analyse
**Ikzf1 in B-cell ALL** (bulk RNA-seq) for a grant resubmission.

Each folder here shows where the files really live on your computer:

| Folder in this example | Real location | Who writes it | Shared? |
|---|---|---|---|
| `global/` | `~/.claude/` | You | No, just you, every project |
| `project/` | Your project folder, e.g. `~/projects/ikzf1-ball-rnaseq/` | You (Claude can help) | Yes, commit it to git (except the `.local` files) |
| `memory/` | `~/.claude/projects/<project>/memory/` | Claude, automatically | No, this machine only, not in git |

## What each file is for

**Guides (read into context; the model *should* follow them, but it can ignore or forget them):**

- `global/CLAUDE.md`: how you like to work, in every project.
- `global/rules/writing-style.md`: extra always-on rules, kept in their own file.
- `project/CLAUDE.md`: what this project is, where things are, how we do things here.
- `project/CLAUDE.local.md`: your personal notes for this project (git-ignored).
- `project/.claude/rules/*.md`: rules that load only when Claude touches matching files (`paths:`).
- `project/docs/decisions.md`: imported with `@`, so it is always read at the start.
- `project/docs/analysis_plan.md`: only *pointed to*, so it is read only when needed.
- `memory/MEMORY.md` + topic files: what Claude has learned about you and the project.
- `global/skills/gene-summary/`: an example **skill**. `SKILL.md` gives the steps, `assets/` holds a
  Markdown report template, `references/` lists the sources to search, and `scripts/` has a small
  NCBI Gene lookup. Personal skills live in `~/.claude/skills/`; put one in a project's
  `.claude/skills/` to share it with your team.

**Hard rules (enforced by Claude Code itself, whatever the model "decides"):**

- `global/settings.json` and `project/.claude/settings.json`: `deny` / `ask` / `allow` permission rules.
- `project/.claude/hooks/protect-raw.sh`: a hook that blocks any edit inside `data/raw/`.

Even hard rules are not a security boundary: a deny rule for `git push` does not catch
`git -C . push`. Keep backups, git history and read-only raw data as the safety net.

## Using them

Copy what is useful and **rewrite it for your own work**. Keep each `CLAUDE.md` short
(Anthropic suggests under 200 lines); longer files cost context in every session and are
followed less well. Never put passwords, tokens or patient data in any of these files.

Checked against the Claude Code docs (memory, settings, permissions, hooks), November 2026.
Details change between versions.
