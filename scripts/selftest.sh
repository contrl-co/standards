#!/usr/bin/env bash
#
# Exercise sync.sh and check-drift.sh against a throwaway consumer built
# from the current working tree.
#
#     scripts/selftest.sh
#
# Both scripts only ever run inside other repositories, so nothing in this
# repo's normal use would catch them breaking. Runs entirely locally; it
# never contacts github.com.
#
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

source_repo="$workdir/source"
consumer="$workdir/consumer"
tag="v0.0.0-selftest"

# A tagged clone of the working tree, including uncommitted edits, so the
# selftest checks what is about to be reviewed and not the last commit.
mkdir -p "$source_repo"
tar -C "$repo_root" --exclude=.git -cf - . | tar -C "$source_repo" -xf -
git -C "$source_repo" init --quiet
git -C "$source_repo" add -A
git -C "$source_repo" \
  -c user.name=selftest \
  -c user.email=selftest@contrl.co \
  -c commit.gpgsign=false \
  commit --quiet -m "selftest snapshot"
git -C "$source_repo" tag "$tag"

git -C "$consumer" init --quiet 2>/dev/null || {
  mkdir -p "$consumer"
  git -C "$consumer" init --quiet
}

export STANDARDS_REPO="file://$source_repo"

echo "--- sync into a fresh consumer"
"$repo_root/scripts/sync.sh" "$consumer" "$tag" >/dev/null

for expected in \
  .standards/VERSION \
  .standards/prose.md \
  .standards/languages/go.md \
  .standards/bin/check-drift.sh \
  .standards/bin/check-branch-name.sh \
  CLAUDE.md \
  AGENTS.md \
  .github/copilot-instructions.md \
  .cursor/rules/contrl-standards.mdc; do
  if [ ! -f "$consumer/$expected" ]; then
    echo "selftest: sync.sh did not produce $expected" >&2
    exit 1
  fi
done
echo "    ok: every expected path was written"

echo "--- drift check on a clean vendor"
"$consumer/.standards/bin/check-drift.sh"

echo "--- branch name gate accepts and rejects the right shapes"
for good in \
  fix/CONTRL-35-rotate-tap-token \
  chore/CONTRL-4-ci-infra-for-crl \
  feat/ERP-12-shipment-release-bundle \
  main develop gh-readonly-queue/develop/pr-27-abc123; do
  if ! "$consumer/.standards/bin/check-branch-name.sh" "$good" >/dev/null 2>&1; then
    echo "selftest: check-branch-name.sh rejected a valid branch: $good" >&2
    exit 1
  fi
done
for bad in \
  codex/CONTRL-35-rotate-tap-token \
  fix/contrl-35-rotate-tap-token \
  fix/rotate-tap-token \
  chore/setup-ci \
  CONTRL-35-rotate-tap-token \
  fix/CONTRL-35 \
  "fix/CONTRL-35-Rotate Tap Token"; do
  if "$consumer/.standards/bin/check-branch-name.sh" "$bad" >/dev/null 2>&1; then
    echo "selftest: check-branch-name.sh accepted an invalid branch: $bad" >&2
    exit 1
  fi
done
echo "    ok: branch shapes accepted and rejected as specified"

echo "--- drift check detects a deleted gate script"
mv "$consumer/.standards/bin/check-branch-name.sh" "$workdir/stashed-gate.sh"
if "$consumer/.standards/bin/check-drift.sh" >/dev/null 2>&1; then
  echo "selftest: check-drift.sh passed a deleted gate script" >&2
  exit 1
fi
mv "$workdir/stashed-gate.sh" "$consumer/.standards/bin/check-branch-name.sh"
chmod +x "$consumer/.standards/bin/check-branch-name.sh"
echo "    ok: deleted gate was rejected"

echo "--- drift check detects an edited vendored file"
echo "unauthorized local edit" >> "$consumer/.standards/prose.md"
if "$consumer/.standards/bin/check-drift.sh" >/dev/null 2>&1; then
  echo "selftest: check-drift.sh passed an edited vendored file" >&2
  exit 1
fi
echo "    ok: edit was rejected"
git -C "$source_repo" show "$tag:standards/prose.md" > "$consumer/.standards/prose.md"

echo "--- drift check detects a moved tag"
echo "# moved" >> "$source_repo/standards/prose.md"
git -C "$source_repo" add -A
git -C "$source_repo" \
  -c user.name=selftest \
  -c user.email=selftest@contrl.co \
  -c commit.gpgsign=false \
  commit --quiet -m "selftest move"
git -C "$source_repo" tag -f "$tag" >/dev/null 2>&1
if "$consumer/.standards/bin/check-drift.sh" >/dev/null 2>&1; then
  echo "selftest: check-drift.sh passed a moved tag" >&2
  exit 1
fi
echo "    ok: moved tag was rejected"

echo "--- sync does not clobber a customized CLAUDE.md"
printf '\n## Repository specifics\n\nlocal note\n' >> "$consumer/CLAUDE.md"
before=$(sha256sum "$consumer/CLAUDE.md" | awk '{print $1}')
git -C "$source_repo" tag -f "$tag" HEAD >/dev/null 2>&1
"$repo_root/scripts/sync.sh" "$consumer" "$tag" >/dev/null
after=$(sha256sum "$consumer/CLAUDE.md" | awk '{print $1}')
if [ "$before" != "$after" ]; then
  echo "selftest: sync.sh overwrote a customized CLAUDE.md without --force" >&2
  exit 1
fi
echo "    ok: CLAUDE.md preserved"

echo
echo "selftest: ok"
