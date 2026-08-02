#!/usr/bin/env node
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const requiredSteps = [
  'provider.join', 'provider.inventory', 'provider.identity',
  'provider.setup_as_offer', 'provider.serve', 'buyerA.join', 'buyerB.join',
  'buyerA.offers', 'buyerB.offers', 'buyerA.order', 'buyerA.status',
  'buyerA.ssh_harmless', 'buyerA.stop', 'buyerA.retry_identical',
  'buyerA.post_stop_rejection', 'internal.signed_interactive_start',
  'internal.signed_cleanup'
];
const reportKeys = ['schemaVersion', 'proofLabel', 'status', 'sanitized', 'timing', 'capturedInput', 'childOutput', 'environments', 'steps', 'publicReceipts', 'internalReceipts', 'replay', 'productionStoreMutation'];
const environmentKeys = ['provider', 'buyerA', 'buyerB'];

function exactKeys(value, keys, label) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error(`${label} must be an object`);
  assert.deepEqual(Object.keys(value).sort(), [...keys].sort(), `${label} keys drift`);
}
function safeText(value, label) {
  assert.equal(typeof value, 'string', `${label} must be text`);
  assert.ok(![ '/' + 'Users/', '/' + 'home/', 'BEGIN ' + 'PRIVATE KEY', 'Bearer' + ' ', 'gh' + 'p_', 'github' + '_pat_', 'SUPA' + 'BASE', 'DATABASE' + '_URL' ].some((term) => value.includes(term)), `${label} contains secret/private material`);
}
function validateReport(report) {
  exactKeys(report, reportKeys, 'disposable POV report');
  assert.equal(report.schemaVersion, 'punch.disposable-pov-report.v1');
  assert.equal(report.proofLabel, 'LOCAL_DETERMINISTIC_PASS');
  assert.equal(report.status, 'PASS');
  assert.equal(report.sanitized, true);
  assert.equal(report.timing, 'UTC+MONOTONIC');
  assert.equal(report.capturedInput, false);
  assert.equal(report.childOutput, 'SANITIZED_IN_MEMORY');
  assert.equal(report.replay, 'OUTPUT_ONLY');
  assert.equal(report.productionStoreMutation, false);
  exactKeys(report.environments, environmentKeys, 'environments');
  const envValues = environmentKeys.map((key) => report.environments[key]);
  for (const value of envValues) safeText(value, 'environment');
  assert.equal(new Set(envValues).size, environmentKeys.length, 'Provider/Buyer environments must be distinct');
  assert.ok(Array.isArray(report.steps) && report.steps.length === 17);
  assert.deepEqual(report.steps.map((step) => step.id), requiredSteps, 'disposable POV step order drift');
  for (const step of report.steps) {
    exactKeys(step, ['id', 'status'], `step ${step.id}`);
    assert.equal(step.status, 'PASS', `step ${step.id} did not pass`);
  }
  assert.ok(Array.isArray(report.publicReceipts) && report.publicReceipts.length === 14, 'required public child receipt count drift');
  for (const receipt of report.publicReceipts) safeText(receipt, 'public receipt');
  for (const required of ['PROVIDER_JOIN', 'PROVIDER_SETUP_AS_OFFER', 'BUYER_A_JOIN', 'BUYER_B_JOIN', 'BUYER_A_STOP_SUCCESS', 'IDENTICAL_RETRY', 'POST_STOP_REJECTED']) assert.ok(report.publicReceipts.includes(required), `missing public receipt: ${required}`);
  assert.deepEqual(report.internalReceipts, ['SIGNED_INTERACTIVE_START', 'SIGNED_CLEANUP']);
}
function load(file) {
  const stat = fs.lstatSync(file);
  if (!stat.isFile() || stat.isSymbolicLink()) throw new Error('execution report must be a regular file');
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}
function fixture() {
  const steps = requiredSteps.map((id) => ({ id, status: 'PASS' }));
  return { schemaVersion: 'punch.disposable-pov-report.v1', proofLabel: 'LOCAL_DETERMINISTIC_PASS', status: 'PASS', sanitized: true, timing: 'UTC+MONOTONIC', capturedInput: false, childOutput: 'SANITIZED_IN_MEMORY', environments: { provider: 'provider-env', buyerA: 'buyer-a-env', buyerB: 'buyer-b-env' }, steps, publicReceipts: ['PROVIDER_JOIN', 'PROVIDER_INVENTORY', 'PROVIDER_IDENTITY', 'PROVIDER_SETUP_AS_OFFER', 'PROVIDER_SERVE', 'BUYER_A_JOIN', 'BUYER_B_JOIN', 'BUYER_A_OFFERS', 'BUYER_A_ORDER', 'BUYER_A_STATUS', 'BUYER_A_SSH', 'BUYER_A_STOP_SUCCESS', 'IDENTICAL_RETRY', 'POST_STOP_REJECTED'], internalReceipts: ['SIGNED_INTERACTIVE_START', 'SIGNED_CLEANUP'], replay: 'OUTPUT_ONLY', productionStoreMutation: false };
}
function selfTest() {
  const valid = fixture();
  // The handoff requires 14 public receipts; this fixture retains the two
  // signed internal receipts separately and exercises the same boundary.
  validateReport(valid);
  for (const mutation of [
    (value) => { value.steps = value.steps.slice(0, -1); },
    (value) => { value.steps.find((step) => step.id === 'buyerA.stop').status = 'FAIL'; },
    (value) => { value.environments.buyerB = value.environments.buyerA; },
    (value) => { value.proofLabel = 'LIVE_E2E_PROVEN'; },
    (value) => { value.publicReceipts.pop(); },
    (value) => { value.publicReceipts[0] = 'STOP_FAILED'; },
    (value) => { value.publicReceipts[0] = 'Bearer' + ' synthetic'; },
    (value) => { value.environments.provider = '/' + 'Users/private'; }
  ]) {
    const value = structuredClone(valid); mutation(value); assert.throws(() => validateReport(value));
  }
  process.stdout.write('docs-smoke report validator and negative fixtures: PASS\n');
}

try {
  const args = process.argv.slice(2);
  if (args.includes('--self-test')) selfTest();
  else {
    const index = args.indexOf('--verify-execution-report');
    if (index === -1 || !args[index + 1]) throw new Error('--verify-execution-report REPORT.json is required');
    validateReport(load(path.resolve(args[index + 1])));
    process.stdout.write('sanitized docs-smoke execution report: LOCAL_DETERMINISTIC_PASS\n');
  }
} catch (error) {
  process.stderr.write(`docs-smoke report validation failed: ${error.message}\n`);
  process.exit(1);
}
