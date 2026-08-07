#!/usr/bin/env node
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const formatVersion = 'punch.runtime-artifact-contract.v1';
const bindingVersion = 'punch.runtime-artifact-binding.v1';
const approvedHandoffContractDigest = '2cb71190ddf89454494b7b61460e05238b5a07e64957383b4db82a6fb2a3c572';

const topBindingKeys = [
  'schemaVersion', 'artifactKind', 'artifactId', 'contractPath', 'sourceRoot',
  'sourceFiles', 'entrypointPath', 'contractDigest', 'sourceDigest',
  'entrypointDigest', 'artifactDigest', 'execution', 'trustRegistryPath',
  'trustRegistryDigest', 'reviewReceiptDigest'
];
const executionKeys = ['interpreterPath', 'executionPath'];
const registryKeys = ['schemaVersion', 'artifactKind', 'releaseStatus', 'entries'];
const registryEntryKeys = [
  'artifactId', 'contractDigest', 'sourceDigest', 'entrypointDigest',
  'artifactDigest', 'interpreterPath', 'executionPath', 'trustState',
  'reviewStatus', 'reviewReceiptDigest'
];

function exactKeys(value, keys, label) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error(`${label} must be an object`);
  assert.deepEqual(Object.keys(value).sort(), [...keys].sort(), `${label} keys drift`);
}

function hashBytes(bytes) { return `sha256:${crypto.createHash('sha256').update(bytes).digest('hex')}`; }
function hashFile(file) { return hashBytes(fs.readFileSync(file)); }
function canonical(value) { return JSON.stringify(value); }
function digestWithout(value, key) {
  const copy = structuredClone(value);
  delete copy[key];
  return hashBytes(canonical(copy));
}
function readJson(file) {
  if (fs.lstatSync(file).isSymbolicLink()) throw new Error(`symlink input rejected: ${file}`);
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}
function regular(file) {
  const stat = fs.lstatSync(file);
  if (!stat.isFile() || stat.isSymbolicLink()) throw new Error(`non-regular input rejected: ${file}`);
  return stat;
}
function absolute(file, label) {
  if (!path.isAbsolute(file)) throw new Error(`${label} must be absolute`);
  return file;
}
function safeRelative(file) {
  return file && !path.isAbsolute(file) && !file.split(path.sep).some((part) => part === '' || part === '.' || part === '..' || part.startsWith('.'));
}
function git(root, args) { return execFileSync('git', ['-C', root, ...args], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }); }

function validateContract(contract) {
  exactKeys(contract, ['schemaVersion', 'artifactKind', 'contractDigest', 'sourceDigest', 'entrypointDigest', 'commands', 'lifecycle'], 'contract');
  assert.equal(contract.schemaVersion, formatVersion);
  assert.equal(contract.artifactKind, 'runtime-cli-contract');
  assert.match(contract.contractDigest, /^sha256:[0-9a-f]{64}$/);
  assert.match(contract.sourceDigest, /^sha256:[0-9a-f]{64}$/);
  assert.match(contract.entrypointDigest, /^sha256:[0-9a-f]{64}$/);
  assert.equal(contract.contractDigest, digestWithout(contract, 'contractDigest'), 'contract content digest drift');
  assert.ok(Array.isArray(contract.commands) && contract.commands.length > 0, 'contract commands missing');
  for (const command of contract.commands) {
    exactKeys(command, ['role', 'name', 'purpose', 'flags'], 'command');
    assert.ok(['provider', 'buyer'].includes(command.role));
    assert.match(command.name, /^[a-z][a-z0-9-]*$/);
    assert.equal(typeof command.purpose, 'string');
    assert.ok(Array.isArray(command.flags));
    for (const flag of command.flags) {
      exactKeys(flag, ['name', 'valueType', 'required', 'repeatable', 'description'], 'flag');
      assert.match(flag.name, /^--[a-z][a-z0-9-]*$/);
      assert.ok(['string', 'integer', 'boolean', 'path', 'json'].includes(flag.valueType));
      assert.equal(typeof flag.required, 'boolean');
      assert.equal(typeof flag.repeatable, 'boolean');
      assert.equal(typeof flag.description, 'string');
    }
  }
  exactKeys(contract.lifecycle, ['provider', 'buyer', 'cleanup'], 'lifecycle');
  for (const key of ['provider', 'buyer', 'cleanup']) {
    assert.ok(Array.isArray(contract.lifecycle[key]) && contract.lifecycle[key].length > 0, `${key} lifecycle missing`);
    for (const step of contract.lifecycle[key]) assert.equal(typeof step, 'string');
  }
}

