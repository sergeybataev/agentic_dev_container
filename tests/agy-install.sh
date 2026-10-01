#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
dockerfile="$repo_root/Dockerfile"

assert_contains() {
  grep -F "$1" "$dockerfile" >/dev/null || {
    echo "missing expected text in $dockerfile: $1" >&2
    exit 1
  }
}

assert_contains 'ARG AGY_VERSION=1.2.14'
assert_contains 'ARG AGY_RELEASE_ID=4571742832820224'
assert_contains 'antigravity-cli/${AGY_VERSION}-${AGY_RELEASE_ID}/${AGY_DIR}/cli_linux_${AGY_ARCH}.tar.gz'
assert_contains 'test "$(/usr/local/bin/agy --version)" = "${AGY_VERSION}"'
if grep -F '1.1.5-5958982624477184' "$dockerfile" >/dev/null; then
  echo "obsolete agy download URL in $dockerfile" >&2
  exit 1
fi

echo "agy installation checks passed"
