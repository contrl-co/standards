#!/usr/bin/env bash
#
# Enforce the mechanically checkable half of standards/prose.md.
#
#     scripts/check-prose.sh [path ...]     defaults to every tracked file
#
# This exists to prove the point the README makes: a rule that can be a gate
# should be a gate. US spelling and AI attribution trailers are both
# mechanically checkable, so they are gated here instead of left to review.
#
set -euo pipefail

status=0

# A while-read loop rather than mapfile: macOS ships bash 3.2, and a gate
# that only runs on CI is a gate you find out about too late.
files=()
if [ $# -gt 0 ]; then
  for argument in "$@"; do files+=("$argument"); done
else
  # --others so a file that has not been staged yet is still checked. A rule
  # that only applies after git add is a rule you find out about too late.
  while IFS= read -r tracked_file; do
    files+=("$tracked_file")
  done < <(
    git ls-files --cached --others --exclude-standard \
      -- '*.md' '*.mdc' '*.go' '*.kt' '*.kts' '*.py' '*.ts' '*.tsx' '*.js' '*.sh' '*.yml' '*.yaml'
  )
fi

# This file defines the forbidden patterns, so it matches all of them. Any
# other file that legitimately needs to name one (a standard describing the
# rule, a test fixture) marks the line with prose-allow. That marker is the
# suppression escape hatch from lint-policy.md: rare, explicit, and visible
# in review rather than silent.
readonly ALLOW_MARKER="prose-allow"

report() { # label, pattern, hint
  local label=$1 pattern=$2 hint=$3
  local hits
  hits=$(grep -nIE --color=never "$pattern" "${files[@]}" 2>/dev/null || true)
  hits=$(printf '%s\n' "$hits" | grep -vF "$ALLOW_MARKER" || true)
  hits=$(printf '%s' "$hits" | sed '/^$/d')
  if [ -n "$hits" ]; then
    echo "FAIL  $label"
    printf '%s\n' "$hits" | sed 's/^/      /'
    echo "      $hint"
    echo
    status=1
  fi
}

# Anchored on a word boundary so 'colorize' and 'Behaviors' produce no noise.
# The -is stems are spelled out so valid US words that share a prefix
# ('analysis', 'organism', 'initialism') do not trip the gate. Proper nouns
# that legitimately use a British spelling take a prose-allow marker on the
# line.
uk_pattern='\b([Cc]olour|[Bb]ehaviour|[Nn]ormalis(e|ation|ing)|[Ii]nitialis(e|ation|ing)|[Aa]nalys(e\b|ed|ing)|[Oo]rganis(e|ation|ing)|[Rr]ecognis(e|ation|ing)|[Ss]erialis(e|ation|ing)|[Gg]rey|[Cc]entre|[Ll]icence|[Dd]efence|[Cc]atalogue)'
report "UK spelling" \
  "$uk_pattern" \
  "US English everywhere, including identifiers. See standards/prose.md."

attribution_pattern='(Co-Authored-By:.*(Claude|GPT|Copilot|Gemini|Codex|Cursor|Devin|OpenAI|Anthropic)|Generated (with|by) \[?(Claude|ChatGPT|GPT|Copilot|Gemini|Codex)|🤖 Generated)' # prose-allow
report "AI attribution trailer" \
  "$attribution_pattern" \
  "Never attribute commits or docs to an agent. See standards/commits.md."

if [ "$status" -eq 0 ]; then
  echo "check-prose: ok (${#files[@]} files)"
fi

exit "$status"
