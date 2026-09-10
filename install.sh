#!/bin/sh
set -eu

usage() {
  printf '%s\n' 'Usage: ./install.sh --role buyer|provider|all [--prefix ABSOLUTE_PATH]'
  printf '%s\n' '       ./install.sh --activate-from ABSOLUTE_VERIFIED_RELEASE_DIR --role buyer|provider|all [--prefix ABSOLUTE_PATH]'
}

fail() {
  printf 'punch-cli install: %s\n' "$1" >&2
  exit 1
}

role=
prefix=${HOME:+"$HOME/.local"}
activate_from=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --role)
      [ "$#" -ge 2 ] || fail 'missing value for --role'
      role=$2
      shift 2
      ;;
    --prefix)
      [ "$#" -ge 2 ] || fail 'missing value for --prefix'
      prefix=$2
      shift 2
      ;;
    --activate-from)
      [ "$#" -ge 2 ] || fail 'missing value for --activate-from'
      [ -n "$2" ] || fail 'empty value for --activate-from'
      activate_from=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "unknown argument: $1"
      ;;
  esac
done

case "$role" in
  buyer|provider|all) ;;
  '') fail '--role is required' ;;
  *) fail '--role must be buyer, provider, or all' ;;
esac

[ -n "$prefix" ] || fail 'HOME is unset; supply --prefix'
case "$prefix" in
  /*) ;;
  *) fail '--prefix must be an absolute path' ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
version_file=$script_dir/VERSION
payload_dir=$script_dir/payload

[ -f "$version_file" ] && [ ! -L "$version_file" ] || fail 'release VERSION file is missing or unsafe'
[ -d "$payload_dir" ] && [ ! -L "$payload_dir" ] || fail 'release payload is missing or unsafe'
[ -x "$payload_dir/runtime/bin/node" ] || fail 'bundled runtime is missing'

source_dir=$script_dir
source_payload_dir=$payload_dir
version=$(sed -n '1p' "$version_file")
case "$version" in
  ''|.|..|*[!0-9A-Za-z._-]*) fail 'release VERSION is invalid' ;;
esac

if [ -n "$activate_from" ]; then
  case "$activate_from" in
    /*) ;;
    *) fail '--activate-from must be an absolute path' ;;
  esac
  [ -d "$activate_from" ] && [ ! -L "$activate_from" ] || fail 'verified release directory is missing or unsafe'
  source_dir=$(CDPATH= cd -- "$activate_from" && pwd -P)
  source_version_file=$source_dir/VERSION
  source_payload_dir=$source_dir/payload
  [ -f "$source_version_file" ] && [ ! -L "$source_version_file" ] || fail 'verified release VERSION file is missing or unsafe'
  [ -d "$source_payload_dir" ] && [ ! -L "$source_payload_dir" ] || fail 'verified release payload is missing or unsafe'
  [ -x "$source_payload_dir/runtime/bin/node" ] || fail 'verified release runtime is missing'
  version=$(sed -n '1p' "$source_version_file")
  case "$version" in
    ''|.|..|*[!0-9A-Za-z._-]*) fail 'verified release VERSION is invalid' ;;
  esac
fi

install_root=$prefix/share/punch-cli
bin_dir=$prefix/bin

payload_manifest() {
  LC_ALL=C find "$1" -mindepth 1 -printf '%P\t%y\n' | LC_ALL=C sort
}

assert_exact_payload() {
  source_payload=$1
  installed_payload=$2
  [ -z "$(find "$source_payload" "$installed_payload" -type l -print -quit)" ] || fail 'activation payload contains an unsafe symlink'
  source_manifest=$(payload_manifest "$source_payload")
  installed_manifest=$(payload_manifest "$installed_payload")
  [ "$source_manifest" = "$installed_manifest" ] || fail 'installed version payload differs from the verified release'
  diff -qr -- "$source_payload" "$installed_payload" > /dev/null 2>&1 || fail 'installed version payload bytes differ from the verified release'
}

assert_activation_executables() {
  [ -x "$install_dir/runtime/bin/node" ] || fail 'installed version bundled runtime is missing or not executable'
  case "$role" in
    buyer) activation_commands='punch punch-buyer' ;;
    provider) activation_commands='punch punch-provider' ;;
    all) activation_commands='punch punch-buyer punch-provider' ;;
  esac
  for activation_command in $activation_commands; do
    [ -x "$install_dir/bin/$activation_command" ] || fail "installed version command is missing or not executable: $activation_command"
  done
}

if [ -n "$activate_from" ]; then
  [ -d "$install_root" ] && [ ! -L "$install_root" ] || fail 'installed Punch program root is missing or unsafe'
  [ -d "$bin_dir" ] && [ ! -L "$bin_dir" ] || fail 'installed Punch bin directory is missing or unsafe'
  install_root=$(CDPATH= cd -- "$install_root" && pwd -P)
  bin_dir=$(CDPATH= cd -- "$bin_dir" && pwd -P)
  install_dir=$install_root/$version
  [ -d "$install_dir" ] && [ ! -L "$install_dir" ] || fail "installed version is missing: $version"
  assert_exact_payload "$source_payload_dir" "$install_dir"
  assert_activation_executables
else
  mkdir -p -- "$install_root" "$bin_dir"
  install_root=$(CDPATH= cd -- "$install_root" && pwd -P)
  bin_dir=$(CDPATH= cd -- "$bin_dir" && pwd -P)
  install_dir=$install_root/$version
  [ ! -e "$install_dir" ] || fail "version is already installed: $version"
  umask 022
fi

check_link() {
  command=$1
  link=$bin_dir/$command
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    fail "refusing to replace non-symlink: $link"
  fi
  if [ -L "$link" ]; then
    old_target=$(readlink "$link")
    case "$old_target" in
      "$install_root"/*/bin/"$command") ;;
      *) fail "refusing to replace unrelated symlink: $link" ;;
    esac
  fi
}

case "$role" in
  buyer)
    check_link punch
    check_link punch-buyer
    ;;
  provider)
    check_link punch
    check_link punch-provider
    ;;
  all)
    check_link punch
    check_link punch-buyer
    check_link punch-provider
    ;;
esac

if [ -z "$activate_from" ]; then
  tmp_dir=$install_root/.install-$version-$$
  trap 'rm -rf -- "$tmp_dir"' EXIT HUP INT TERM
  mkdir -- "$tmp_dir"
  cp -R -- "$source_payload_dir"/. "$tmp_dir"/

  for command in punch punch-buyer punch-provider; do
    [ -x "$tmp_dir/bin/$command" ] || fail "release command is missing: $command"
  done

  mv -- "$tmp_dir" "$install_dir"
  trap - EXIT HUP INT TERM
fi

install_link() {
  command=$1
  link=$bin_dir/$command
  target=$install_dir/bin/$command
  tmp_link=$bin_dir/.$command.$$

  ln -s -- "$target" "$tmp_link"
  mv -f -- "$tmp_link" "$link"
}

case "$role" in
  buyer)
    install_link punch
    install_link punch-buyer
    ;;
  provider)
    install_link punch
    install_link punch-provider
    ;;
  all)
    install_link punch
    install_link punch-buyer
    install_link punch-provider
    ;;
esac

if [ -n "$activate_from" ]; then
  printf 'Activated Punch CLI %s (%s) under %s from %s\n' "$version" "$role" "$prefix" "$source_dir"
else
  printf 'Installed Punch CLI %s (%s) under %s\n' "$version" "$role" "$prefix"
fi
printf 'Add %s to PATH if needed.\n' "$bin_dir"
