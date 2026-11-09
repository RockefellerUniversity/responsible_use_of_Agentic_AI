---
name: bio-review
description: >
  Review R/Rmd or Python bioinformatics analysis scripts (bulk RNA-seq,
  single-cell/single-nucleus RNA-seq, proteomics/mass-spec, CUT&RUN,
  Ribo-seq/ribosome profiling, gene-level CLIP-seq / CLIP score, or general R/Python analysis code) for
  basic code errors AND for design/stats
  decisions specific to the assay type. Supports four tiers — simple,
  rigorous, fresh, thorough — passed as an argument (e.g. "/bio-review rigorous",
  "/bio-review fresh", "/bio-review thorough scRNA"). Use whenever the user asks to review, check
  over, check for errors in, or audit an analysis script, even if they just
  says "review this Rmd", "check my script", or "review this Python
  notebook" without naming the skill.
---

# Bio-Review Skill

Reviews a bioinformatics analysis script (R/Rmd or Python) at one of four
effort tiers, combining a generic code-quality pass with a method-specific
methodology/design/stats pass matched to the assay type being analyzed. The
design/stats concerns in the reference files are language-agnostic — a
confounded comparison, a mismatched imputation mechanism, or an MST
trajectory artifact is the same problem whether it shows up in a Seurat/R
pipeline or a scanpy/Python one. Only the concrete function/package names
differ, and the reference files below list both where they diverge.

## Step 1 — Determine the tier

Parse the skill argument for one of: `simple`, `rigorous`, `fresh`, `thorough`.

- If none given, ask the user which tier they want rather than guessing — the
  token cost difference between tiers is large (see Step 4).
- Tiers are defined in Step 4.

## Step 2 — Identify the assay/method type

Look at the target file's library imports, function calls, and file/project
naming to determine which reference file applies:

| Signals | Reference file |
|---|---|
| **R:** `DESeq2`, `results()`, `dds`, bulk count matrix, `enrichGO`/`enricher`/`gseGO` on a DESeq2 result. **Python:** `pydeseq2` (`DeseqDataSet`, `DeseqStats`), `gseapy` (`enrichr`/`prerank`/`gsea`) on a DE result | `references/bulk_rnaseq.md` |
| **R:** `Seurat`, `Read10X`/`Read10X_h5`, `FindClusters`, `RunUMAP`, `scrublet`/doublet detection, `CellBender`. **Python:** `scanpy`/`AnnData` (`sc.pp.*`, `sc.tl.leiden`/`sc.tl.louvain`, `sc.tl.umap`), `scrublet`, `cellbender`, `scvelo`, `cellrank`, `palantir` | `references/scrnaseq.md` |
| **R:** `DEP`, `limma` on a protein abundance matrix, `SummarizedExperiment` with protein IDs, `impute()`/QRILC/MinProb/KNN imputation, Olink/mass-spec terminology. **Python:** a protein-abundance dataframe/matrix, `sklearn.impute` (`KNNImputer`/`IterativeImputer`), `statsmodels`-based moderated testing, Olink/mass-spec terminology | `references/proteomics.md` |
| **R:** `riboWaltz` (`bamtolist`, `psite`, `psite_info`, `frame_psite*`, `metaprofile_psite`), `ribosomeProfilingQC` (`estimatePsite`, `getPsiteCoordinates`, `assignReadingFrame`), `RiboProfiling`, `RiboseQC`, `ORFik`; P-site / periodicity / reading-frame / RPF terminology. **Python:** `plastid`, `RiboCode`, `ribotricer`, `riboviz` | `references/riboseq.md` |
| Gene-level CLIP-seq: CTK / CLIPflexR (`tag2collapse.pl`, `ctk_tag2collapse`, `fq2collapse`, `stripBarcode`), read names `readID#copyNumber#barcode`, `*_uniq_clpsed.bed`, STAR + `samtools view -q 255` on CLIP, `featureCounts` on CLIP BAMs, "CLIP score" / `CLIP_log2RPKM ~ RNA_log2TPM` regression, BC filters, DESeq2 `method` (CLIP/RNA) interaction designs. **Not** peak calling / crosslink sites (nf-core/clipseq, PureCLIP, iCount, Paraclu, Piranha) — no checklist for those yet | `references/clip_genelevel.md` |
| CUT&RUN/CUT&Tag terminology, `IgG` control, peak calling (`MACS2`/`SEACR`), spike-in normalization — these are CLI tools invoked the same way from an R, Python (`subprocess`/Snakemake), or shell wrapper script, so the same checklist applies regardless of the calling language | `references/cutrun.md` |

