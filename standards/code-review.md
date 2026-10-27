# Code review

## Every pull request tracks a ticket

Open the ticket before the branch. The branch name carries its key
(`fix/CONTRL-35-rotate-tap-token`, see [commits.md](commits.md)), so the
link is automatic and the board reflects real work without anyone
maintaining it by hand.

The ticket says why the change is wanted and how we will know it landed. The
pull request says what changed and what you verified. Neither restates the
other. See [issue-tracker.md](issue-tracker.md).

## Labels

Every pull request carries exactly one type label and exactly one status
label. CI fails otherwise.

Type: `fix`, `feat`, `chore`.

Status: `Engineers at work`, `Test & Merge`, `DO NOT MERGE`.

`DO NOT MERGE` fails the gate on purpose. It is a hold, not a warning.

Type and status labels are applied by people. Path based auto labeling must
never strip them, because that would let a rule decide whether a
pull request is mergeable.

## Approval

At least one CODEOWNER approval on protected branches.

The identity that last pushed cannot be the approver. If you pushed the
final commit, someone else approves it. This applies to automation too: when
a release pipeline pushes a branch under a token, whoever owns that token is
not eligible to approve that pull request.

All review threads resolved before merge.

A push after approval dismisses the approval. Expect to ask again.

## Required checks

The aggregate gate job is the required check, not the individual jobs. It
must fail closed: a job result that is not `success` and not a deliberate
`skipped` fails the gate.

Never mark a check required by name if it can be skipped conditionally,
because a skipped required check blocks forever.

## What blocks a merge

- A failing gate.
- No ticket, or a branch name that does not carry its key.
- A missing or conflicting label.
- An unresolved review thread.
- A linter suppression added to make the build pass. See
  [lint-policy.md](lint-policy.md).
- A change to canonical output or a serialization format without the
  corresponding version or edition declaration.
- New tests that do not pin the behavior they claim to cover.

## Tests serve a purpose, not a count

Coverage percentage is not the goal. Deduplicate and group repetitive tests,
keep the ones that pin a real decision, delete the rest.

A test that asserts the code does what the code does is noise. A test that
pins a decision someone could plausibly reverse is coverage.

Deleting a redundant test in a pull request is a normal, welcome change. Say
in the description which decision the remaining tests still pin.

## What does not block a merge

Formatting opinions a formatter does not enforce. If you care about it,
encode it in the formatter or drop it.

Preference restated as a requirement. Say "I would do X" and let the author
decide, or make it a rule here and gate it.

## Before you open the pull request

Your job, not the reviewer's. The full list is in
[ai-guidelines.md](ai-guidelines.md); the short version:

- Read every line of your own diff, top to bottom.
- Run the code.
- Verify every dependency, API, version, and function signature exists.
- Remove code you do not understand, and anything you did not ask for.
- Keep the change small. Splitting 800 generated lines is your job.
- Match the conventions of this codebase, not a model's idea of best
  practice.

## Pull request descriptions

Say **why** the change exists and **what you personally verified**. The diff
already says what changed.

Name the verification. "Ran the suite" is not verification. "Ran
`go test ./... -race`, and confirmed the new tag resolves on the module
proxy" is.

## Reviewing agent-authored changes

The author is accountable for the diff regardless of what produced it.
"The agent wrote it" is not a review response.

AI review is encouraged. Human review is required. An AI review does not
satisfy the CODEOWNER approval.

To run one, point an agent at
[agent-review-guide.md](agent-review-guide.md). It tells the agent what CI
already gates so it does not spend its attention there, what to check
instead, and how to report findings without burying you in output.

Look specifically for:

- Suppressed lint findings, added tests that assert nothing, and error paths
  swallowed to make a gate pass.
- Tests that confirm the implementation instead of the intended behavior. A
  test generated from buggy code passes against the bug and reports it as
  intended. That is worse than no test.
- Confidently wrong comments describing behavior the code does not have.
- Invented APIs, flags, fields, or versions. Check that referenced symbols
  exist.
- Code nobody asked for: defensive branches, config flags, try/catch around
  things that do not throw, abstractions for a second use case that does not
  exist. Dead code is forever.
- Scope creep: unrelated files touched, dependencies added, configuration
  changed.

Sending a pull request back as unfiltered AI output is not rude. It is how
we protect each other's time.
