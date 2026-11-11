# Single-cell RNA-seq checklist (Seurat / Bioconductor / scanpy)

Written with Seurat names first; scanpy and Bioconductor equivalents are given
inline. The underlying problems are the same in every toolkit.

## Contents
1. Cell QC
2. Ambient RNA and doublets
3. Normalization and integration
4. Clustering
5. Annotation
6. Differential expression between conditions
7. Composition
8. Trajectories and velocity
9. Design questions to raise

## 1. Cell QC

- **Thresholds should be per sample or data-driven** (e.g. MAD-based with
  `scater::isOutlier`), not one fixed cutoff copied from a tutorial. Samples
  differ in depth and quality.
- **Mitochondrial % is tissue-dependent.** Neurons and single-nucleus data
  call for strict cutoffs; heart, muscle and kidney can legitimately exceed
  10–20%. A copied `percent.mt < 5` should be questioned.
- **Mito gene pattern must match species**: `^MT-` (human) vs `^mt-` (mouse).
  The wrong one gives 0% for every cell — check the QC plot isn't flat.
- Look for QC plots before and after filtering, and cell counts per sample
  at each step.

## 2. Ambient RNA and doublets

- Ambient RNA (SoupX, CellBender, DecontX) matters most for tissues with a
  few very highly expressed genes; markers from abundant cell types appear in
  every cluster without it.
- **Run doublet detection per sample, before merging** (scDblFinder,
  scrublet, DoubletFinder). Doublets form between cells captured together,
  so merged-object detection is wrong.
- Doublet callers are stochastic; check for a seed and that detection isn't
  re-run in a way that changes calls already reported.

## 3. Normalization and integration

- Normalization method should be consistent: mixing SCTransform and
  LogNormalize objects before integration causes trouble.
- **Integrated/batch-corrected values are for clustering and embedding only.**
  DE and marker finding should use the uncorrected RNA assay
  (`DefaultAssay(obj) <- "RNA"`; scanpy: raw counts layer, not `X_scVI`).
- **Seurat v5 layers:** after merging, `JoinLayers()` is needed before DE on
  the RNA assay.
- **Over-integration:** if condition is fully confounded with batch,
  integration can erase the biology. Check what was integrated over.

## 4. Clustering

- Resolution should be justified (clustree sweep, marker distinctness,
  expected cell types), not just picked.
- **Reference the explicit resolution column** (`RNA_snn_res.0.5`) rather
  than `seurat_clusters`/`Idents()`, which reflect whichever resolution ran
  last. scanpy: use distinct `key_added` values.
- Number of PCs should be checked against an elbow plot or variance
  explained, not hardcoded from another dataset.
- UMAP is a visualization. Distances and cluster sizes on it are not
  quantitative evidence.

## 5. Annotation

- Reference atlases should match the tissue, species, and developmental
  stage of the query.
- Per-cluster majority labels should report purity — a 45% majority is a
  very different claim from 95%.
- Marker-based annotation should show the markers (dot plot), not just
  assert labels.

## 6. Differential expression between conditions

- **Cell-level tests across conditions are pseudoreplicated.**
  `FindMarkers(ident.1 = "treated", ident.2 = "control")` treats thousands of
  cells as independent replicates, giving tiny p-values driven by sample
  effects. Use **pseudobulk**: aggregate counts per sample × cell type, then
  DESeq2/edgeR/limma with samples as replicates. (`AggregateExpression()`,
  `scuttle::aggregateAcrossCells`, `decoupler.get_pseudobulk`.)
- Marker finding between clusters within a sample is fine with
  `FindAllMarkers`; just don't present those p-values as calibrated.
- One sample per condition means no valid between-condition test at all —
  results are descriptive.

## 7. Composition

- Proportion changes need sample-level methods (`speckle::propeller`,
  `scCODA`, `miloR`), not a chi-square or Fisher test on pooled cell counts,
  which treats cells as independent.
- Compositional data are coupled: one population expanding makes others look
  depleted.

## 8. Trajectories and velocity

- MST-based trajectories (Slingshot, Monocle) will connect clusters even
  across empty space. Check the path runs through populated regions.
- Pseudotime has no inherent direction; the root must come from external
  evidence.
- RNA velocity needs spliced/unspliced counts from the same barcodes —
  velocyto barcodes use a different format from Cell Ranger and must be
  reconciled. Velocity can't model jumps between disconnected populations.

## 9. Design questions to raise

- How many biological samples per condition? (Cells are not replicates.)
- Were conditions processed in the same batch/run, or confounded with it?
- Is the cell-cycle or stress signature regressed out, and is that
  appropriate for the biological question?