function validateRegistry(registry, binding) {
  exactKeys(registry, registryKeys, 'trust registry');
  assert.equal(registry.schemaVersion, 'punch.public-artifact-trust-registry.v1');
  assert.equal(registry.artifactKind, 'artifact-trust-registry');
  assert.equal(registry.releaseStatus, 'GATED_UNRELEASED');
  assert.ok(Array.isArray(registry.entries));
  const entry = registry.entries.find((candidate) => candidate.artifactId === binding.artifactId);
  if (!entry) throw new Error('artifact is absent from trust registry');
  exactKeys(entry, registryEntryKeys, 'trust registry entry');
  assert.equal(entry.trustState, 'TRUSTED');
  assert.equal(entry.reviewStatus, 'MANAGER_APPROVED');
  assert.match(entry.reviewReceiptDigest, /^sha256:[0-9a-f]{64}$/);
  for (const key of ['contractDigest', 'sourceDigest', 'entrypointDigest', 'artifactDigest', 'reviewReceiptDigest']) {
    assert.equal(entry[key], binding[key], `trust registry ${key} mismatch`);
  }
  assert.equal(entry.interpreterPath, binding.execution.interpreterPath, 'trust registry interpreterPath mismatch');
  assert.equal(entry.executionPath, binding.execution.executionPath, 'trust registry executionPath mismatch');
  return entry;
}

