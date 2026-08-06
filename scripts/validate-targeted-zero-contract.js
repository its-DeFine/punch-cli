#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const assert = require('assert');

const repo = path.resolve(__dirname, '..');
const schemaPath = path.join(repo, 'docs/schemas/targeted-zero-test-public.v2.json');
const markdownPath = path.join(repo, 'docs/TARGETED_ZERO_TEST.md');

const topKeys = [
  'schemaVersion', 'artifactKind', 'offerMode', 'releaseStatus',
  'runtimeMatchRequired', 'providerAuthorization', 'buyerVisibility',
  'directIdProbe', 'replay', 'expiry', 'consumption', 'moneyEffects',
  'sablier', 'liveProof'
];
const authorizationKeys = ['required', 'singleUse', 'issuer', 'binds'];
const expectedBinds = [
  'providerActor', 'providerMachine', 'targetBuyerActor', 'capacity',
  'window', 'expiry', 'authorizationDigest'
];
const expected = {
  schemaVersion: 'punch.targeted-zero-test.v2',
  artifactKind: 'public-reference-schema',
  offerMode: 'TARGETED_ZERO_TEST',
  releaseStatus: 'SUPERVISED_PREVIEW9_ONLY',
  runtimeMatchRequired: true,
  buyerVisibility: 'TARGET_ONLY',
  directIdProbe: 'GENERIC_NOT_FOUND',
  replay: 'SAME_BUYER_SAME_ORDER_REFERENCE_AND_PAYLOAD_ONLY',
  expiry: 'FAIL_CLOSED',
  consumption: 'SINGLE_USE_SETUP_AUTHORIZATION_REUSABLE_TARGETED_OFFER',
  moneyEffects: 'NONE',
  sablier: 'NONE',
  liveProof: 'ONE_OWNER_OPERATED_PROVIDER_BUYER_E2E_PASS'
};

function exactKeys(object, keys, label) {
  if (!object || typeof object !== 'object' || Array.isArray(object)) {
    throw new Error(`${label} must be an object`);
  }
  assert.deepStrictEqual(Object.keys(object).sort(), [...keys].sort(), `${label} keys drift`);
}

function validateSchema(value) {
  exactKeys(value, topKeys, 'schema');
  for (const key of Object.keys(expected)) {
    assert.strictEqual(value[key], expected[key], `${key} drift`);
  }
  exactKeys(value.providerAuthorization, authorizationKeys, 'providerAuthorization');
  assert.strictEqual(value.providerAuthorization.required, true, 'authorization required drift');
  assert.strictEqual(value.providerAuthorization.singleUse, true, 'authorization single-use drift');
  assert.strictEqual(value.providerAuthorization.issuer, 'BOOTSTRAP_OWNER_ADMIN_ONLY', 'authorization issuer drift');
  assert.deepStrictEqual(value.providerAuthorization.binds, expectedBinds, 'ordered authorization binds drift');
}

const requiredMarkdownClaims = [
  'released only for the supervised `v0.1.0-preview.9`',
  'matching runtime artifact and explicit owner authorization',
  'not a publicly claimable free offer',
  'Only the bootstrap owner administrator',
  'single-use authorization ID',
  'exact Provider actor and machine',
  'same generic\nnot-found result',
  'Capacity reservation is atomic',
  'creates no payment authorization, tender, ledger money',
  'Stop is lifecycle termination and cleanup',
  'ONE_OWNER_OPERATED_PROVIDER_BUYER_E2E_PASS',
  'No real funds were used',
  'does not establish self-service'
];
const contradictoryMarkdown = [
  /\b(?:payment|settlement)\s+(?:(?:is|was|has been)\s+)?settled\b/i,
  /\bSablier[-\s]+(?:stream[-\s]+)?created\b/i,
  /\bis a publicly claimable free offer\b/i,
  /\bself-service Provider onboarding is (?:released|enabled|available)\b/i
];

function validateMarkdown(markdown) {
  for (const claim of requiredMarkdownClaims) {
    if (!markdown.includes(claim)) throw new Error(`Markdown boundary claim missing: ${claim}`);
  }
  for (const pattern of contradictoryMarkdown) {
    if (pattern.test(markdown)) throw new Error(`Markdown overclaim: ${pattern}`);
  }
}

function loadAndValidate(schema = JSON.parse(fs.readFileSync(schemaPath, 'utf8')), markdown = fs.readFileSync(markdownPath, 'utf8')) {
  validateSchema(schema);
  validateMarkdown(markdown);
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function assertRejected(label, fn) {
  assert.throws(fn, undefined, `${label} unexpectedly passed`);
}

function runNegativeFixtures(schema, markdown) {
  for (const key of topKeys) {
    const fixture = clone(schema);
    delete fixture[key];
    assertRejected(`omit top-level ${key}`, () => validateSchema(fixture));
    const extra = clone(schema);
    extra[`extra_${key}`] = true;
    assertRejected(`extra top-level ${key}`, () => validateSchema(extra));
  }
  for (const key of authorizationKeys) {
    const fixture = clone(schema);
    delete fixture.providerAuthorization[key];
    assertRejected(`omit authorization ${key}`, () => validateSchema(fixture));
    const extra = clone(schema);
    extra.providerAuthorization[`extra_${key}`] = true;
    assertRejected(`extra authorization ${key}`, () => validateSchema(extra));
  }
  for (const key of ['required', 'singleUse']) {
    const fixture = clone(schema);
    fixture.providerAuthorization[key] = false;
    assertRejected(`mutate authorization ${key}`, () => validateSchema(fixture));
  }
  const wrongIssuer = clone(schema);
  wrongIssuer.providerAuthorization.issuer = 'ANY_ADMIN';
  assertRejected('mutate authorization issuer', () => validateSchema(wrongIssuer));
  for (const key of Object.keys(expected)) {
    const fixture = clone(schema);
    fixture[key] = typeof expected[key] === 'boolean' ? !expected[key] : `${expected[key]}_DRIFT`;
    assertRejected(`mutate ${key}`, () => validateSchema(fixture));
  }
  for (let index = 0; index < expectedBinds.length; index += 1) {
    const fixture = clone(schema);
    fixture.providerAuthorization.binds[index] = `${expectedBinds[index]}_DRIFT`;
    assertRejected(`mutate bind ${expectedBinds[index]}`, () => validateSchema(fixture));
  }
  const missingBind = clone(schema);
  missingBind.providerAuthorization.binds.pop();
  assertRejected('omit final authorization bind', () => validateSchema(missingBind));
  const overclaim = `${markdown}\nPayment is settled, a Sablier stream was created, and this is a publicly claimable free offer.\n`;
  assertRejected('Markdown release/payment/Sablier overclaim', () => validateMarkdown(overclaim));
}

try {
  loadAndValidate();
  if (process.argv.includes('--self-test')) {
    runNegativeFixtures(JSON.parse(fs.readFileSync(schemaPath, 'utf8')), fs.readFileSync(markdownPath, 'utf8'));
    process.stdout.write('targeted-zero structural validator and negative fixtures: PASS\n');
  } else {
    process.stdout.write('targeted-zero structural validator: PASS\n');
  }
} catch (error) {
  process.stderr.write(`targeted-zero structural validation failed: ${error.message}\n`);
  process.exit(1);
}
