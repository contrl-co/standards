# Changelog

Consumers pin a tag, so every entry here is something a consumer opts into
by rerunning `scripts/sync.sh`.

- PATCH: wording, typos, clarification that changes no behavior.
- MINOR: a new rule, or a rule that is relaxed.
- MAJOR: a rule that tightens and will fail existing code or review.

## Unreleased

### Added

- `standards/ai-guidelines.md`, adapted from the company AI Guidelines page
  in Confluence (last modified 31 Jul 2026, retrieved 7 Aug 2026). Covers
  the cost asymmetry between generating and reviewing AI output, the
  pre-pull-request checklist, and ownership. Re-sync by hand when either
  copy changes; see the provenance section in that file.
- `standards/issue-tracker.md`. Tickets carry the ask, not a build log. No
  status narration once a pull request exists, one running comment rather
  than an append log, and comments only when a person has to act.
- Initial standards: agent boundaries, prose, commits, code review, and lint
  policy.
- Every pull request tracks a ticket, and branch names carry its key:
  `<type>/<TICKET-KEY>-<short-description>`, for example
  `fix/CONTRL-35-rotate-tap-token`. One written exception, for reverting a
  break on a protected branch. The type is a commit type and never a tool
  name, so `codex/` and `claude/` branches are rejected.
- Language notes for Go, Python, and Node with Vite. Python standardizes on
  uv: `pyproject.toml` plus `uv.lock`, both committed, `requirements.txt`
  generated and never an input, and every gate run through `uv run`. The
  Node document also carries the UI rules: dumb components, a single source
  for design tokens, and a demonstrable example of every visual state.
- Agent instruction templates for Claude Code, AGENTS.md, Copilot, and
  Cursor, each restating the same non-negotiables so a rule cannot exist for
  one tool only.
- `scripts/sync.sh` to vendor a pinned tag into a consumer repository.
- `scripts/vendored.txt`, the single list of which gate scripts reach
  consumers. `sync.sh` copies from it and `check-drift.sh` rebuilds the
  expected `.standards/bin` from the same list, so deleting a gate locally
  to stop it running fails the drift check.
- `scripts/check-drift.sh` to fail a consumer's CI when its vendored copy is
  edited, when a gate script is deleted, or when the tag it pinned is moved.
- `scripts/check-branch-name.sh` to gate the branch shape and the presence
  of a ticket key.
- `scripts/check-prose.sh` to gate the mechanically checkable prose rules
  rather than leaving them to review.
- `scripts/selftest.sh` to exercise sync and drift detection locally.