If the file mixes signals or none match clearly, ask the user which assay type
this is rather than guessing — a wrong-method checklist gives false
confidence.

**Always load `references/generic_code_quality.md` regardless of assay type**
— it applies to every review.

**These reference files are a floor, not a ceiling.** Each one captures
specific issues already confirmed against real scripts in this workspace —
they are not a complete list of everything that can go wrong with that assay
type, and `cutrun.md` in particular is an unvalidated draft. Always reason
from general knowledge of the method (Seurat/DESeq2/limma/scanpy/DEP
conventions, current best practices, known pitfalls not yet seen in any
script here) in addition to the checklist, not instead of it. If the file
being reviewed uses a tool or pattern the reference file doesn't mention at
all, don't skip commentary on it just because it isn't written down —
reviewing only what's listed would make the skill regress toward whatever
was already caught before, instead of improving on it.

## Step 3 — Static analysis only

State explicitly, every time (do not rely on this being inherited from
context): **no execution of shell/R/Python/etc. commands against real data —
static analysis only** — unless the user has explicitly authorized specific
command(s) for this specific review. This applies to you directly and to any
subagent spawned in `fresh` or `thorough` mode; restate it in every subagent prompt.
A prompt-only "don't use Bash" instruction has proven leaky — subagents have
still run read-only `grep` through Bash — so also tell them to search with the
Read/Grep/Glob file tools instead of the shell, and report any shell use they
admit to back to the user in the final summary.

## Step 4 — Run at the requested tier

### `simple`
Single pass, by you directly (no subagents). Read the file once, apply
`generic_code_quality.md` only. Report obvious code errors, style
inconsistencies, and anything that looks like it would error or silently
misbehave. Skip method-specific design/stats commentary unless something
jumps out. Fast, cheap — use for a quick sanity check.

### `rigorous`
Single pass, by you directly (no subagents). Read the file, apply
`generic_code_quality.md` **and** the matched method-specific reference file
explicitly — walk its checklist item by item rather than skimming. Then go
beyond the checklist: bring general knowledge of the method to bear on
whatever the file does that the reference file doesn't cover. Give
design/stats commentary (e.g. "is this comparison confounded," "does the
imputation method match the missingness mechanism," "is multiple-testing
correction applied consistently across sibling analyses"), not just
correctness bugs. This is the default depth for a normal "review this file"
ask.

### `fresh`
One fresh, adversarial reviewer — a single subagent via the `Agent` tool (not
`Workflow`), sitting between `rigorous` and `thorough`. The point is
independence, not scale: the main agent has usually helped write or edit the
code under review and carries the same assumptions and blind spots, while a
fresh agent with no conversation history reads the file cold. Costs roughly one
agent's worth of tokens instead of the dozens `thorough` can spawn.

1. **Before spawning**, gather what the fresh agent can't know: the target
   file path(s); the matched reference file paths
   (`~/.claude/skills/bio-review/references/...`); sibling/upstream files worth
   cross-checking; and the **settled decisions** and **already-known issues**
   from project memory, so it doesn't re-flag deliberate choices (it may still
   flag a bug in how a settled choice is *implemented*).
