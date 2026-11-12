---
name: project-second-run
description: Samples 7-12 came from a second sequencing run and cluster apart on PCA
metadata:
  type: project
---

Samples 7-12 were sequenced on a second run (delivered 2026-10-14) and separate from
samples 1-6 on PC2 of the PCA.

**Why:** Seen in the first QC report; recorded as a decision in `docs/decisions.md`.

**How to apply:** Colour QC plots by run as well as genotype, and keep `run` in the
DE design. Don't call a PC2 split "biology" without checking run first.
