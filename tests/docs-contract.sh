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
require docs/EXECUTABLE_DOCS.md 'GATED_UNRELEASED'
require docs/EXECUTABLE_DOCS.md 'generated CLI reference is valid only when an exact runtime-artifact'
require docs/EXECUTABLE_DOCS.md 'Buyer `stop` operation'
require docs/EXECUTABLE_DOCS.md 'there is no new'
require docs/NEXT_COMMAND_REFERENCE.md 'LOCAL_DETERMINISTIC_PASS'
require docs/NEXT_COMMAND_REFERENCE.md 'punch.public-cli-contract.v1'
require docs/NEXT_COMMAND_REFERENCE.md '"name": "stop"'
require docs/NEXT_COMMAND_REFERENCE.md '"name": "setup"'
require docs/NEXT_COMMAND_REFERENCE.md 'release-authority: false'
node scripts/validate-targeted-zero-contract.js --self-test
node scripts/generate-command-reference.mjs \
  --contract tests/fixtures/public-safe-contract.v1.json \
  --binding tests/fixtures/public-safe-contract-binding.v1.json \
  --target docs/NEXT_COMMAND_REFERENCE.md
node scripts/generate-command-reference.mjs --self-test
node scripts/run-docs-smoke.mjs --self-test
node scripts/scan-public-material.mjs --self-test

printf '%s\n' 'public docs command/proof contract: PASS'
