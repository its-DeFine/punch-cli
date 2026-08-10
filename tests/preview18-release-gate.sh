#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

node --input-type=module <<'NODE'
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const runtime = JSON.parse(readFileSync('docs/preview18-runtime-contract.json', 'utf8'));
assert.equal(runtime.schemaVersion, 'punch.preview18-runtime-contract.v1');
assert.equal(runtime.releaseVersion, '0.1.0-preview.18');
assert.equal(runtime.releaseStatus, 'GATED_UNRELEASED');
assert.deepEqual(runtime.privateReleaseSource, {
  commit: '4e4aae1bb335092d69dc467a74651ad9527c4c17',
  tree: 'a0fbb1491130d179b602c64e9b7fe170c7011de6'
});
assert.equal(runtime.controlArchiveSha256, 'sha256:fcaa8d0c28d48f68bf940811457cfcd2ff594c9d14139dae33301749d6c0ae5a');
assert.deepEqual(runtime.artifactBinding, {
  authority: 'PENDING_DETERMINISTIC_BUILD',
  archiveSha256: null,
  sha256SumsSha256: null,
  packagedCliSurfaceSha256: null
});
assert.equal(runtime.guidedCli.directCommands, null);
assert.equal(runtime.guidedCli.appendOnlyProviderOnboarding, true);
assert.equal(runtime.guidedCli.explicitOfferSelection, true);
assert.equal(runtime.guidedCli.sequentialOfferReplacement, true);
assert.equal(runtime.guidedCli.singleNonterminalOfferPerMachine, true);
assert.equal(runtime.buyer.guidedTargetedCanonicalZeroOnly, true);
assert.equal(runtime.buyer.scopedSshEgressConsentRequired, true);
assert.equal(runtime.buyer.guidedSshSpawnsChild, false);
assert.equal(runtime.buyer.copyReadySshCommandVisible, true);
assert.equal(runtime.buyer.osc52ClipboardExplicitConsentRequired, true);
assert.equal(runtime.buyer.osc52UnsupportedKeepsVisibleFallback, true);

const template = JSON.parse(readFileSync('docs/preview18-public-command-contract.template.json', 'utf8'));
assert.equal(template.schemaVersion, 'punch.preview18-public-command-contract.v1');
assert.equal(template.releaseVersion, '0.1.0-preview.18');
assert.equal(template.releaseStatus, 'GATED_UNRELEASED');
assert.deepEqual(template.privateRuntimeBinding, {
  commit: runtime.privateReleaseSource.commit,
  tree: runtime.privateReleaseSource.tree,
  controlArchiveSha256: runtime.controlArchiveSha256
});
for (const value of Object.values(template.artifact)) assert.equal(value, 'PENDING_DETERMINISTIC_BUILD');
for (const name of ['offer-list', 'offer-replace']) {
  assert.ok(template.commands.some((command) => command.role === 'provider' && command.name === name), name + ' missing');
}
assert.equal(template.security.appendOnlyProviderOnboarding, true);
assert.equal(template.security.sequentialOfferReplacementOnly, true);
assert.equal(template.security.guidedTargetedCanonicalZeroOnly, true);
assert.equal(template.security.scopedBuyerSshEgressConsentRequired, true);
assert.equal(template.security.guidedSshSpawnsChild, false);
assert.equal(template.security.osc52ClipboardExplicitConsentRequired, true);
process.stdout.write('Preview.18 pending runtime/static binding: PASS\n');
NODE

[ ! -e docs/preview18-public-command-contract.json ] || {
  printf '%s\n' 'Preview.18 must not carry a pseudo-bound public command contract before build' >&2
  exit 1
}

