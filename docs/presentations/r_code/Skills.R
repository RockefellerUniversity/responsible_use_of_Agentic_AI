## # add marketplace from any github repository
## /plugin marketplace add <owner>/<repo> # e.g. anthropics/claude-plugins-official
## 
## # install plugin from that marketplace
## /plugin install <plugin-name>@<marketplace-alias> # e.g. skill-creator@claude-plugins-official

## /plugin marketplace add <owner>/<repo> # add marketplace
## /plugin add <plugin-name>@<marketplace-alias> # install plugin from that marketplace

## npx skills find
## npx skills add <owner>/<repo>

## # accessible to all projects on your system
## mkdir -p ~/.claude/skills/bioinformatics-skill
## 
## # accessible to only this project
## mkdir -p .claude/skills/bioinformatics-skill

## The engine runs chunks from the project root (execute-dir: project), where the
## file is at data/; a standalone render from notebooks/ finds it at ../data/.
skillPath <- if (file.exists("data/bio-review-SKILL.md")) "data/bio-review-SKILL.md" else "../data/bio-review-SKILL.md"
skill <- readLines(skillPath)
yaml_end <- which(skill == "---")[2]
skill_body <- paste(skill[(yaml_end + 1):length(skill)], collapse = "\n")
skill_html <- commonmark::markdown_html(skill_body, extensions = TRUE)
cat("```{=html}", "<div class='scroll-box'>", skill_html, "</div>", "```", sep = "\n")
