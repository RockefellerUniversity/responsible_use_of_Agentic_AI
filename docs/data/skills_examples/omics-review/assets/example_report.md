# Review: `de_analysis.Rmd`

> **Example only.** This report reviews a made-up script to show how
> `report_template.md` is filled in. The script, samples and line numbers are
> fictional.

## Verdict

**FAIL** — the contrast is reversed, so every reported fold change points the
opposite way from what the text says.

| Severity | Count |
|---|---|
| High | 2 |
| Medium | 2 |
| Low | 1 |

## Scope

- **Script(s):** `de_analysis.Rmd` (212 lines)
- **Tier:** standard
- **Assay identified:** bulk RNA-seq — from `library(DESeq2)`,
  `DESeqDataSetFromMatrix()`, and `featureCounts` input at line 14
- **References loaded:** `generic_code_quality.md`, `bulk_rnaseq.md`
- **Execution:** static analysis only — no code was run.

## Findings

| # | Severity | Type | Location | Finding |
|---|---|---|---|---|
| 1 | High | Bug | `de_analysis.Rmd:41` | Contrast is reversed, so LFCs are control vs treated |
| 2 | High | Bug | `de_analysis.Rmd:33` | No check that count columns match sample sheet order |
| 3 | Medium | Bug | `de_analysis.Rmd:118` | `enrichGO()` has no `universe` |
| 4 | Medium | Judgment call | `de_analysis.Rmd:29` | Batch is in the sample sheet but not the design |
| 5 | Low | Bug | `de_analysis.Rmd:150` | GSEA input filtered on `padj` instead of `stat` |

### 1. Contrast is reversed, so LFCs are control vs treated

- **Location:** `de_analysis.Rmd:41`
- **Source:** checklist — §2 Design and contrasts
- **Evidence:** `condition` is read as character (`"control"`, `"treated"`)
  and converted with `factor()` at line 38 without `levels =`. Alphabetical
  order makes `"control"` the reference, which is what's wanted — but line 41
  then calls `results(dds, contrast = c("condition", "control", "treated"))`,
  which reverses it. The text at line 160 says "genes up in treated", but
  positive LFCs here mean up in control.
- **Suggested fix:** `results(dds, contrast = c("condition", "treated", "control"))`,
  and set `factor(condition, levels = c("control", "treated"))` explicitly.

### 2. No check that count columns match sample sheet order

- **Location:** `de_analysis.Rmd:33`
- **Source:** checklist — `generic_code_quality.md` §1
- **Evidence:** count columns follow the order BAMs were passed to
  featureCounts (a hand-typed vector at line 12), while the sample sheet is
  read from a CSV sorted by sample ID. Nothing ties the two together, and
  `DESeqDataSetFromMatrix()` matches by position, so a mismatch would label
  samples wrongly without any error.
- **Suggested fix:**
  `counts <- counts[, coldata$sample_id]` then
  `stopifnot(identical(colnames(counts), coldata$sample_id))`.

### 3. `enrichGO()` has no `universe`

- **Location:** `de_analysis.Rmd:118`
- **Source:** checklist — §6 Enrichment
- **Evidence:** `enrichGO(gene = sig_genes, OrgDb = org.Hs.eg.db, keyType = "ENSEMBL")`
  uses every annotated gene as background, inflating significance.
- **Suggested fix:** add `universe = rownames(res)`.

### 4. Batch is in the sample sheet but not the design

- **Location:** `de_analysis.Rmd:29`
- **Source:** checklist — §7 Design questions
- **Evidence:** the sample sheet has a `batch` column with two levels, and the
  PCA at line 70 colours by condition only. The design is `~ condition`.
- **Suggested fix:** needs your decision — if both conditions are in both
  batches, use `~ batch + condition`; if not, batch is confounded and can't be
  corrected.

### 5. GSEA input filtered on `padj` instead of `stat`

- **Location:** `de_analysis.Rmd:150`
- **Source:** checklist — §6 Enrichment
- **Evidence:** `filter(!is.na(padj))` drops genes removed by independent
  filtering, which still have a valid `stat`, shrinking the ranked list.
- **Suggested fix:** `filter(!is.na(stat))`.

## Design and statistics questions

- Are the two batches balanced across conditions? (Decides finding 4.)
- Three replicates per group — is that the full experiment, or were samples
  excluded?

## Not checked

- Whether the sample orders actually mismatch — needs the featureCounts file
  and sample sheet loaded.
- Strandedness setting in the upstream featureCounts call — not in this script.
