#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

sh -n install.sh uninstall.sh packaging/punch-buyer packaging/punch-provider \
  images/interactive/punch-interactive images/interactive/punch-ssh-stdio \
  tests/install-uninstall.sh tests/validate-without-rg.sh

for required in packaging/THIRD_PARTY_NOTICES.template.md packaging/third_party/ws-8.21.1/LICENSE; do
  [ -s "$required" ] || {
    printf 'required public licensing template is missing: %s\n' "$required" >&2
    exit 1
  }
done
node_marker_count=$(awk '
  {
    line = $0
    while ((position = index(line, "NODE_VERSION")) != 0) {
      count++
      line = substr(line, position + length("NODE_VERSION"))
    }
  }
  END { print count + 0 }
' packaging/THIRD_PARTY_NOTICES.template.md)
[ "$node_marker_count" -eq 1 ] || {
  printf '%s\n' 'third-party notices template must contain exactly one Node version marker' >&2
  exit 1
}
rendered_notices=$(sed 's/NODE_VERSION/v0.0.0-test/' packaging/THIRD_PARTY_NOTICES.template.md)
if printf '%s\n' "$rendered_notices" | grep -Eq 'NODE_VERSION|must be replaced|must be copied|before release|public source repository'; then
  printf '%s\n' 'rendered third-party notices contain a placeholder or build instruction' >&2
  exit 1
fi
grep -F 'Copyright (c) 2016 Luigi Pinca and contributors' packaging/third_party/ws-8.21.1/LICENSE > /dev/null || {
  printf '%s\n' 'ws 8.21.1 license template is incomplete' >&2
  exit 1
}

for file in README.md SECURITY.md CONTRIBUTING.md docs/*.md packaging/*.md; do
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

scan_pattern='(/home/|/Users/|192\.168\.|100\.77\.|SUPABASE|DATABASE_URL|BEGIN [A-Z ]*PRIVATE KEY|ghp_|github_pat_|cloudflared.*token|punch-compute)'
scan_dir=$(mktemp -d "${TMPDIR:-/tmp}/punch-public-scan.XXXXXX") || {
  printf '%s\n' 'could not create temporary directory for public material scan' >&2
  exit 1
}
scan_matches=$scan_dir/matches
scan_errors=$scan_dir/errors
find_errors=$scan_dir/find-errors
: > "$scan_matches" || exit 1
: > "$scan_errors" || exit 1
: > "$find_errors" || exit 1
trap 'rm -rf -- "$scan_dir"' EXIT HUP INT TERM

set +e
find . \
  -path './.git' -prune -o \
  -type f ! -path './scripts/validate-public.sh' \
  -exec sh -c '
    pattern=$1
    matches=$2
    errors=$3
    shift 3
    scan_error() {
      printf "%s\n" error >> "$errors" 2> /dev/null || printf "%s\n" error >&2
      exit 1
    }
    for file do
      grep -Eq "$pattern" "$file" > /dev/null 2>&1
      status=$?
      case "$status" in
        0)
          case "$file" in
            *[!A-Za-z0-9_./-]*) display="./[path-withheld]" ;;
            *)
              printf "%s\n" "$file" | grep -Eq "$pattern" > /dev/null 2>&1
              path_status=$?
              case "$path_status" in
                0) display="./[path-withheld]" ;;
                1) display=$file ;;
                *) scan_error ;;
              esac
              ;;
          esac
          printf "%s\n" "$display" >> "$matches" 2> /dev/null || scan_error
          ;;
        1) ;;
        *) scan_error ;;
      esac
    done
  ' sh "$scan_pattern" "$scan_matches" "$scan_errors" {} + 2> "$find_errors"
find_status=$?
set -e
if [ "$find_status" -ne 0 ] || [ -s "$scan_errors" ] || [ -s "$find_errors" ]; then
  printf '%s\n' 'public material scan failed' >&2
  exit 1
fi
if [ -s "$scan_matches" ]; then
  while IFS= read -r file; do
    printf 'private or secret-like material detected in %s\n' "$file" >&2
  done < "$scan_matches"
  exit 1
fi

rm -rf -- "$scan_dir"
trap - EXIT HUP INT TERM

./tests/install-uninstall.sh
printf '%s\n' 'public repository validation: PASS'
