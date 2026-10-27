#!/bin/bash

if ! command -v jq &>/dev/null; then
  echo "BLOCKED: git-guard needs jq to inspect commands. Install jq." >&2
  exit 2
fi

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Matched case-insensitively.
DANGEROUS_PATTERNS=(
  'git\s+push'
  'git\s+reset\s+--hard'
  'git\s+clean\s+-fd'
  'git\s+clean\s+-f'
  'git\s+checkout\s+\.'
  'git\s+restore\s+\.'
  'push\s+--force'
  'reset\s+--hard'
  'git\s+clean\s+-[a-zA-Z]*f'
  'git\s+checkout\s+--\s+\.'
  'git\s+add\s+(-A\b|\.\s*$|\.\s*&&|\.\s*;)'
)

# Matched case-sensitively: -D force-deletes, -d is the safe delete.
CASE_SENSITIVE_PATTERNS=(
  'git\s+branch\s+-D'
)

block() {
  echo "BLOCKED: '$COMMAND' matches dangerous pattern '$1'. The user has prevented you from doing this." >&2
  exit 2
}

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  echo "$COMMAND" | grep -qiE "$pattern" && block "$pattern"
done

for pattern in "${CASE_SENSITIVE_PATTERNS[@]}"; do
  echo "$COMMAND" | grep -qE "$pattern" && block "$pattern"
done

exit 0
