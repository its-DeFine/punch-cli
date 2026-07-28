#!/bin/sh
set -eu

usage() {
  printf '%s\n' 'Usage: ./install.sh --role buyer|provider|all [--prefix ABSOLUTE_PATH]'
}

fail() {
  printf 'punch-cli install: %s\n' "$1" >&2
  exit 1
}

role=
prefix=${HOME:+"$HOME/.local"}

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
version=$(sed -n '1p' "$version_file")
case "$version" in
  ''|.|..|*[!0-9A-Za-z._-]*) fail 'release VERSION is invalid' ;;
esac

[ -d "$payload_dir" ] && [ ! -L "$payload_dir" ] || fail 'release payload is missing or unsafe'
[ -x "$payload_dir/runtime/bin/node" ] || fail 'bundled runtime is missing'

install_root=$prefix/share/punch-cli
install_dir=$install_root/$version
bin_dir=$prefix/bin

mkdir -p -- "$install_root" "$bin_dir"
install_root=$(CDPATH= cd -- "$install_root" && pwd -P)
bin_dir=$(CDPATH= cd -- "$bin_dir" && pwd -P)
install_dir=$install_root/$version
[ ! -e "$install_dir" ] || fail "version is already installed: $version"
umask 022

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
  buyer) check_link punch-buyer ;;
  provider) check_link punch-provider ;;
  all)
    check_link punch-buyer
    check_link punch-provider
    ;;
esac

tmp_dir=$install_root/.install-$version-$$
trap 'rm -rf -- "$tmp_dir"' EXIT HUP INT TERM
mkdir -- "$tmp_dir"
cp -R -- "$payload_dir"/. "$tmp_dir"/

for command in punch-buyer punch-provider; do
  [ -x "$tmp_dir/bin/$command" ] || fail "release command is missing: $command"
done

mv -- "$tmp_dir" "$install_dir"
trap - EXIT HUP INT TERM

install_link() {
  command=$1
  link=$bin_dir/$command
  target=$install_dir/bin/$command
  tmp_link=$bin_dir/.$command.$$

  ln -s -- "$target" "$tmp_link"
  mv -f -- "$tmp_link" "$link"
}

case "$role" in
  buyer) install_link punch-buyer ;;
  provider) install_link punch-provider ;;
  all)
    install_link punch-buyer
    install_link punch-provider
    ;;
esac

printf 'Installed Punch CLI %s (%s) under %s\n' "$version" "$role" "$prefix"
printf 'Add %s to PATH if needed.\n' "$bin_dir"
