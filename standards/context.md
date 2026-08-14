# Context

What anyone — person or agent — needs to know about this organization
before touching code. Facts here change; when one does, change it here so
every repository inherits the correction on its next sync.

## What we build

CONTRL is a capital-governance platform for milestone-based infrastructure
escrow: money moves only when independently verifiable facts show the
governing rules are satisfied. It is API-only; there is no end-user
frontend. CRL, the CONTRL Rule Language, is the public language those rules
are written in.

## Where the code lives

The GitHub org `contrl-co` is authoritative for every repository.
`gitlab.com/contrl-group` is the legacy home, kept read-only for old
consumers. Never push there and never open work there.

- `platform` — CONTRL Core services (Go) and the rule-builder studio
  sidecar (Python). `develop` is the integration branch; `main` is
  promoted from it.
- `crl` — the public CRL repository. Work lands on `develop`; `main` is
  the published face.
- `standards` — this repository, vendored into the others.
- `workflows` — reusable CI that other repositories pin.
- `studio`, `website`, `infrastructure`, `homebrew-tap`, `connectors`,
  `erp-frontend`, `erp-backend` — what their names say.

Tickets live in Jira under the `CONTRL` project key; branch names carry
the key ([commits.md](commits.md)).

## Invariants no change may weaken

These are the product. A diff that touches one is a blocker until its owner
signs off, however small the diff looks.

- **No master key.** No single party, CONTRL included, can complete
  verification alone; the verifier policy enforces mutual validation. A
  change that lets one party or one key fragment verify by itself is a
  defect by definition.
- **Canonical output is stable.** Anything that moves the hash of
  unchanged input is a breaking change and carries a version or edition
  bump in the same pull request. See [languages/go.md](languages/go.md).
- **Gates fail closed.** A verification, trust, or settlement path that
  hits missing data must refuse, never assume. Fail-open is the defect
  class this company exists to eliminate.
- **Tests that need a real service fail loudly without it.** A suite that
  silently skips reports coverage that does not exist. If a test needs
  Postgres or any other fixture, require it and fail when it is absent.

## Licensing

CRL is published under AGPL-3.0, and the only-vs-or-later question is an
open decision. Do not add a dependency on the public CRL module from a
closed-source service, and do not resolve license wording inside an
unrelated diff. Stop and flag it to the owner instead.