const handoffContractKeys = ['schemaVersion', 'publicCli', 'claims', 'contractDigest', 'buildBinding'];
const handoffBindingKeys = ['schemaVersion', 'artifactKind', 'contractDigest', 'buildBinding', 'trustRegistryPath'];
const handoffBuildBindingKeys = ['schemaVersion', 'sourceIdentity', 'artifactDigest', 'providerEntrypointDigest', 'buyerEntrypointDigest', 'sbomDigest', 'contractDigest'];
const handoffRegistryKeys = ['schemaVersion', 'artifactKind', 'authorityStatus', 'releaseAuthority', 'proofLabel', 'entries'];
const handoffRegistryEntryKeys = ['sourceIdentity', 'artifactDigest', 'providerEntrypointDigest', 'buyerEntrypointDigest', 'sbomDigest', 'contractDigest', 'trustState'];
const handoffExpected = {
  provider: {
    booleanFlags: ['help', 'json'],
    flow: ['join', 'inventory', 'identity-init', 'setup', 'serve', 'status', 'drain'],
    commands: [
      ['join', ['invitation', 'punch-origin', 'credential-file'], 'join --invitation ABSOLUTE_JSON --punch-origin ORIGIN --credential-file ABSOLUTE_JSON'],
      ['inventory', ['observed-at'], 'inventory [--observed-at ISO_TIMESTAMP]'],
      ['identity-init', ['state-dir', 'machine-id'], 'identity-init --state-dir DIR --machine-id ID'],
      ['setup', ['machine-id', 'state-dir', 'agent-config', 'idempotency-key', 'cpu-cores', 'gpu-units', 'gpu-uuid', 'gpu-cdi', 'gpu-uuids', 'gpu-cdis', 'gpu-communication', 'vram-mib', 'ram-mib', 'disk-gib', 'window-seconds', 'price-minor', 'targeted-zero-authorization-id', 'targeted-buyer-actor-id'], 'setup --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --idempotency-key KEY --price-minor 0 --targeted-zero-authorization-id ID --targeted-buyer-actor-id ID'],
      ['serve', ['machine-id', 'state-dir', 'agent-config', 'interval-ms'], 'serve --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON [--interval-ms N]'],
      ['status', ['state-dir', 'machine-id'], 'status --state-dir DIR --machine-id ID'],
      ['drain', ['state-dir'], 'drain --state-dir DIR'],
      ['offer-status', ['machine-id', 'state-dir', 'agent-config', 'offer-id'], 'offer-status --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID'],
      ['offer-unlist', ['machine-id', 'state-dir', 'agent-config', 'offer-id', 'idempotency-key'], 'offer-unlist --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY'],
      ['offer-retire', ['machine-id', 'state-dir', 'agent-config', 'offer-id', 'idempotency-key'], 'offer-retire --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY']
    ]
  },
  buyer: {
    booleanFlags: ['help', 'json', 'yes', 'dry-run'],
    flow: ['join', 'offers', 'order', 'status', 'ssh', 'stop'],
    commands: [
      ['join', ['config', 'invitation', 'json'], 'join --invitation ABSOLUTE_JSON --config ABSOLUTE_PUBLIC_CONFIG'],
      ['offers', ['config', 'json'], 'offers --config ABSOLUTE_PUBLIC_CONFIG'],
      ['order', ['config', 'offer-id', 'request-file', 'order-ref', 'ssh-public-key-file', 'json'], 'order --offer-id ID|--request-file ABSOLUTE_JSON --order-ref REF --config ABSOLUTE_PUBLIC_CONFIG'],
      ['status', ['config', 'job-id', 'json'], 'status --job-id JOB_ID --config ABSOLUTE_PUBLIC_CONFIG'],
      ['output', ['config', 'job-id', 'task-id', 'output', 'json'], 'output --job-id JOB_ID --task-id TASK_ID --output ABSOLUTE_FILE --config ABSOLUTE_PUBLIC_CONFIG'],
      ['ssh', ['config', 'job'], 'ssh --job JOB_ID --config ABSOLUTE_PUBLIC_CONFIG'],
      ['stop', ['config', 'job', 'json'], 'stop --job JOB_ID --config ABSOLUTE_PUBLIC_CONFIG']
    ]
  }
};

