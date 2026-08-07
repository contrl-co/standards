#!/usr/bin/env bash
#
# Fail if a consumer's vendored .standards/ differs from the version it
# pinned. Vendored to .standards/bin/check-drift.sh by sync.sh and run from
# the consumer's CI:
#
#     - run: .standards/bin/check-drift.sh
#
# Clones over anonymous HTTPS, so it needs no token and works from a public
# repository. That is why contrl-co/standards has to stay public.
#
set -euo pipefail

# STANDARDS_REPO exists so selftest.sh can point at a local clone. Consumers
# never set it.
readonly SOURCE_REPO="${STANDARDS_REPO:-https://github.com/contrl-co/standards.git}"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
vendor_dir=$(dirname "$script_dir")
version_file="$vendor_dir/VERSION"

[ -f "$version_file" ] || {
  echo "check-drift: $version_file is missing. Rerun sync.sh." >&2
  exit 1
}

pinned_tag=$(sed -n 's/^tag=//p' "$version_file")
pinned_commit=$(sed -n 's/^commit=//p' "$version_file")

[ -n "$pinned_tag" ] && [ -n "$pinned_commit" ] || {
  echo "check-drift: $version_file does not record both tag and commit." >&2
  exit 1
}

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$pinned_tag" \
  "$SOURCE_REPO" "$workdir/standards"
actual_commit=$(git -C "$workdir/standards" rev-parse HEAD)

# Tags are mutable. Comparing the resolved commit catches a tag that was
# moved after this consumer vendored it, which a tag-only check would miss.
if [ "$actual_commit" != "$pinned_commit" ]; then
  cat >&2 <<EOF
check-drift: tag $pinned_tag no longer points at the commit this repository
             pinned.

  pinned:  $pinned_commit
  actual:  $actual_commit

A published tag was moved. Confirm that was intentional before rerunning
sync.sh.
EOF
  exit 1
fi

status=0

if ! diff -r \
  --exclude=VERSION \
  --exclude=bin \
  "$workdir/standards/standards" "$vendor_dir"; then
  echo "check-drift: vendored standards differ from $pinned_tag." >&2
  status=1
fi

# Rebuild what bin/ should contain from the pinned tag's own list, then
# compare both directions. A one-way diff would miss a gate script that was
# deleted locally to stop it running.
expected_bin="$workdir/expected-bin"
mkdir -p "$expected_bin"
while read -r script_name; do
  case "$script_name" in ''|\#*) continue ;; esac
  cp "$workdir/standards/scripts/$script_name" "$expected_bin/"
done < "$workdir/standards/scripts/vendored.txt"

if ! diff -r "$expected_bin" "$script_dir"; then
  echo "check-drift: vendored .standards/bin differs from $pinned_tag." >&2
  status=1
fi

if [ "$status" -ne 0 ]; then
  cat >&2 <<EOF

.standards/ is a vendored copy and must not be edited in this repository.
To change a rule, open a pull request against contrl-co/standards. To adopt
a newer version, rerun sync.sh with the new tag.
EOF
  exit 1
fi

echo "check-drift: .standards/ matches $pinned_tag (${pinned_commit:0:7})"
