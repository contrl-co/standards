#!/usr/bin/env bash
#
# Fail if a branch name does not carry a commit type and a ticket key.
#
#     .standards/bin/check-branch-name.sh [branch-name]
#
# With no argument it reads GITHUB_HEAD_REF (set on pull_request events),
# then falls back to the current branch. Base branches and merge-queue refs
# are skipped: they are not feature branches and nobody named them.
#
# Required shape:
#
#     <type>/<TICKET-KEY>-<short-description>
#     fix/CONTRL-35-rotate-tap-token
#
# See standards/commits.md and standards/code-review.md.
#
set -euo pipefail

# Commit types from standards/commits.md. A tool name is not a type: a branch
# an agent produced is still fix/ or chore/, never codex/ or claude/.
readonly TYPES="fix|feat|chore|docs|refactor|test|perf|ci|build"

# Branches that exist for their own sake and were never named by an author.
readonly BASE_BRANCHES="main|develop|master"

branch="${1:-${GITHUB_HEAD_REF:-}}"
if [ -z "$branch" ]; then
  branch=$(git rev-parse --abbrev-ref HEAD)
fi

if [[ "$branch" =~ ^($BASE_BRANCHES)$ ]]; then
  echo "check-branch-name: $branch is a base branch, nothing to check"
  exit 0
fi

# GitHub's merge queue creates gh-readonly-queue/<base>/pr-<n>-<sha>. The
# pull request that fed it was already checked.
if [[ "$branch" == gh-readonly-queue/* ]]; then
  echo "check-branch-name: $branch is a merge-queue ref, nothing to check"
  exit 0
fi

# Ticket key: uppercase project code, hyphen, number. Jira links the branch
# to the ticket by matching this exactly, so a lowercase key does not link.
readonly PATTERN="^($TYPES)/[A-Z][A-Z0-9]*-[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$"

if [[ "$branch" =~ $PATTERN ]]; then
  echo "check-branch-name: ok  $branch"
  exit 0
fi

cat >&2 <<EOF
check-branch-name: "$branch" does not match the required shape.

  <type>/<TICKET-KEY>-<short-description>

  fix/CONTRL-35-rotate-tap-token
  chore/CONTRL-4-ci-infra-for-crl
  feat/ERP-12-shipment-release-bundle

  type          one of: ${TYPES//|/, }
                never a tool name such as codex or claude
  ticket key    uppercase, exactly as Jira writes it
  description   two to five words, lowercase, hyphenated

Every pull request tracks a ticket. If one does not exist yet, open it
first: it takes less time than arguing with this check.

See .standards/commits.md and .standards/code-review.md.
EOF
exit 1