function validateHandoffContract(contract) {
  exactKeys(contract, handoffContractKeys, 'public-safe contract');
  assert.equal(contract.schemaVersion, 'punch.public-safe-contract.v1');
  assert.match(contract.contractDigest, /^[0-9a-f]{64}$/);
  assert.equal(contract.contractDigest, approvedHandoffContractDigest, 'public-safe handoff contract digest is not manager-approved');
  exactKeys(contract.publicCli, ['schemaVersion', 'provider', 'buyer', 'proofBoundary'], 'public CLI contract');
  assert.equal(contract.publicCli.schemaVersion, 'punch.public-cli-contract.v1');
  for (const role of ['provider', 'buyer']) {
    const cli = contract.publicCli[role];
    exactKeys(cli, role === 'provider' ? ['executable', 'booleanFlags', 'commands', 'flow', 'setupCreatesOffer', 'publicOfferVerb'] : ['executable', 'booleanFlags', 'commands', 'flow', 'stopCommand'], `${role} CLI`);
    assert.equal(cli.executable, role === 'provider' ? 'punch-provider' : 'punch-buyer');
    assert.deepEqual(cli.booleanFlags, handoffExpected[role].booleanFlags, `${role} boolean flags drift`);
    assert.ok(Array.isArray(cli.commands) && cli.commands.length > 0);
    assert.deepEqual(cli.flow, handoffExpected[role].flow, `${role} flow drift`);
    assert.deepEqual(cli.commands.map((command) => [command.name, command.flags, command.synopsis]), handoffExpected[role].commands, `${role} command contract drift`);
    for (const command of cli.commands) {
      exactKeys(command, ['name', 'flags', 'synopsis'], `${role} command`);
      assert.match(command.name, /^[a-z][a-z0-9-]*$/);
      assert.ok(Array.isArray(command.flags));
      for (const flag of command.flags) assert.match(flag, /^[a-z][a-z0-9-]*$/);
      assert.equal(typeof command.synopsis, 'string');
    }
    assert.deepEqual(cli.flow, cli.commands.map((command) => command.name).filter((name) => cli.flow.includes(name)), `${role} flow contains unknown command`);
  }
  assert.equal(contract.publicCli.provider.setupCreatesOffer, true);
  assert.equal(contract.publicCli.provider.publicOfferVerb, null);
  assert.equal(contract.publicCli.buyer.stopCommand, 'stop');
  exactKeys(contract.publicCli.proofBoundary, ['localDeterministic', 'releasedArtifact', 'liveE2E'], 'proof boundary');
  assert.equal(contract.publicCli.proofBoundary.localDeterministic, 'LOCAL_DETERMINISTIC_PASS');
  exactKeys(contract.claims, ['setupCreatesImmutableOffer', 'publicOfferVerb', 'buyerStopCommand', 'noPrivateRoutesOrCredentials', 'proofBoundary'], 'public claims');
  assert.equal(contract.claims.setupCreatesImmutableOffer, true);
  assert.equal(contract.claims.publicOfferVerb, null);
  assert.equal(contract.claims.buyerStopCommand, 'stop');
  assert.equal(contract.claims.noPrivateRoutesOrCredentials, true);
  assert.deepEqual(contract.claims.proofBoundary, contract.publicCli.proofBoundary);
  exactKeys(contract.buildBinding, handoffBuildBindingKeys, 'build binding');
  assert.equal(contract.buildBinding.schemaVersion, 'punch.build-binding.v1');
  exactKeys(contract.buildBinding.sourceIdentity, ['kind', 'value'], 'source identity');
  assert.equal(contract.buildBinding.contractDigest, contract.contractDigest);
  assert.equal(contract.buildBinding.sourceIdentity.kind, 'DECLARED');
  for (const key of ['artifactDigest', 'providerEntrypointDigest', 'buyerEntrypointDigest', 'contractDigest']) assert.match(contract.buildBinding[key], /^[0-9a-f]{64}$/);
  assert.equal(contract.buildBinding.sbomDigest, null);
}

function validateHandoffFiles(contractPath, bindingPath, target, write) {
  const contract = readJson(contractPath);
  const binding = readJson(bindingPath);
  validateHandoffContract(contract);
  exactKeys(binding, handoffBindingKeys, 'public-safe binding');
  assert.equal(binding.schemaVersion, 'punch.public-safe-contract-binding.v1');
  assert.equal(binding.artifactKind, 'public-safe-contract-binding');
  assert.equal(binding.contractDigest, contract.contractDigest);
  assert.deepEqual(binding.buildBinding, contract.buildBinding);
  const registryPath = path.isAbsolute(binding.trustRegistryPath) ? binding.trustRegistryPath : path.resolve(repo, binding.trustRegistryPath);
  const registry = readJson(registryPath);
  exactKeys(registry, handoffRegistryKeys, 'handoff trust registry');
  assert.equal(registry.schemaVersion, 'punch.public-artifact-trust-registry.v1');
  assert.equal(registry.artifactKind, 'artifact-trust-registry');
  assert.equal(registry.authorityStatus, 'MANAGER_APPROVED_HANDOFF');
  assert.equal(registry.releaseAuthority, false);
  assert.equal(registry.proofLabel, 'LOCAL_DETERMINISTIC_PASS');
  assert.equal(registry.entries.length, 1);
  exactKeys(registry.entries[0], handoffRegistryEntryKeys, 'handoff trust entry');
  const expectedEntry = { ...contract.buildBinding };
  delete expectedEntry.schemaVersion;
  expectedEntry.trustState = 'HANDOFF_APPROVED';
  assert.deepEqual(registry.entries[0], expectedEntry);
  const files = [contractPath, bindingPath, registryPath].map((file) => ({ file, digest: hashFile(file) }));
  updateTarget(target, render(contract, { artifactId: contract.buildBinding.sourceIdentity.value, artifactDigest: contract.buildBinding.artifactDigest, contractDigest: contract.contractDigest, handoff: true }), write);
  assert.deepEqual(files, files.map(({ file, digest }) => ({ file, digest: hashFile(file) })), 'handoff input changed during generation');
}

