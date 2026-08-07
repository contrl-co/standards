# contrl-co/standards

Single source of truth for how we write code, review it, and direct coding
agents. Consumer repositories vendor a copy of `standards/` and a CI job
fails if that copy drifts from the version it pinned.

Written for humans first. Agents read the same files. If a rule only makes
sense to a machine, it is in the wrong place.

Start with [standards/ai-guidelines.md](standards/ai-guidelines.md). It is
the reason the rest of this exists: AI output is unverified evidence, not
established fact, and human judgment is the verification layer.

## What belongs here

Conventions, review process, and agent boundaries. Things a person applies
by judgment.

## What does not belong here

Anything an agent or a person can violate silently. Those need teeth, not
prose: a formatter, a linter, a CI script, a required status check. A
sentence in a markdown file is advisory. `gofmt -l` is not.

When you are tempted to add a rule here, first ask whether it can be a gate
instead. If it can, write the gate and link it from here.

## Adopting this in a repository

From a checkout of this repo:

```sh
scripts/sync.sh /path/to/consumer-repo v1.0.0
```

That writes into the consumer:

```
.standards/              vendored copy of standards/, do not hand edit
.standards/VERSION       pinned tag and commit
.standards/bin/          gate scripts, run by the consumer's CI
                         (the list lives in scripts/vendored.txt)
CLAUDE.md                thin pointer, created only if absent
AGENTS.md                thin pointer, created only if absent
.github/copilot-instructions.md
.cursor/rules/contrl-standards.mdc
```

Then add one job to the consumer's CI:

```yaml
  standards:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v5
      - run: .standards/bin/check-drift.sh
      - run: .standards/bin/check-branch-name.sh
```

`check-branch-name.sh` reads `GITHUB_HEAD_REF` on a pull request, and skips
base branches and merge-queue refs, so the same step is safe on every event.

The drift check clones this repo over anonymous HTTPS at the pinned tag.
That is why this repository has to stay public: our public repos cannot
read a private one in CI without a cross-repo token, which is the exact
problem that forced workflow vendoring in `contrl-co/crl`.

## Versioning

Tagged, semver, `vMAJOR.MINOR.PATCH`.

Consumers pin a tag. They never track `main`. Tracking `main` means one
edit here reddens every repository in the org at the same time.

`.standards/VERSION` records both the tag and the commit it resolved to.
Tags are mutable; the recorded commit is what the drift check compares.

- PATCH: wording, typos, clarification that changes no behavior.
- MINOR: a new rule, or a rule that is relaxed.
- MAJOR: a rule that tightens and will fail existing code or review.

Upgrading a consumer is a normal pull request: rerun `sync.sh` with the new
tag, review the diff, merge.

## Proposing a change

Open a pull request here. Say what broke or what argument kept recurring
that made the rule necessary. A rule with no story behind it gets deleted
the first time it is inconvenient.

## Copyright

Copyright (C) 2026 Contrl. All rights reserved.

