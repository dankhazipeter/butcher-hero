#!/bin/sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
current=$(git config --local --get core.hooksPath || true)
if [ -n "$current" ] && [ "$current" != '.githooks' ]; then
    printf 'Existing hook configuration (%s) left unchanged. Integrate it first.\n' "$current" >&2
    exit 1
fi
git config --local core.hooksPath .githooks
printf 'Enabled mandatory pre-commit and pre-push reward tests for this clone.\n'