function sourceDigest(root, files) {
  return hashBytes(files.map((file) => `${file}\0${hashFile(path.join(root, file))}\0`).join(''));
}
function snapshot(binding) {
  const files = [binding.contractPath, binding.entrypointPath, binding.trustRegistryPath, ...binding.sourceFiles.map((file) => path.join(binding.sourceRoot, file))];
  return files.map((file) => { const stat = regular(file); return { file, size: stat.size, mtimeMs: stat.mtimeMs, digest: hashFile(file) }; });
}
function assertStable(before, binding) {
  const after = snapshot(binding);
  assert.deepEqual(after, before, 'input changed during reference generation (TOCTOU)');
}

function validateBinding(binding, options = {}) {
  exactKeys(binding, topBindingKeys, 'binding');
  assert.equal(binding.schemaVersion, bindingVersion);
  assert.equal(binding.artifactKind, 'runtime-artifact-binding');
  absolute(binding.contractPath, 'contractPath');
  absolute(binding.sourceRoot, 'sourceRoot');
  absolute(binding.entrypointPath, 'entrypointPath');
  absolute(binding.trustRegistryPath, 'trustRegistryPath');
  for (const file of [binding.contractPath, binding.entrypointPath, binding.trustRegistryPath]) regular(file);
  assert.ok(Array.isArray(binding.sourceFiles) && binding.sourceFiles.length > 0);
  for (const file of binding.sourceFiles) {
    if (!safeRelative(file)) throw new Error(`hidden or ambiguous source path: ${file}`);
    regular(path.join(binding.sourceRoot, file));
    try { git(binding.sourceRoot, ['ls-files', '--error-unmatch', '--', file]); } catch { throw new Error(`source is not tracked: ${file}`); }
  }
  if (git(binding.sourceRoot, ['status', '--porcelain', '--untracked-files=all', '--', ...binding.sourceFiles]).trim()) throw new Error('dirty source rejected');
  exactKeys(binding.execution, executionKeys, 'execution');
  absolute(binding.execution.interpreterPath, 'interpreterPath');
  assert.equal(binding.execution.interpreterPath, options.interpreterPath || process.execPath, 'interpreter substitution rejected');
  assert.equal(binding.execution.executionPath, options.executionPath || process.env.PATH, 'PATH substitution rejected');
  const contract = readJson(binding.contractPath);
  validateContract(contract);
  assert.equal(binding.contractDigest, contract.contractDigest, 'contract binding mismatch');
  assert.equal(binding.sourceDigest, sourceDigest(binding.sourceRoot, binding.sourceFiles), 'source digest mismatch');
  assert.equal(binding.entrypointDigest, hashFile(binding.entrypointPath), 'entrypoint digest mismatch');
  assert.equal(binding.artifactDigest, hashBytes(`${binding.contractDigest}\0${binding.sourceDigest}\0${binding.entrypointDigest}`), 'artifact digest mismatch');
  const registry = readJson(binding.trustRegistryPath);
  validateRegistry(registry, binding);
  assert.equal(binding.trustRegistryDigest, hashFile(binding.trustRegistryPath), 'trust registry digest mismatch');
  assert.equal(binding.reviewReceiptDigest, registry.entries.find((entry) => entry.artifactId === binding.artifactId).reviewReceiptDigest);
  const before = snapshot(binding);
  if (options.betweenSnapshotAndRender) options.betweenSnapshotAndRender();
  assertStable(before, binding);
  return { contract, before };
}

