#!/usr/bin/env bash
#
# Lint every shell script with a pinned shellcheck.
#
#     scripts/check-shell.sh [path ...]     defaults to every tracked *.sh
#
# The distro shellcheck moves when the runner image does, so an unrelated
# pull request goes red the day it moves. This fetches one release, checks
# it against a checksum recorded here, and caches the binary per version so
# a second run does not touch the network. Linux x86_64, aarch64 and armv7,
# and macOS x86_64 and arm64 are covered; anything else fails loud instead
# of falling back to whatever is on PATH.
#
set -euo pipefail

version=v0.11.0

# One checksum per release archive. Bump version and every line together.
case "$(uname -s)/$(uname -m)" in
  Linux/x86_64)
    target=linux.x86_64
    sha256=8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198
    ;;
  Linux/aarch64)
    target=linux.aarch64
    sha256=12b331c1d2db6b9eb13cfca64306b1b157a86eb69db83023e261eaa7e7c14588
    ;;
  Linux/armv6l | Linux/armv7l)
    target=linux.armv6hf
    sha256=8afc50b302d5feeac9381ea114d563f0150d061520042b254d6eb715797c8223
    ;;
  Darwin/x86_64)
    target=darwin.x86_64
    sha256=3c89db4edcab7cf1c27bff178882e0f6f27f7afdf54e859fa041fca10febe4c6
    ;;
  Darwin/arm64)
    target=darwin.aarch64
    sha256=56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79
    ;;
  *)
    echo "check-shell: no shellcheck $version release for $(uname -s)/$(uname -m)" >&2
    exit 1
    ;;
esac

# RUNNER_TEMP is per-job on GitHub Actions; TMPDIR is the local equivalent.
cache="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/shellcheck-$version-$target"
shellcheck="$cache/shellcheck-$version/shellcheck"

if [ ! -x "$shellcheck" ]; then
  mkdir -p "$cache"
  archive="$cache/shellcheck.tar.xz"
  curl -fsSL --proto '=https' --tlsv1.2 -o "$archive" \
    "https://github.com/koalaman/shellcheck/releases/download/$version/shellcheck-$version.$target.tar.xz"
  # GNU and BSD sha256sum disagree on --check flags, and older macOS only
  # has shasum, so compare the digest here instead of trusting either.
  if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$archive" | cut -d' ' -f1)
  else
    actual=$(shasum -a 256 "$archive" | cut -d' ' -f1)
  fi
  if [ "$actual" != "$sha256" ]; then
    echo "check-shell: checksum mismatch for $archive" >&2
    echo "  expected $sha256" >&2
    echo "  actual   $actual" >&2
    rm -f "$archive"
    exit 1
  fi
  tar -xJf "$archive" -C "$cache"
  rm -f "$archive"
fi

if [ $# -gt 0 ]; then
  files=("$@")
else
  # --others so a script that has not been staged yet is still linted.
  files=()
  while IFS= read -r file; do
    files+=("$file")
  done < <(git ls-files --cached --others --exclude-standard -- '*.sh')
fi

if [ ${#files[@]} -eq 0 ]; then
  echo "check-shell: no shell scripts to lint"
  exit 0
fi

"$shellcheck" --severity=style "${files[@]}"
echo "check-shell: ok (${#files[@]} files, shellcheck $version)"
