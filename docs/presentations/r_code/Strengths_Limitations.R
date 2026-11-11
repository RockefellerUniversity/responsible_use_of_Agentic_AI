## flowchart LR
##   subgraph CHECK ["All three must be true"]
##     direction LR
##     A["<b>Known task</b><br/>looks like text it has seen before"]
##     B["<b>All context provided</b><br/>everything it needs is in the prompt"]
##     C["<b>Verifiable output</b><br/>you can check the result quickly"]
##     A --> B --> C
##   end
## 
##   G(["<b>Good fit for an LLM</b><br/>a good workflow"])
##   C --> G
## 
##   classDef cond fill:#ffffff,stroke:#EB811B,stroke-width:2px,color:#000000,font-family:Arial
##   classDef ok fill:#2E8B57,stroke:#2E8B57,color:#ffffff,font-family:Arial
##   class A,B,C cond
##   class G ok
## 
##   style CHECK fill:#EAF3FB,stroke:#9CC3E6,stroke-width:1.5px,color:#23373B

## flowchart TB
##   subgraph ONE ["One big prompt"]
##     direction LR
##     L1["<b>Prompt 1</b><br/>Complete a scRNAseq analysis<br/>on this mouse PBMC dataset"]
##     L2{{"Review results"}}
##     L1 --> L2
##   end
## 
##   subgraph STEP ["Step-by-step with checkpoints"]
##     direction LR
##     R1["<b>Prompt 1</b><br/>Read this scRNAseq mouse PBMC<br/>dataset into Seurat in R and do<br/>some basic QC. Make a report."]
##     R2{{"Review report<br/>QC concerns?"}}
##     R3["<b>Prompt 2</b><br/>Filter cells with mt rate > 1,<br/>regress out cell cycle, and check<br/>for doublets using Scrublet."]
##     R4{{"Re-review results"}}
##     R5(["...many more<br/>steps"])
##     R1 --> R2 --> R3 --> R4
##     R4 -.-> R5
##   end
## 
##   ONE ~~~ STEP
## 
##   classDef prompt fill:#23373B,stroke:#23373B,color:#ffffff,font-family:Arial
##   classDef review fill:#EB811B,stroke:#EB811B,color:#000000,font-family:Arial
##   classDef more fill:#ffffff,stroke:#999999,stroke-dasharray: 5 5,color:#555555,font-family:Arial
##   class L1,R1,R3 prompt
##   class L2,R2,R4 review
##   class R5 more
## 
##   style ONE fill:#EAF3FB,stroke:#9CC3E6,stroke-width:1.5px,color:#23373B
##   style STEP fill:#EAF3FB,stroke:#9CC3E6,stroke-width:1.5px,color:#23373B

# Pulled live from Bioconductor each time the slides are built
suppressPackageStartupMessages({library(ggplot2); library(dplyr); library(ggrepel)})
scores <- read.delim("https://bioconductor.org/packages/stats/bioc/bioc_pkg_scores.tab", stringsAsFactors = FALSE)
scores <- scores |> arrange(desc(Download_score)) |> mutate(rank = row_number())
lab <- filter(scores, Package %in% c("limma", "DESeq2", "scran", "DropletUtils", "scHiCcompare"))
ggplot(scores, aes(rank, Download_score)) +
  geom_area(fill = "grey85") +
  geom_point(data = lab, colour = "#EB811B", size = 3) +
  geom_text_repel(data = lab, aes(label = Package), seed = 42, min.segment.length = 0,
                  nudge_x = 300, direction = "y", hjust = 0) +
  scale_y_continuous(labels = scales::comma) +
  labs(x = "Package rank (most to least downloaded)", y = "Bioconductor download score",
       title = "Bioconductor packages: a long tail of usage") +
  theme_minimal(base_size = 14)
