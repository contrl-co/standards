# Node and Vite

## Toolchain

The Node version lives in `.nvmrc` and in `engines` in `package.json`. CI
reads `.nvmrc` through `node-version-file`. Never hardcode a version in a
workflow; the two drift and the drift is silent.

```yaml
- uses: actions/setup-node@<pinned-sha>
  with:
    node-version-file: .nvmrc
    cache: npm
```

One package manager per repository, with its lockfile committed. CI installs
from the lock and never resolves fresh:

```sh
npm ci        # not npm install
pnpm install --frozen-lockfile
```

`npm install` in CI can pick a different tree than the last run, which makes
the build unreproducible and lets a transitive update land without review.

## Required gates

Every pull request:

- `tsc --noEmit` with `strict: true`.
- `eslint .` at a pinned eslint version.
- `prettier --check .`
- The test suite, with no watch mode and no bail.
- `vite build`, because a type-clean project can still fail to bundle.
- A dependency vulnerability scan on a schedule as well as on pull requests.

Pin the tool versions in `package.json`. Caret ranges on dev tooling mean
your gates change without a commit.

## TypeScript

`strict: true`. Not strict-per-file, not strict-eventually.

`any` needs the same justification as a lint suppression: a comment saying
why no real type exists. `unknown` plus a narrowing check is almost always
the correct answer instead.

No `@ts-ignore`. Use `@ts-expect-error` with a reason, so the suppression
itself fails once the underlying problem is fixed.

## Logging

A real logger, configured once at the entry point. Never `console.log` to
report what the application is doing.

Logs have to be filterable by level and sanitizable in production. A
`console.log` cannot be leveled, silenced, redacted, or routed, and in a
browser bundle it ships to every user with whatever was in the object.

`console.log` left in a diff is a review comment, not a merge.

## Immutability

State is replaced, never mutated in place. Props are read-only, always.

Mark data shapes `readonly` and use `readonly T[]`. A `readonly` field
holding a mutable array still lets the array be mutated: the annotation is a
claim about the field, not about what is inside it. See
[lint-policy.md](lint-policy.md).

Do not reach for a deep-freeze helper to make an unsound shape safe. Fix the
shape.

## Components are dumb

Zero logic in a component. No filtering, no sorting, no mapping, no
formatting decisions, no conditional business rules.

State and logic live in hooks, stores, or the server. The component reads
state and emits events. If a component needs a derived value, derive it
where the state lives and pass it in already derived.

A component you cannot render from a plain object of props has logic in it.

## Design tokens

Exactly one place holds raw color, spacing, and typography literals. That
file is the only one permitted to contain a hex code.

Everywhere else reads a named token. A component with `#3b82f6` in it is a
defect, even when the value is correct, because the next theme change has to
find it.

The same rule applies to any design system value: define once, name it,
consume the name.

## Component states are demonstrable

Every component has a rendered example of each of its visual states:
loading, success, error, and empty. Storybook, a route in a dev-only
gallery, or a test that renders each state and snapshots it.

A state you cannot render on demand is a state nobody has looked at. Verbose
story files are fine; a story file longer than the component is not a
problem worth solving.

## Environment variables and secrets

Anything prefixed `VITE_` is inlined into the client bundle at build time
and is public. It ships to every visitor and appears in the served
JavaScript.

Never put an API key, a token, or any credential behind a `VITE_` prefix.
The prefix is not a scoping mechanism, it is a publication mechanism.

Server-side values stay unprefixed and are read on the server only. If a
value must reach the browser and must stay secret, the answer is a backend
endpoint, not a build-time variable.

Commit a `.env.example` listing every variable with placeholder values.
Never commit `.env`.

## Build output

`vite build` output is a build artifact. It is never committed.

Pin the base path and asset naming so a rebuild of the same commit produces
the same file names. Content-hashed asset names that move between builds of
identical source point at a nondeterministic input, usually a timestamp or a
dependency resolved at build time.

## Dependencies

Adding a dependency is a review decision, not an implementation detail. In
the pull request, say what it does and why the platform or an existing
dependency does not.

Prefer no dependency for anything under roughly fifty lines you could write
and test. Every added package is a supply chain surface and a future upgrade.
