#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

node --input-type=module <<'NODE'
import { readFileSync } from 'node:fs';

const contract = JSON.parse(readFileSync('docs/preview17-runtime-contract.json', 'utf8'));
const version = '0.1.0-preview.17';
const privateSource = {
  commit: '5a2e9d4f4e4e38ce4dcd782891533a67c2a51768',
  tree: '2e4439d38ded6679afbafc4ad2e16cb282308eb7'
};
if (!contract || typeof contract !== 'object' || Array.isArray(contract)
    || contract.schemaVersion !== 'punch.preview17-runtime-contract.v1'
    || contract.releaseVersion !== version || contract.releaseStatus !== 'PUBLISHED_PRERELEASE'
    || contract.platform !== 'linux-x64'
    || contract.privateReleaseSource?.commit !== privateSource.commit
    || contract.privateReleaseSource?.tree !== privateSource.tree
    || contract.accessTransport !== 'NETBIRD_CONTRACT_SCOPED_GATEWAY'
    || contract.offerPolicy !== 'OWNER_TARGETED_ZERO_ONLY' || contract.priceMinor !== 0
    || contract.paymentSettlementEnabled !== false || contract.selfServiceProviderOnboarding !== false) {
  throw new Error('Public Preview.17 runtime contract is incompatible with the private builder.');
}
if (contract.controlArchiveSha256 !== 'sha256:33fcb27b312c346540075df64a8598133eb32b1bdce81378cb3b22026d5f8d1e') {
  throw new Error('Public Preview.17 runtime contract lost the reviewed Control archive binding.');
}
if (contract.artifactBinding?.authority !== 'AUTHORITATIVE_PACKAGED_CLI_SURFACE'
    || contract.artifactBinding.archiveSha256 !== 'sha256:76648c0bd4d9b96399fe52b553151ad8594e49af9c46aba565e23217ee56f10c'
    || contract.artifactBinding.sha256SumsSha256 !== 'sha256:807ba2bac9b9d8324dc7aac9942d92f4f5ad2a366c590a023df58d747b0eed52'
    || contract.artifactBinding.packagedCliSurfaceSha256 !== 'sha256:8d9de3adaf3e0753c87d12f9b1300fda60f74727e5638dfa93ed161ebee2db2a'
    || contract.guidedCli?.directCommands !== contract.artifactBinding.packagedCliSurfaceSha256) {
  throw new Error('Public Preview.17 runtime contract lost the authoritative packaged artifact binding.');
}
process.stdout.write('Preview.17 private-builder runtime-contract compatibility: PASS\n');
NODE

for required in \
  'PUBLISHED_PRERELEASE' \
  'PENDING_AGENT' \
  'LISTED' \
  'public onboarding packet' \
  'Guided Buyer authorization repair' \
  'failed authorization stops before dependency installation or join' \
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
  grep -F -- "$required" docs/PREVIEW17.md > /dev/null || {
    printf 'Preview.17 release-gate documentation missing: %s\n' "$required" >&2
    exit 1
  }
done

if grep -F -- 'PENDING_VALIDATION' docs/PREVIEW17.md docs/preview17-runtime-contract.json > /dev/null; then
  printf '%s\n' 'Preview.17 must use PENDING_AGENT, not PENDING_VALIDATION' >&2
  exit 1
fi

if grep -F -- 'GATED_UNRELEASED' \
  docs/PREVIEW17.md docs/PREVIEW17_COMMAND_REFERENCE.md \
  docs/preview17-runtime-contract.json \
  docs/preview17-public-command-contract.template.json \
  docs/preview17-public-command-contract.json \
  docs/schemas/preview17-clean-host-e2e-execution-receipt.v1.json \
  docs/schemas/preview17-clean-host-e2e-report.v1.json \
  docs/schemas/preview17-public-command-contract-format.v1.json > /dev/null; then
  printf '%s\n' 'Preview.17 published surfaces retain a gated contradiction' >&2
  exit 1
fi

