# Standards index

Read these in order on your first day. After that, treat them as reference.

| File | Covers |
|---|---|
| [ai-guidelines.md](ai-guidelines.md) | Why any of this exists. What you owe a reader. Read this first. |
| [context.md](context.md) | What we build, where the code lives, and the invariants no change may weaken. |
| [agent-boundaries.md](agent-boundaries.md) | What a coding agent may and may not do. |
| [prose.md](prose.md) | Writing rules for code, comments, docs, and commit messages. |
| [commits.md](commits.md) | Commit format, signing, merge methods. |
| [code-review.md](code-review.md) | Labels, approvals, required checks, what blocks a merge. |
| [issue-tracker.md](issue-tracker.md) | What a ticket is for, and what does not belong in a comment. |
| [agent-review-guide.md](agent-review-guide.md) | Point an agent at this to review a pull request against these standards. |
| [lint-policy.md](lint-policy.md) | Why suppressing a linter is a defect. |
| [languages/go.md](languages/go.md) | Go specifics. |
| [languages/python.md](languages/python.md) | Python specifics. |
| [languages/node-vite.md](languages/node-vite.md) | Node, TypeScript, and Vite specifics, including UI. |

## Precedence

1. A repository's own `CONTRIBUTING.md` or `CLAUDE.md`, where it states an
   explicit exception and says why.
2. These standards.
3. Language or framework defaults.

An exception in a consumer repo is fine. An undocumented divergence is not.
