# Decisions (short: imported into every session)

- 2026-10-02: Compare Ikzf1 knockout vs wild-type pre-B cells; 6 vs 6 mice.
- 2026-10-20: Samples 7-12 were sequenced on a second run, so include `run` as a covariate.
- 2026-10-28: Sample KO_04 fails QC (12% reads in genes); excluded. Keep it in the sample sheet, marked `exclude = TRUE`.
- 2026-11-03: Use DESeq2 with `~ run + genotype`, not edgeR, to match the 2024 paper.
