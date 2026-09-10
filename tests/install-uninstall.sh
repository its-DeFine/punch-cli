#!/bin/sh
set -eu
umask 022

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

old_release=$test_dir/old-release
candidate_release=$test_dir/candidate-release
cp -R -- "$release_dir" "$old_release"
printf '%s\n' '0.0.0-old' > "$old_release/VERSION"
cp -R -- "$release_dir" "$candidate_release"
printf '%s\n' '0.0.0-candidate' > "$candidate_release/VERSION"

"$old_release/install.sh" --role all --prefix "$prefix" > /dev/null
[ "$(readlink "$prefix/bin/punch")" = "$prefix/share/punch-cli/0.0.0-old/bin/punch" ]
[ "$(readlink "$prefix/bin/punch-buyer")" = "$prefix/share/punch-cli/0.0.0-old/bin/punch-buyer" ]
[ "$(readlink "$prefix/bin/punch-provider")" = "$prefix/share/punch-cli/0.0.0-old/bin/punch-provider" ]
old_payload_hash=$(sha256sum "$prefix/share/punch-cli/0.0.0-old/lib/punch.mjs")
state_hash=$(sha256sum "$prefix/state/identity")

"$candidate_release/install.sh" --role all --prefix "$prefix" > /dev/null
[ "$(readlink "$prefix/bin/punch")" = "$prefix/share/punch-cli/0.0.0-candidate/bin/punch" ]
[ -d "$prefix/share/punch-cli/0.0.0-old" ]
[ -d "$prefix/share/punch-cli/0.0.0-candidate" ]
candidate_payload_hash=$(sha256sum "$prefix/share/punch-cli/0.0.0-candidate/lib/punch.mjs")
if "$candidate_release/install.sh" --role all --prefix "$prefix" > "$test_dir/repeat.out" 2>&1; then
  printf '%s\n' 'installer accepted a same-version repeat' >&2
  exit 1
fi
grep -q 'version is already installed' "$test_dir/repeat.out"
[ "$(readlink "$prefix/bin/punch")" = "$prefix/share/punch-cli/0.0.0-candidate/bin/punch" ]
[ "$(sha256sum "$prefix/share/punch-cli/0.0.0-candidate/lib/punch.mjs")" = "$candidate_payload_hash" ]
[ "$(sha256sum "$prefix/state/identity")" = "$state_hash" ]

"$candidate_release/install.sh" --activate-from "$old_release" --role all --prefix "$prefix" > /dev/null
[ "$(readlink "$prefix/bin/punch")" = "$prefix/share/punch-cli/0.0.0-old/bin/punch" ]
[ "$(readlink "$prefix/bin/punch-buyer")" = "$prefix/share/punch-cli/0.0.0-old/bin/punch-buyer" ]
[ "$(readlink "$prefix/bin/punch-provider")" = "$prefix/share/punch-cli/0.0.0-old/bin/punch-provider" ]
[ "$(sha256sum "$prefix/share/punch-cli/0.0.0-old/lib/punch.mjs")" = "$old_payload_hash" ]
[ "$(sha256sum "$prefix/state/identity")" = "$state_hash" ]

"$candidate_release/install.sh" --activate-from "$candidate_release" --role all --prefix "$prefix" > /dev/null
tampered_release=$test_dir/tampered-release
cp -R -- "$old_release" "$tampered_release"
printf '%s\n' 'tampered' >> "$tampered_release/payload/lib/punch.mjs"
if "$candidate_release/install.sh" --activate-from "$tampered_release" --role all --prefix "$prefix" > "$test_dir/tampered.out" 2>&1; then
  printf '%s\n' 'activation accepted a mismatched payload' >&2
  exit 1
fi
grep -q 'installed version payload bytes differ' "$test_dir/tampered.out"
[ "$(readlink "$prefix/bin/punch")" = "$prefix/share/punch-cli/0.0.0-candidate/bin/punch" ]
[ "$(sha256sum "$prefix/share/punch-cli/0.0.0-old/lib/punch.mjs")" = "$old_payload_hash" ]
[ "$(sha256sum "$prefix/state/identity")" = "$state_hash" ]

old_provider_payload_hash=$(sha256sum "$prefix/share/punch-cli/0.0.0-old/lib/punch.mjs")
chmod a-x "$prefix/share/punch-cli/0.0.0-old/bin/punch-provider"
if "$candidate_release/install.sh" --activate-from "$old_release" --role all --prefix "$prefix" > "$test_dir/non-executable.out" 2>&1; then
  printf '%s\n' 'activation accepted a non-executable installed command' >&2
  exit 1
fi
grep -q 'missing or not executable: punch-provider' "$test_dir/non-executable.out"
[ "$(readlink "$prefix/bin/punch")" = "$prefix/share/punch-cli/0.0.0-candidate/bin/punch" ]
[ "$(sha256sum "$prefix/share/punch-cli/0.0.0-old/lib/punch.mjs")" = "$old_provider_payload_hash" ]
[ "$(sha256sum "$prefix/state/identity")" = "$state_hash" ]
chmod a+x "$prefix/share/punch-cli/0.0.0-old/bin/punch-provider"

if "$candidate_release/install.sh" --activate-from '' --role all --prefix "$prefix" > "$test_dir/empty-activate.out" 2>&1; then
  printf '%s\n' 'installer accepted an empty --activate-from value' >&2
  exit 1
fi
grep -q 'empty value for --activate-from' "$test_dir/empty-activate.out"
[ "$(readlink "$prefix/bin/punch")" = "$prefix/share/punch-cli/0.0.0-candidate/bin/punch" ]
[ "$(sha256sum "$prefix/state/identity")" = "$state_hash" ]

rm -- "$prefix/bin/punch"
ln -s -- /bin/true "$prefix/bin/punch"
if "$candidate_release/install.sh" --activate-from "$old_release" --role all --prefix "$prefix" > "$test_dir/unrelated.out" 2>&1; then
  printf '%s\n' 'activation replaced an unrelated symlink' >&2
  exit 1
fi
grep -q 'refusing to replace unrelated symlink' "$test_dir/unrelated.out"
[ "$(readlink "$prefix/bin/punch")" = /bin/true ]
[ "$(readlink "$prefix/bin/punch-buyer")" = "$prefix/share/punch-cli/0.0.0-candidate/bin/punch-buyer" ]
[ "$(sha256sum "$prefix/state/identity")" = "$state_hash" ]
rm -- "$prefix/bin/punch"

"$candidate_release/uninstall.sh" --version 0.0.0-candidate --prefix "$prefix" > /dev/null
"$old_release/uninstall.sh" --version 0.0.0-old --prefix "$prefix" > /dev/null
[ ! -e "$prefix/share/punch-cli/0.0.0-candidate" ]
[ ! -e "$prefix/share/punch-cli/0.0.0-old" ]
[ "$(sha256sum "$prefix/state/identity")" = "$state_hash" ]
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
