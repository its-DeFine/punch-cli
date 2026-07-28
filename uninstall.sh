#!/bin/sh
set -eu

usage() {
  printf '%s\n' 'Usage: ./uninstall.sh --version VERSION [--prefix ABSOLUTE_PATH]'
}

fail() {
  printf 'punch-cli uninstall: %s\n' "$1" >&2
  exit 1
}

version=
prefix=${HOME:+"$HOME/.local"}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      [ "$#" -ge 2 ] || fail 'missing value for --version'
      version=$2
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

case "$version" in
  ''|.|..|*[!0-9A-Za-z._-]*) fail '--version is required and must be a release version' ;;
esac
[ -n "$prefix" ] || fail 'HOME is unset; supply --prefix'
case "$prefix" in
  /*) ;;
  *) fail '--prefix must be an absolute path' ;;
esac

install_root=$prefix/share/punch-cli
bin_dir=$prefix/bin

if [ ! -d "$install_root" ] || [ -L "$install_root" ]; then
  printf 'Punch CLI program root is absent; no program files were removed.\n'
  exit 0
fi
install_root=$(CDPATH= cd -- "$install_root" && pwd -P)
install_dir=$install_root/$version
if [ -d "$bin_dir" ]; then
  bin_dir=$(CDPATH= cd -- "$bin_dir" && pwd -P)
fi

for command in punch-buyer punch-provider; do
  link=$bin_dir/$command
  if [ -L "$link" ]; then
    target=$(readlink "$link")
    if [ "$target" = "$install_dir/bin/$command" ]; then
      rm -- "$link"
    fi
  fi
done

if [ -d "$install_dir" ] && [ ! -L "$install_dir" ]; then
  case "$install_dir" in
    "$install_root"/*) rm -rf -- "$install_dir" ;;
    *) fail 'resolved install directory is outside the Punch program root' ;;
  esac
fi

printf 'Removed Punch CLI program version %s.\n' "$version"
printf '%s\n' 'Buyer sessions, Provider credentials, identities, and state were not removed.'
