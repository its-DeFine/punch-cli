#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

sh -n install.sh uninstall.sh packaging/punch-buyer packaging/punch-provider tests/install-uninstall.sh

for file in README.md SECURITY.md CONTRIBUTING.md docs/*.md packaging/README.md; do
  sed -n 's/.*](\([^#][^)]*\.md\)).*/\1/p' "$file" | while IFS= read -r target; do
    case "$target" in
      /*) resolved=$target ;;
      *) resolved=$(dirname "$file")/$target ;;
    esac
    [ -f "$resolved" ] || {
      printf 'broken Markdown link in %s: %s\n' "$file" "$target" >&2
      exit 1
    }
  done
done

if rg -n --hidden -S \
  '(/home/|/Users/|192\.168\.|100\.77\.|SUPABASE|DATABASE_URL|BEGIN [A-Z ]*PRIVATE KEY|ghp_|github_pat_|cloudflared.*token|punch-compute)' \
  --glob '!scripts/validate-public.sh' .; then
  printf '%s\n' 'private or secret-like material detected' >&2
  exit 1
fi

./tests/install-uninstall.sh
printf '%s\n' 'public repository validation: PASS'
