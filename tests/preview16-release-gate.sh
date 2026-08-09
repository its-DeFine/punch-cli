#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

node --input-type=module <<'NODE'
import { readFileSync } from 'node:fs';

const contract = JSON.parse(readFileSync('docs/preview16-runtime-contract.json', 'utf8'));
const version = '0.1.0-preview.16';
const privateSource = {
  commit: 'c0cabb6f18e7eba6c3c9910abe4e76ad814c05d2',
  tree: '7d67f0967ac2cfab5b47a92716fe5bbda069d08e'
};
if (!contract || typeof contract !== 'object' || Array.isArray(contract)
    || contract.schemaVersion !== 'punch.preview16-runtime-contract.v1'
    || contract.releaseVersion !== version || contract.releaseStatus !== 'PUBLISHED_PRERELEASE'
    || contract.platform !== 'linux-x64'
    || contract.privateReleaseSource?.commit !== privateSource.commit
    || contract.privateReleaseSource?.tree !== privateSource.tree
    || contract.accessTransport !== 'NETBIRD_CONTRACT_SCOPED_GATEWAY'
    || contract.offerPolicy !== 'OWNER_TARGETED_ZERO_ONLY' || contract.priceMinor !== 0
    || contract.paymentSettlementEnabled !== false || contract.selfServiceProviderOnboarding !== false) {
  throw new Error('Public Preview.16 runtime contract is incompatible with the private builder.');
}
if (contract.controlArchiveSha256 !== 'sha256:ba7d8c32ba2cdad2d7bdef32739ca4d8b2a1d03c26f0b5a4c946249d68f3b28b') {
  throw new Error('Public Preview.16 runtime contract lost the reviewed Control archive binding.');
}
if (contract.artifactBinding?.authority !== 'AUTHORITATIVE_PACKAGED_CLI_SURFACE'
    || contract.artifactBinding.archiveSha256 !== 'sha256:49d1dba584c52de7e0b75dc77a2b9572c3a31ef417575e8c80a5f6e16422da17'
    || contract.artifactBinding.sha256SumsSha256 !== 'sha256:83258b75849ac55f8a03637d66fd9b6b4f9548071185d65f3d90632ff8391617'
    || contract.artifactBinding.packagedCliSurfaceSha256 !== 'sha256:8d9de3adaf3e0753c87d12f9b1300fda60f74727e5638dfa93ed161ebee2db2a'
    || contract.guidedCli?.directCommands !== contract.artifactBinding.packagedCliSurfaceSha256) {
  throw new Error('Public Preview.16 runtime contract lost the authoritative packaged artifact binding.');
}
process.stdout.write('Preview.16 private-builder runtime-contract compatibility: PASS\n');
NODE

for required in \
  'PUBLISHED_PRERELEASE' \
  'PENDING_AGENT' \
  'LISTED' \
  'public onboarding packet' \
  'INVITE_READY' \
  'mode-`0600`' \
  '`sudo -n true`' \
  'interactive `sudo -v`' \
  'cached `sudo`' \
  'multiple approved Providers' \
  '`259200` seconds' \
  'ineligible offers fail closed' \
  'immutable image pull + digest verification' \
  'real local container/SSH cleanup canary' \
  'fake Docker/fetch/SSH seam' \
  'Payment, settlement, payout, and refund'; do
  grep -F -- "$required" docs/PREVIEW16.md > /dev/null || {
    printf 'Preview.16 release-gate documentation missing: %s\n' "$required" >&2
    exit 1
  }
done

if grep -F -- 'PENDING_VALIDATION' docs/PREVIEW16.md docs/preview16-runtime-contract.json > /dev/null; then
  printf '%s\n' 'Preview.16 must use PENDING_AGENT, not PENDING_VALIDATION' >&2
  exit 1
fi

for required in \
  'AUTHORITATIVE_PACKAGED_CLI_SURFACE' \
  'privateReleaseSource' \
  'NETBIRD_CONTRACT_SCOPED_GATEWAY' \
  'OWNER_TARGETED_ZERO_ONLY' \
  'c0cabb6f18e7eba6c3c9910abe4e76ad814c05d2' \
  '7d67f0967ac2cfab5b47a92716fe5bbda069d08e' \
  'sha256:ba7d8c32ba2cdad2d7bdef32739ca4d8b2a1d03c26f0b5a4c946249d68f3b28b' \
  'sha256:49d1dba584c52de7e0b75dc77a2b9572c3a31ef417575e8c80a5f6e16422da17' \
  'sha256:83258b75849ac55f8a03637d66fd9b6b4f9548071185d65f3d90632ff8391617' \
  'sha256:8d9de3adaf3e0753c87d12f9b1300fda60f74727e5638dfa93ed161ebee2db2a' \
  'GUIDED_PROVIDER_ONBOARDING' \
  'providerPreflightBeforeIdentity' \
  'WAITING_FOR_INVITE' \
  'INVITE_READY' \
  'ownerDeliveredInvitationRequired' \
  'invitationFileMode' \
  'authenticatedOverview' \
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
  grep -F -- "$required" docs/preview16-runtime-contract.json > /dev/null || {
    printf 'Preview.16 runtime contract missing: %s\n' "$required" >&2
    exit 1
  }
