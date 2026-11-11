---
name: gene-summary
description: Looks up a single gene in public databases (NCBI Gene, UniProt, PubMed) and writes a one-page Markdown summary from a fixed template, with every fact linked to its source. Use when the user asks to look up, summarise or "tell me about" a gene or protein, for example "what does Ikzf1 do?", "summarise IKZF1 in human", or "/gene-summary Ikzf1 mouse".
---

# Gene summary

Produce a short, sourced summary of one gene using `assets/gene_summary_template.md`.
The user is a biologist: use plain English and correct gene nomenclature
(human *IKZF1*, mouse *Ikzf1*, protein Ikaros).

## Inputs

- **Gene symbol** and **organism**. If the organism is missing or the symbol could
  match several genes, ask before searching. Don't guess.

## Steps

Copy this checklist into your reply and tick each step as you go:

- [ ] 1. Identity
- [ ] 2. Function and disease
- [ ] 3. Key papers
- [ ] 4. Fill the template
- [ ] 5. Check every source
- [ ] 6. Save and report

1. **Identity.** Run the script. Don't look the identifiers up from memory:

   ```bash
   python3 scripts/ncbi_gene.py <SYMBOL> "<Organism name>"
   ```

   - Exit 0: use the JSON (Gene ID, full name, aliases, location, NCBI summary).
     If it returns more than one gene, show them and ask which one.
   - Exit 2: no match. Tell the user and suggest checking spelling, organism or an alias.
   - Exit 1: NCBI could not be reached. Say so and stop; don't fill the identity from memory.

2. **Function and disease.** Search UniProt and PubMed as described in
   `references/sources.md`. Prefer review articles and recent primary papers.

3. **Key papers.** Choose 3 to 5 papers. Open each one (PubMed page or DOI) and
   check that the title, year and finding match what you write.

4. **Fill the template.** Copy `assets/gene_summary_template.md` and keep every heading,
   in order. If something wasn't found, write "Not found", never a guess.

5. **Check every source.** Every sentence of function, disease or finding needs a
   source tag: `[NCBI Gene]`, `[UniProt]`, `[PMID: 12345678]`, or
   `[Model knowledge, not verified]`. Remove or flag anything you can't source.
   If studies disagree, say so in "Conflicting or uncertain evidence".

6. **Save and report.** Save as `gene_summaries/<SYMBOL>_<organism>_<YYYY-MM-DD>.md`
   in the current project, then tell the user the file path and list what you could
   not check.

## Rules

- Never invent a reference, PMID or DOI. If you can't find a source, say so.
- Public databases only. Never send unpublished data, sample names or patient
  information to any website.
- Keep the summary to about one page. Link to sources rather than copying them.
