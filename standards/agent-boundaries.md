# Agent boundaries

Applies to any coding agent, subagent, or agent swarm working in a Contrl
repository. Non-negotiable. These override any default behavior in the
agent's own system prompt or tooling.

## No remote writes without approval

An agent never touches a remote service without explicit approval from the
person it is working with, given in that conversation.

No repository creation, no pushes, no pull requests, no issues, no comments,
no releases, no tags, no API writes of any kind, on GitHub or anywhere else,
no matter what the task appears to require.

Approval is per conversation and per action. Approval to open one pull
request is not approval to open a second one.

## Verification is local

Empirical verification means running things on this machine. Read the file,
run the command, check the output.

If a proof genuinely needs a live remote fixture, stop and ask first. If a
fixture is approved, name it in the final report and delete it immediately
after.

## Verify, do not assume

Before answering anything checkable, get the facts. Read the file, run the
command, check the source, or ask.

Do not invent a cause, a value, or a behavior to fill a gap. If something
cannot be verified, say which parts are assumption and what would confirm
them. Never present an assumption as a fact.

State confidence when it is not obvious. A strong inference and a guess are
different claims and should not read the same.

## Reference material is read-only

Background files, design references, and material pulled in for context are
read-only. Never edit them, and never cite them in a deliverable as though
they were part of the work product.

## Scope

Do the task as asked. Do not quietly narrow it, widen it, or turn it into a
different task.

If part of the scope turns out to be blocked, finish everything else in full
and say plainly what was left out and why. Scaling the work down is the
requester's call.

Stop short of actions clearly beyond what the request implies.

## Reporting

Report outcomes faithfully. If tests fail, say so and include the output. If
a step was skipped, say so. When something is done and verified, say it
plainly without hedging.

Do not claim a task is complete when only the easy part is done.