function render(contract, binding) {
  if (contract.schemaVersion === 'punch.public-safe-contract.v1') {
    const publicContract = {
      schemaVersion: contract.publicCli.schemaVersion,
      contractDigest: contract.contractDigest,
      proofLabel: 'LOCAL_DETERMINISTIC_PASS',
      releaseStatus: 'GATED_UNRELEASED',
      authority: 'MANAGER_APPROVED_HANDOFF_ONLY',
      artifactId: binding.artifactId,
      artifactDigest: binding.artifactDigest,
      provider: contract.publicCli.provider,
      buyer: contract.publicCli.buyer
    };
    return `<!-- GENERATED CLI CONTRACT:BEGIN -->\n<!-- proof: LOCAL_DETERMINISTIC_PASS -->\n<!-- authority: MANAGER_APPROVED_HANDOFF_ONLY; release-authority: false -->\n<!-- contract-digest: ${contract.contractDigest} -->\n<!-- artifact-digest: ${binding.artifactDigest} -->\n${JSON.stringify(publicContract, null, 2)}\n<!-- GENERATED CLI CONTRACT:END -->`;
  }
  const publicContract = {
    schemaVersion: contract.schemaVersion,
    contractDigest: binding.contractDigest,
    artifactId: binding.artifactId,
    commands: contract.commands,
    lifecycle: contract.lifecycle
  };
  return `<!-- GENERATED CLI CONTRACT:BEGIN -->\n<!-- proof: RUNTIME_ARTIFACT_BOUND_PASS -->\n<!-- artifact: ${binding.artifactId} -->\n<!-- contract-digest: ${binding.contractDigest} -->\n${JSON.stringify(publicContract, null, 2)}\n<!-- GENERATED CLI CONTRACT:END -->`;
}

function updateTarget(target, generated, write) {
  regular(target);
  const text = fs.readFileSync(target, 'utf8');
  const marker = /<!-- GENERATED CLI CONTRACT:BEGIN -->[\s\S]*?<!-- GENERATED CLI CONTRACT:END -->/;
  if (!marker.test(text)) throw new Error('target is missing generated CLI contract markers');
  const updated = text.replace(marker, generated);
  if (write) {
    const temp = `${target}.tmp-${process.pid}`;
    fs.writeFileSync(temp, updated, { encoding: 'utf8', mode: 0o644, flag: 'wx' });
    fs.renameSync(temp, target);
  } else if (updated !== text) {
    throw new Error('generated command reference is stale; rerun with --write');
  }
}

function parseArgs(argv) {
  const args = { write: false, selfTest: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--write') args.write = true;
    else if (arg === '--self-test') args.selfTest = true;
    else if (['--contract', '--binding', '--target'].includes(arg)) args[arg.slice(2)] = argv[++i];
    else throw new Error(`unknown argument: ${arg}`);
  }
  return args;
}

