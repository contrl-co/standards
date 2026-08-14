# AI guidelines

## We do not ship noise

CONTRL exists because information without judgment creates risk. AI makes it
easier than ever to generate content, code, documentation, and opinions.
That does not make them true, useful, or ours.

Treat AI output as unverified evidence, not established fact. Human judgment
is the verification layer.

AI can generate, assist, and critique. Only people decide what is worth
shipping. If your name is on it, you own it.

## For everyone

Use AI constantly. It should make you dramatically faster.

The speed is yours and the cost lands on someone else. AI content is very
cheap to create and expensive to consume. When you hand unfiltered AI output
to a teammate, you have not saved that work, you have moved it onto them.
Your reviewer's time is worth more than the time you saved.

Before you share something, ask:

- Is this actually true?
- Does every paragraph deserve to exist?
- Would I defend every sentence if someone challenged it?
- Does this read like a person wrote it?

If AI generated ten pages and only two matter, send two.

Do the part AI cannot:

- Decide what matters.
- Remove what does not.
- Verify what is true.
- Apply taste and judgment.

At a bare minimum, do not make your work look like AI wrote it. If it reads
like a model, it gets read like one. See [prose.md](prose.md) for the
specifics, and note that `scripts/check-prose.sh` gates the parts of that
which can be gated.

If something lands on you as unfiltered AI output, send it back. That is not
rude. It is how we protect each other's time.

## For engineering

You are the author, regardless of who wrote the first draft. "The AI wrote
it" is never an explanation.

### Before opening a pull request

- Read every line of your own diff, top to bottom. Most of this dies right
  there and it costs you five minutes.
- Run the code.
- Verify every dependency, API, version, and function signature actually
  exists. Invented APIs and confidently wrong version assumptions are the
  most common failure mode.
- Remove code you do not understand.
- Delete what you did not ask for: defensive branches, config flags,
  try/catch around things that do not throw, abstractions for a second use
  case that does not exist. Dead code is forever.
- Keep the change small. AI made it trivial to generate 800 lines.
  Splitting that up is your job, not the reviewer's.
- Match the conventions of the existing codebase, not the model's idea of
  best practice.

If you cannot defend a line during review, it does not belong in the pull
request.

### Tests

Tests must verify the behavior you wanted, not confirm the implementation
the model produced.

A test generated from buggy code will pass against that bug and tell you it
was intended. That is worse than no test.

### Pull request descriptions

Explain **why** the change exists and **what you personally verified**. The
diff already explains what changed.

"Ran the suite" is not verification. Name what you actually checked: the
command you ran, the case you exercised, the assumption you confirmed
against a source.

### Review

AI review is encouraged. Human review is required. See
[code-review.md](code-review.md).

## Ownership

A human name is attached to everything we ship. That person owns the
outcome. Not the model, not the prompt, not the tool.

We are the computation layer of the evidence economy. Our credibility depends on applying
the same standards internally that we expect the world to trust externally.

We do not ship noise. We ship judgment.

## Related

- [agent-boundaries.md](agent-boundaries.md) covers what an agent may and may
  not do. This file covers what you owe a reader.
- [code-review.md](code-review.md) turns the pre-pull-request list above into
  what a reviewer blocks on.

## Provenance

Adapted from the company AI Guidelines page in Confluence (Wiki space, last
modified 31 Jul 2026). This file is the canonical engineering copy; the
Confluence page is the company-wide one. When either changes in substance,
re-sync the other by hand and note it in the changelog.
