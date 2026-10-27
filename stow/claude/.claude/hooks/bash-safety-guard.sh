#!/usr/bin/env bash
# Bash safety guard — blocks destructive commands before execution.
# Runs as PreToolUse hook on Bash tool. Exits 0 (pass-through) if safe.

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$CMD" ]; then
  exit 0
fi

block() {
  jq -n --arg reason "$1" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": $reason
    }
  }'
  exit 0
}

# --- Destructive file operations ---
echo "$CMD" | grep -qE '\brm\s+(-[a-zA-Z]*r[a-zA-Z]*f|(-[a-zA-Z]*f[a-zA-Z]*r))\s' && \
  block "BLOCKED: rm -rf detected. Specify exact paths and get user confirmation first."

echo "$CMD" | grep -qE '\brm\s+(-[a-zA-Z]*r[a-zA-Z]*\s+|--recursive\s+)\s*(/|~|\.\s|\.\.|\$HOME)' && \
  block "BLOCKED: recursive delete on broad path. Be specific about what to delete."

# --- Dangerous git operations: handled by git-guard.sh ---

# --- Privilege escalation ---
echo "$CMD" | grep -qE '^\s*sudo\s' && \
  block "BLOCKED: sudo requires explicit user approval."

# --- Database destruction ---
echo "$CMD" | grep -qiE '\bDROP\s+(TABLE|DATABASE)\b' && \
  block "BLOCKED: DROP TABLE/DATABASE detected. Confirm with user."

echo "$CMD" | grep -qiE '\bDELETE\s+FROM\b' && echo "$CMD" | grep -qivE '\bWHERE\b' && \
  block "BLOCKED: DELETE FROM without WHERE clause. Add a WHERE clause or confirm with user."

# --- Container/process nukes ---
echo "$CMD" | grep -qiE '\bdocker\s+(system\s+prune|rm\s+-f|rmi\s+-f)' && \
  block "BLOCKED: destructive Docker operation. Confirm with user."

echo "$CMD" | grep -qE '\bkill\s+-9\b' && \
  block "BLOCKED: kill -9. Use graceful signals first or confirm with user."

# If nothing matched, pass through silently
exit 0
