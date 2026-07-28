#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/punch-cli-test.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT HUP INT TERM

release_dir=$test_dir/release
prefix=$test_dir/prefix
mkdir -p -- "$release_dir/payload/bin" "$release_dir/payload/lib" "$release_dir/payload/runtime/bin"
cp -- "$repo_dir/install.sh" "$repo_dir/uninstall.sh" "$release_dir/"
cp -- "$repo_dir/packaging/punch-buyer" "$repo_dir/packaging/punch-provider" "$release_dir/payload/bin/"
cp -- /bin/sh "$release_dir/payload/runtime/bin/node"
printf '%s\n' '0.0.0-test' > "$release_dir/VERSION"

"$release_dir/install.sh" --role buyer --prefix "$prefix"
[ -L "$prefix/bin/punch-buyer" ]
[ ! -e "$prefix/bin/punch-provider" ]
[ -d "$prefix/share/punch-cli/0.0.0-test" ]

mkdir -p -- "$prefix/state"
printf '%s\n' 'preserve' > "$prefix/state/identity"
"$release_dir/uninstall.sh" --version 0.0.0-test --prefix "$prefix"
[ ! -e "$prefix/bin/punch-buyer" ]
[ ! -e "$prefix/share/punch-cli/0.0.0-test" ]
[ "$(sed -n '1p' "$prefix/state/identity")" = preserve ]

ln -s -- /bin/true "$prefix/bin/punch-buyer"
if "$release_dir/install.sh" --role buyer --prefix "$prefix" > /dev/null 2>&1; then
  printf '%s\n' 'installer replaced an unrelated symlink' >&2
  exit 1
fi
[ "$(readlink "$prefix/bin/punch-buyer")" = /bin/true ]
[ ! -e "$prefix/share/punch-cli/0.0.0-test" ]

mkdir -p -- "$prefix/share/preserve"
printf '%s\n' 'sentinel' > "$prefix/share/preserve/sentinel"
if "$release_dir/uninstall.sh" --version .. --prefix "$prefix" > /dev/null 2>&1; then
  printf '%s\n' 'uninstaller accepted a traversal-like version' >&2
  exit 1
fi
[ "$(sed -n '1p' "$prefix/share/preserve/sentinel")" = sentinel ]

printf '%s\n' 'install/uninstall tests: PASS'
