#!/usr/bin/env node
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const schema = JSON.parse(fs.readFileSync(path.join(repo, 'docs/schemas/preview14-clean-host-e2e-report.v1.json'), 'utf8'));
const forbidden = [
  '/Users/', '/home/', 'BEGIN PRIVATE KEY', 'Bearer ', 'ghp_', 'github_pat_',
  'DATABASE_URL', 'NETBIRD_SETUP_KEY', 'redemptionSecret', 'credentialId'
];

const topLevel = schema.requiredTopLevelKeys;
const providerSteps = schema.requiredProviderSteps;
const buyerSteps = schema.requiredBuyerSteps;
const cleanupSteps = schema.requiredCleanupSteps;
const guardKeys = Object.keys(schema.requiredSubstitutionGuards);

function exactKeys(value, keys, label) {
  assert.ok(value && typeof value === 'object' && !Array.isArray(value), `${label} must be an object`);
  assert.deepEqual(Object.keys(value).sort(), [...keys].sort(), `${label} keys drift`);
}

function safeText(value, label) {
  assert.equal(typeof value, 'string', `${label} must be text`);
  for (const term of forbidden) assert.ok(!value.includes(term), `${label} contains private or credential material`);
}

function digest(value, label) {
  assert.equal(typeof value, 'string', `${label} must be text`);
  assert.match(value, /^sha256:[0-9a-f]{64}$/, `${label} must be a sha256 digest`);
}

function passSteps(value, keys, label) {
  exactKeys(value, keys, label);
  for (const key of keys) assert.equal(value[key], 'PASS', `${label}.${key} must pass`);
}

function validate(report) {
  safeText(JSON.stringify(report), 'clean-host E2E report');
  exactKeys(report, topLevel, 'clean-host E2E report');
  assert.equal(report.schemaVersion, schema.schemaVersion);
  assert.equal(report.releaseVersion, '0.1.0-preview.14');
  assert.equal(report.proofLabel, 'CLEAN_HOST_E2E_PASS');
  assert.equal(report.status, 'PASS');
  assert.equal(report.sanitized, true);
  assert.equal(report.credentialsCaptured, false);

  exactKeys(report.execution, Object.keys(schema.requiredExecution), 'execution');
  for (const [key, expected] of Object.entries(schema.requiredExecution)) {
    assert.equal(report.execution[key], expected, `execution.${key} must prove the real seam`);
  }

  exactKeys(report.artifact, ['source', 'archiveSha256', 'installer', 'launchers'], 'artifact');
  assert.equal(report.artifact.source, 'RELEASE_ARCHIVE');
  digest(report.artifact.archiveSha256, 'artifact.archiveSha256');
  assert.equal(report.artifact.installer, 'RELEASE_ARCHIVE_INSTALLER');
  assert.deepEqual(report.artifact.launchers, ['punch', 'punch-buyer', 'punch-provider']);

  passSteps(report.provider, providerSteps, 'provider');
  passSteps(report.buyer, buyerSteps, 'buyer');
  passSteps(report.cleanup, cleanupSteps, 'cleanup');

  exactKeys(report.substitutionGuards, guardKeys, 'substitutionGuards');
  for (const [key, expected] of Object.entries(schema.requiredSubstitutionGuards)) {
    assert.equal(report.substitutionGuards[key], expected, `substitutionGuards.${key} must reject substituted acceptance`);
  }
}

function fixture() {
  const passed = (keys) => Object.fromEntries(keys.map((key) => [key, 'PASS']));
  return {
    schemaVersion: schema.schemaVersion,
    releaseVersion: '0.1.0-preview.14',
    proofLabel: 'CLEAN_HOST_E2E_PASS',
    status: 'PASS',
    sanitized: true,
    credentialsCaptured: false,
    execution: structuredClone(schema.requiredExecution),
    artifact: {
      source: 'RELEASE_ARCHIVE',
      archiveSha256: `sha256:${crypto.createHash('sha256').update('fixture').digest('hex')}`,
      installer: 'RELEASE_ARCHIVE_INSTALLER',
      launchers: ['punch', 'punch-buyer', 'punch-provider']
    },
    provider: passed(providerSteps),
    buyer: passed(buyerSteps),
    cleanup: passed(cleanupSteps),
    substitutionGuards: structuredClone(schema.requiredSubstitutionGuards)
  };
}

function selfTest() {
  validate(fixture());
  for (const mutate of [
    (report) => { report.execution.containerEngine = 'FAKE_DOCKER'; },
    (report) => { report.execution.registry = 'FIXTURE_IMAGE'; },
    (report) => { report.execution.ssh = 'MOCK_SSH'; },
    (report) => { report.artifact.source = 'SOURCE_CHECKOUT'; },
    (report) => { report.artifact.launchers.pop(); },
    (report) => { report.provider.interactiveCanary = 'FAIL'; },
    (report) => { report.buyer.stop = 'PENDING'; },
    (report) => { report.cleanup.newConnectionRejected = 'UNKNOWN'; },
    (report) => { report.substitutionGuards.fakeDocker = true; },
    (report) => { report.substitutionGuards.sourceCli = true; },
    (report) => { report.sanitized = false; },
    (report) => { report.artifact.archiveSha256 = '/home/provider/archive'; }
  ]) {
    const candidate = structuredClone(fixture());
    mutate(candidate);
    assert.throws(() => validate(candidate));
  }
  const file = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'punch-preview14-gate-')), 'report.json');
  fs.writeFileSync(file, JSON.stringify(fixture()));
  validate(JSON.parse(fs.readFileSync(file, 'utf8')));
  process.stdout.write('Preview.14 clean-host E2E release gate negative fixtures: PASS\n');
}

try {
  const args = process.argv.slice(2);
  if (args.length === 1 && args[0] === '--self-test') {
    selfTest();
  } else if (args.length === 2 && args[0] === '--report') {
    const reportPath = path.resolve(args[1]);
    const stat = fs.lstatSync(reportPath);
    assert.ok(stat.isFile() && !stat.isSymbolicLink(), 'report must be a regular file');
    validate(JSON.parse(fs.readFileSync(reportPath, 'utf8')));
    process.stdout.write('Preview.14 clean-host E2E release gate: PASS\n');
  } else {
    throw new Error('usage: verify-preview14-clean-host-e2e.mjs --report REPORT.json | --self-test');
  }
} catch (error) {
  process.stderr.write(`Preview.14 clean-host E2E release gate: FAIL: ${error.message}\n`);
  process.exit(1);
}
