#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

node --input-type=module <<'NODE'
import assert from 'node:assert/strict';
import fs from 'node:fs';

const handoff = fs.readFileSync('docs/PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md', 'utf8');
const schema = JSON.parse(fs.readFileSync('docs/schemas/buyer-stop-operation.v1.json', 'utf8'));
for (const text of [
  'punch-buyer stop --config ABSOLUTE_PUBLIC_CONFIG --job JOB_ID [--json]',
  'POST /api/v0/buyer/jobs/{jobId}/stop',
  'GET /api/v0/buyer/jobs/{jobId}/stop',
  '"state": "ACCEPTANCE_PENDING"',
  '"phase": "ACCEPTANCE"',
  'ACCEPTANCE_PENDING',
  'PREPARED',
  'buyer_cli_operations',
  'canonical lifecycle acceptance',
  'state: "SUCCEEDED"',
  'cleanupState: "RELEASED"',
  'state: "FAILED"',
  'IN_PROGRESS',
  '202',
  '200',
  '409',
  'retryAfterMs',
  'Exact retries preserve the same operation identity and terminal result',
  '400 VALIDATION_ERROR',
  '409 IDEMPOTENCY_CONFLICT',
  '`{"code":"NOT_FOUND"}`',
  'GET polling must not depend on synchronous heavy reconciliation',
  'The public response never awaits relay revocation',
  'BUYER_STOP_TIMEOUT',
  'No admin/Provider fallback',
  'Acceptance boundary',
  'A `503` is',
  'before the durable intent can begin',
  'GET returns',
  'fail-closed `404`',
  'never creates stop intent',
  'may re-enqueue',
  '## Status/reconcile journal boundary',
  'access',
  'revocation first',
  'signed Provider cleanup',
  'cleanupState: "PENDING"',
  '## CLI reconciliation',
  '10-second bound',
  '300-second overall reconciliation deadline',
  '524',
  'GET first',
  'operation and contract binding',
  'BUYER_PROTOCOL_INVALID'
]) assert.ok(handoff.includes(text), `handoff missing ${text}`);
assert.ok(handoff.includes('A `202` stop operation never surfaces an ambiguous'));
assert.equal(schema.properties.schemaVersion.const, 'punch.buyer-stop-operation.v1');
assert.equal(schema.additionalProperties, false);
assert.equal(schema.properties.operationId.pattern, '^bso_[0-9a-f]{48}$');
assert.equal(schema.properties.correlationId.pattern, '^bso_[0-9a-f]{48}$');
assert.equal(schema.properties.retryAfterMs.minimum, 1);
assert.equal(schema.properties.retryAfterMs.maximum, 300000);
assert.ok(schema.properties.state.enum.includes('IN_PROGRESS'));
assert.ok(schema.properties.state.enum.includes('ACCEPTANCE_PENDING'));
assert.ok(schema.properties.cleanupState.enum.includes('PENDING'));
assert.ok(schema.properties.cleanupState.enum.includes('RELEASED'));
assert.deepEqual(schema.properties.phase.enum, [
  'ACCEPTANCE', 'ACCESS_REVOCATION', 'LIFECYCLE_FINALIZATION', 'PROVIDER_CLEANUP', 'COMPLETED', 'TERMINAL_FAILURE'
]);
assert.equal(schema.allOf.length, 7);
assert.equal(schema.allOf[0].then.properties.retryable.const, true);
const success = schema.allOf.find((entry) => entry.if?.properties?.state?.const === 'SUCCEEDED');
assert.equal(success.then.properties.retryable.const, false);
assert.equal(success.then.properties.cleanupState.const, 'RELEASED');
assert.notEqual(success.then.properties.cleanupState.const, 'PENDING');
const failed = schema.allOf.find((entry) => entry.if?.properties?.state?.const === 'FAILED');
assert.equal(failed.then.properties.retryable.const, false);
const acceptancePending = schema.allOf.find((entry) =>
  entry.if?.properties?.state?.const === 'ACCEPTANCE_PENDING'
);
assert.equal(acceptancePending.then.properties.phase.const, 'ACCEPTANCE');
const inProgress = schema.allOf.find((entry) =>
  entry.if?.properties?.state?.const === 'IN_PROGRESS'
);
assert.deepEqual(inProgress.then.properties.phase.enum, ['ACCESS_REVOCATION', 'PROVIDER_CLEANUP']);
const accessRevocation = schema.allOf.find((entry) =>
  entry.if?.properties?.phase?.const === 'ACCESS_REVOCATION'
);
assert.deepEqual(accessRevocation.then.not.required, ['cleanupState']);
const providerCleanup = schema.allOf.find((entry) =>
  entry.if?.properties?.phase?.const === 'PROVIDER_CLEANUP'
);
assert.ok(providerCleanup, 'schema must constrain in-progress provider cleanup');
assert.deepEqual(providerCleanup.then.required, ['cleanupState']);
assert.equal(providerCleanup.then.properties.cleanupState.const, 'PENDING');
console.log('Buyer async stop contract/polling fixtures: PASS');
NODE
