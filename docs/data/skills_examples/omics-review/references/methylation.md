# DNA methylation checklist (arrays and bisulfite sequencing)

Two very different data types share this file. Section 1 covers Illumina
arrays (450K/EPIC); section 2 covers bisulfite and enzymatic sequencing
(WGBS, RRBS, EM-seq). Sections 3–4 apply to both.

## Contents
1. Arrays (minfi, sesame, ChAMP)
2. Bisulfite sequencing (bismark, methylKit, DSS, dmrseq)
3. Statistics and interpretation
4. Design questions to raise

## 1. Arrays

- **Probe filtering:** remove failed probes (detection p-value), probes
  overlapping SNPs, known cross-reactive probes, and — unless sex is the
  question — sex-chromosome probes. Check the cross-reactive list matches the
  array version (450K vs EPIC vs EPICv2).
- **Sample QC:** detection p-value failure rate per sample, predicted sex vs
  recorded sex (catches swaps), bisulfite conversion controls.
- **Normalization** (Noob, funnorm, SWAN, BMIQ) should be stated; funnorm
  suits global differences between groups less well than within-sample
  methods.
- **Beta vs M-values:** M-values for statistical testing (better variance
  properties), beta values for reporting effect sizes. Testing on betas with
  limma at small n is a common mistake.
- **Array position and slide batch** are strong technical effects; check
  whether condition is confounded with slide.
- **Cell-type composition:** in blood or other mixed tissues, differences in
  cell proportions look like methylation changes. Look for estimation
  (`estimateCellCounts2`, EpiDISH) and adjustment, or a reason it isn't needed.

## 2. Bisulfite sequencing

- **Coverage filtering:** CpGs with very low coverage give extreme
  methylation estimates (0% or 100% from one read). Look for a minimum
  coverage, and an upper cap to drop PCR artifacts.
- **Strand merging:** CpG methylation is usually symmetric; merging the two
  strands' counts increases coverage. It should be a stated choice.
- **C-to-T SNPs** look like unmethylated cytosines; filter known SNP
  positions for the population studied.
- **M-bias:** bias at read ends should be checked (bismark M-bias plots) and
  ends trimmed or ignored accordingly.
- **Conversion rate** (from lambda spike-in or non-CpG context in mammals)
  should be reported; low conversion inflates methylation.
- **Methods that use counts** (DSS, dmrseq, methylKit with overdispersion)
  are preferable to tests on percentages that ignore coverage.

## 3. Statistics and interpretation

- **DMRs vs DMPs:** region-level calling (DMRcate, dmrseq, bumphunter)
  reduces multiple testing and is more robust; DMR boundaries depend on
  smoothing parameters, which should be stated.
- **Effect size thresholds:** tiny significant differences (Δβ < 0.05) in
  large cohorts may be technically real but biologically doubtful — report
  Δβ alongside p.
- **Gene-set enrichment** of differentially methylated CpGs is biased by the
  number of probes per gene; use `missMethyl::gometh` or similar, not
  standard ORA.
- **Genome build** of annotation must match alignment (bisulfite genomes are
  built from a specific reference).

## 4. Design questions to raise

- Is tissue/cell-type heterogeneity accounted for?
- Are age and sex (strong methylation effects) in the model?
- Is the comparison confounded with array slide or sequencing batch?
- For causal language ("methylation silences X"), is there expression data
  to support it?
