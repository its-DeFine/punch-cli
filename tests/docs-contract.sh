#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

require() {
  file=$1
  text=$2
  grep -F -- "$text" "$file" > /dev/null || {
    printf 'public docs contract missing from %s: %s\n' "$file" "$text" >&2
    exit 1
  }
}

require docs/COMMANDS.md 'punch-buyer join|offers|order|status|output|ssh'
require docs/COMMANDS.md 'There is no Buyer `stop` or `cancel` command'
require docs/BUYER.md 'None of those actions calls a Punch job-stop'
require docs/TROUBLESHOOTING.md 'it does not request lifecycle termination'
require docs/RELEASES.md 'They are not evidence of a completed testnet transfer'

printf '%s\n' 'public docs command/proof contract: PASS'
