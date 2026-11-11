## flowchart LR
##   R[("Your code<br/>and data")] --> C["<b>Checks</b><br/>13 rules, no AI<br/>e.g. Excel-mangled<br/>gene names"]
##   R --> M["<b>Two AI reviewers</b><br/>different model families<br/>read every file"]
##   M --> D["<b>Documentation check</b><br/>each claim checked against<br/>the package's own docs"]
##   C --> P["<b>Report</b><br/>file, lines, why it<br/>matters, the fix"]
##   D --> P
