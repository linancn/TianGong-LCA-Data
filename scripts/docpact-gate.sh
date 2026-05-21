#!/bin/sh
set -eu

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

docpact_cmd="$repo_root/scripts/docpact"
current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
head_ref="${DOCPACT_HEAD_REF:-HEAD}"
base_ref="${DOCPACT_BASE_REF:-origin/main}"

case "$current_branch" in
  main | master | promote/* | hotfix/* | release/*)
    if [ -z "${DOCPACT_BASE_REF:-}" ]; then
      base_ref="origin/main"
    fi
    ;;
esac

while [ "$#" -gt 0 ]; do
  case "$1" in
    --base)
      base_ref="$2"
      shift 2
      ;;
    --head)
      head_ref="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if ! base_sha="$(git merge-base "$head_ref" "$base_ref" 2>/dev/null)"; then
  echo "Could not resolve merge-base for $head_ref and $base_ref." >&2
  echo "Fetch the base ref or rerun with DOCPACT_BASE_REF=<ref>." >&2
  exit 2
fi

head_sha="$(git rev-parse "$head_ref")"
report_path="${TMPDIR:-/tmp}/docpact-gate-$$.json"
trap 'rm -f "$report_path"' EXIT HUP INT TERM

echo "Running docpact config validation."
"$docpact_cmd" validate-config --root "$repo_root" --strict

echo "Running docpact lint: base=$base_sha head=$head_sha."
"$docpact_cmd" lint --root "$repo_root" --base "$base_sha" --head "$head_sha" --mode enforce --output "$report_path"
