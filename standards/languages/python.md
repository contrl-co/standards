# Python

## uv, not pip

uv is the only supported package manager. New projects start with
`uv init`. Existing ones migrate.

Two files, both committed:

| File             | Holds                                 | Analogue                      |
|------------------|---------------------------------------|-------------------------------|
| `pyproject.toml` | declared dependencies and constraints | `go.mod`, `package.json`      |
| `uv.lock`        | the resolved graph, with hashes       | `go.sum`, `package-lock.json` |

That split is the point. Declared intent stays separate from resolution, so
a reviewer can see what you asked for and what you got as two different
things.

`requirements.txt` is not a source of truth here. It collapses both roles
into one file, which is why nothing can tell you it has gone stale: there is
no declaration left to compare the resolution against. If an external
consumer needs one, generate it with `uv export` and treat it as a build
artifact, never an input.

`pyproject.toml` is PEP 621, a standard, not a uv invention. Only the lock
format is uv-specific, so the manifest stays portable if we ever move.

### To be accurate about pip

pip is not unsafe. `pip-compile --generate-hashes` plus
`pip install --require-hashes` gives the same integrity guarantee `uv.lock`
does. The difference is defaults: uv records hashes because it always does,
pip records them if you remembered both flags.

We standardize on uv for these reasons, in order:

1. **Drift is detectable.** `uv lock --check` fails when the lock no longer
   matches `pyproject.toml`. There is no equivalent for a bare
   `requirements.txt` because there is nothing to check it against.
2. **One lockfile for every platform.** `uv.lock` resolves across operating
   systems and Python versions. A compiled `requirements.txt` is per
   environment, so multi-platform work means several files that drift
   independently.
3. **Hashes by default**, rather than by remembering a flag.
4. **The Python version is enforced, not suggested.** `uv python pin` writes
   `.python-version` and uv installs and uses that interpreter. A
   `.python-version` file alone is advisory.

### CI

```sh
uv lock --check     # lock matches pyproject.toml, or fail
uv sync --locked    # install exactly the lock, or fail
```

Use `--locked`, not `--frozen`. `--frozen` installs the lock *without*
checking it against `pyproject.toml`, so a stale lock passes silently.
`--locked` raises instead of updating.

Pin uv itself in the workflow. An unpinned resolver is an unpinned build:
the lock is reproducible only under a resolver that reads it the same way.

### The Python version

Lives in `pyproject.toml` under `requires-python`, and in `.python-version`
via `uv python pin`. CI reads those. Never hardcode a version in a workflow;
the two drift and the drift is silent.

## Required gates

Every pull request:

- `uv lock --check`
- `uv sync --locked`
- `uv run ruff format --check .`
- `uv run ruff check .`
- A type checker in strict mode across the whole package, not per file.
- `uv run pytest -q` with no warnings escalated away.
- A dependency vulnerability scan on a schedule as well as on pull requests.

Run everything through `uv run` so the gate uses the locked environment. A
tool invoked from the ambient PATH is a different tool than the one the lock
describes, and it will disagree with local runs at the worst moment.

Tool versions belong in `pyproject.toml` as dev dependencies, which puts
them in the lock. A linter that upgrades itself turns an unrelated pull
request red.

## Typing

Type hints are required on every public function, method, and module-level
constant. Internal helpers may omit them where the inference is obvious and
local.

Strict mode is the default. `Any` is an escape hatch that needs the same
justification as a lint suppression: a comment saying why no real type
exists.

`# type: ignore` without a specific error code and a reason is a defect. Use
`# type: ignore[arg-type]  # reason`, or fix the type.

## Errors

Never a bare `except:`. Never `except Exception:` without re-raising or
logging with the traceback.

Never swallow an exception to make a test or a gate pass. That is the same
defect as a lint suppression, and it is harder to find later.

## Logging

`logging`, or a structured logger configured once at the entry point. Never
`print` to report what the program is doing.

Logs have to be filterable by level and sanitizable in production. A `print`
cannot be leveled, silenced, redacted, or routed, so it is either noise in
production or a leak.

`print` is fine for a CLI writing its actual output to stdout. That is the
program's result, not a log.

Log the exception with `logger.exception(...)` inside an `except` block so
the traceback survives. A logged message without the traceback is a
debugging session you will have to redo.

## Immutability

Data models are frozen dataclasses or Pydantic models with mutation
disabled, not plain classes with a convention.

`frozen=True` on a dataclass holding a `list` still lets the list be
mutated. If the contents must not change, use a tuple or a frozenset. The
annotation is a claim, and a claim about a container says nothing about what
is inside it. See [lint-policy.md](lint-policy.md).

Never use a mutable default argument. Use `field(default_factory=list)` or
`None` plus a guard.

## Layout

Src layout, so tests import the installed package rather than the working
directory:

```
pyproject.toml
src/<package>/
tests/
```

A test that passes only because `.` is on `sys.path` will fail the moment
the package is installed for real.

## Notebooks

Notebooks are for exploration, not for shipping. Anything a notebook proves
that matters gets moved into `src/` with a test before it counts.

If a notebook is committed, strip its outputs. Committed outputs make every
diff unreadable and leak whatever was on screen.
