---
paths:
  - "reports/**/*.qmd"
---

# Report rules (load only when Claude reads or edits a report)

- Start each report with: question, input files, date, and the git commit it was run from.
- Explain every plot in one plain-English sentence underneath it.
- Show sample numbers per group, and list excluded samples with the reason.
- End with "What this does not show": the limits of this step.
