---
name: omics-review
description: >
  Review R/Rmd or Python bioinformatics analysis scripts for code errors AND
  for assay-specific design and statistics problems. Covers bulk RNA-seq,
  single-cell RNA-seq, chromatin assays (ATAC-seq, ChIP-seq, CUT&RUN/CUT&Tag),
  proteomics (mass-spec, Olink), and DNA methylation (arrays and bisulfite
  sequencing). Supports three tiers — quick, standard, independent — passed
  as an argument (e.g. "/omics-review standard", "/omics-review independent").
  Use whenever the user asks to review, check over, audit, or sanity-check an
  analysis script or notebook, even if they just say "can you look over my
  DESeq2 Rmd?" or "is my Seurat script ok?" without naming the skill.
---

# Omics Review

Reviews a bioinformatics analysis script in two passes: a generic code-quality
pass that applies to any script, and a method-specific pass on the design and
statistics choices for the assay being analyzed. The method concerns are
language-agnostic — a confounded design or pseudoreplicated test is the same
problem in R or Python — so each reference file lists R and Python tool names
side by side.

## How this skill is organized — load only what you need

```
omics-review/
├── SKILL.md                         ← you are here
├── references/
│   ├── generic_code_quality.md      ← load for EVERY review
│   ├── bulk_rnaseq.md               ← load only the ONE file that
│   ├── scrnaseq.md                     matches the assay (Step 2)
│   ├── chromatin.md
│   ├── proteomics.md
│   └── methylation.md
└── assets/
    ├── report_template.md           ← fill this in for every review
    └── example_report.md            ← a filled-in example; read only if
                                        unsure how the template is used
```

Read `generic_code_quality.md` plus the single assay file that matches the
script. Don't read the other assay files: they're long, they won't apply, and
irrelevant checklists dilute attention as well as wasting context. The only
exception is a genuinely multi-assay script (e.g. a multiome RNA + ATAC
analysis, CITE-seq with protein), where you load each matching file.

## Step 1 — Determine the tier

Parse the argument for `quick`, `standard`, or `independent`. If none is given,
ask the user which they want rather than guessing — the cost difference
between tiers is large. Suggest `standard` as the usual choice.

## Step 2 — Identify the assay

Look at library imports, function calls, and file/project naming:

| Signals | Reference file |
|---|---|
| **R:** `DESeq2`, `edgeR`, `limma::voom`, `tximport`, `featureCounts` output, `enrichGO`/`gseGO` on DE results. **Python:** `pydeseq2`, `gseapy` | `references/bulk_rnaseq.md` |
| **R:** `Seurat`, `SingleCellExperiment`, `scran`, `Read10X`, `FindClusters`, `SoupX`, `scDblFinder`. **Python:** `scanpy`, `AnnData`, `scvi`, `scrublet`, `scvelo` | `references/scrnaseq.md` |
| **R:** `DiffBind`, `csaw`, `ChIPseeker`, `ArchR`, `Signac`, `ATACseqQC`. **CLI/Python:** `MACS2`/`MACS3`, `SEACR`, `deeptools`, `pyranges`, `snapatac2`; IgG/input controls, peaks, FRiP, TSS enrichment | `references/chromatin.md` |
| **R:** `DEP`, `limma` on protein intensities, `MSstats`, `OlinkAnalyze`. **Python:** protein-intensity matrices with `sklearn.impute`, `statsmodels`; MaxQuant/DIA-NN/Spectronaut output, NPX values | `references/proteomics.md` |
| **R:** `minfi`, `sesame`, `ChAMP`, `methylKit`, `DSS`, `dmrseq`, `bsseq`. **CLI/Python:** `bismark`, `MethylDackel`, `methylpy`; beta/M-values, CpG, DMP/DMR | `references/methylation.md` |

If no row matches clearly, ask the user which assay it is — a wrong-method
checklist gives false confidence. If the script is generic analysis code with
no assay at all, run the generic pass only and say so.

**The reference files are a floor, not a ceiling.** They list common pitfalls,
not everything that can go wrong. Always bring general knowledge of the method
to bear on whatever the script does that the checklist doesn't mention.

## Step 3 — Static analysis only

State explicitly, every time: **no execution of shell/R/Python commands
against real data — static analysis only** — unless the user has authorized
specific commands for this review. Restate this in any subagent prompt, and
tell subagents to search with file tools (Read/Grep/Glob) rather than the
shell. Prompt-only "don't use Bash" instructions have proven leaky, so ask
subagents to report any shell use and pass that on to the user.

## Step 4 — Run at the requested tier

### `quick`
One pass by you, no subagents. Apply `generic_code_quality.md` only: things
that will error or silently misbehave. Skip design/stats commentary unless
something jumps out. Cheap — for a quick sanity check.

### `standard`
One pass by you, no subagents. Apply `generic_code_quality.md` **and** the
matched assay file, walking its checklist item by item rather than skimming.
Then go beyond the checklist with general knowledge of the method. Include
design/stats commentary ("is this comparison confounded?", "is this test
pseudoreplicated?"), not just bugs. This is the default depth.

### `independent`
One fresh subagent via the `Agent` tool. The point is independence: if you
helped write or edit the script, you share its assumptions and blind spots;
an agent with no conversation history reads it cold.

1. **Before spawning**, gather what it can't know: the script path(s), the
   matched reference file paths, sibling files worth cross-checking, and any
   decisions the user has already settled (so it doesn't re-flag them).
2. **In the prompt**, restate: static analysis only, file tools instead of
   Bash, no edits; references are a floor, not a ceiling; an adversarial
   stance; the evidence rules in Step 5. Ask it to try to refute each of its
   own findings against the code before reporting, dropping any that don't
   survive.
3. **Ask for structured output** per finding: title, file:line, severity,
   bug vs. judgment call, checklist- vs. general-knowledge-sourced, evidence,
   suggested fix — plus a not-checked list and a verdict.
4. **Afterwards**, spot-check the top findings yourself, say where you
   disagree and why, then write the report per Step 5.

## Step 5 — Write the report

Fill in `assets/report_template.md` (read it now if you haven't). Look at
`assets/example_report.md` only if you're unsure how a section should read.

Adopt an adversarial stance: you're looking for reasons the script is wrong,
not confirming it looks reasonable. Regardless of tier:

- **Every finding needs evidence** — a file:line, the specific code, or a
  worked example. "This looks wrong" is not a finding.
- **Separate bugs from judgment calls.** A judgment call needs the user's
  input, not a fix.
- **Label general-knowledge findings** ("not in the checklist, but…") so the
  user knows it's less battle-tested — and so it can be added to the
  reference file if confirmed.
- **Say what you did not check** and why, rather than letting silence imply
  full coverage.
- **Close with a verdict** — PASS, PASS WITH CONCERNS, or FAIL — and a
  severity (High/Med/Low) per finding. If nothing real turned up, say so;
  don't pad a clean review.
- **Edits are separate.** Any change to the script itself means showing the
  diff and getting confirmation first.

## Iterative reviews

If the user has edited the script since your last review, re-read it — don't
trust the version in context. Confirm what's now fixed before reporting
anything new, and look specifically for fixes that introduced a new problem.
