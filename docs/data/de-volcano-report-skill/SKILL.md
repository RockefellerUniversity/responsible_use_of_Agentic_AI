---
name: de-volcano-report-skill
description: Build a Quarto (.qmd) differential-expression report from a DESeq2 results table — a labelled volcano plot (up = green, down = purple, top genes in white label boxes), a table of up/down gene counts, and an interactive DT table of all results. Use this whenever Douglas has a DESeq2 / DGE results CSV (e.g. "*_DGEanalysis*.csv", "X_minus_Y" contrasts, files with log2FoldChange and padj columns) and wants a volcano plot, a DE report, a DE summary Rmd or qmd, or "a plot and table of my DE results" — even if he only says "make a volcano plot for this" or "turn this DESeq2 output into a report".
---

# DE volcano report

Produces one Quarto `.qmd` per DESeq2 results table by filling the settings of a bundled template.
The template already encodes the house style Douglas settled on, so the job here is mostly
mapping the input's columns and contrast into the template's `settings` chunk — plain R
variables, not YAML `params:`, so the qmd can be run line by line — not rewriting plotting code.

Template: `assets/volcano_report_template.qmd` (relative to this skill's directory).

## Defaults the template encodes

- Axes: log2FC (x) vs |stat| (y, the DESeq2 Wald statistic). Significance colouring is still
  `padj < 0.05` and `|log2FC| >= 1` (2-fold); dashed lines mark only the log2FC cutoffs (a padj
  cutoff has no fixed |stat| position); the subtitle states both cutoffs.
- Colours: up `#008300` (green), down `#6250d6` (purple), not significant `#c3c2b7` (grey).
- Labels: top 5 genes by |stat| on *each* side (so up to 10), white `geom_label_repel` boxes; falls
  back to `geom_label` if ggrepel isn't installed.
- Genes with NA padj are dropped — DESeq2 filtered them, so they aren't "not significant",
  they're untested.
- Code is folded (`code-fold: true`); readers click "Code" to expand any chunk. The HTML is
  self-contained (`embed-resources: true`), so it can be shared as a single file.
- Each fold button has a short label via `#| code-summary:` (e.g. "Code - Define parameters").
  If you add a chunk, give it one too.
- Under the title: "Project: <project_name>", the render date, and "Lab: Bioinformatics Resource
  Center". These are a `.lead` div after the settings chunk, not YAML, because YAML can't see
  `project_name`.
- The volcano is also saved as `<csv_stem>_volcano.pdf` beside the qmd (8 × 6 in, via
  `cairo_pdf` so the ≥ in the subtitle renders). Re-rendering overwrites that PDF.
- Only sections with a plot or table get a heading: genes by direction (counts coloured to match
  the plot, with % of tested and a total row) → volcano → interactive DT table of all tested genes
  (search, per-column filters, copy/CSV/Excel buttons; falls back to a static top-50 `kable` if DT
  isn't installed) → session info (`sessionInfo()`; the one heading kept without a plot or
  table). Settings, loading and prep are heading-less chunks.

If the user asks for different cutoffs, colours, or label counts, change the corresponding
variable in the `settings` chunk rather than editing the code.

## Steps

1. **Inspect the table header.** Read only the first ~5 lines of the CSV — enough to see column
   names and value formats. These can be sensitive genomics data, so don't load or print more
   than needed.

2. **Map columns to the template settings.** The template renames columns internally, so set:
   - `id_col` — gene identifier (e.g. `ID`, `gene_id`, `ensembl`, or the unnamed first column
     `...1` that `read_csv` creates when DESeq2 results were written with row names). Required.
   - `lfc_col` (`log2FoldChange`), `stat_col` (`stat`) and `padj_col` (`padj`) — required. If any
     can't be found confidently, ask rather than guess; the whole report depends on them.
   - `symbol_col`, `basemean_col`, `lfcse_col`, `pvalue_col` — optional; set to `""` if absent.
     Without a symbol column, labels fall back to the ID.

3. **Work out the contrast.** `numerator` is the group whose increase gives positive log2FC.
   BRC filenames follow `<numerator>_minus_<denominator>_DGEanalysis...csv` — e.g.
   `p53_null_minus_p53_WT_...` → numerator `p53 null`, denominator `p53 WT` (underscores to spaces
   reads better in plot text). If the filename doesn't make the direction clear, ask: getting it
   backwards silently flips every "up" and "down" in the report.
   Also ask for the project name (`project_name`). If none is given, leave the `PROJECT_NAME`
   placeholder and say so in the report-back, since it prints in the report.

4. **Write the qmd** next to the CSV as `<csv_stem>_volcano_report.qmd`, copying the template and
   filling only the `settings` chunk and the YAML `title` (`de_file` is the CSV's basename, since
   the qmd sits beside it; the title is literal text, since YAML can't see chunk variables — write
   it as "Differential expression: <numerator> vs <denominator>"). Douglas's rules: creating a new file is fine when asked; if that filename already exists,
   show a diff and get approval before overwriting. Never modify the CSV.

5. **Don't render automatically.** Rendering is a shell command, which needs his approval in these
   projects. Offer to render, or give him the command: `quarto render <qmd>` (or the Render
   button in RStudio).

6. **Report back briefly:** the file path, the column mapping and contrast you chose (so he can
   catch a wrong guess), any non-default settings, and the PDF name the render will write. Mention
   ggrepel / DT only as optional packages the report falls back without — never install them.

## Notes

- One report per contrast. For several CSVs, write one qmd each with the same steps.
- Extra BRC columns such as `label_pt` / `label_pt_goi` (pre-flagged genes) are ignored by
  default. If the user wants those genes labelled instead of the top hits, replace the
  `top_genes` step with `filter(de_plot, <that column>)` — and keep it in the `de_std` select by
  adding it to `col_map`.
