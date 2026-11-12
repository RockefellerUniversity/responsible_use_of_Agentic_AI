#!/usr/bin/env python3
"""Look up a gene in NCBI Gene and print its identity as JSON.

Usage:  python3 scripts/ncbi_gene.py IKZF1 "Homo sapiens"
        python3 scripts/ncbi_gene.py Ikzf1 "Mus musculus"

Uses only the Python standard library and NCBI's public E-utilities API
(https://www.ncbi.nlm.nih.gov/books/NBK25501/). No API key needed for light use.
Exit codes: 0 found, 2 no match, 1 network or API error.
"""
import json
import sys
import time
import urllib.parse
import urllib.request

EUTILS = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
TIMEOUT = 30  # seconds; NCBI is usually fast, but can be slow at peak times


def get(endpoint, **params):
    params.update(retmode="json", tool="gene-summary-skill")
    url = EUTILS + endpoint + "?" + urllib.parse.urlencode(params)
    with urllib.request.urlopen(url, timeout=TIMEOUT) as r:
        return json.load(r)


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    symbol, organism = sys.argv[1], sys.argv[2]
    term = f"{symbol}[sym] AND {organism}[orgn] AND alive[prop]"
    try:
        ids = get("esearch.fcgi", db="gene", term=term)["esearchresult"]["idlist"]
        if not ids:
            print(f"No NCBI Gene record for symbol '{symbol}' in '{organism}'. "
                  "Check the spelling and organism, or try an alias.", file=sys.stderr)
            sys.exit(2)
        time.sleep(0.4)  # NCBI allows 3 requests/second without an API key
        summary = get("esummary.fcgi", db="gene", id=",".join(ids))["result"]
    except Exception as e:  # network, HTTP or unexpected JSON
        print(f"NCBI request failed: {e}", file=sys.stderr)
        sys.exit(1)

    genes = []
    for gid in summary["uids"]:
        g = summary[gid]
        genes.append({
            "ncbi_gene_id": gid,
            "symbol": g.get("name"),
            "full_name": g.get("description"),
            "aliases": g.get("otheraliases"),
            "organism": g.get("organism", {}).get("scientificname"),
            "chromosome": g.get("chromosome"),
            "location": g.get("maplocation"),
            "ncbi_summary": g.get("summary") or None,
            "url": f"https://www.ncbi.nlm.nih.gov/gene/{gid}",
        })
    print(json.dumps(genes, indent=2))  # more than one entry means: ask the user which


if __name__ == "__main__":
    main()
