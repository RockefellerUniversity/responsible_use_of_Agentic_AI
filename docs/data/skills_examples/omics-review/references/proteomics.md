# Proteomics checklist (mass-spec and Olink)

There's no single dominant Python package here; Python pipelines are usually
pandas + `sklearn.impute` + `statsmodels`. The statistical concerns below
apply whatever library implements them.

## Contents
1. Input data and filtering
2. Missing values and imputation
3. Normalization and batch
4. Statistical testing
5. Olink-specific points
6. Design questions to raise

## 1. Input data and filtering

- **Know what the intensity is:** LFQ, iBAQ, raw intensity, TMT reporter
  ion, DIA precursor quantity. They aren't interchangeable, and some are
  already normalized.
- **Log-transform** (usually log2) before limma or t-tests; check it's done
  exactly once.
- **Remove contaminants, reverse/decoy hits, and "only identified by site"**
  rows from MaxQuant-style output.
- **Protein groups** can map to several genes (`"GENE1;GENE2"`). Splitting,
  taking the first, or keeping the group string should be deliberate.
- **Duplicated gene symbols** across protein groups need a defined order:
  make unique before imputation, aggregate after, not before.

## 2. Missing values and imputation

- **Missingness mechanism decides the method.** Abundance-dependent
  missingness (low-abundance proteins drop out — MNAR) suits left-censored
  methods (MinProb, QRILC, down-shifted normal). Random missingness (MAR)
  suits KNN or similar. Look for a diagnostic (e.g. `DEP::plot_detect()`,
  intensity distributions of proteins with vs without missing values)
  before the choice.
- `sklearn`'s `KNNImputer`/`IterativeImputer` are MAR-oriented — using them
  by default on MNAR data biases low-abundance proteins upward.
- **Filter by group, not globally:** requiring valid values in ≥ k samples of
  at least one group keeps proteins present only in one condition. A global
  % missing cutoff throws these away.
- Imputed values inflate certainty: report how many values were imputed per
  protein, and consider flagging hits driven by imputation.

## 3. Normalization and batch

- Median centering or quantile normalization should be stated; check it's
  applied once and before imputation if the method assumes that.
- **TMT multi-plex designs** need between-plex normalization (bridge/
  reference channel, IRS) — comparing across plexes without it is mostly
  batch effect.
- `limma::removeBatchEffect()` is for visualization only; model batch in the
  design for testing.

## 4. Statistical testing

- **Moderated statistics** (limma) are preferable to per-protein t-tests at
  small n.
- **Repeated measures** (same subject over time) need the subject modelled —
  `duplicateCorrelation()` + `block =` in limma, or a mixed model — not
  independent samples.
- Two thresholds (padj < 0.05 and < 0.1) need the looser one labelled
  exploratory.
- **Cross-platform comparisons** (MS vs Olink) should compare standardized
  statistics (t), not raw fold changes, because dynamic ranges differ.

## 5. Olink-specific points

- **NPX is already log2-scaled** — don't log-transform again.
- Values below LOD: keep, set to LOD, or exclude — a stated choice. Assays
  with most samples below LOD are unreliable.
- **Plate effects** need bridging samples or plate in the model when samples
  span plates.
- Check QC/assay warning flags from the NPX file are used.

## 6. Design questions to raise

- How many biological replicates, and was sample processing order
  randomized relative to condition?
- Plasma/serum: was haemolysis or depletion checked? Highly abundant
  proteins can dominate.
- Are protein-level conclusions reported at the gene level when several
  isoforms/groups map to the same gene?
