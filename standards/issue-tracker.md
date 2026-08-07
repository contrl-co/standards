# Issue tracker

Applies to Jira, to humans, and to any agent acting on a person's behalf.

The board exists so a person can decide what to work on and confirm what was
built. It is not a build log. Every comment costs everyone who follows the
ticket a read.

## The ticket is the ask, not the diary

A description says what outcome is wanted and how we will know it happened.
Keep it bite-sized so a human can act as the final verification layer on what
gets built.

Some detail and explanation is fine. A wall of text is not: if nobody can
read it in under a minute, nobody verifies it, and an unverified ticket is
worse than a short one.

If the reasoning is long, it belongs in a linked document or a decision
record. Link it, do not paste it.

## A ticket is not a copy of the pull request

Every pull request tracks a ticket ([code-review.md](code-review.md)). That
rule creates an obvious failure mode: tickets opened only to satisfy it,
whose description is the pull request description pasted a day early.

That is the same noise this document exists to stop, produced by policy
instead of by habit.

The ticket is written before the work and says what outcome is wanted. The
pull request is written after and says what changed and what was verified.
If you can write the ticket only after finishing the branch, the ticket is
not an ask, it is a receipt, and nobody needs it.

## Do not narrate status

Progress is not news. Commits, branches, test runs, and green pipelines are
already recorded where they happened.

Once a pull request exists, link it once and stop. The diff shows what
changed, the commits show when, and CI shows whether it passed. Restating
that in a comment produces a second, staler copy of a story the reviewer is
about to read in full anyway.

Specifically, do not comment:

- That work has started, resumed, or is ongoing.
- That a local commit exists, or its hash, when it is not pushed.
- That a test suite, linter, or scanner passed. That is the baseline, and
  CI is the record.
- A restatement of what the linked pull request already shows.
- A summary of a previous comment on the same ticket.

## One running comment, not an append log

When there is genuinely no pull request to point at, a status comment is the
right channel. Keep exactly one, and edit it as things change.

Appending a fresh comment every time the state moves leaves a stack where
only the last one is true and every earlier one still has to be read to find
that out. Five comments in an afternoon that each supersede the previous one
is four comments too many.

Update the ticket status field. That is what it is for.

## Comment when a human has to act

The bar is: a person reading this needs to do something, decide something,
or would be wrong without it.

That includes:

- Blocked, and by what specifically.
- Needs a decision, with the options and a recommendation.
- Needs a credential, an approval, or access somebody else controls.
- Scope changed, or the acceptance criteria no longer match reality.
- A finding that changes the plan, with the evidence.

"Pending: independent approval and the release credential" is a good
comment. It names what a human must do next.

## For agents

Do not post to the tracker unless you were asked to, in that conversation,
for that ticket. See [agent-boundaries.md](agent-boundaries.md): the tracker
is a remote service like any other.

When you are asked to, write one comment that a person can act on. If the
information is "here is what I did", the answer is a pull request, not a
comment.

Never post a running commentary of your own work. The person you are working
with can see your work. The rest of the team cannot unsubscribe.

## Why this is a standard and not a preference

We use AI to make the work lighter. Generated status updates invert that:
one agent produces them in seconds and every person on the ticket pays to
read them. That is the same cost asymmetry described in
[ai-guidelines.md](ai-guidelines.md), pointed at the board instead of the
pull request.
