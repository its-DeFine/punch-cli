#!/usr/bin/env node
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const schema = JSON.parse(fs.readFileSync(path.join(repo, 'docs/schemas/preview16-clean-host-e2e-report.v1.json'), 'utf8'));
const receiptSchema = JSON.parse(fs.readFileSync(path.join(repo, 'docs/schemas/preview16-clean-host-e2e-execution-receipt.v1.json'), 'utf8'));
const forbidden = [
  ['', 'Users', ''].join('/'), ['', 'home', ''].join('/'), ['BEGIN', 'PRIVATE', 'KEY'].join(' '),
  ['Bearer', ''].join(' '), ['ghp', ''].join('_'), ['github', 'pat', ''].join('_'),
  ['DATABASE', 'URL'].join('_'), 'NETBIRD_SETUP_KEY', 'redemptionSecret', 'credentialId'
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

function exactValues(value, expected, label) {
  exactKeys(value, Object.keys(expected), label);
  for (const [key, required] of Object.entries(expected)) {
    assert.deepEqual(value[key], required, `${label}.${key} must equal ${JSON.stringify(required)}`);
  }
}

function safeText(value, label) {
  assert.equal(typeof value, 'string', `${label} must be text`);
  for (const term of forbidden) assert.ok(!value.includes(term), `${label} contains private or credential material`);
}

function digest(value, label) {
  assert.equal(typeof value, 'string', `${label} must be text`);
  assert.match(value, /^sha256:[0-9a-f]{64}$/, `${label} must be a sha256 digest`);
}

function hashBytes(value) {
  return `sha256:${crypto.createHash('sha256').update(value).digest('hex')}`;
}

function passSteps(value, keys, label) {
  exactKeys(value, keys, label);
  for (const key of keys) assert.equal(value[key], 'PASS', `${label}.${key} must pass`);
}

function validateReceipt(receipt, report, receiptBytes) {
  safeText(JSON.stringify(receipt), 'clean-host E2E execution receipt');
  exactKeys(receipt, receiptSchema.requiredTopLevelKeys, 'clean-host E2E execution receipt');
  assert.equal(receipt.schemaVersion, receiptSchema.schemaVersion);
  assert.equal(receipt.receiptKind, receiptSchema.requiredReceiptKind);
  assert.equal(receipt.releaseVersion, report.releaseVersion, 'receipt releaseVersion must match report');
  assert.equal(receipt.status, 'PASS');
  assert.equal(receipt.sanitized, true);
  assert.equal(receipt.credentialsCaptured, false);

  exactValues(receipt.onboarding, receiptSchema.requiredOnboarding, 'receipt.onboarding');
  exactValues(receipt.setup, receiptSchema.requiredSetup, 'receipt.setup');
  exactValues(receipt.buyerJoin, receiptSchema.requiredBuyerJoin, 'receipt.buyerJoin');
  exactValues(receipt.order, receiptSchema.requiredOrder, 'receipt.order');
  exactValues(receipt.restart, receiptSchema.requiredRestart, 'receipt.restart');
  exactValues(receipt.buyerSsh, receiptSchema.requiredBuyerSsh, 'receipt.buyerSsh');
  exactValues(receipt.stop, receiptSchema.requiredStop, 'receipt.stop');
  exactValues(receipt.cleanup, receiptSchema.requiredCleanup, 'receipt.cleanup');

  exactKeys(receipt.provenance, receiptSchema.requiredProvenanceKeys, 'receipt.provenance');
  digest(receipt.provenance.archiveSha256, 'receipt.provenance.archiveSha256');
  assert.equal(receipt.provenance.archiveSha256, report.artifact.archiveSha256, 'receipt archive digest must match report artifact');
  for (const [key, expected] of Object.entries(receiptSchema.requiredProvenanceAssertions)) {
    assert.equal(receipt.provenance[key], expected, `receipt.provenance.${key} must reject substituted execution`);
  }

  exactKeys(report.executionReceipt, Object.keys(schema.requiredExecutionReceipt), 'executionReceipt');
  assert.equal(report.executionReceipt.schemaVersion, receiptSchema.schemaVersion);
  digest(report.executionReceipt.sha256, 'executionReceipt.sha256');
  assert.equal(report.executionReceipt.sha256, hashBytes(receiptBytes), 'execution receipt digest mismatch');
}

function validate(report, receipt, receiptBytes) {
  safeText(JSON.stringify(report), 'clean-host E2E report');
  exactKeys(report, topLevel, 'clean-host E2E report');
  assert.equal(report.schemaVersion, schema.schemaVersion);
  assert.equal(report.releaseVersion, '0.1.0-preview.16');
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

  validateReceipt(receipt, report, receiptBytes);
}

function receiptFixture(archiveSha256) {
  return {
    schemaVersion: receiptSchema.schemaVersion,
    receiptKind: receiptSchema.requiredReceiptKind,
    releaseVersion: '0.1.0-preview.16',
    status: 'PASS',
    sanitized: true,
    credentialsCaptured: false,
    onboarding: structuredClone(receiptSchema.requiredOnboarding),
    setup: structuredClone(receiptSchema.requiredSetup),
    buyerJoin: structuredClone(receiptSchema.requiredBuyerJoin),
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

function fixture() {
  const passed = (keys) => Object.fromEntries(keys.map((key) => [key, 'PASS']));
  const archiveSha256 = `sha256:${crypto.createHash('sha256').update('fixture archive').digest('hex')}`;
  const receipt = receiptFixture(archiveSha256);
  const receiptBytes = Buffer.from(JSON.stringify(receipt));
  return {
    report: {
      schemaVersion: schema.schemaVersion,
      releaseVersion: '0.1.0-preview.16',
      proofLabel: 'CLEAN_HOST_E2E_PASS',
      status: 'PASS',
      sanitized: true,
      credentialsCaptured: false,
      executionReceipt: {
        schemaVersion: receiptSchema.schemaVersion,
        sha256: hashBytes(receiptBytes)
      },
      execution: structuredClone(schema.requiredExecution),
      artifact: {
        source: 'RELEASE_ARCHIVE',
        archiveSha256,
        installer: 'RELEASE_ARCHIVE_INSTALLER',
        launchers: ['punch', 'punch-buyer', 'punch-provider']
      },
      provider: passed(providerSteps),
      buyer: passed(buyerSteps),
      cleanup: passed(cleanupSteps),
      substitutionGuards: structuredClone(schema.requiredSubstitutionGuards)
    },
    receipt,
    receiptBytes
  };
}

function selfTest() {
  const valid = fixture();
  validate(valid.report, valid.receipt, valid.receiptBytes);
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
    (report) => { report.artifact.archiveSha256 = ['', 'home', 'provider', 'archive'].join('/'); }
  ]) {
    const candidate = fixture();
    mutate(candidate.report);
    assert.throws(() => validate(candidate.report, candidate.receipt, candidate.receiptBytes));
  }
  for (const mutate of [
    (receipt) => { receipt.onboarding.preflightBeforeIdentity = false; },
    (receipt) => { receipt.onboarding.inviteReadyObserved = false; },
    (receipt) => { receipt.setup.firstSetupCompleted = false; },
    (receipt) => { receipt.setup.sameSetupRef = false; },
    (receipt) => { receipt.buyerJoin.joinReplayCompleted = false; },
    (receipt) => { receipt.order.oneContract = false; },
    (receipt) => { receipt.restart.duplicateContainers = 1; },
    (receipt) => { receipt.buyerSsh.realOpenSsh = false; },
    (receipt) => { receipt.stop.sameTerminalReceiptDigest = false; },
    (receipt) => { receipt.cleanup.activeSessions = 1; },
    (receipt) => { receipt.provenance.noFixtureTransport = false; }
  ]) {
    const candidate = fixture();
    mutate(candidate.receipt);
    candidate.receiptBytes = Buffer.from(JSON.stringify(candidate.receipt));
    candidate.report.executionReceipt.sha256 = hashBytes(candidate.receiptBytes);
    assert.throws(() => validate(candidate.report, candidate.receipt, candidate.receiptBytes));
  }
  const unbound = fixture();
  unbound.receiptBytes = Buffer.concat([unbound.receiptBytes, Buffer.from('\n')]);
  assert.throws(() => validate(unbound.report, unbound.receipt, unbound.receiptBytes));

  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'punch-preview16-gate-'));
  const reportFile = path.join(root, 'report.json');
  const receiptFile = path.join(root, 'receipt.json');
  fs.writeFileSync(reportFile, JSON.stringify(valid.report));
  fs.writeFileSync(receiptFile, valid.receiptBytes);
  validate(JSON.parse(fs.readFileSync(reportFile, 'utf8')), JSON.parse(fs.readFileSync(receiptFile, 'utf8')), fs.readFileSync(receiptFile));
  process.stdout.write('Preview.16 clean-host E2E release gate negative fixtures: PASS\n');
}

