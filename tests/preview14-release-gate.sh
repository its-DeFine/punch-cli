#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

node --input-type=module <<'NODE'
import { readFileSync } from 'node:fs';

const contract = JSON.parse(readFileSync('docs/preview14-runtime-contract.json', 'utf8'));
const version = '0.1.0-preview.14';
const privateSource = {
  commit: 'ff99837cfa9fd7ff0683335cd5dd917db3dad90a',
  tree: 'e753ee79e69678e495c133fb503bddbe2d9544dc'
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
if (contract.controlArchiveSha256 !== 'sha256:9853db9ad522df45f237519909166b195258b43fc9102049659c8f37c91288d6') {
  throw new Error('Public Preview.14 runtime contract lost the reviewed Control archive binding.');
}
if (contract.artifactBinding?.authority !== 'AUTHORITATIVE_PACKAGED_CLI_SURFACE'
    || contract.artifactBinding.archiveSha256 !== 'sha256:bea2829770919a68ac3f0bf69f4a5d510875fca65efe742027a822b214d587ce'
    || contract.artifactBinding.sha256SumsSha256 !== 'sha256:04c3800011fb5041fa81abc858a3493199b26135fcdee68d90603951f261fd11'
    || contract.artifactBinding.packagedCliSurfaceSha256 !== 'sha256:d90f5d73e3838ff0ed391033dc71ecb751861243ad0d4806c3bdaa5d95b347b9'
    || contract.guidedCli?.directCommands !== contract.artifactBinding.packagedCliSurfaceSha256) {
  throw new Error('Public Preview.14 runtime contract lost the authoritative packaged artifact binding.');
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
  'AUTHORITATIVE_PACKAGED_CLI_SURFACE' \
  'privateReleaseSource' \
  'NETBIRD_CONTRACT_SCOPED_GATEWAY' \
  'OWNER_TARGETED_ZERO_ONLY' \
  'ff99837cfa9fd7ff0683335cd5dd917db3dad90a' \
  'e753ee79e69678e495c133fb503bddbe2d9544dc' \
  '9853db9ad522df45f237519909166b195258b43fc9102049659c8f37c91288d6' \
  'bea2829770919a68ac3f0bf69f4a5d510875fca65efe742027a822b214d587ce' \
  '04c3800011fb5041fa81abc858a3493199b26135fcdee68d90603951f261fd11' \
  'd90f5d73e3838ff0ed391033dc71ecb751861243ad0d4806c3bdaa5d95b347b9' \
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

for required in \
  '"name": "--agent-config"' \
  '"name": "--observed-at"' \
  '"name": "--offer-id"' \
  '"name": "--window-seconds"' \
  '"name": "--price-minor"' \
  '"name": "--targeted-zero-authorization-id"' \
  '"name": "--targeted-buyer-actor-id"' \
  '"provider": ["identity-init", "join", "doctor", "setup", "service-status", "offer-status"]' \
  '"buyer": ["doctor", "join", "offers", "order", "status", "ssh", "stop"]'; do
  grep -F -- "$required" docs/preview14-public-command-contract.template.json > /dev/null || {
    printf 'Preview.14 static command contract missing: %s\n' "$required" >&2
    exit 1
  }
done

contract=docs/preview14-public-command-contract.json
[ -e "$contract" ] || {
  printf '%s\n' 'Preview.14 bound public command contract is missing' >&2
  exit 1
}
for required in \
  'bea2829770919a68ac3f0bf69f4a5d510875fca65efe742027a822b214d587ce' \
  '04c3800011fb5041fa81abc858a3493199b26135fcdee68d90603951f261fd11' \
  '99a294c6c2db751bb10e8d281604205f8fb78f35180d741a387d894bb961c0fc' \
  'd90f5d73e3838ff0ed391033dc71ecb751861243ad0d4806c3bdaa5d95b347b9'; do
  grep -F -- "$required" "$contract" > /dev/null || {
    printf 'Preview.14 bound command contract is missing artifact digest: %s\n' "$required" >&2
    exit 1
  }
done
node scripts/generate-preview14-command-reference.mjs \
  --contract "$contract" \
  --target docs/PREVIEW14_COMMAND_REFERENCE.md
printf '%s\n' 'Preview.14 public release-gate contract: PASS'
