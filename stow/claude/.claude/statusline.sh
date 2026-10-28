#!/bin/bash
# Claude Code status line: model and tokens used this session, summed from the transcript.

if ! command -v jq &>/dev/null; then
  echo "statusline needs jq"
  exit 0
fi

INPUT=$(cat)
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "Claude"')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')

# The transcript repeats a message's usage once per content block, so dedupe by message id.
read -r IN CACHED OUT < <(
  [[ -f $TRANSCRIPT ]] && jq -Rnr '
    [inputs | fromjson? | select(.type == "assistant" and .message.usage)
      | {id: .message.id, u: .message.usage}]
    | unique_by(.id) | map(.u)
    | [ (map((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) | add // 0),
        (map(.cache_read_input_tokens // 0) | add // 0),
        (map(.output_tokens // 0) | add // 0) ]
    | @tsv' "$TRANSCRIPT"
)

human() {
  awk -v n="${1:-0}" 'BEGIN {
    if (n >= 1e6) printf "%.1fM", n / 1e6
    else if (n >= 1e3) printf "%.1fk", n / 1e3
    else printf "%d", n
  }'
}

echo "$MODEL | tokens: $(human "$IN") in ($(human "$CACHED") cached) · $(human "$OUT") out"
