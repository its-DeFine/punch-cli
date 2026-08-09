#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

node --input-type=module <<'NODE'
import { readFileSync } from 'node:fs';

const contract = JSON.parse(readFileSync('docs/preview14-runtime-contract.json', 'utf8'));
const version = '0.1.0-preview.14';
const privateSource = {
  commit: '7ddafc478ca2cdb479e1d43ce6704d2d0cbdd4c2',
  tree: '46baf3a04e79d41e4f2c6371ce0bf10da9dd4ecb'
};
if (!contract || typeof contract !== 'object' || Array.isArray(contract)
    || contract.schemaVersion !== 'punch.preview14-runtime-contract.v1'
    || contract.releaseVersion !== version || contract.platform !== 'linux-x64'
    || contract.privateReleaseSource?.commit !== privateSource.commit
    || contract.privateReleaseSource?.tree !== privateSource.tree
    || contract.accessTransport !== 'NETBIRD_CONTRACT_SCOPED_GATEWAY'
    || contract.offerPolicy !== 'OWNER_TARGETED_ZERO_ONLY' || contract.priceMinor !== 0
    || contract.paymentSettlementEnabled !== false || contract.selfServiceProviderOnboarding !== false) {
  throw new Error('Public Preview.14 runtime contract is incompatible with the private builder.');
}
if (contract.controlArchiveSha256 !== 'sha256:9a89da1956ce48a9a91d5859a2e108623e85d6e6016864fc273b4f37a493e2cf') {
  throw new Error('Public Preview.14 runtime contract lost the reviewed Control archive binding.');
}
process.stdout.write('Preview.14 private-builder runtime-contract compatibility: PASS\n');
NODE

for required in \
  'GATED_UNRELEASED' \
  'PENDING_AGENT' \
  'LISTED' \
  'public onboarding packet' \
  'cached `sudo`' \
  'multiple approved Providers' \
  '`259200` seconds' \
  'ineligible offers fail closed' \
  'immutable image pull + digest verification' \
  'real local container/SSH cleanup canary' \
  'fake Docker/fetch/SSH seam' \
  'Payment, settlement, payout, and refund'; do
  grep -F -- "$required" docs/PREVIEW14.md > /dev/null || {
    printf 'Preview.14 release-gate documentation missing: %s\n' "$required" >&2
    exit 1
  }
done

if grep -F -- 'PENDING_VALIDATION' docs/PREVIEW14.md docs/preview14-runtime-contract.json > /dev/null; then
  printf '%s\n' 'Preview.14 must use PENDING_AGENT, not PENDING_VALIDATION' >&2
  exit 1
fi

for required in \
  'AUTHORITATIVE_PACKAGED_CLI_SURFACE_REQUIRED' \
  'privateReleaseSource' \
  'NETBIRD_CONTRACT_SCOPED_GATEWAY' \
  'OWNER_TARGETED_ZERO_ONLY' \
  '7ddafc478ca2cdb479e1d43ce6704d2d0cbdd4c2' \
  '46baf3a04e79d41e4f2c6371ce0bf10da9dd4ecb' \
  '9a89da1956ce48a9a91d5859a2e108623e85d6e6016864fc273b4f37a493e2cf' \
  'REVIEWED_FINAL_COMMAND_MAP_PUBLIC_ARTIFACT_BINDING_PENDING' \
  'STATE_AWARE_HOME' \
  'PENDING_AGENT' \
  'prelistProofRequired' \
  'providerSetupSingleSession' \
  'joinResumableUntilExactNetBirdBinding' \
  'multipleSupervisedProviders' \
  'maxAuthorizedWindowSeconds' \
  'ineligibleOffersOrderable' \
  'accessStartsAfterSshAndGatewayReady' \
  'stopRevocationFirst' \
  'paymentSettlementEnabled'; do
  grep -F -- "$required" docs/preview14-runtime-contract.json > /dev/null || {
    printf 'Preview.14 runtime contract missing: %s\n' "$required" >&2
    exit 1
  }
done

grep -F 'GENERATED PREVIEW14 COMMAND REFERENCE:BEGIN' docs/PREVIEW14_COMMAND_REFERENCE.md > /dev/null || {
  printf '%s\n' 'Preview.14 generated command-reference target is missing its begin marker' >&2
  exit 1
}

for required in \
  'punch.preview14-public-command-contract.v1' \
  'privateRuntimeBindingKeys' \
  'generationRule' \
  'runtimeMatchRequired' \
  'nonInteractivePrivilegedInstallRequiresCachedSudo' \
  'multipleSupervisedProviders' \
  'maxAuthorizedWindowSeconds' \
  'ineligibleOffersOrderable'; do
  grep -F -- "$required" docs/schemas/preview14-public-command-contract-format.v1.json > /dev/null || {
    printf 'Preview.14 generated command-contract format missing: %s\n' "$required" >&2
    exit 1
  }
done

for required in \
  'REAL_DOCKER_ENGINE' \
  'REAL_REGISTRY_DIGEST_PULL' \
  'REAL_SSH_DATA_PLANE' \
  'executionReceipt' \
  'punch.preview14-clean-host-e2e-execution-receipt.v1' \
  'fakeDocker' \
  'fakeFetch' \
  'inMemoryControl' \
  'sourceCli' \
  'mockSsh'; do
  grep -F -- "$required" docs/schemas/preview14-clean-host-e2e-report.v1.json > /dev/null || {
    printf 'Preview.14 clean-host schema missing: %s\n' "$required" >&2
    exit 1
  }
done

for required in \
  'sameMachineId' \
  'sameSetupRef' \
  'sameOfferId' \
  'sameOrderRefSameJob' \
  'oneContract' \
  'oneReservation' \
  'sameContainerBinding' \
  'realOpenSsh' \
  'sameTerminalReceiptDigest' \
  'signedCleanupDigestPresent' \
  'activeSessions' \
  'activeTickets' \
  'noFixtureTransport' \
  'noDependencyInjection'; do
  grep -F -- "$required" docs/schemas/preview14-clean-host-e2e-execution-receipt.v1.json > /dev/null || {
    printf 'Preview.14 execution-receipt schema missing: %s\n' "$required" >&2
    exit 1
  }
done

node scripts/verify-preview14-clean-host-e2e.mjs --self-test
node --test tests/preview14-clean-host-e2e-verifier.mjs
node scripts/generate-preview14-command-reference.mjs --self-test
node scripts/generate-preview14-command-reference.mjs \
  --template docs/preview14-public-command-contract.template.json

contract=docs/preview14-public-command-contract.json
if [ -e "$contract" ]; then
  node scripts/generate-preview14-command-reference.mjs \
    --contract "$contract" \
    --target docs/PREVIEW14_COMMAND_REFERENCE.md
else
  for required in \
    '7ddafc478ca2cdb479e1d43ce6704d2d0cbdd4c2' \
    '46baf3a04e79d41e4f2c6371ce0bf10da9dd4ecb' \
    '9a89da1956ce48a9a91d5859a2e108623e85d6e6016864fc273b4f37a493e2cf' \
    'public artifact binding pending deterministic build'; do
    grep -F -- "$required" docs/PREVIEW14_COMMAND_REFERENCE.md > /dev/null || {
      printf 'Preview.14 pending command reference is missing source/artifact boundary: %s\n' "$required" >&2
      exit 1
    }
  done
fi
printf '%s\n' 'Preview.14 public release-gate contract: PASS'
