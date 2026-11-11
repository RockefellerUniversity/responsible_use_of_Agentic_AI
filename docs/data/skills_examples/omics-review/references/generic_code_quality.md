# Generic code-quality checklist

Applies to every review, whatever the assay. These are failure modes that
don't usually throw an error — they produce a wrong but plausible-looking
result, which is why they're worth checking for deliberately.

## Contents
1. Sample/metadata alignment
2. Joins and merges
3. NA handling and type coercion
4. Gene/protein ID mapping
5. Hardcoded values
6. Reproducibility
7. Paths and file handling
8. Copy-paste and template drift
9. Multiple-testing consistency
10. Python-specific pitfalls

## 1. Sample/metadata alignment

- **Counts columns and metadata rows must be in the same order.** Many tools
  (DESeq2, limma, edgeR) match by position, not by name. Look for an explicit
  check such as `stopifnot(identical(colnames(counts), rownames(coldata)))` or
  a reorder with `match()`. Its absence is worth flagging even if the order
  happens to be right today.
- **Sample names that differ subtly** (`Sample-1` vs `Sample.1` after
  `read.csv(check.names = TRUE)`, trailing whitespace, case) break joins
  silently.

## 2. Joins and merges

- After any join, check: row count as expected, no unexpected NAs, and
  ideally one value spot-checked against the source. `left_join` with a
  duplicated key multiplies rows; a key mismatch fills NAs without complaint.
- Seurat `AddMetaData` and pandas `.join` on `.obs` both produce silent NAs
  on a barcode mismatch.

## 3. NA handling and type coercion

- `==`, `&`, `|` against `NA` return `NA`; `filter()` then drops those rows,
  base `[` subsetting keeps them as NA rows. Use `is.na()` explicitly.
- `mean()`/`sum()` without `na.rm` return NA; with `na.rm = TRUE` they hide
  missingness that might matter. Either way it should be a deliberate choice.
- Factor vs character vs numeric comparisons can evaluate `FALSE` for every
  row instead of erroring. Check both sides of consequential comparisons.
- **Spreadsheet corruption:** gene symbols like `SEPT1`, `MARCH1`, `DEC1`
  turned into dates by Excel; sample IDs with leading zeros read as numbers.

## 4. Gene/protein ID mapping

- `AnnotationDbi::select()` can return several rows per key; a later
  `!duplicated()` keeps an arbitrary one. Prefer
  `mapIds(..., multiVals = "first")` or handle one-to-many explicitly.
- Dropping unmapped IDs (`filter(!is.na(symbol))`) silently removes genes
  without symbols — often lncRNAs and novel genes. Check how many are lost.
- Annotation release and genome build should match the alignment reference.

## 5. Hardcoded values

- Column indices (`df[, 3:8]`) break silently when an upstream column is
  added. Prefer names.
- Row-count assumptions (`rep("rest", nrow(df) - 10)`) fail when a table is
  smaller than expected.
- Thresholds defined inline in several places can drift apart; prefer one
  definition near the top.

## 6. Reproducibility

- Every stochastic step needs a seed: UMAP, Leiden/Louvain, t-SNE, k-means,
  imputation, permutation tests, train/test splits.
- `set.seed()` in R does not seed Python code run through `reticulate`.
  In Python, `np.random.seed()` does not seed scanpy, torch, or UMAP — each
  takes its own seed or `random_state`.
- Record package versions (`sessionInfo()`, `pip freeze`); results from
  clustering and normalization methods change between releases.

## 7. Paths and file handling

- Relative paths depend on the working directory at run time, which differs
  between knitting, `Rscript`, Jupyter and schedulers. Prefer one base path
  variable defined at the top.
- `dir.create(path, "subdir")` does not create `path/subdir` — the second
  argument is `showWarnings`. Use `file.path()`.
- Outputs written to a fixed filename get silently overwritten by the next
  run or the next comparison in a loop.

## 8. Copy-paste and template drift

- When scripts are cloned per sample or per comparison, fixes land in one
  copy and not the others. If sibling files exist, diff them.
- Copied code carries the previous project's hardcoded group names, gene
  lists, or thresholds deep inside the file — grep for them.
- Helper functions copied into a shared chunk accumulate dead code.

## 9. Multiple-testing consistency

- If a script runs several families of tests (DE, enrichment, composition),
  check that correction is applied consistently. A prose caveat ("p-values
  may be inflated") is not a substitute for correcting if a sibling analysis
  does correct.
- If two thresholds are reported (padj < 0.05 and < 0.1), the looser one
  should be labelled exploratory.

## 10. Python-specific pitfalls

- Mutable default arguments (`def f(x=[])`) persist across calls.
- Chained indexing (`df[df.a > 0]["b"] = 1`) can write to a copy; use
  `.loc[mask, "b"] = 1`.
- `np.nan == np.nan` is `False`, so equality masks silently exclude NaN rows.
- Notebooks run out of order leave stale variables that a top-to-bottom read
  won't reveal.
