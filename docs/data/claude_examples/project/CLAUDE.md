# Project: Ikzf1 in B-cell ALL (bulk RNA-seq)

Does losing Ikzf1 in mouse pre-B cells switch on a stem-like, therapy-resistant
expression programme? Results feed Figure 2 of an R01 resubmission.

## Decisions so far (always read)

@docs/decisions.md

## Where things are

- `data/raw/`: FASTQ files and the sample sheet from the sequencing core. **Read-only.**
- `data/processed/`: counts and DESeq2 objects made by our scripts. Can be regenerated.
- `scripts/`: R scripts, numbered in run order (`01_qc.R`, `02_counts.R`, `03_de.R`).
- `reports/`: Quarto reports, one per analysis step, rendered to HTML.
- `docs/analysis_plan.md`: the full plan and design. Read it before planning any new analysis step.

## Conventions

- **Git:** small commits with a one-line message saying *why*. Never commit anything under `data/`.
- **Docker:** run R inside the project image: `docker run --rm -v "$PWD":/work brc/rnaseq:4.5 Rscript scripts/<script>`.
- **Reporting:** every analysis step gets its own report in `reports/`. Figures go in the report, not loose PNGs.

## Software

- R 4.5 with DESeq2, edgeR, ggplot2, Quarto.
- Gene annotation: GENCODE mouse M36 (mm39). Don't mix with other annotations.
- BRC tools: the `brcshiny-db` MCP server holds our DE results and IGV sessions.

## Output formats

- Tables: CSV with gene ID, gene symbol, log2 fold change, adjusted p-value.
- Figures: PDF for the grant, PNG for reports. Colour-blind safe palettes.
- Significance: adjusted p < 0.05 **and** |log2FC| > 1, unless the plan says otherwise.
