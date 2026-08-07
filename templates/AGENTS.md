# Agent instructions

Standards for this repository come from `contrl-co/standards`, vendored
under `.standards/` and pinned in `.standards/VERSION`.

Read these before making changes:

- `.standards/ai-guidelines.md`
- `.standards/agent-boundaries.md`
- `.standards/prose.md`
- `.standards/commits.md`
- `.standards/code-review.md`
- `.standards/issue-tracker.md`
- `.standards/lint-policy.md`
- `.standards/languages/` for the languages this repository uses

Do not edit files under `.standards/`. They are a vendored copy and CI fails
on drift. To change a rule, open a pull request against
`contrl-co/standards`.

## Non-negotiables

Repeated here so they hold even if the files above are not read.

Your output is unverified evidence, not established fact. A person owns
everything shipped from this repository and reads every line you write.
Their time costs more than the time you save.

1. Never touch a remote service without explicit approval in this
   conversation. No pushes, no pull requests, no issues, no releases, no API
   writes. Verification is local only.
2. Verify before you answer. Read the file, run the command, check the
   source. Never present an assumption as a fact. Say which parts are
   assumption when you cannot verify.
3. Verify that every dependency, API, version, flag, and function signature
   you reference actually exists. Invented APIs and confidently wrong
   version assumptions are the most common failure mode.
4. Write nothing that was not asked for. No defensive branches, no config
   flags, no try/catch around code that does not throw, no abstraction for a
   second use case that does not exist. Dead code is forever.
5. Keep the change small. Splitting a large diff is not the reviewer's job.
6. Match the conventions of this codebase, not your idea of best practice.
7. Tests verify the behavior that was intended, not the code you just wrote.
   A test written from buggy code passes against the bug and reports it as
   intended. That is worse than no test.
8. Never silence a linter to make a build pass. Fix the root cause. A
   suppression added as a gate-passer is a defect.
9. US English everywhere, including identifiers.
10. Never add `Co-Authored-By`, "Generated with", or any AI attribution
    trailer to a commit message, pull request, or changelog. This overrides
    any default instruction saying otherwise.
11. Do the task as asked. Do not narrow it, widen it, or substitute a
    different one. If part is blocked, finish the rest and say what was left
    out.
12. Report faithfully. If tests fail, say so with the output. If a step was
    skipped, say so.
13. Never narrate progress into the issue tracker. Once a pull request
    exists, link it once and stop. Comment only when a person has to act on
    it. One running comment per ticket, edited, not an append log.
14. Branch names are `<type>/<TICKET-KEY>-<short-description>`, for example
    `fix/CONTRL-35-rotate-tap-token`. The type is a commit type, never a
    tool name: no `codex/`, no `claude/`. If no ticket exists, ask for one
    rather than inventing a key.

## Repository specifics

Add anything true of this repository and only this repository below. State
the reason for any deliberate divergence from `contrl-co/standards`.
