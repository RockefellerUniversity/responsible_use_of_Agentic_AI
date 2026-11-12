## %%{init: {"themeVariables": {"fontSize": "30px"}, "flowchart": {"padding": 30, "wrappingWidth": 500}}}%%
## flowchart LR
##   A["'Run initial QC on
## my scRNA-seq data'"] --> B["SKILL.md
## detect input format"]
##   B -->|".h5ad (AnnData)"| C["references/qc_scanpy.md
## scripts/qc_scanpy.py"]
##   B -->|"10x .h5 / mtx"| Q{"Ask user:
## R or Python?"}
##   B -->|".rds (Seurat)"| D["references/qc_seurat.md
## scripts/qc_seurat.R"]
##   Q -->|Python| C
##   Q -->|R| D
##   C --> G["QC report
## genes, counts, % mito"]
##   D --> G
## 
##   classDef skill fill:#fde3cc,stroke:#EB811B,color:#5a2d00
##   classDef ref fill:#e8daf7,stroke:#a97de0,color:#4a1e8a
##   classDef script fill:#d6e8fa,stroke:#7ab4e8,color:#1a3d6b
##   class B skill
##   class C,D ref

## # accessible to all projects on your system
## mkdir -p ~/.claude/skills/bioinformatics-skill
## 
## # accessible to only this project
## mkdir -p .claude/skills/bioinformatics-skill

## # add marketplace from any github repository
## claude plugin marketplace add <owner>/<repo> # e.g. anthropics/claude-plugins-official
## 
## # install plugin from that marketplace
## claude plugin install <plugin-name>@<marketplace-alias> # e.g. skill-creator@claude-plugins-official
## 
## # if in CLI (started with `claude` in terminal), use /plugin

## codex plugin marketplace add <owner>/<repo> # add marketplace
## codex plugin add <plugin-name>@<marketplace-alias> # install plugin from that marketplace

## # You may need to install Node.js (nodejs.org) to get npx
## npx skills find
## npx skills add <owner>/<repo>
