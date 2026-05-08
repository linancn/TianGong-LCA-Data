#!/bin/sh
set -eu

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

find_docpact() {
  if [ -n "${DOCPACT_BIN:-}" ] && "$DOCPACT_BIN" --version >/dev/null 2>&1; then
    printf '%s\n' "$DOCPACT_BIN"
    return 0
  fi

  if [ -x "$HOME/.cargo/bin/docpact" ] && "$HOME/.cargo/bin/docpact" --version >/dev/null 2>&1; then
    printf '%s\n' "$HOME/.cargo/bin/docpact"
    return 0
  fi

  if command -v docpact >/dev/null 2>&1; then
    command -v docpact
    return 0
  fi

  echo "docpact was not found. Install it with: cargo install docpact --version 0.1.4 --force" >&2
  echo "Or set DOCPACT_BIN to an executable docpact binary." >&2
  return 127
}

docpact_bin="$(find_docpact)"
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
"$docpact_bin" validate-config --root . --strict

echo "Running docpact lint: base=$base_sha head=$head_sha."
"$docpact_bin" lint --root . --base "$base_sha" --head "$head_sha" --mode enforce --output "$report_path"
