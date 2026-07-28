#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/punch-cli-no-rg.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT HUP INT TERM

marker=$test_dir/rg-invoked
printf '%s\n' '#!/bin/sh' ': > "$PUNCH_RG_MARKER"' 'exit 127' > "$test_dir/rg"
chmod 0755 "$test_dir/rg"

PUNCH_RG_MARKER=$marker PATH="$test_dir:$PATH" "$repo_dir/scripts/validate-public.sh"
[ ! -e "$marker" ] || {
  printf '%s\n' 'public validation still invoked rg' >&2
  exit 1
}

fixture_repo=$test_dir/repo
mkdir -p -- "$fixture_repo"
cp -R "$repo_dir/." "$fixture_repo/"

secret_value=$(printf '%s%s' 'gh' 'p_SYNTHETIC_PUBLIC_SCANNER_TEST_VALUE')
stdout=$test_dir/stdout
stderr=$test_dir/stderr
printf '%s\n' "$secret_value" > "$fixture_repo/synthetic-secret.txt"
if PATH="$test_dir:$PATH" "$fixture_repo/scripts/validate-public.sh" > "$stdout" 2> "$stderr"; then
  printf '%s\n' 'public validation accepted synthetic secret material' >&2
  exit 1
fi
if grep -F "$secret_value" "$stdout" "$stderr" > /dev/null 2>&1; then
  printf '%s\n' 'public validation exposed matched secret contents' >&2
  exit 1
fi
rm -- "$fixture_repo/synthetic-secret.txt"

mkdir -p -- "$fixture_repo/nested"
printf '%s\n' "$secret_value" > "$fixture_repo/nested/validate-public.sh"
if PATH="$test_dir:$PATH" "$fixture_repo/scripts/validate-public.sh" > "$stdout" 2> "$stderr"; then
  printf '%s\n' 'public validation skipped a nested same-basename file' >&2
  exit 1
fi
if ! grep -F './nested/validate-public.sh' "$stderr" > /dev/null 2>&1; then
  printf '%s\n' 'public validation did not report the nested same-basename file' >&2
  exit 1
fi
if grep -F "$secret_value" "$stdout" "$stderr" > /dev/null 2>&1; then
  printf '%s\n' 'public validation exposed matched contents from nested file' >&2
  exit 1
fi
rm -- "$fixture_repo/nested/validate-public.sh"

outside_dir=$test_dir/outside
outside_file=$outside_dir/external-secret.txt
mkdir -p -- "$outside_dir"
printf '%s\n' "$secret_value" > "$outside_file"
ln -s -- "$outside_file" "$fixture_repo/external-file-link"
ln -s -- "$outside_dir" "$fixture_repo/external-dir-link"
PATH="$test_dir:$PATH" "$fixture_repo/scripts/validate-public.sh" > "$stdout" 2> "$stderr"
if grep -F "$secret_value" "$stdout" "$stderr" > /dev/null 2>&1 ||
   grep -F "$outside_file" "$stdout" "$stderr" > /dev/null 2>&1; then
  printf '%s\n' 'public validation followed or exposed an external symlink target' >&2
  exit 1
fi

printf '%s\n' 'validation without rg: PASS'
