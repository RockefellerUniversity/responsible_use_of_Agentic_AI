#!/bin/bash
# Runs before every Edit/Write. Claude Code sends the tool call as JSON on stdin.
# Exit code 2 blocks the action and sends the stderr message back to Claude.
# Must be executable: chmod +x .claude/hooks/protect-raw.sh
if grep -q '"file_path" *: *"[^"]*/data/raw/'; then
  echo "Blocked: data/raw/ is read-only. Write to data/processed/ instead." >&2
  exit 2
fi
exit 0
