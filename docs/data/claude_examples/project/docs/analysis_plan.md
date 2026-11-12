# Analysis plan (long: pointed to, not imported)

CLAUDE.md only *mentions* this file, so it costs no context until Claude opens it.

## Question
Does loss of Ikzf1 de-repress proliferation and self-renewal genes in pre-B cells?

## Steps
1. QC: reads in genes, alignment rate, PCA coloured by genotype and run (`01_qc.R`).
2. Counts: featureCounts against GENCODE M36 (`02_counts.R`).
3. Differential expression: DESeq2, `~ run + genotype` (`03_de.R`).
4. Gene set enrichment: Hallmark and published IKZF1-deletion signatures.
5. Figure 2: volcano plot, heatmap of top 50 genes, enrichment dot plot.

## Checks before anything goes in the grant
- Re-run from raw counts on a clean checkout; numbers must match.
- Compare our top genes with published IKZF1-deleted B-ALL signatures.
- My PI reviews every figure and the methods text.

## Out of scope
- Single-cell data, T-ALL, human patient samples.
