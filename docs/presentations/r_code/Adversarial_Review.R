## flowchart LR
##   subgraph HPC ["All on the Rockefeller HPC"]
##     direction LR
##     A["Your code"] --> B["Automatic checks<br/>(no AI)"]
##     B --> C["Three AI<br/>reviewers"]
##     C --> D["Check against<br/>package docs"]
##     D --> E["Ranked report"]
##   end
##   style HPC fill:none,stroke:#23373B,stroke-dasharray:5 5
