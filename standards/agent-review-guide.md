# Agent review guide

Written for an agent reviewing a pull request, running alongside a human
doing the same. You are the second pair of eyes, not the approver. A human
still has to approve ([code-review.md](code-review.md)).

Invoke with something like:

```
Review the diff on this branch against .standards/agent-review-guide.md.
Report findings only.
```

## Output contract

One line per finding:

```
path:line  <severity>  <what is wrong>  <standard it violates>
```

Severities:

- `blocker` matches the "What blocks a merge" list in
  [code-review.md](code-review.md). Nothing else earns it.
- `should-fix` is a real defect that does not block.
- `note` is worth a sentence in review and nothing more.

Rules for your output:

- Report violations only. No praise, no summary of the pull request, no
  restatement of the diff. The human already read it.
- If you find nothing, write `No findings.` and stop. That is a complete,
  correct answer.
- If you have more than fifteen findings, report the fifteen most severe and
  state how many you dropped. Never truncate silently.
- Never guess. If you cannot verify something, mark it `unverified` and say
  what would confirm it. A confident wrong finding costs more review time
  than the bug it invented.

The point of this review is to save the human time. If your output takes
longer to read than the diff, you have made things worse. See
[ai-guidelines.md](ai-guidelines.md).

## Do not re-check what CI already gates

These fail the build on their own. Reporting them is noise, and it buries
the findings that need a person.

| Already gated                                 | By                     |
|-----------------------------------------------|------------------------|
| US spelling, AI attribution trailers          | `check-prose.sh`       |
| Shell script lint                             | `check-shell.sh`       |
| Branch shape and ticket key                   | `check-branch-name.sh` |
| Edited or deleted vendored `.standards/`      | `check-drift.sh`       |
| Exactly one type and one status label         | the label gate         |
| Formatting, vet, lint, tests, vulnerabilities | the language jobs      |

If one of these is broken, CI is red and the author already knows. The
exception worth reporting: a change that **weakens or removes a gate**. That
is a blocker every time.

## Highest yield checks

These are where agent-authored changes actually fail. Start here.

**Invented APIs, flags, fields, and versions.** The most common failure mode
by a wide margin. For every symbol, package, version, environment variable,
and CLI flag the diff introduces or references, confirm it exists. Read the
dependency's source, run `--help`, check the lockfile. Do not accept that it
looks plausible. Report anything you could not confirm as `unverified`.

**Code nobody asked for.** Defensive branches for conditions that cannot
occur, configuration flags with one caller, try/catch around code that does
not throw, an abstraction for a second use case that does not exist. Dead
code is forever. Check the diff against the ticket: work that the ticket
does not ask for is scope creep even when it is good.

**Tests that confirm the implementation instead of the intent.** A test
generated from buggy code passes against the bug and reports it as intended.
For each new test, ask what behavior it pins and whether that behavior is
what the ticket asked for. A test that would still pass if the function
returned a constant is not a test.

**Suppressions added to make a gate pass.** Any new `@Suppress`, `noqa`,
`eslint-disable`, `ts-ignore`, `nolint`, `type: ignore`, added ignore-list
path, or lowered severity threshold. Acceptable only where the language
offers no correct fix, and only with a comment saying why. Without that
comment it is a defect. See [lint-policy.md](lint-policy.md).

**Annotations claiming a property the code does not have.** A stability or
immutability marker on a type with a mutable field, `frozen` on a container
whose contents still mutate, `readonly` on a field holding a mutable array,
`as any` or `Any` used to end an argument with the type checker. The
annotation is a claim; check whether it is true.

**Comments that describe behavior the code does not have.** Read each new
comment against the code beneath it. Confidently wrong comments outlive the
code they describe.

**Diff size.** If the change is large and mechanical, say so and suggest the
split. Splitting is the author's job, not the reviewer's.

## Per-standard checks

### Commits and branches

- Commit subject carries the change, Conventional Commits format.
- No `Co-Authored-By` trailer naming an AI tool, no "generated with"
  footer, anywhere in commits, the pull request body, or the changelog.
- Branch is `<type>/<TICKET-KEY>-<short-description>`, and the type is a
  commit type, never a tool name.
- On a branch requiring verified signatures, the merge method is squash or
  merge commit. Rebase and merge is rejected.

### Pull request body

- Says **why** the change exists and **what the author personally verified**.
- The verification is named. "Ran the suite" is not verification. A command,
  a case exercised, or an assumption confirmed against a source is.
- A ticket exists and the branch carries its key. The only exception is
  reverting a break on a protected branch.

### Issue tracker

- The change does not add status narration to a ticket. Once a pull request
  exists, the diff tells the story.
- If a ticket was opened for this pull request, it states an ask, not a
  receipt written after the fact.

### CI and tooling changes

- Every action is pinned to a commit SHA, not a tag.
- Every tool is pinned to a version, and containers to a digest. An
  unpinned linter turns an unrelated pull request red the day it moves.
- No `ubuntu-latest` or other floating runner label.
- A required check cannot be conditionally skipped. A skipped required check
  blocks forever.
- The aggregate gate fails closed: any result that is not `success` and not
  a deliberate `skipped` fails.

### Go

- Version comes from `go.mod` via `go-version-file`, never hardcoded in a
  workflow.
- Tests run with `-race` and `-count=1`.
- A change that moves the hash of unchanged source carries an edition or
  version declaration, a regenerated golden corpus, and a changelog entry in
  the same pull request. No override path. Blocker.
- No `fmt.Println` used as logging. Printing a CLI's actual result is fine.

### Python

- uv only. `pyproject.toml` and `uv.lock` both committed. A
  `requirements.txt` used as an input is a blocker; generated by
  `uv export` is fine.
- CI uses `uv sync --locked`, not `--frozen`. `--frozen` skips the check
  against `pyproject.toml`, so a stale lock passes silently.
- Gates run through `uv run`, not the ambient PATH.
- No bare `except:`. No `except Exception:` that neither re-raises nor logs
  the traceback.
- No mutable default arguments.
- No `print` used as logging.

### Node, TypeScript, Vite

- **Any secret behind a `VITE_` prefix is a blocker.** That prefix inlines
  the value into the client bundle and ships it to every visitor. Check
  every added environment variable.
- CI installs with `npm ci` or `--frozen-lockfile`, never `npm install`.
- The lockfile is committed and changed in the same commit as
  `package.json`.
- `strict: true` holds. `@ts-ignore` is a defect; `@ts-expect-error` with a
  reason is acceptable.
- No `console.log` used as logging.
- No hex colors or raw design values outside the single token file.
- No logic in components: no filtering, sorting, mapping, or business rules.
- New or changed components have a rendered example of every visual state.
- A new dependency is justified in the pull request body.

## What you cannot verify

State these as unknown rather than assuming. Fabricating any of them is
worse than skipping them.

- Whether CI passed. Read the run. Do not infer it from the diff.
- Whether the ticket exists and says what the branch claims. Check it, or
  report that you could not.
- Runtime behavior you did not execute.
- Whether a required secret or credential is configured.
- Whether a human reviewer already raised the point.

## Related

- [code-review.md](code-review.md) is what a human blocks on.
- [ai-guidelines.md](ai-guidelines.md) is why the bar is where it is.
- [agent-boundaries.md](agent-boundaries.md) applies to you while reviewing:
  read and report, do not push, comment, or approve.
