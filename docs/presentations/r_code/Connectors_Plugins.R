## flowchart LR
##   A["<b>Agent</b><br/>Claude Code / Codex"] -- "calls a tool<br/>with inputs" --> S["<b>MCP server</b><br/>a catalogue of tools"]
##   S -- "returns a result" --> A
##   S --> X[("Service or data<br/>GitHub · Google · Microsoft 365<br/>docs · your lab database")]
## 
##   classDef agent fill:#23373B,stroke:#23373B,color:#ffffff,font-family:Arial
##   classDef server fill:#EB811B,stroke:#EB811B,color:#000000,font-family:Arial
##   class A agent
##   class S server

## # Claude Code: remote server
## claude mcp add --transport http github https://api.githubcopilot.com/mcp/
## 
## # Claude Code: local server (everything after -- is the command to run)
## claude mcp add --transport stdio markitdown -- uvx markitdown-mcp
## 
## # Codex
## codex mcp add github --url https://api.githubcopilot.com/mcp/
## codex mcp add markitdown -- uvx markitdown-mcp

## claude mcp add --transport http context7 https://mcp.context7.com/mcp

## claude mcp add --transport stdio markitdown -- uvx markitdown-mcp

## claude mcp add playwright -- npx @playwright/mcp@latest --isolated
