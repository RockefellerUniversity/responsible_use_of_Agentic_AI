# Bulk RNA-seq checklist (DESeq2 / edgeR / limma-voom)

Python equivalents: `pydeseq2` ports DESeq2's model, so the same issues apply;
`gseapy` covers enrichment.

## Contents
1. Input data
2. Design and contrasts
3. Filtering and normalization
4. Results and thresholds
5. Sample-level QC
6. Enrichment (ORA and GSEA)
7. Design questions to raise

## 1. Input data

- **DESeq2 and edgeR need raw integer counts**, not TPM, FPKM, CPM or
  already-normalized values. Feeding normalized values breaks the
  mean–variance model even if it runs.
- **Salmon/kallisto via tximport:** use `DESeqDataSetFromTximport()` (or
  edgeR's offset approach) so transcript-length offsets are kept. Rounding
  `txi$counts` into `DESeqDataSetFromMatrix()` drops them.
- **Sample order:** count columns and colData rows must match — see
  `generic_code_quality.md` §1.
- **Strandedness:** featureCounts/HTSeq strand setting must match the library
  prep; the wrong setting loses most reads or counts antisense signal.

## 2. Design and contrasts

- **Reference level:** factors default to alphabetical order. Look for an
  explicit `relevel()` or `factor(levels = ...)` so log2 fold changes point
  the intended way.
- **Design columns must be factors**, not character or numeric codes —
  `batch = 1, 2, 3` as numeric fits a linear trend, not a batch effect.
- **Contrast naming:** `results(dds, name = "...")` strings break silently
  when levels change. Check against `resultsNames(dds)` or use
  `contrast = c("condition", "treated", "control")`.
- **Interaction terms:** with `~ genotype + treatment + genotype:treatment`,
  the main `treatment` coefficient is the effect in the reference genotype
  only. Check the reported comparison matches what the text claims.
- **Paired designs** (same donor/animal across conditions) need the pairing
  variable in the design, e.g. `~ donor + condition`.
- **Full confounding** (all controls in batch 1, all treated in batch 2)
  cannot be fixed statistically. Flag it as High severity.

## 3. Filtering and normalization

- Pre-filtering low-count genes is fine and speeds things up; DESeq2's
  independent filtering handles the rest.
- `vst()`/`rlog()` are for visualization and clustering, not for DE input.
  `blind = TRUE` is right for unbiased QC; `blind = FALSE` when the design
  effects are expected to be large.
- `limma::removeBatchEffect()` is for plots only. Testing on a
  batch-corrected matrix understates variance — put batch in the design.
- `DESeq()`/`vst()` can fail on tiny or sparse subsets with a `locfit`
  "out of vertex space" error; `fitType = "mean"` on that specific call is
  the usual fix. `vst()` has its own `fitType`, separate from `DESeq()`'s.

## 4. Results and thresholds

- **`alpha` in `results()`** should match the padj cutoff used downstream —
  it tunes independent filtering for that threshold.
- **Filtering on |log2FC| after the test** is not the same as testing against
  a threshold. If a fold-change cutoff matters, use `lfcThreshold`.
- **`lfcShrink()`** (apeglm/ashr) is for ranking and plotting effect sizes;
  it does not change p-values. apeglm needs `coef`, not `contrast`.
- **padj is NA** both for genes removed by independent filtering (which still
  have a valid `stat`) and for all-zero genes. Don't treat NA as "not
  significant" when counting, and don't drop NA-padj genes from GSEA input.
- **Cook's distance outliers** set p-values to NA in small designs; check
  whether a single sample drives many of them.

## 5. Sample-level QC

- Look for a PCA or sample-distance heatmap before DE. Outliers or a
  batch-driven PC1 change the analysis plan.
- **Sample swaps:** sex genes (`XIST`, `RPS4Y1`, `DDX3Y`) are a cheap check
  against the metadata.
- Library size and % reads assigned per sample should be reported; a sample
  with far fewer assigned reads is a candidate for exclusion.

## 6. Enrichment (ORA and GSEA)

- **Over-representation needs an explicit `universe`** — the genes actually
  tested, not the default of every gene in the database. A missing universe
  inflates significance. (`gseapy`: `background=`.)
- **`enrichGO()`/`gseGO()` default to `keyType = "ENTREZID"`.** With Ensembl
  rownames, set `keyType = "ENSEMBL"`, or IDs silently fail to match and
  results come back nearly empty.
- **GSEA ranking:** rank all tested genes by `stat` (or a signed p-value
  metric), not only significant genes. Filter on `!is.na(stat)`, not
  `!is.na(padj)`.
- **p = 0 rows** turn `-log10(p)` into `Inf`; check how they're handled.
- **Duplicated genes after ID mapping** produce ties or errors in the
  ranked list.

## 7. Design questions to raise

- Is the comparison confounded with batch, sex, RIN, lane, or collection
  date? Are those in the design?
- How many biological replicates per group? With n = 2, results are fragile;
  with n = 1, DESeq2 can't estimate dispersion properly — label as
  exploratory.
- Are technical replicates collapsed (`collapseReplicates()`) rather than
  treated as biological replicates?
- Is the reported fold-change direction stated in plain words in the text
  ("up in treated vs control")?
