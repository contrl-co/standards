# Go

## Toolchain

The Go version lives in `go.mod` and nowhere else. CI resolves it with
`go-version-file: go.mod`. Never hardcode a version in a workflow; the two
drift and the drift is silent.

```yaml
- uses: actions/setup-go@<pinned-sha>
  with:
    go-version-file: go.mod
    cache-dependency-path: go.sum
```

`GOFLAGS: -mod=readonly` in CI. A build that edits `go.mod` is a build that
was not reproducible.

## Required gates

Every pull request:

- `gofmt -l .` produces no output.
- `go build ./...`
- `go vet ./...`
- `golangci-lint` at a pinned version.
- `go test ./... -race -count=1`
- `govulncheck ./...` at a pinned analyzer version.

`-count=1` because a cached test result is not a test run.

## Cross-platform

If the product is deterministic output, test on Linux, macOS, and Windows.
A single Linux runner does not prove determinism, and determinism is exactly
the property that breaks per platform.

Pin line endings so a Windows checkout does not silently rewrite fixtures:

```
* text=auto
*.go   text eol=lf
*.json text eol=lf
*.md   text eol=lf
*.txt  text eol=lf
```

Add every extension present under `testdata/`, `examples/`, and golden
corpora. An uncovered extension falls back to platform-native line endings
and the golden test fails only on Windows.

## Determinism and canonical output

If a change moves the hash of unchanged source, it is a breaking change to
consumers regardless of what the type system says.

Such a change requires, in the same pull request:

1. A declared version or edition bump.
2. A regenerated golden corpus.
3. A changelog entry saying hashes moved and why.

No override path. Gate it with a script, not a review checklist.

## Module paths

Changing a module path is breaking. Consumers pinned to older tags cannot
resolve the new path, and `@latest` resolves to a tag whose `go.mod`
declares the old path, which fails with:

```
module declares its path as: <old>
        but was required as: <new>
```

After a module path change, cut a new tag before documenting
`go install <new-path>@latest`. Until that tag exists, the documented
command is broken.

## Logging

A real logger, chosen once per binary and passed down. Never `fmt.Println`
or `fmt.Printf` to report what the program is doing.

Logs have to be filterable by level and sanitizable in production. A
`Println` cannot be leveled, silenced, redacted, or routed, so it is either
noise in production or a leak.

`fmt.Print` is fine for a CLI writing its actual output to stdout. That is
the program's result, not a log.

## Immutability

Prefer value semantics. A function that takes a slice or a map takes a
reference to the caller's data and can mutate it from under them.

If a type must not be mutated after construction, do not document that,
enforce it: unexported fields with a constructor, accessor methods, and a
copy on the way out. A comment saying "do not modify" is a claim, not a
guarantee. See [lint-policy.md](lint-policy.md).

## Reproducible builds

CGO disabled, `-trimpath`, stripped symbols, and `mod_timestamp` pinned to
the commit. The same tag must build byte-identical binaries anywhere.

Verify it in CI with a snapshot build, not only at release time.