function readRegularFile(file, label) {
  const stat = fs.lstatSync(file);
  assert.ok(stat.isFile() && !stat.isSymbolicLink(), `${label} must be a regular file`);
  return fs.readFileSync(file);
}

function parseFiles(args) {
  assert.equal(args.length, 4, 'usage: verify-preview16-clean-host-e2e.mjs --report REPORT.json --receipt RECEIPT.json | --self-test');
  const files = {};
  for (let index = 0; index < args.length; index += 2) {
    const flag = args[index];
    assert.ok(flag === '--report' || flag === '--receipt', `unknown argument: ${flag}`);
    const key = flag.slice(2);
    assert.equal(files[key], undefined, `duplicate argument: ${flag}`);
    files[key] = path.resolve(args[index + 1]);
  }
  assert.ok(files.report && files.receipt, '--report and --receipt are required');
  return files;
}

try {
  const args = process.argv.slice(2);
  if (args.length === 1 && args[0] === '--self-test') {
    selfTest();
  } else {
    const files = parseFiles(args);
    const reportBytes = readRegularFile(files.report, 'report');
    const receiptBytes = readRegularFile(files.receipt, 'receipt');
    validate(JSON.parse(reportBytes), JSON.parse(receiptBytes), receiptBytes);
    process.stdout.write('Preview.16 clean-host E2E release gate: PASS\n');
  }
} catch (error) {
  process.stderr.write(`Preview.16 clean-host E2E release gate: FAIL: ${error.message}\n`);
  process.exit(1);
}
