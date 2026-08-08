import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const verifier = path.join(repo, 'scripts/verify-preview14-clean-host-e2e.mjs');
const reportSchema = JSON.parse(fs.readFileSync(path.join(repo, 'docs/schemas/preview14-clean-host-e2e-report.v1.json'), 'utf8'));
const receiptSchema = JSON.parse(fs.readFileSync(path.join(repo, 'docs/schemas/preview14-clean-host-e2e-execution-receipt.v1.json'), 'utf8'));

const hashBytes = (value) => `sha256:${crypto.createHash('sha256').update(value).digest('hex')}`;
const archiveSha256 = hashBytes('focused verifier fixture archive');

function receiptFixture() {
  return {
    schemaVersion: receiptSchema.schemaVersion,
    receiptKind: receiptSchema.requiredReceiptKind,
    releaseVersion: '0.1.0-preview.14',
    status: 'PASS',
    sanitized: true,
    credentialsCaptured: false,
    setup: structuredClone(receiptSchema.requiredSetup),
    order: structuredClone(receiptSchema.requiredOrder),
    restart: structuredClone(receiptSchema.requiredRestart),
    buyerSsh: structuredClone(receiptSchema.requiredBuyerSsh),
    stop: structuredClone(receiptSchema.requiredStop),
    cleanup: structuredClone(receiptSchema.requiredCleanup),
    provenance: {
      archiveSha256,
      ...structuredClone(receiptSchema.requiredProvenanceAssertions)
    }
  };
}

function reportFixture(receiptBytes) {
  const passed = (keys) => Object.fromEntries(keys.map((key) => [key, 'PASS']));
  return {
    schemaVersion: reportSchema.schemaVersion,
    releaseVersion: '0.1.0-preview.14',
    proofLabel: 'CLEAN_HOST_E2E_PASS',
    status: 'PASS',
    sanitized: true,
    credentialsCaptured: false,
    executionReceipt: {
      schemaVersion: receiptSchema.schemaVersion,
      sha256: hashBytes(receiptBytes)
    },
    execution: structuredClone(reportSchema.requiredExecution),
    artifact: {
      source: 'RELEASE_ARCHIVE',
      archiveSha256,
      installer: 'RELEASE_ARCHIVE_INSTALLER',
      launchers: ['punch', 'punch-buyer', 'punch-provider']
    },
    provider: passed(reportSchema.requiredProviderSteps),
    buyer: passed(reportSchema.requiredBuyerSteps),
    cleanup: passed(reportSchema.requiredCleanupSteps),
    substitutionGuards: structuredClone(reportSchema.requiredSubstitutionGuards)
  };
}

function runVerifier(t, { mutateReceipt, mutateReport, appendAfterBinding = '' } = {}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'punch-preview14-verifier-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const receipt = receiptFixture();
  mutateReceipt?.(receipt);
  const boundReceiptBytes = Buffer.from(`${JSON.stringify(receipt, null, 2)}\n`);
  const report = reportFixture(boundReceiptBytes);
  mutateReport?.(report);
  const receiptBytes = Buffer.concat([boundReceiptBytes, Buffer.from(appendAfterBinding)]);
  const reportPath = path.join(root, 'summary.json');
  const receiptPath = path.join(root, 'execution-receipt.json');
  fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`);
  fs.writeFileSync(receiptPath, receiptBytes);
  return spawnSync(process.execPath, [verifier, '--report', reportPath, '--receipt', receiptPath], { encoding: 'utf8' });
}

function rejected(t, options, message) {
  const result = runVerifier(t, options);
  assert.notEqual(result.status, 0, message);
  assert.match(result.stderr, /release gate: FAIL/);
}

function failingValue(required) {
  if (typeof required === 'boolean') return !required;
  if (typeof required === 'number') return required + 1;
  return 'INVALID';
}

test('accepts the v1 summary only with its exact sanitized companion receipt bytes', (t) => {
  const result = runVerifier(t);
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /release gate: PASS/);

  rejected(t, { appendAfterBinding: '\n' }, 'changed companion bytes must break the summary digest binding');
});

test('requires exact setup replay without duplicate durable Provider resources', (t) => {
  for (const [key, required] of Object.entries(receiptSchema.requiredSetup)) {
    rejected(t, { mutateReceipt: (receipt) => { receipt.setup[key] = failingValue(required); } }, `setup.${key} must fail closed`);
  }
});

test('requires idempotent order correlation, restart adoption, and real archive-installed Buyer SSH', (t) => {
  for (const group of ['order', 'restart', 'buyerSsh']) {
    const expected = receiptSchema[`required${group[0].toUpperCase()}${group.slice(1)}`];
    for (const [key, required] of Object.entries(expected)) {
      rejected(t, { mutateReceipt: (receipt) => { receipt[group][key] = failingValue(required); } }, `${group}.${key} must fail closed`);
    }
  }
});

test('requires identical terminal stop retry and signed zero-state cleanup', (t) => {
  for (const group of ['stop', 'cleanup']) {
    const expected = receiptSchema[`required${group[0].toUpperCase()}${group.slice(1)}`];
    for (const [key, required] of Object.entries(expected)) {
      rejected(t, { mutateReceipt: (receipt) => { receipt[group][key] = failingValue(required); } }, `${group}.${key} must fail closed`);
    }
  }
});

test('requires matching release-archive provenance and rejects fake or injected seams', (t) => {
  rejected(t, {
    mutateReceipt: (receipt) => { receipt.provenance.archiveSha256 = hashBytes('different archive'); }
  }, 'receipt and summary archive digests must match');

  for (const key of Object.keys(receiptSchema.requiredProvenanceAssertions)) {
    rejected(t, { mutateReceipt: (receipt) => { receipt.provenance[key] = false; } }, `provenance.${key} must fail closed`);
  }
  for (const key of Object.keys(reportSchema.requiredSubstitutionGuards)) {
    rejected(t, { mutateReport: (report) => { report.substitutionGuards[key] = true; } }, `substitutionGuards.${key} must fail closed`);
  }
  rejected(t, { mutateReport: (report) => { report.artifact.source = 'SOURCE_CHECKOUT'; } }, 'source checkout provenance must fail closed');
});
