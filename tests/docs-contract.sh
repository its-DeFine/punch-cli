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

require README.md 'v0.1.0-preview.11'
require README.md 'v0.1.0-preview.12'
require README.md 'v0.1.0-preview.13'
require README.md 'v0.1.0-preview.14'
require README.md 'included in the gated, unpublished Preview.14 supervised source; not installed or supported by published Preview.9'
require docs/PREVIEW11.md 'GATED_UNRELEASED'
require docs/PREVIEW11.md 'one-off, ephemeral setup key'
require docs/PREVIEW12.md 'GATED_UNRELEASED'
require docs/PREVIEW12.md 'continuous, state-aware `punch` home'
require docs/PREVIEW13.md 'Dynamic require of "events" is not supported'
require docs/PREVIEW13.md 'createRequire'
require docs/PREVIEW10.md 'never publicly promoted'
require docs/PREVIEW10.md '--offer-id'
require docs/BUYER.md 'NetBird bootstrap'
require docs/BUYER.md 'mode-`0600`'
require docs/PREVIEW9.md 'clean-v4 supervised pilot'
require docs/PREVIEW9.md 'no payment settlement'
require docs/PREVIEW9.md 'Exact order and stop retries'
require docs/COMMANDS.md 'punch-buyer join|offers|order|status|output|ssh|stop'
require docs/COMMANDS.md 'Providers do not normally retype'
require docs/COMMANDS.md 'exact-match recovery/diagnostic overrides only'
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
require docs/OFFER_LIFECYCLE_PREVIEW.md 'Preview.14 release source — gated and not published'
require docs/OFFER_LIFECYCLE_PREVIEW.md 'not in the published `v0.1.0-preview.9` archive'
require docs/OFFER_LIFECYCLE_PREVIEW.md 'It never stops, revokes, fences, or cleans up an accepted contract.'
require docs/OFFER_LIFECYCLE_PREVIEW.md 'The exact replay returns the original durable receipt.'
require docs/OFFER_LIFECYCLE_PREVIEW.md 'does not delete, relist, or recreate either record.'
require docs/COMMANDS.md 'do not alter the Buyer command surface.'
require docs/COMMANDS.md 'are part of the Preview.14'
require docs/COMMANDS.md 'Guided `punch` home'
require docs/GUIDED_CLI.md 'continuous'
require docs/GUIDED_CLI.md 'punch buyer'
require docs/GUIDED_CLI.md 'punch provider'
require docs/GUIDED_CLI.md 'Punch agent runbook'
require docs/AGENT_RUNBOOK.md 'APPROVAL_REQUIRED'
require docs/AGENT_RUNBOOK.md 'punch buyer stop'
require docs/AGENT_RUNBOOK.md 'punch provider offer-retire'
require docs/preview11-runtime-contract.json '0e615565780e60c49fd1c5fc6d1d07940e1d4be4'
require docs/preview11-runtime-contract.json '76041898382f764d3404ecb12112b684bafad1af'
require docs/preview12-runtime-contract.json '67b8735939154375fd6da3a44d540631af55777d'
require docs/preview12-runtime-contract.json 'PENDING_EXACT_PREVIEW12_ARCHIVE_ACCEPTANCE'
require docs/preview13-runtime-contract.json '7af5f302db2076cfde14c69baf1e5d8b1d4017ab'
require docs/preview13-runtime-contract.json 'PENDING_EXACT_PREVIEW13_ARCHIVE_ACCEPTANCE'
require docs/PREVIEW14.md 'GATED_UNRELEASED'
require docs/PREVIEW14.md 'PENDING_AGENT'
require docs/PREVIEW14.md 'source checkout, guessed flag'
require docs/PREVIEW14.md 'explicit consent'
require docs/PREVIEW14.md 'Payment, settlement, payout, and refund'
require docs/preview14-runtime-contract.json 'AUTHORITATIVE_PACKAGED_CLI_SURFACE_REQUIRED'
require docs/preview14-runtime-contract.json 'privateReleaseSource'
require docs/preview14-runtime-contract.json 'NETBIRD_CONTRACT_SCOPED_GATEWAY'
require docs/preview14-runtime-contract.json 'OWNER_TARGETED_ZERO_ONLY'
require docs/preview14-runtime-contract.json 'PENDING_AGENT'
require docs/preview14-runtime-contract.json 'accessStartsAfterSshAndGatewayReady'
require docs/PREVIEW14.md 'Resident recovery is bound to the completed setup baseline'
require docs/PREVIEW14.md 'expiry never extends access through recovery'
require docs/PREVIEW14_COMMAND_REFERENCE.md '7ddafc478ca2cdb479e1d43ce6704d2d0cbdd4c2'
require docs/PREVIEW14_COMMAND_REFERENCE.md '46baf3a04e79d41e4f2c6371ce0bf10da9dd4ecb'
require docs/PREVIEW14_COMMAND_REFERENCE.md 'public artifact binding pending deterministic build'
require docs/preview14-public-command-contract.template.json 'PENDING_DETERMINISTIC_BUILD'
require docs/preview14-public-command-contract.template.json '9a89da1956ce48a9a91d5859a2e108623e85d6e6016864fc273b4f37a493e2cf'
require docs/preview14-public-command-contract.template.json 'service-install'
require docs/preview14-public-command-contract.template.json 'offer-retire'
require docs/PROVIDER.md 'One Provider setup operation'
require docs/PROVIDER.md 'Manual NetBird enrollment'
require docs/PROVIDER.md 'public onboarding packet'
require docs/PROVIDER.md 'cached `sudo`'
require docs/PROVIDER.md '`259200` seconds'
require docs/GUIDED_CLI.md 'PENDING_AGENT'
require docs/GUIDED_CLI.md 'resumable until the exact Buyer/NetBird binding'
require docs/GUIDED_CLI.md 'Multiple supervised Providers'
require docs/BUYER.md 'ineligible'
require docs/preview14-public-command-contract.template.json '"provider": ["identity-init", "join"'
require docs/preview14-public-command-contract.template.json '"maxAuthorizedWindowSeconds": 259200'

node scripts/validate-targeted-zero-contract.js --self-test
node scripts/generate-command-reference.mjs \
  --contract tests/fixtures/public-safe-contract.v1.json \
  --binding tests/fixtures/public-safe-contract-binding.v1.json \
  --target docs/NEXT_COMMAND_REFERENCE.md
node scripts/generate-command-reference.mjs --self-test
node scripts/run-docs-smoke.mjs --self-test
node scripts/scan-public-material.mjs --self-test
node --test tests/agent-runbook-contract.mjs
sh tests/preview14-release-gate.sh

printf '%s\n' 'public docs command/proof contract: PASS'
