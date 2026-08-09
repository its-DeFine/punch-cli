#!/usr/bin/env node
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const format = JSON.parse(fs.readFileSync(path.join(repo, 'docs/schemas/preview14-public-command-contract-format.v1.json'), 'utf8'));
const marker = /<!-- GENERATED PREVIEW14 COMMAND REFERENCE:BEGIN -->[\s\S]*?<!-- GENERATED PREVIEW14 COMMAND REFERENCE:END -->/;
const formatKeys = ['schemaVersion', 'artifactKind', 'releaseStatus', 'runtimeMatchRequired', 'contractSchema', 'requiredTopLevelKeys', 'privateRuntimeBindingKeys', 'artifactKeys', 'commandKeys', 'flagKeys', 'workflowKeys', 'securityKeys', 'generationRule'];
const pendingArtifact = 'PENDING_DETERMINISTIC_BUILD';
const expectedPrivateRuntimeBinding = Object.freeze({
  commit: '830160e9b4209baa18745c948505c8d9731d9ccc',
  tree: '5c39f16be6f0d9ec9bd0add3c6fd33cf3360ed26',
  controlArchiveSha256: 'sha256:841d34705dea77a31a9090d87e835190b9db8b2d8edb880112148557b08001c3'
});

function exactKeys(value, keys, label) {
  assert.ok(value && typeof value === 'object' && !Array.isArray(value), `${label} must be an object`);
  assert.deepEqual(Object.keys(value).sort(), [...keys].sort(), `${label} keys drift`);
}

function digest(value, label) {
  assert.equal(typeof value, 'string', `${label} must be text`);
  assert.match(value, /^sha256:[0-9a-f]{64}$/, `${label} must be sha256`);
}

function sha256(value) {
  return `sha256:${crypto.createHash('sha256').update(value).digest('hex')}`;
}

function regular(file, label) {
  const stat = fs.lstatSync(file);
  assert.ok(stat.isFile() && !stat.isSymbolicLink(), `${label} must be a regular file`);
}

function sha256File(file, label) {
  regular(file, label);
  return sha256(fs.readFileSync(file));
}

function commandSurfaceDigest(contract) {
  return sha256(JSON.stringify({ commands: contract.commands, workflows: contract.workflows, security: contract.security }));
}

function commandById(contract, role, name) {
  const command = contract.commands.find((candidate) => candidate.role === role && candidate.name === name);
  assert.ok(command, `required public command is missing: ${role}:${name}`);
  return command;
}

function requireFlags(contract, role, name, expected) {
  const flags = new Set(commandById(contract, role, name).flags.map((flag) => flag.name));
  for (const flag of expected) assert.ok(flags.has(flag), `${role}:${name} is missing ${flag}`);
}

function validateStaticReleaseSurface(contract) {
  commandById(contract, 'buyer', 'doctor');
  requireFlags(contract, 'buyer', 'doctor', ['--config', '--json']);
  requireFlags(contract, 'provider', 'doctor', ['--agent-config']);
  requireFlags(contract, 'provider', 'inventory', ['--observed-at']);
  requireFlags(contract, 'provider', 'setup', [
    '--offer-id', '--window-seconds', '--price-minor',
    '--targeted-zero-authorization-id', '--targeted-buyer-actor-id'
  ]);
  assert.deepEqual(contract.workflows.provider,
    ['identity-init', 'join', 'doctor', 'setup', 'service-status', 'offer-status'],
    'Provider guided workflow drift');
  assert.deepEqual(contract.workflows.buyer,
    ['doctor', 'join', 'offers', 'order', 'status', 'ssh', 'stop'],
    'Buyer guided workflow drift');
}

function validateFormat() {
  exactKeys(format, formatKeys, 'Preview.14 command-contract format');
  assert.equal(format.schemaVersion, 'punch.preview14-public-command-contract-format.v1');
  assert.equal(format.artifactKind, 'public-format-description');
  assert.equal(format.releaseStatus, 'GATED_UNRELEASED');
  assert.equal(format.runtimeMatchRequired, true);
  assert.equal(format.contractSchema, 'punch.preview14-public-command-contract.v1');
  assert.deepEqual(format.requiredTopLevelKeys, ['schemaVersion', 'releaseVersion', 'releaseStatus', 'privateRuntimeBinding', 'artifact', 'commands', 'workflows', 'security']);
  assert.deepEqual(format.privateRuntimeBindingKeys, ['commit', 'tree', 'controlArchiveSha256']);
  assert.deepEqual(format.artifactKeys, ['archiveSha256', 'sha256SumsSha256', 'runtimeContractSha256', 'packagedCliSurfaceSha256']);
  assert.deepEqual(format.commandKeys, ['role', 'executable', 'name', 'purpose', 'flags']);
  assert.deepEqual(format.flagKeys, ['name', 'valueType', 'required', 'description']);
  assert.deepEqual(format.workflowKeys, ['provider', 'buyer']);
  assert.deepEqual(format.securityKeys, [
    'supportedPlatforms', 'privilegedInstallConfirmationRequired',
    'nonInteractivePrivilegedInstallRequiresCachedSudo',
    'multipleSupervisedProviders', 'maxAuthorizedWindowSeconds',
    'ineligibleOffersOrderable', 'paymentSettlementEnabled'
  ]);
}