for required in \
  'AUTHORITATIVE_PACKAGED_CLI_SURFACE' \
  'privateReleaseSource' \
  'NETBIRD_CONTRACT_SCOPED_GATEWAY' \
  'OWNER_TARGETED_ZERO_ONLY' \
  '5a2e9d4f4e4e38ce4dcd782891533a67c2a51768' \
  '2e4439d38ded6679afbafc4ad2e16cb282308eb7' \
  'sha256:33fcb27b312c346540075df64a8598133eb32b1bdce81378cb3b22026d5f8d1e' \
  'sha256:76648c0bd4d9b96399fe52b553151ad8594e49af9c46aba565e23217ee56f10c' \
  'sha256:807ba2bac9b9d8324dc7aac9942d92f4f5ad2a366c590a023df58d747b0eed52' \
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
  'guidedInstallPasswordlessProbe' \
  'guidedInstallInteractiveFallback' \
  'guidedInstallAuthorizationFailureStopsBeforeJoin' \
  'multipleSupervisedProviders' \
  'maxAuthorizedWindowSeconds' \
  'ineligibleOffersOrderable' \
  'accessStartsAfterSshAndGatewayReady' \
  'stopRevocationFirst' \
  'paymentSettlementEnabled'; do
  grep -F -- "$required" docs/preview17-runtime-contract.json > /dev/null || {
    printf 'Preview.17 runtime contract missing: %s\n' "$required" >&2
    exit 1
  }
done

grep -F 'GENERATED PREVIEW17 COMMAND REFERENCE:BEGIN' docs/PREVIEW17_COMMAND_REFERENCE.md > /dev/null || {
  printf '%s\n' 'Preview.17 generated command-reference target is missing its begin marker' >&2
  exit 1
}

for required in \
  'punch.preview17-public-command-contract.v1' \
  'privateRuntimeBindingKeys' \
  'generationRule' \
  'runtimeMatchRequired' \
  'nonInteractivePrivilegedInstallRequiresCachedSudo' \
  'multipleSupervisedProviders' \
  'maxAuthorizedWindowSeconds' \
  'ineligibleOffersOrderable'; do
  grep -F -- "$required" docs/schemas/preview17-public-command-contract-format.v1.json > /dev/null || {
    printf 'Preview.17 generated command-contract format missing: %s\n' "$required" >&2
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
  'punch.preview17-clean-host-e2e-execution-receipt.v1' \
  'fakeDocker' \
  'fakeFetch' \
  'inMemoryControl' \
  'sourceCli' \
  'mockSsh'; do
  grep -F -- "$required" docs/schemas/preview17-clean-host-e2e-report.v1.json > /dev/null || {
    printf 'Preview.17 clean-host schema missing: %s\n' "$required" >&2
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
  grep -F -- "$required" docs/schemas/preview17-clean-host-e2e-execution-receipt.v1.json > /dev/null || {
    printf 'Preview.17 execution-receipt schema missing: %s\n' "$required" >&2
    exit 1
  }
done

node scripts/verify-preview17-clean-host-e2e.mjs --self-test
node --test tests/preview17-clean-host-e2e-verifier.mjs
node scripts/generate-preview17-command-reference.mjs --self-test
node scripts/generate-preview17-command-reference.mjs \
  --template docs/preview17-public-command-contract.template.json

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
  grep -F -- "$required" docs/preview17-public-command-contract.template.json > /dev/null || {
    printf 'Preview.17 static command contract missing: %s\n' "$required" >&2
    exit 1
  }
done

contract=docs/preview17-public-command-contract.json
[ -e "$contract" ] || {
  printf '%s\n' 'Preview.17 bound public command contract is missing' >&2
  exit 1
}
for required in \
  '76648c0bd4d9b96399fe52b553151ad8594e49af9c46aba565e23217ee56f10c' \
  '807ba2bac9b9d8324dc7aac9942d92f4f5ad2a366c590a023df58d747b0eed52' \
  'a59c807fc41cd8f8c1f3c21f0e8ef2d49b52bd0a072e33ae2171b105ffb8fcdc' \
  '8d9de3adaf3e0753c87d12f9b1300fda60f74727e5638dfa93ed161ebee2db2a'; do
  grep -F -- "$required" "$contract" > /dev/null || {
    printf 'Preview.17 bound command contract is missing artifact digest: %s\n' "$required" >&2
    exit 1
  }
done
node scripts/generate-preview17-command-reference.mjs \
  --contract "$contract" \
  --target docs/PREVIEW17_COMMAND_REFERENCE.md
printf '%s\n' 'Preview.17 public release-gate contract: PASS'
