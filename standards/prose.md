# Prose

Applies to everything that ships under our name: code, identifiers,
comments, doc comments, documentation, commit messages, changelogs, pull
request descriptions, and release notes.

## US English everywhere

Never UK spellings. Write `color`, `behavior`, `normalize`, `gray`,
`center`, `initialize`, `analyze`. Not `colour`, `behaviour`, `normalise`, <!-- prose-allow -->
`grey`, `centre`, `initialise`, `analyse`. <!-- prose-allow -->

This applies to identifiers too. A field named `backgroundColour` is a <!-- prose-allow -->
defect.

`scripts/check-prose.sh` gates this. A line that has to name a British
spelling, such as this section, carries a `prose-allow` marker. Treat that
marker the way [lint-policy.md](lint-policy.md) treats a suppression: rare,
explicit, and visible in review.

We use US English because programming languages generally follow US English,
and mixing spellings creates a code smell.

## Write like a person

No filler. No fluff. No warmup paragraphs. Start with the most useful thing.

Avoid the patterns that read as machine generated:

- Bold-lead bullet lists in prose that should be sentences.
- "There are several ways to look at this."
- Restating the question before answering it.
- Summarizing what you just said at the end of a short passage.
- Hedging every claim into meaninglessness.

If a sentence would survive being deleted, delete it.

## Comments

Only what is necessary. A comment earns its place by explaining something
the code cannot: a constraint, a reason, a non-obvious consequence.

Do not comment what the code already says.

Do not reference project phases, sprints, ticket numbers as the only
explanation, or the history of how the code got here. Write for whoever
reads it next, who has none of that context.

## Naming

No single-letter names. No vague names. This includes lambda parameters.

Simplicity over cleverness. Simplify complex code. Never complicate code to
make it look sophisticated.

## Documentation

Prefer a working example over a paragraph describing one.

Every documented command or snippet must actually run. If a snippet cannot
be checked by CI, it will drift, so either gate it or delete it.