2. **Spawn one agent** whose prompt restates: static analysis only, file tools
   instead of Bash, no edits; the reference files are a floor, not a ceiling;
   an adversarial stance (it didn't write this code and should look for reasons
   it's wrong); and the evidence rules from Step 5. Tell it to read the whole
   target file, walk the reference checklists item by item, check
   correctness, method/design/stats and cross-file consistency, and then —
   before reporting — **try to refute each of its own findings** against the
   actual code (already handled elsewhere? intentional? misread?), dropping or
   downgrading any that don't survive. That self-refutation pass replaces
   `thorough`'s per-finding verifier agents.
3. **Ask for structured output**: per finding — title, file:line, severity
   (High/Med/Low), bug vs design call, checklist- vs general-knowledge-sourced,
   evidence, suggested fix, and what the refutation attempt found; plus a
   not-checked list and a verdict.
4. **Main agent's job afterwards**: spot-check the top findings against the
   file before relaying (you have the context to catch a misreading quickly),
   say plainly where you disagree with the fresh reviewer and why rather than
   silently dropping its findings, dedupe, and present per Step 5 with a
   verdict. Report any shell use the agent admitted to.

Use `fresh` as the default when the user wants an independent second opinion on
code that has been heavily edited in the current conversation.

### `thorough`
Multi-agent, via the `Workflow` tool — only invoke this when explicitly
requested (`thorough`), since it costs meaningfully more tokens than
`rigorous` or `fresh`: the per-finding verify step means agent count scales with
the number of findings (a 2026-09-28 run on one ~800-line Rmd used 49 agents and
~2.2M tokens). Prefer `fresh` unless maximum coverage is worth that cost.
Structure:

1. **Find, in parallel** — one agent per dimension: (a) code correctness, (b)
   method-specific methodology/design/stats (using the matched reference file
   as a starting point, explicitly instructed to also draw on general
   knowledge of the method beyond it), (c) cross-file consistency if this
   script has sibling files/templates (check the project directory for
   similarly-named files). Each agent prompt must restate the static-
   analysis-only constraint, restate that the reference file is a floor not a
   ceiling, and include the actual file content/path — a fresh subagent has
   no context otherwise.
2. **Verify, in parallel per finding** — an adversarial pass on each finding
   from step 1: a second agent tries to refute it (e.g. "is this actually
   wrong, or is it intentional/already handled elsewhere in the file?").
   Drop findings that don't survive.
3. **Report** — combine surviving findings, most severe first.

## Step 5 — How to present findings

Adopt an adversarial stance, especially at `rigorous`/`fresh`/`thorough`: you did not
write this code and have no stake in it looking good. Your job is to find
reasons it's wrong, not to confirm it looks reasonable. Actively try to
refute the script's own implicit claims of correctness (a filter that's
supposed to remove all NAs, a "this is idempotent" assumption, a comment
claiming a step was already validated) rather than taking them at face
value — re-derive a small example by hand where that's enough to check it.

Regardless of tier:
- **Every finding needs evidence**: a file:line reference, the specific
  code/output it's based on, or a worked example — not just an assertion.
  "This looks wrong" is not a finding; "line 214 filters on `padj` but line
  198 shows `stat` has no NAs in this dataset, so line 214 should use `stat`"
  is.
- State what's actually wrong or worth discussing, with the file:line
  reference, not a restatement of what the code does.
- Distinguish correctness bugs from design/stats judgment calls — a judgment
  call needs the user's input, not a fix.
- If the user says they've already made a deliberate decision on something (e.g.
  "QC filtering is off for now"), don't re-flag it in future reviews of the
  same file unless they ask to revisit it — check project memory for
  previously-settled decisions before flagging something as an issue.
- Any actual *edit* to the file (not just a finding) requires showing the
  diff and getting confirmation first — this is a hard rule in every project
  CLAUDE.md in this workspace, not just a preference.
- When a finding comes from general knowledge of the method rather than
  anything written in the reference file, say so briefly (e.g. "this isn't
  in the checklist yet, but...") — that tells the user it's a newer/less
  battle-tested observation than a checklist-sourced one, and flags it as a
  candidate to fold into the reference file if they agrees it's real (see
  `~/.claude/skills/bio-review/references/` — update the relevant file
  directly when a new finding is confirmed, the same way the existing
  checklists were built).
- State explicitly what you did **not** check and why (e.g. "did not verify
  the HPC path resolves — no execution access"), rather than letting silence
  imply full coverage.
- For `rigorous`/`fresh`/`thorough`, close with an explicit verdict — **PASS**,
  **PASS WITH CONCERNS**, or **FAIL** — plus severity (High/Med/Low) per
  finding. If nothing real turned up, say so plainly; don't pad a clean
  review with generic praise.

## Iterative reviews

If the user says they've edited the file since your last review and asks you to
"reread and check again": re-`Read` the file — don't trust the version
already in context. Confirm what's now resolved before reporting anything
new, and watch specifically for edits that overcorrected or introduced a new
inconsistency (this has happened before — e.g. fixing a `universe` bug by
switching `enricher()` to `enrichGO()` but introducing a `keyType` mismatch
in the same edit).