preview17_files='
docs/PREVIEW17.md
docs/PREVIEW17_COMMAND_REFERENCE.md
docs/preview17-public-command-contract.json
docs/preview17-public-command-contract.template.json
docs/preview17-runtime-contract.json
docs/schemas/preview17-clean-host-e2e-execution-receipt.v1.json
docs/schemas/preview17-clean-host-e2e-report.v1.json
docs/schemas/preview17-public-command-contract-format.v1.json
scripts/generate-preview17-command-reference.mjs
scripts/verify-preview17-clean-host-e2e.mjs
tests/preview17-clean-host-e2e-verifier.mjs
tests/preview17-release-gate.sh
'
# shellcheck disable=SC2086
git diff --quiet bb7da95 -- $preview17_files || {
  printf '%s\n' 'Preview.17 versioned surfaces changed' >&2
  exit 1
}

for file in README.md docs/RELEASES.md; do
  grep -F 'v0.1.0-preview.17' "$file" >/dev/null || {
    printf 'Current-release pointer changed before Preview.18 publication: %s\n' "$file" >&2
    exit 1
  }
done
grep -F 'punch-cli-0.1.0-preview.17-linux-x64.tar.gz' docs/INSTALL.md >/dev/null || {
  printf '%s\n' 'Install current-release pointer changed before Preview.18 publication' >&2
  exit 1
}

for required in \
  'PUBLISHED_PRERELEASE' \
  'matching non-draft' \
  'and its pending metadata are not install authority' \
  'Append-only Provider onboarding' \
  'permits only one nonterminal offer' \
  'canonical numeric +0' \
  'Prepare SSH command' \
  'does not spawn SSH' \
  'OSC 52' \
  '4e4aae1bb335092d69dc467a74651ad9527c4c17' \
  'a0fbb1491130d179b602c64e9b7fe170c7011de6' \
  'sha256:fcaa8d0c28d48f68bf940811457cfcd2ff594c9d14139dae33301749d6c0ae5a'; do
  grep -F "$required" docs/PREVIEW18.md >/dev/null || {
    printf 'Preview.18 release note missing: %s\n' "$required" >&2
    exit 1
  }
done

for pair in \
  'docs/GUIDED_CLI.md|Prepare SSH command' \
  'docs/GUIDED_CLI.md|one nonterminal offer per machine' \
  'docs/PROVIDER.md|punch-provider offer-list' \
  'docs/PROVIDER.md|punch-provider offer-replace' \
  'docs/BUYER.md|canonical numeric +0' \
  'docs/BUYER.md|BatchMode=yes' \
  'docs/OFFER_LIFECYCLE_PREVIEW.md|distinct PENDING_AGENT successor' \
  'docs/TROUBLESHOOTING.md|BUYER_SSH_EGRESS_ROLLBACK_UNPROVEN' \
  'docs/INVITATIONS.md|append-only' \
  'docs/COMMANDS.md|offer-replace'; do
  file=${pair%%|*}
  required=${pair#*|}
  grep -F "$required" "$file" >/dev/null || {
    printf 'Preview.18 operator documentation missing %s in %s\n' "$required" "$file" >&2
    exit 1
  }
done

if rg -n '76648c0bd4d9b96399fe52b553151ad8594e49af9c46aba565e23217ee56f10c|807ba2bac9b9d8324dc7aac9942d92f4f5ad2a366c590a023df58d747b0eed52|8d9de3adaf3e0753c87d12f9b1300fda60f74727e5638dfa93ed161ebee2db2a' \
  docs/PREVIEW18.md docs/PREVIEW18_COMMAND_REFERENCE.md docs/preview18-* docs/schemas/preview18-* >/dev/null; then
  printf '%s\n' 'Preview.18 candidate contains a stale Preview.17 artifact digest' >&2
  exit 1
fi

node scripts/generate-preview18-command-reference.mjs --self-test
node scripts/generate-preview18-command-reference.mjs \
  --template docs/preview18-public-command-contract.template.json \
  --target docs/PREVIEW18_COMMAND_REFERENCE.md
node scripts/verify-preview18-clean-host-e2e.mjs --self-test
node --test tests/preview18-clean-host-e2e-verifier.mjs

printf '%s\n' 'Preview.18 public artifact-source gate: PASS'
