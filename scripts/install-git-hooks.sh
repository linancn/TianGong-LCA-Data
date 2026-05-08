#!/bin/sh
set -eu

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

git config core.hooksPath .githooks
chmod +x .githooks/pre-push scripts/docpact-gate.sh

echo "Configured git hooks: core.hooksPath=.githooks"