function load(file) {
  regular(file, file);
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function validate(contract) {
  exactKeys(contract, format.requiredTopLevelKeys, 'Preview.14 command contract');
  assert.equal(contract.schemaVersion, 'punch.preview14-public-command-contract.v1');
  assert.equal(contract.releaseVersion, '0.1.0-preview.14');
  assert.equal(contract.releaseStatus, 'GATED_UNRELEASED');
  exactKeys(contract.privateRuntimeBinding, format.privateRuntimeBindingKeys, 'private runtime binding');
  assert.deepEqual(contract.privateRuntimeBinding, expectedPrivateRuntimeBinding, 'private runtime binding drift');
  exactKeys(contract.artifact, format.artifactKeys, 'artifact');
  for (const key of format.artifactKeys) digest(contract.artifact[key], `artifact.${key}`);
  assert.ok(Array.isArray(contract.commands) && contract.commands.length > 0, 'commands must not be empty');
  const commandIds = new Set();
  for (const command of contract.commands) {
    exactKeys(command, format.commandKeys, 'command');
    assert.ok(['provider', 'buyer'].includes(command.role), 'command role is invalid');
    assert.match(command.executable, /^punch(?:-buyer|-provider)?$/, 'command executable is invalid');
    assert.match(command.name, /^[a-z][a-z0-9-]*$/, 'command name is invalid');
    assert.equal(typeof command.purpose, 'string');
    assert.ok(command.purpose.length > 0, 'command purpose is empty');
    const id = `${command.role}:${command.name}`;
    assert.ok(!commandIds.has(id), `duplicate command: ${id}`);
    commandIds.add(id);
    assert.ok(Array.isArray(command.flags), 'command flags must be an array');
    const flags = new Set();
    for (const flag of command.flags) {
      exactKeys(flag, format.flagKeys, 'command flag');
      assert.match(flag.name, /^--[a-z][a-z0-9-]*$/, 'flag name is invalid');
      assert.ok(!flags.has(flag.name), `duplicate flag: ${flag.name}`);
      flags.add(flag.name);
      assert.ok(['string', 'integer', 'boolean', 'path', 'json'].includes(flag.valueType), 'flag value type is invalid');
      assert.equal(typeof flag.required, 'boolean');
      assert.equal(typeof flag.description, 'string');
    }
  }
  exactKeys(contract.workflows, format.workflowKeys, 'workflows');
  for (const role of format.workflowKeys) {
    assert.ok(Array.isArray(contract.workflows[role]) && contract.workflows[role].length > 0, `${role} workflow is empty`);
    for (const name of contract.workflows[role]) {
      assert.match(name, /^[a-z][a-z0-9-]*$/, `${role} workflow command is invalid`);
      assert.ok(commandIds.has(`${role}:${name}`), `${role} workflow names an undocumented command: ${name}`);
    }
  }
  validateStaticReleaseSurface(contract);
  exactKeys(contract.security, format.securityKeys, 'security');
  assert.deepEqual(contract.security.supportedPlatforms, ['linux-x64']);
  assert.equal(contract.security.privilegedInstallConfirmationRequired, true);
  assert.equal(contract.security.nonInteractivePrivilegedInstallRequiresCachedSudo, true);
  assert.equal(contract.security.multipleSupervisedProviders, true);
  assert.equal(contract.security.maxAuthorizedWindowSeconds, 259200);
  assert.equal(contract.security.ineligibleOffersOrderable, false);
  assert.equal(contract.security.paymentSettlementEnabled, false);
  assert.equal(contract.artifact.packagedCliSurfaceSha256, commandSurfaceDigest(contract), 'packaged CLI command surface digest mismatch');
}

function validateTemplate(template) {
  exactKeys(template?.artifact, format.artifactKeys, 'template artifact');
  for (const key of format.artifactKeys) {
    assert.equal(template.artifact[key], pendingArtifact, `template artifact.${key} must remain explicitly pending`);
  }
  const candidate = structuredClone(template);
  for (const key of format.artifactKeys) candidate.artifact[key] = sha256(`preview14-template-${key}`);
  candidate.artifact.packagedCliSurfaceSha256 = commandSurfaceDigest(candidate);
  validate(candidate);
}

function markdown(contract) {
  const lines = [
    '<!-- GENERATED PREVIEW14 COMMAND REFERENCE:BEGIN -->',
    `<!-- contract-sha256: sha256:${crypto.createHash('sha256').update(JSON.stringify(contract)).digest('hex')} -->`,
    `<!-- private-runtime-commit: ${contract.privateRuntimeBinding.commit} -->`,
    `<!-- private-runtime-tree: ${contract.privateRuntimeBinding.tree} -->`,
    `<!-- control-archive-sha256: ${contract.privateRuntimeBinding.controlArchiveSha256} -->`,
    `<!-- release-archive-sha256: ${contract.artifact.archiveSha256} -->`,
    `<!-- sha256sums-sha256: ${contract.artifact.sha256SumsSha256} -->`,
    `<!-- runtime-contract-sha256: ${contract.artifact.runtimeContractSha256} -->`,
    `<!-- packaged-cli-surface-sha256: ${contract.artifact.packagedCliSurfaceSha256} -->`,
    '# Preview.14 generated command reference',
    '',
    '> This reference is generated from the release-bound public command contract. It is not release authority without the matching published archive and `SHA256SUMS`.',
    ''
  ];
  for (const role of ['provider', 'buyer']) {
    lines.push(`## ${role === 'provider' ? 'Provider' : 'Buyer'}`, '', '| Command | Purpose | Flags |', '| --- | --- | --- |');
    for (const command of contract.commands.filter((candidate) => candidate.role === role)) {
      const flags = command.flags.map((flag) => `\`${flag.name}\`${flag.required ? ' (required)' : ''}`).join(', ') || '—';
      lines.push(`| \`${command.executable} ${command.name}\` | ${command.purpose} | ${flags} |`);
    }
    lines.push('', `Workflow: ${contract.workflows[role].map((name) => `\`${name}\``).join(' → ')}.`, '');
  }
  lines.push('## Security boundary', '', '- Linux/x64 only.', '- Privileged dependency changes require explicit confirmation; direct non-interactive installation requires cached sudo.', '- Multiple supervised Providers are supported; each order requires one eligible offer.', '- Authorized access windows are capped at 259200 seconds.', '- Payment settlement is disabled for this preview.', '', '<!-- GENERATED PREVIEW14 COMMAND REFERENCE:END -->');
  return `${lines.join('\n')}\n`;
}

function verifyBinding(contract, args) {
  for (const key of ['archive', 'sha256sums', 'runtime-contract']) {
    assert.equal(typeof args[key], 'string', `--${key} is required with --verify-binding`);
  }
  const archive = path.resolve(args.archive);
  const sums = path.resolve(args.sha256sums);
  const runtimeContract = path.resolve(args['runtime-contract']);
  assert.equal(sha256File(archive, 'archive'), contract.artifact.archiveSha256, 'archive digest mismatch');
  assert.equal(sha256File(sums, 'SHA256SUMS'), contract.artifact.sha256SumsSha256, 'SHA256SUMS digest mismatch');
  const archiveLine = `${contract.artifact.archiveSha256.slice('sha256:'.length)}  ${path.basename(archive)}`;
  assert.ok(fs.readFileSync(sums, 'utf8').split(/\r?\n/).includes(archiveLine), 'SHA256SUMS does not bind the archive');
  assert.equal(sha256File(runtimeContract, 'runtime contract'), contract.artifact.runtimeContractSha256, 'runtime contract digest mismatch');
  const runtime = load(runtimeContract);
  assert.equal(runtime.schemaVersion, 'punch.preview14-runtime-contract.v1', 'runtime contract schema mismatch');
  assert.equal(runtime.releaseVersion, contract.releaseVersion, 'runtime contract version mismatch');
  assert.equal(runtime.releaseStatus, contract.releaseStatus, 'runtime contract release status mismatch');
  exactKeys(runtime.privateReleaseSource, ['commit', 'tree'], 'runtime private release source');
  assert.equal(runtime.privateReleaseSource.commit, contract.privateRuntimeBinding.commit, 'runtime private release commit mismatch');
  assert.equal(runtime.privateReleaseSource.tree, contract.privateRuntimeBinding.tree, 'runtime private release tree mismatch');
  assert.equal(runtime.controlArchiveSha256, contract.privateRuntimeBinding.controlArchiveSha256, 'runtime Control archive binding mismatch');
  exactKeys(runtime.artifactBinding, ['authority', 'archiveSha256', 'sha256SumsSha256', 'packagedCliSurfaceSha256'], 'runtime artifact binding');
  assert.equal(runtime.artifactBinding.authority, 'AUTHORITATIVE_PACKAGED_CLI_SURFACE', 'runtime artifact authority mismatch');
  for (const key of ['archiveSha256', 'sha256SumsSha256', 'packagedCliSurfaceSha256']) {
    assert.equal(runtime.artifactBinding[key], contract.artifact[key], `runtime artifact binding ${key} mismatch`);
  }
}

function update(target, generated, write) {
  const stat = fs.lstatSync(target);
  assert.ok(stat.isFile() && !stat.isSymbolicLink(), 'reference target must be a regular file');
  const current = fs.readFileSync(target, 'utf8');
  assert.match(current, marker, 'reference target is missing generated markers');
  const next = current.replace(marker, generated.trimEnd());
  if (!write) {
    assert.equal(next, current, 'generated Preview.14 command reference is stale; rerun with --write');
    return;
  }
  const temporary = `${target}.tmp-${process.pid}`;
  fs.writeFileSync(temporary, next, { encoding: 'utf8', mode: 0o644, flag: 'wx' });
  fs.renameSync(temporary, target);
}

function fixture() {
  const candidate = structuredClone(load(path.join(repo, 'docs/preview14-public-command-contract.template.json')));
  for (const key of format.artifactKeys) candidate.artifact[key] = sha256(`preview14-fixture-${key}`);
  candidate.artifact.packagedCliSurfaceSha256 = commandSurfaceDigest(candidate);
  return candidate;
}

function selfTest() {
  const valid = fixture();
  valid.artifact.packagedCliSurfaceSha256 = commandSurfaceDigest(valid);
  validate(valid);
  const pending = structuredClone(valid);
  for (const key of format.artifactKeys) pending.artifact[key] = pendingArtifact;
  validateTemplate(pending);
  for (const mutate of [
    (contract) => { contract.commands[0].name = 'bad_name'; },
    (contract) => { contract.commands[0].flags.push(structuredClone(contract.commands[0].flags[0])); },
    (contract) => { contract.commands = contract.commands.filter(({ role, name }) => role !== 'buyer' || name !== 'doctor'); },
    (contract) => { commandById(contract, 'provider', 'doctor').flags = commandById(contract, 'provider', 'doctor').flags.filter(({ name }) => name !== '--agent-config'); },
    (contract) => { commandById(contract, 'provider', 'inventory').flags = commandById(contract, 'provider', 'inventory').flags.filter(({ name }) => name !== '--observed-at'); },
    (contract) => { commandById(contract, 'provider', 'setup').flags = commandById(contract, 'provider', 'setup').flags.filter(({ name }) => name !== '--offer-id'); },
    (contract) => { contract.workflows.provider = ['serve']; },
    (contract) => { contract.security.paymentSettlementEnabled = true; },
    (contract) => { contract.security.maxAuthorizedWindowSeconds = 259201; },
    (contract) => { contract.security.ineligibleOffersOrderable = true; },
    (contract) => { contract.privateRuntimeBinding.commit = '0000000000000000000000000000000000000000'; },
    (contract) => { contract.artifact.archiveSha256 = 'not-a-digest'; },
    (contract) => { contract.artifact.packagedCliSurfaceSha256 = sha256('wrong'); }
  ]) {
    const candidate = structuredClone(valid);
    mutate(candidate);
    assert.throws(() => validate(candidate));
  }
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'punch-preview14-reference-'));
  const contractPath = path.join(directory, 'contract.json');
  const target = path.join(directory, 'reference.md');
  fs.writeFileSync(contractPath, JSON.stringify(valid));
  fs.writeFileSync(target, '<!-- GENERATED PREVIEW14 COMMAND REFERENCE:BEGIN -->\nstale\n<!-- GENERATED PREVIEW14 COMMAND REFERENCE:END -->\n');
  update(target, markdown(load(contractPath)), true);
  update(target, markdown(load(contractPath)), false);
  const changed = structuredClone(valid);
  changed.commands[0].purpose = 'verify local prerequisites and image readiness';
  assert.throws(() => update(target, markdown(changed), false));
  const archive = path.join(directory, 'punch-cli-0.1.0-preview.14-linux-x64.tar.gz');
  const sums = path.join(directory, 'SHA256SUMS');
  const runtime = path.join(directory, 'preview14-runtime-contract.json');
  fs.writeFileSync(archive, 'fixture archive');
  const bound = fixture();
  bound.artifact.archiveSha256 = sha256File(archive, 'fixture archive');
  bound.artifact.packagedCliSurfaceSha256 = commandSurfaceDigest(bound);
  fs.writeFileSync(sums, `${bound.artifact.archiveSha256.slice('sha256:'.length)}  ${path.basename(archive)}\n`);
  bound.artifact.sha256SumsSha256 = sha256File(sums, 'fixture SHA256SUMS');
  fs.writeFileSync(runtime, JSON.stringify({
    schemaVersion: 'punch.preview14-runtime-contract.v1',
    releaseVersion: bound.releaseVersion,
    releaseStatus: bound.releaseStatus,
    privateReleaseSource: { commit: bound.privateRuntimeBinding.commit, tree: bound.privateRuntimeBinding.tree },
    controlArchiveSha256: bound.privateRuntimeBinding.controlArchiveSha256,
    platform: 'linux-x64',
    accessTransport: 'NETBIRD_CONTRACT_SCOPED_GATEWAY',
    offerPolicy: 'OWNER_TARGETED_ZERO_ONLY',
    priceMinor: 0,
    paymentSettlementEnabled: false,
    selfServiceProviderOnboarding: false,
    artifactBinding: { authority: 'AUTHORITATIVE_PACKAGED_CLI_SURFACE', archiveSha256: bound.artifact.archiveSha256, sha256SumsSha256: bound.artifact.sha256SumsSha256, packagedCliSurfaceSha256: bound.artifact.packagedCliSurfaceSha256 }
  }));
  bound.artifact.runtimeContractSha256 = sha256File(runtime, 'fixture runtime contract');
  validate(bound);
  verifyBinding(bound, { archive, sha256sums: sums, 'runtime-contract': runtime });
  fs.appendFileSync(archive, 'drift');
  assert.throws(() => verifyBinding(bound, { archive, sha256sums: sums, 'runtime-contract': runtime }));
  process.stdout.write('Preview.14 generated command-reference drift gate negative fixtures: PASS\n');
}

function parseArgs(args) {
  const parsed = { write: false, selfTest: false, verifyBinding: false };
  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (arg === '--self-test') parsed.selfTest = true;
    else if (arg === '--write') parsed.write = true;
    else if (arg === '--verify-binding') parsed.verifyBinding = true;
    else if (arg === '--contract' || arg === '--template' || arg === '--target' || arg === '--archive' || arg === '--sha256sums' || arg === '--runtime-contract') parsed[arg.slice(2)] = args[++index];
    else throw new Error(`unknown argument: ${arg}`);
  }
  return parsed;
}

try {
  validateFormat();
  const args = parseArgs(process.argv.slice(2));
  if (args.selfTest && !args.contract && !args.target && !args.write && !args.verifyBinding) {
    selfTest();
  } else if (!args.selfTest && args.template && !args.contract && !args.target && !args.write && !args.verifyBinding) {
    validateTemplate(load(path.resolve(args.template)));
    process.stdout.write('Preview.14 command-contract template: valid and artifact binding pending\n');
  } else if (!args.selfTest && args.contract && args.target) {
    const contract = load(path.resolve(args.contract));
    validate(contract);
    if (args.verifyBinding) verifyBinding(contract, args);
    else assert.ok(!args.archive && !args.sha256sums && !args['runtime-contract'], 'archive binding paths require --verify-binding');
    update(path.resolve(args.target), markdown(contract), args.write);
    process.stdout.write(`Preview.14 generated command reference: ${args.write ? 'updated' : 'current'}\n`);
  } else {
    throw new Error('usage: generate-preview14-command-reference.mjs --template TEMPLATE.json | --contract CONTRACT.json --target REFERENCE.md [--write] [--verify-binding --archive ARCHIVE --sha256sums SHA256SUMS --runtime-contract RUNTIME.json] | --self-test');
  }
} catch (error) {
  process.stderr.write(`Preview.14 command reference: FAIL: ${error.message}\n`);
  process.exit(1);
}
