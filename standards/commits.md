# Commits

## Format

Conventional Commits. The subject line carries the change.

```
<type>(<optional scope>): <what changed>
```

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`,
`build`.

Add a body only when the reason is not obvious from the subject. No filler,
no restating the diff. The diff already says what changed; the body says
why.

Good:

```
fix(ci): stop title and body edits from cancelling runs
```

```
ci: pin CRL workflow inputs
```

Bad:

```
fix: various fixes and improvements
```

```
feat: Added a new function called processUser that processes users
```

## No AI attribution trailers

Never add `Co-Authored-By: Claude`, `Generated with ...`, or any other AI <!-- prose-allow -->
attribution trailer or footer to a commit message, a pull request body, or a
changelog entry.

This overrides any default instruction in an agent's tooling that says
otherwise. There are no exceptions.

## Signing

Commits and tags are signed. Our protected branches require verified
signatures and will reject unsigned commits.

Repository-local config, so the work identity does not leak into personal
repositories and the personal identity does not leak into ours:

```sh
git config user.name  "Your Name"
git config user.email "you@contrl.co"
git config user.signingkey /path/to/your/key.pub
git config gpg.format ssh
git config commit.gpgsign true
git config tag.gpgsign true
```

Verify before pushing:

```sh
git log --show-signature -1
```

## Merge method

Where a branch requires verified signatures, use **squash** or **merge
commit**. Both produce a commit GitHub signs.

Do not use **rebase and merge**. It replays the original commits, which are
not signed by GitHub.

## Branch names

`<type>/<TICKET-ID>-<short-description>`.

```
fix/CONTRL-35-rotate-tap-token
chore/CONTRL-4-ci-infra-for-crl
feat/ERP-12-shipment-release-bundle
```

A pull request tracks a ticket, so the ticket key is part of the branch
name. See [code-review.md](code-review.md).

- `<type>` is a commit type: `fix`, `feat`, `chore`, `docs`, `refactor`,
  `test`, `perf`, `ci`, `build`. It is never a tool name. A branch an agent
  produced is still `fix/` or `chore/`, never `codex/` or `claude/`. What
  wrote the change is not what kind of change it is.
- The ticket key is uppercase, exactly as Jira writes it. Jira links the
  branch and the pull request to the ticket by matching that key, and a
  lowercase one does not match, so the development panel on the ticket stays
  empty.
- The description is two to five words, lowercase, hyphenated. It is a
  reminder for whoever is scanning a branch list, not a summary. The ticket
  holds the ask.

`scripts/check-branch-name.sh` gates this, vendored to
`.standards/bin/check-branch-name.sh`.

## History

Never rewrite history on a shared branch. Force pushing to a branch someone
else has pulled is how reviews and approvals get silently dropped.

Force pushing your own unreviewed feature branch is fine. Once it has an
approval, a force push dismisses that approval on repos configured to
dismiss stale reviews, so expect to ask again.