function selfTest() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'punch-reference-'));
  const sourceRoot = path.join(root, 'source');
  fs.mkdirSync(path.join(sourceRoot, 'bin'), { recursive: true });
  execFileSync('git', ['init', '-q', sourceRoot]);
  execFileSync('git', ['-C', sourceRoot, 'config', 'user.email', 'fixture@example.invalid']);
  execFileSync('git', ['-C', sourceRoot, 'config', 'user.name', 'fixture']);
  const sourceFile = 'cli.js';
  const entrypoint = path.join(sourceRoot, 'bin/punch');
  fs.writeFileSync(path.join(sourceRoot, sourceFile), 'export const fixture = true;\n');
  fs.writeFileSync(entrypoint, '#!/usr/bin/env node\n');
  execFileSync('git', ['-C', sourceRoot, 'add', sourceFile, 'bin/punch']);
  execFileSync('git', ['-C', sourceRoot, 'commit', '-qm', 'fixture']);
  const contractPath = path.join(root, 'contract.json');
  const contract = {
    schemaVersion: formatVersion, artifactKind: 'runtime-cli-contract', contractDigest: '', sourceDigest: 'sha256:' + '0'.repeat(64), entrypointDigest: 'sha256:' + '0'.repeat(64),
    commands: [{ role: 'provider', name: 'setup', purpose: 'create the offer', flags: [{ name: '--json', valueType: 'boolean', required: false, repeatable: false, description: 'emit JSON' }] }, { role: 'buyer', name: 'stop', purpose: 'stop access', flags: [] }],
    lifecycle: { provider: ['install', 'setup-as-offer'], buyer: ['install', 'discover', 'order', 'status', 'stop'], cleanup: ['signed-cleanup', 'lease-release', 'relay-zero'] }
  };
  contract.contractDigest = digestWithout(contract, 'contractDigest');
  fs.writeFileSync(contractPath, JSON.stringify(contract, null, 2));
  const bindingBase = { schemaVersion: bindingVersion, artifactKind: 'runtime-artifact-binding', artifactId: 'fixture-runtime', contractPath, sourceRoot, sourceFiles: [sourceFile], entrypointPath: entrypoint, contractDigest: 'sha256:' + '1'.repeat(64), sourceDigest: sourceDigest(sourceRoot, [sourceFile]), entrypointDigest: hashFile(entrypoint), execution: { interpreterPath: process.execPath, executionPath: process.env.PATH } };
  bindingBase.artifactDigest = hashBytes(`${bindingBase.contractDigest}\0${bindingBase.sourceDigest}\0${bindingBase.entrypointDigest}`);
  const receipt = hashBytes('manager-approved-fixture-receipt');
  const registryPath = path.join(root, 'registry.json');
  const registry = { schemaVersion: 'punch.public-artifact-trust-registry.v1', artifactKind: 'artifact-trust-registry', releaseStatus: 'GATED_UNRELEASED', entries: [{ artifactId: bindingBase.artifactId, contractDigest: bindingBase.contractDigest, sourceDigest: bindingBase.sourceDigest, entrypointDigest: bindingBase.entrypointDigest, artifactDigest: bindingBase.artifactDigest, interpreterPath: process.execPath, executionPath: process.env.PATH, trustState: 'TRUSTED', reviewStatus: 'MANAGER_APPROVED', reviewReceiptDigest: receipt }] };
  fs.writeFileSync(registryPath, JSON.stringify(registry, null, 2));
  const binding = { ...bindingBase, trustRegistryPath: registryPath, trustRegistryDigest: hashFile(registryPath), reviewReceiptDigest: receipt };
  const bindingPath = path.join(root, 'binding.json'); fs.writeFileSync(bindingPath, JSON.stringify(binding, null, 2));
  const target = path.join(root, 'reference.md'); fs.writeFileSync(target, '<!-- GENERATED CLI CONTRACT:BEGIN -->\nold\n<!-- GENERATED CLI CONTRACT:END -->\n');
  const run = (overrides = {}, options = {}) => validateBinding({ ...binding, ...overrides }, { interpreterPath: process.execPath, executionPath: process.env.PATH, ...options });
  assert.throws(() => run(), /contract binding mismatch/);
  binding.contractDigest = contract.contractDigest; // repair the fixture's intentionally stale field
  binding.artifactDigest = hashBytes(`${binding.contractDigest}\0${binding.sourceDigest}\0${binding.entrypointDigest}`);
  registry.entries[0].contractDigest = binding.contractDigest;
  registry.entries[0].artifactDigest = binding.artifactDigest;
  fs.writeFileSync(registryPath, JSON.stringify(registry, null, 2));
  binding.trustRegistryDigest = hashFile(registryPath);
  run();
  const validated = validateBinding(binding, { interpreterPath: process.execPath, executionPath: process.env.PATH });
  updateTarget(target, render(validated.contract, binding), true); updateTarget(target, render(validated.contract, binding), false);
  const staleContract = structuredClone(contract); staleContract.commands[0].flags[0].name = '--stale'; fs.writeFileSync(contractPath, JSON.stringify(staleContract, null, 2));
  assert.throws(() => run(), /drift|mismatch/);
  fs.writeFileSync(contractPath, JSON.stringify(contract, null, 2));
  assert.throws(() => run({ ...binding, execution: { interpreterPath: '/wrong/node', executionPath: process.env.PATH } }), /interpreter substitution/);
  assert.throws(() => run({ ...binding, execution: { interpreterPath: process.execPath, executionPath: 'substituted' } }), /PATH substitution/);
  registry.entries[0].trustState = 'UNTRUSTED'; fs.writeFileSync(registryPath, JSON.stringify(registry, null, 2)); binding.trustRegistryDigest = hashFile(registryPath); assert.throws(() => run(), /TRUSTED/);
  registry.entries[0].trustState = 'TRUSTED'; registry.entries[0].reviewStatus = 'SELF_ASSERTED'; fs.writeFileSync(registryPath, JSON.stringify(registry, null, 2)); binding.trustRegistryDigest = hashFile(registryPath); assert.throws(() => run(), /MANAGER_APPROVED/);
  registry.entries[0].reviewStatus = 'MANAGER_APPROVED'; fs.writeFileSync(registryPath, JSON.stringify(registry, null, 2)); binding.trustRegistryDigest = hashFile(registryPath);
  fs.writeFileSync(path.join(sourceRoot, sourceFile), 'dirty\n'); assert.throws(() => run(), /dirty source|source digest mismatch/);
  execFileSync('git', ['-C', sourceRoot, 'checkout', '--', sourceFile]);
  assert.throws(() => run({}, { betweenSnapshotAndRender: () => fs.appendFileSync(path.join(sourceRoot, sourceFile), 'race\n') }), /TOCTOU/);
  process.stdout.write('command-reference structural and negative fixtures: PASS\n');
}

