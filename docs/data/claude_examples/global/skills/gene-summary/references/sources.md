# Sources for gene summaries

Use these public sources, in this order. All are free and need no login.

| What | Source | How to search |
|---|---|---|
| Identity (ID, name, aliases, location) | NCBI Gene | Run `scripts/ncbi_gene.py`; record page: `https://www.ncbi.nlm.nih.gov/gene/<id>` |
| Protein function, domains, disease notes | UniProt | `https://rest.uniprot.org/uniprotkb/search?query=gene_exact:<SYMBOL>+AND+organism_id:<taxon>+AND+reviewed:true&format=json` |
| Papers | PubMed | `https://pubmed.ncbi.nlm.nih.gov/?term=<SYMBOL>[tiab]+AND+review[pt]` for reviews; add a topic, e.g. `+AND+leukemia[tiab]` |
| Ensembl gene ID and coordinates | Ensembl REST | `https://rest.ensembl.org/lookup/symbol/<species>/<SYMBOL>?content-type=application/json` (species e.g. `homo_sapiens`, `mus_musculus`) |

Common taxon IDs for UniProt: human `9606`, mouse `10090`, rat `10116`, zebrafish `7955`.

## Citing

- Link papers to PubMed (`https://pubmed.ncbi.nlm.nih.gov/<PMID>/`) or to the DOI
  (`https://doi.org/<DOI>`).
- Use UniProt **reviewed** (Swiss-Prot) entries for function statements. Unreviewed
  (TrEMBL) entries are computer-annotated.
- NCBI's "Summary" text comes from RefSeq curators: tag it `[NCBI Gene]`.

## Watch out for

- **Aliases shared between genes.** For example, "Ikaros" is a protein name, not a
  symbol. Always confirm with the NCBI Gene ID.
- **Human vs mouse.** Findings in one organism don't automatically apply to the other.
  Say which organism each finding comes from.
- **Retracted papers.** PubMed marks them "Retracted Publication". Don't cite them as evidence.
