# Chromatin assays checklist (ATAC-seq, ChIP-seq, CUT&RUN / CUT&Tag)

Peak callers and coverage tools are CLI programs called the same way from R,
Python, Snakemake or shell, so this checklist applies whatever the wrapper
language.

## Contents
1. Alignment and read filtering
2. Library QC
3. Controls and normalization
4. Peak calling
5. Consensus peaks and differential binding
6. Annotation and downstream analysis
7. Design questions to raise

## 1. Alignment and read filtering

- **Genome build and chromosome naming** must be consistent across alignment,
  peaks, blacklist, annotation (TxDb/GTF) and motif databases — `hg19` vs
  `hg38`, `chr1` vs `1`. Mismatches give silently empty overlaps.
- **Blacklist filtering** (ENCODE blacklist for the right build) should be
  applied to peaks or reads; blacklist regions produce strong artifactual
  peaks.
- **Duplicates:** typically removed for ATAC and ChIP; for low-input
  CUT&RUN/CUT&Tag, high duplication is expected and removal is a judgment
  call — it should be a stated choice.
- **ATAC mitochondrial reads** should be removed before calling peaks and
  their fraction reported.
- **MAPQ filtering** for multi-mappers should be explicit (e.g. `-q 30`).

## 2. Library QC

- **FRiP** (fraction of reads in peaks) per sample — a low outlier suggests
  a failed library.
- **ATAC:** TSS enrichment score and fragment-size distribution with
  nucleosome periodicity.
- **ChIP:** fingerprint plots or cross-correlation (NSC/RSC).
- Replicate concordance (correlation of coverage, peak overlap) should be
  shown before merging or comparing.

## 3. Controls and normalization

- **ChIP needs an input control** used in peak calling; CUT&RUN/CUT&Tag
  typically uses IgG. Check that the control is actually passed to the
  caller (`-c` in MACS, the control track in SEACR).
- **Spike-in normalization** (E. coli carry-over or exogenous chromatin):
  if the protocol used a spike-in, normalization factors should come from
  spike-in counts. CPM normalization hides global changes, e.g. after
  knocking down the targeted histone modifier.
- Bigwig tracks compared side by side should use the same normalization.

## 4. Peak calling

- **Match the caller to the signal:** narrow peaks for TFs, broad mode for
  marks like H3K27me3/H3K36me3/H3K9me3.
- **ATAC with MACS:** `--nomodel --shift -100 --extsize 200` (or BAMPE for
  paired-end); the default model-building step is designed for ChIP.
- **Replicates:** use IDR or a reproducibility rule (peak in ≥ 2 replicates)
  rather than calling on one replicate or a pooled file only.
- Thresholds (q-value, SEACR stringent vs relaxed) should be stated and
  justified.

## 5. Consensus peaks and differential binding

- **Comparing independently called peak sets by overlap is not a
  differential test.** Peaks "unique to condition A" often just fall below
  threshold in B. Use a consensus peak set, count reads in it for every
  sample, then test (DiffBind, csaw, DESeq2/edgeR).
- **Normalization in differential binding matters:** library-size vs
  RLE/TMM within peaks assume different things about global changes. DiffBind
  defaults changed between versions — check which is used.
- Replicates are required for a statistical test; pooled tracks are
  descriptive only.

## 6. Annotation and downstream analysis

- Nearest-gene assignment (ChIPseeker, HOMER annotatePeaks) is a heuristic;
  distal peaks may regulate genes far away. Gene-level claims should be
  worded accordingly.
- Annotation TxDb/GTF must match the genome build.
- **Motif enrichment needs an appropriate background** — GC-matched, or the
  consensus set rather than the whole genome — or GC-rich motifs dominate.
- Enrichment of genes near peaks needs a universe that reflects peak
  detectability (e.g. GREAT-style region-based methods).

## 7. Design questions to raise

- How many biological replicates per condition, and were conditions
  processed together?
- Is the antibody validated for this application (CUT&Tag vs ChIP grade)?
- If global levels of the mark are expected to change, is the normalization
  able to see that?