function selfTestHandoff() {
  const contractPath = path.join(repo, 'tests/fixtures/public-safe-contract.v1.json');
  const bindingPath = path.join(repo, 'tests/fixtures/public-safe-contract-binding.v1.json');
  const contract = readJson(contractPath);
  validateHandoffContract(contract);
  const stale = structuredClone(contract);
  stale.publicCli.buyer.commands.find((command) => command.name === 'stop').flags.push('stale-flag');
  assert.throws(() => validateHandoffContract(stale), /flow|flags|command/);
  const selfConsistentWrongDigest = structuredClone(contract);
  selfConsistentWrongDigest.contractDigest = 'f'.repeat(64);
  selfConsistentWrongDigest.buildBinding.contractDigest = selfConsistentWrongDigest.contractDigest;
  assert.throws(() => validateHandoffContract(selfConsistentWrongDigest), /manager-approved/);
  assert.throws(() => validateHandoffFiles(contractPath, bindingPath, path.join(os.tmpdir(), 'missing-target.md'), false), /target|artifact/);
  const target = path.join(os.tmpdir(), `punch-handoff-reference-${process.pid}.md`);
  fs.writeFileSync(target, '<!-- GENERATED CLI CONTRACT:BEGIN -->\nold\n<!-- GENERATED CLI CONTRACT:END -->\n');
  validateHandoffFiles(contractPath, bindingPath, target, true);
  validateHandoffFiles(contractPath, bindingPath, target, false);
  fs.unlinkSync(target);
  process.stdout.write('approved public-safe handoff binding: PASS\n');
}

try {
  const args = parseArgs(process.argv.slice(2));
  if (args.selfTest) { selfTest(); selfTestHandoff(); }
  else {
    if (!args.contract || !args.binding || !args.target) throw new Error('--contract, --binding, and --target are required');
    const binding = readJson(args.binding);
    if (binding.schemaVersion === 'punch.public-safe-contract-binding.v1') {
      validateHandoffFiles(args.contract, args.binding, args.target, args.write);
      process.stdout.write(`command reference ${args.write ? 'updated' : 'verified'}: LOCAL_DETERMINISTIC_PASS; release-authority=false\n`);
    } else {
      const validated = validateBinding(binding);
      updateTarget(args.target, render(validated.contract, binding), args.write);
      process.stdout.write(`command reference ${args.write ? 'updated' : 'verified'}: RUNTIME_ARTIFACT_BOUND_PASS\n`);
    }
  }
} catch (error) {
  process.stderr.write(`command-reference validation failed: ${error.message}\n`);
  process.exit(1);
}
