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

require README.md 'v0.1.0-preview.9'
require README.md 'v0.1.0-preview.10'
require docs/PREVIEW10.md 'GATED_UNRELEASED'
require docs/PREVIEW10.md 'one-off, ephemeral setup key'
require docs/BUYER.md 'NetBird bootstrap'
require docs/BUYER.md 'mode-`0600`'
require docs/PREVIEW9.md 'clean-v4 supervised pilot'
require docs/PREVIEW9.md 'no payment settlement'
require docs/PREVIEW9.md 'Exact order and stop retries'
require docs/COMMANDS.md 'punch-buyer join|offers|order|status|output|ssh|stop'
require docs/COMMANDS.md '`--price-minor 0`'
require docs/COMMANDS.md '`--targeted-zero-authorization-id`'
require docs/COMMANDS.md '`--targeted-buyer-actor-id`'
require docs/BUYER.md '"netBirdGateway": true'
require docs/BUYER.md 'state: ACTIVE'
require docs/BUYER.md 'punch-buyer stop'
require docs/PROVIDER.md 'does not expose a public SSH port'
require docs/PROVIDER.md 'TCP `22222`'
require docs/PROVIDER.md 'The Provider never receives the NetBird management token'
require docs/TROUBLESHOOTING.md 'ends only that local connection'
require docs/RELEASES.md 'does not activate payment, payout, settlement, or refunds'
require docs/ARCHITECTURE.md 'Preview.9 releases `punch-buyer stop`'
require docs/NETBIRD_PREVIEW.md 'NetBird never becomes marketplace authority'
require docs/schemas/targeted-zero-test-public.v2.json 'SUPERVISED_PREVIEW9_ONLY'
require docs/schemas/targeted-zero-test-public.v2.json 'SINGLE_USE_SETUP_AUTHORIZATION_REUSABLE_TARGETED_OFFER'
require docs/EXECUTABLE_DOCS.md 'GATED_UNRELEASED'
require docs/EXECUTABLE_DOCS.md 'generated CLI reference is valid only when an exact runtime-artifact'
require docs/PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md 'GET polling must not depend on synchronous heavy reconciliation'
require docs/PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md 'durable `PREPARED`'
require docs/PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md 'cleanupState: "PENDING"'
require docs/PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md '10-second bound'
require docs/PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md '300-second overall reconciliation deadline'
require docs/schemas/buyer-stop-operation.v1.json 'punch.buyer-stop-operation.v1'
require docs/NEXT_COMMAND_REFERENCE.md 'LOCAL_DETERMINISTIC_PASS'
require docs/NEXT_COMMAND_REFERENCE.md 'release-authority: false'
require docs/OFFER_LIFECYCLE_PREVIEW.md 'GATED_UNRELEASED Preview.10+ candidate'
require docs/OFFER_LIFECYCLE_PREVIEW.md 'not in the published `v0.1.0-preview.9` archive'
require docs/OFFER_LIFECYCLE_PREVIEW.md 'It never stops, revokes, fences, or cleans up an accepted contract.'
require docs/OFFER_LIFECYCLE_PREVIEW.md 'The exact replay returns the original durable receipt.'
require docs/OFFER_LIFECYCLE_PREVIEW.md 'does not delete, relist, or recreate either record.'
require docs/COMMANDS.md 'do not alter the Buyer command surface.'

node scripts/validate-targeted-zero-contract.js --self-test
node scripts/generate-command-reference.mjs \
  --contract tests/fixtures/public-safe-contract.v1.json \
  --binding tests/fixtures/public-safe-contract-binding.v1.json \
  --target docs/NEXT_COMMAND_REFERENCE.md
node scripts/generate-command-reference.mjs --self-test
node scripts/run-docs-smoke.mjs --self-test
node scripts/scan-public-material.mjs --self-test

printf '%s\n' 'public docs command/proof contract: PASS'
