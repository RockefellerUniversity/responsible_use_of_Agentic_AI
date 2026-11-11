## flowchart LR
##   P["1 Plan<br/>plan.md"] --> E["2 Pin environment<br/>environment.yml / renv.lock"]
##   E --> M
## 
##   subgraph LOOP ["Repeat for every step (e.g. QC, filtering, normalization, clustering, DE)"]
##     direction LR
##     M["3 Pick the next step<br/>write what you expect to see"] --> C["4 Generate code<br/>scripts/"]
##     C --> S["5 Run on a subset<br/>logs/"]
##     S --> U["6 Understand the code<br/>and check the output"]
##     U --> D{"Does it make sense<br/>and do you understand it?"}
##     D -- "no: fix or ask" --> C
##     D -- "yes" --> UP["7 Update the plan<br/>record what you learned<br/>and re-decide the next step"]
##     UP -. "back to the plan" .-> M
##   end
## 
##   UP -- "all modules done" --> F["8 Scale up<br/>full data"]
##   F --> R["9 Report<br/>"]
## 
##   classDef step fill:#ffffff,stroke:#EB811B,stroke-width:2px,color:#000000,font-family:Arial
##   classDef setup fill:#23373B,stroke:#23373B,color:#ffffff,font-family:Arial
##   classDef check fill:#EB811B,stroke:#EB811B,color:#000000,font-family:Arial
##   classDef done fill:#2E8B57,stroke:#2E8B57,color:#ffffff,font-family:Arial
##   class P,E setup
##   class M,C,S,U,UP step
##   class D check
##   class F,R done
##   style LOOP fill:#f4f4f4,stroke:#23373B,stroke-width:2px

## flowchart TB
##   subgraph ROW [" "]
##     direction LR
##     AI["AI proposes an action<br/>e.g. delete files, install packages"]
##     L1["Layer 1<br/>CLAUDE.md / AGENTS.md<br/><i>advisory: can be ignored or lost in a long session</i>"]
##     L2["Layer 2<br/>Permission settings and deny rules<br/><i>enforced by the app</i>"]
##     L3["Layer 3<br/>Human review<br/>"]
##     OK(["Safe outcome"])
##     AI --> L1 --> L2 --> L3 --> OK
##   end
## 
##   subgraph BASE [" "]
##     NET["<div style='width:640px'>SAFETY NET: backups · git history · read-only raw data<br/><i>if every layer above fails, you can undo it</i></div>"]
##   end
## 
##   ROW ~~~ BASE
## 
##   classDef ai fill:#EB811B,stroke:#EB811B,color:#000000,font-family:Arial
##   classDef layer fill:#ffffff,stroke:#EB811B,stroke-width:2px,color:#000000,font-family:Arial
##   classDef human fill:#23373B,stroke:#23373B,color:#ffffff,font-family:Arial
##   classDef net fill:#2F6FA8,stroke:#2F6FA8,color:#ffffff,font-family:Arial
##   classDef ok fill:#2E8B57,stroke:#2E8B57,color:#ffffff,font-family:Arial
##   class AI ai
##   class L1,L2 layer
##   class L3 human
##   class NET net
##   class OK ok
##   style ROW fill:none,stroke:none
##   style BASE fill:none,stroke:none