done

grep -F 'GENERATED PREVIEW16 COMMAND REFERENCE:BEGIN' docs/PREVIEW16_COMMAND_REFERENCE.md > /dev/null || {
  printf '%s\n' 'Preview.16 generated command-reference target is missing its begin marker' >&2
  exit 1
}

for required in \
  'punch.preview16-public-command-contract.v1' \
  'privateRuntimeBindingKeys' \
  'generationRule' \
  'runtimeMatchRequired' \
  'nonInteractivePrivilegedInstallRequiresCachedSudo' \
  'multipleSupervisedProviders' \
  'maxAuthorizedWindowSeconds' \
  'ineligibleOffersOrderable'; do
  grep -F -- "$required" docs/schemas/preview16-public-command-contract-format.v1.json > /dev/null || {
    printf 'Preview.16 generated command-contract format missing: %s\n' "$required" >&2
    exit 1
  }
done

for required in \
  'REAL_DOCKER_ENGINE' \
  'REAL_REGISTRY_DIGEST_PULL' \
  'REAL_SSH_DATA_PLANE' \
  'DISPOSABLE_CLEAN_PROVIDER_VM' \
  'INDEPENDENT_DISPOSABLE_CLEAN_BUYER_VM' \
  'waitingForInvite' \
  'inviteReady' \
  'invitationResume' \
  'executionReceipt' \
  'punch.preview16-clean-host-e2e-execution-receipt.v1' \
  'fakeDocker' \
  'fakeFetch' \
  'inMemoryControl' \
  'sourceCli' \
  'mockSsh'; do
  grep -F -- "$required" docs/schemas/preview16-clean-host-e2e-report.v1.json > /dev/null || {
    printf 'Preview.16 clean-host schema missing: %s\n' "$required" >&2
    exit 1
  }
done

for required in \
  'preflightBeforeIdentity' \
  'waitingForInviteObserved' \
  'inviteReadyObserved' \
  'ownerDeliveredInvitationMode0600' \
  'sameRequestRef' \
  'sameIdentity' \
  'invitationResumed' \
  'privateMaterialCaptured' \
  'firstSetupCompleted' \
  'sameMachineId' \
  'sameSetupRef' \
  'sameOfferId' \
  'firstJoinCompleted' \
  'joinReplayCompleted' \
  'sameBuyerIdentity' \
  'duplicateBuyerPeers' \
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
  grep -F -- "$required" docs/schemas/preview16-clean-host-e2e-execution-receipt.v1.json > /dev/null || {
    printf 'Preview.16 execution-receipt schema missing: %s\n' "$required" >&2
    exit 1
  }
done

node scripts/verify-preview16-clean-host-e2e.mjs --self-test
node --test tests/preview16-clean-host-e2e-verifier.mjs
node scripts/generate-preview16-command-reference.mjs --self-test
node scripts/generate-preview16-command-reference.mjs \
  --template docs/preview16-public-command-contract.template.json

for required in \
  '"name": "--agent-config"' \
  '"name": "--observed-at"' \
  '"name": "--offer-id"' \
  '"name": "--window-seconds"' \
  '"name": "--price-minor"' \
  '"name": "--targeted-zero-authorization-id"' \
  '"name": "--targeted-buyer-actor-id"' \
  '"name": "prepare-host"' \
  '"name": "onboarding-request"' \
  '"name": "onboarding-status"' \
  '"name": "overview"' \
  '"provider": ["prepare-host", "identity-init", "onboarding-request", "onboarding-status", "join", "overview", "doctor", "setup", "service-status", "offer-status"]' \
  '"buyer": ["doctor", "join", "offers", "order", "status", "ssh", "stop"]'; do
  grep -F -- "$required" docs/preview16-public-command-contract.template.json > /dev/null || {
    printf 'Preview.16 static command contract missing: %s\n' "$required" >&2
    exit 1
  }
done

contract=docs/preview16-public-command-contract.json
[ -e "$contract" ] || {
  printf '%s\n' 'Preview.16 bound public command contract is missing' >&2
  exit 1
}
for required in \
  '49d1dba584c52de7e0b75dc77a2b9572c3a31ef417575e8c80a5f6e16422da17' \
  '83258b75849ac55f8a03637d66fd9b6b4f9548071185d65f3d90632ff8391617' \
  'd6a8ada6063a997a2bd510e1ccdc8898fe4ad61e52159d92e09dff7e05490318' \
  '8d9de3adaf3e0753c87d12f9b1300fda60f74727e5638dfa93ed161ebee2db2a'; do
  grep -F -- "$required" "$contract" > /dev/null || {
    printf 'Preview.16 bound command contract is missing artifact digest: %s\n' "$required" >&2
    exit 1
  }
done
node scripts/generate-preview16-command-reference.mjs \
  --contract "$contract" \
  --target docs/PREVIEW16_COMMAND_REFERENCE.md
printf '%s\n' 'Preview.16 public release-gate contract: PASS'
