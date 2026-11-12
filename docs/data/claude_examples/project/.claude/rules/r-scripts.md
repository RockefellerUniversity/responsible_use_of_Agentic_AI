---
paths:
  - "scripts/**/*.R"
---

# R script rules (load only when Claude reads or edits a script)

- Read inputs from `data/`; write outputs to `data/processed/`. Never write into `data/raw/`.
- Set a random seed at the top of any script that samples or permutes.
- Add a comment above each block saying what it does, in plain English.
- End with `sessionInfo()` so package versions are recorded.
