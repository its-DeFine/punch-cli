#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/punch-cli-test.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT HUP INT TERM

release_dir=$test_dir/release
prefix=$test_dir/prefix
mkdir -p -- "$release_dir/payload/bin" "$release_dir/payload/lib" "$release_dir/payload/runtime/bin"
cp -- "$repo_dir/install.sh" "$repo_dir/uninstall.sh" "$release_dir/"
cp -- "$repo_dir/packaging/punch" "$repo_dir/packaging/punch-buyer" "$repo_dir/packaging/punch-provider" "$release_dir/payload/bin/"
printf '%s\n' '#!/bin/sh' 'exec /bin/sh "$@"' > "$release_dir/payload/runtime/bin/node"
chmod 0755 "$release_dir/payload/runtime/bin/node"
printf '%s\n' '#!/bin/sh' 'printf "buyer:%s\n" "$1"' > "$release_dir/payload/lib/punch-buyer.mjs"
printf '%s\n' '#!/bin/sh' 'printf "provider:%s\n" "$1"' > "$release_dir/payload/lib/punch-provider.mjs"
printf '%s\n' '#!/bin/sh' 'printf "guided:%s\n" "$1"' > "$release_dir/payload/lib/punch.mjs"
printf '%s\n' '0.0.0-test' > "$release_dir/VERSION"

[ "$("$release_dir/payload/bin/punch-buyer" direct)" = buyer:direct ]
[ "$("$release_dir/payload/bin/punch-provider" direct)" = provider:direct ]
[ "$("$release_dir/payload/bin/punch" direct)" = guided:direct ]

"$release_dir/install.sh" --role buyer --prefix "$prefix"
[ -L "$prefix/bin/punch" ]
[ -L "$prefix/bin/punch-buyer" ]
[ ! -e "$prefix/bin/punch-provider" ]
[ -d "$prefix/share/punch-cli/0.0.0-test" ]
[ "$(PATH="$prefix/bin:$PATH" punch-buyer installed)" = buyer:installed ]
[ "$(PATH="$prefix/bin:$PATH" punch installed)" = guided:installed ]

mkdir -p -- "$prefix/state"
printf '%s\n' 'preserve' > "$prefix/state/identity"
"$release_dir/uninstall.sh" --version 0.0.0-test --prefix "$prefix"
[ ! -e "$prefix/bin/punch-buyer" ]
[ ! -e "$prefix/bin/punch" ]
[ ! -e "$prefix/share/punch-cli/0.0.0-test" ]
[ "$(sed -n '1p' "$prefix/state/identity")" = preserve ]

"$release_dir/install.sh" --role provider --prefix "$prefix"
[ -L "$prefix/bin/punch" ]
[ ! -e "$prefix/bin/punch-buyer" ]
[ -L "$prefix/bin/punch-provider" ]
[ "$(PATH="$prefix/bin:$PATH" punch-provider installed)" = provider:installed ]
[ "$(PATH="$prefix/bin:$PATH" punch installed)" = guided:installed ]
"$release_dir/uninstall.sh" --version 0.0.0-test --prefix "$prefix"
[ ! -e "$prefix/bin/punch-provider" ]
[ ! -e "$prefix/bin/punch" ]
[ "$(sed -n '1p' "$prefix/state/identity")" = preserve ]

ln -s -- /bin/true "$prefix/bin/punch"
if "$release_dir/install.sh" --role buyer --prefix "$prefix" > /dev/null 2>&1; then
  printf '%s\n' 'installer replaced an unrelated guided launcher symlink' >&2
  exit 1
fi
[ "$(readlink "$prefix/bin/punch")" = /bin/true ]
rm -- "$prefix/bin/punch"

ln -s -- /bin/true "$prefix/bin/punch-buyer"
if "$release_dir/install.sh" --role buyer --prefix "$prefix" > /dev/null 2>&1; then
  printf '%s\n' 'installer replaced an unrelated symlink' >&2
  exit 1
fi
[ "$(readlink "$prefix/bin/punch-buyer")" = /bin/true ]
[ ! -e "$prefix/share/punch-cli/0.0.0-test" ]

mkdir -p -- "$test_dir/chain-a" "$test_dir/chain-b"
ln -s -- "$release_dir/payload/bin/punch-buyer" "$test_dir/chain-b/punch-buyer"
ln -s -- "$test_dir/chain-b/punch-buyer" "$test_dir/chain-a/punch-buyer"
if "$test_dir/chain-a/punch-buyer" chained > /dev/null 2>&1; then
  printf '%s\n' 'launcher accepted a chained symlink' >&2
  exit 1
fi

mkdir -p -- "$test_dir/cross-role"
ln -s -- "$release_dir/payload/bin/punch-provider" "$test_dir/cross-role/punch-buyer"
if "$test_dir/cross-role/punch-buyer" crossed > /dev/null 2>&1; then
  printf '%s\n' 'Buyer launcher accepted a Provider target' >&2
  exit 1
fi
rm -- "$test_dir/cross-role/punch-buyer"
ln -s -- "$release_dir/payload/bin/punch-buyer" "$test_dir/cross-role/punch-provider"
if "$test_dir/cross-role/punch-provider" crossed > /dev/null 2>&1; then
  printf '%s\n' 'Provider launcher accepted a Buyer target' >&2
  exit 1
fi

mkdir -p -- "$prefix/share/preserve"
printf '%s\n' 'sentinel' > "$prefix/share/preserve/sentinel"
if "$release_dir/uninstall.sh" --version .. --prefix "$prefix" > /dev/null 2>&1; then
  printf '%s\n' 'uninstaller accepted a traversal-like version' >&2
  exit 1
fi
[ "$(sed -n '1p' "$prefix/share/preserve/sentinel")" = sentinel ]

printf '%s\n' 'install/uninstall tests: PASS'
