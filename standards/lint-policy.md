# Lint policy

## A lint finding is a design signal

Never silence a linter to make a build pass. Not with `@Suppress`, not with
`// noqa`, not with `eslint-disable`, not with `//nolint`, not by lowering a
severity threshold, not by adding a path to an ignore list.

Fix the root cause. In practice that means one of:

- Extract a constant.
- Rename or split a file.
- Decompose a function or a class.
- Delete the code the linter is complaining about.

## The only acceptable suppression

Where the language offers no correct fix. An unavoidable unchecked cast
inside a generic function is the usual real example.

Every such suppression carries a comment saying why no fix exists:

```ts
// The upstream SDK types this response as unknown. The shape is guaranteed
// by the schema validated on the line above, and this is the only call site.
// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
```

A suppression without that comment is a defect.

## Do not annotate your way out

The same failure wearing a different hat: using a marker to assert a
property instead of making the property true.

- A stability or immutability annotation on a type that still has a mutable
  field. The compiler believes it, the runtime does not.
- `# type: ignore` or `as any` to make a type checker stop asking, when the
  real answer is that the type is wrong.
- A frozen or readonly marker on a container whose contents are still
  mutable.

An annotation is a claim. If the claim is false, you have not fixed
anything, you have moved the failure somewhere harder to find. Make the
property real: remove the mutable field, use an immutable collection type,
fix the type.

## Suppressions added to pass a gate are defects

Treat them the same as a commented-out test. They will be caught in review
and sent back.

This is the single most common failure mode in agent-authored changes: the
agent hits a lint error, cannot see a clean fix, and reaches for the
suppression because it makes the command exit zero. Exit zero is not the
goal.

## Pin the linter

The linter version is pinned in a reviewed commit, not resolved at run time.
A tool that upgrades itself turns an unrelated pull request red and trains
everyone to ignore the gate.

Pin the tool, not just the action or installer that fetches it. Most
installer actions pin themselves and leave the tool version floating.

## Vulnerability scanners are the exception

Scanner databases are fetched live on every run, by design. A scan that was
green yesterday can be red today because the world changed, not because the
code did.

That means:

- Scan results are not reproducible, so never treat them as a determinism
  gate.
- Run them on a schedule as well as on pull requests, so a disclosure lands
  as its own red run instead of ambushing an unrelated change.
- Pin the scanner binary or container by digest even though its database
  floats.
