#!/usr/bin/env node
import fs from 'node:fs';
import os from 'node:os';
import assert from 'node:assert/strict';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const contentPatterns = [
  /(?:^|[^A-Za-z0-9_])(?:\/Users\/|\/home\/|192\.168\.|100\.77\.)/,
  /BEGIN [A-Z ]*PRIVATE KEY/,
  /(?:ghp_|github_pat_|cloudflared\s+.*token|SUPABASE|DATABASE_URL|punch-compute)/i,
  /Authorization:\s*Bearer\s+/i,
  /(?:raw|unsanitized)\s+(?:command\s+)?transcript/i
];
const pathPattern = /(?:^|[\\/])(?:\.env(?:\.|$)|.*(?:credential|private[-_]?key|secret|transcript).*|id_(?:rsa|ed25519))$/i;
const ignored = new Set(['.git', 'node_modules']);
const scannerSelf = path.join('scripts', 'scan-public-material.mjs');

function walk(directory, files = []) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    if (ignored.has(entry.name)) continue;
    const file = path.join(directory, entry.name);
    if (entry.isSymbolicLink()) continue;
    if (entry.isDirectory()) walk(file, files);
    else if (entry.isFile()) files.push(file);
  }
  return files;
}
function fail(message) { throw new Error(message); }
function scan(directory) {
  for (const file of walk(directory).sort()) {
    const relative = path.relative(root, file);
    if (directory === root && relative === scannerSelf) continue;
    if (pathPattern.test(relative)) fail(`private or secret-like path: ./${relative}`);
    const text = fs.readFileSync(file, 'utf8');
    for (const pattern of contentPatterns) if (pattern.test(text)) fail(`private or raw-transcript material: ./${relative}`);
  }
}
function selfTest() {
  const fixture = fs.mkdtempSync(path.join(os.tmpdir(), 'punch-material-'));
  fs.writeFileSync(path.join(fixture, 'safe.txt'), 'safe\n');
  scan(fixture);
  fs.writeFileSync(path.join(fixture, 'private-key.txt'), 'safe\n');
  try { scan(fixture); assert.fail('private path fixture passed'); } catch (error) { if (error.message === 'private path fixture passed') throw error; }
  fs.unlinkSync(path.join(fixture, 'private-key.txt'));
  fs.writeFileSync(path.join(fixture, 'safe.txt'), 'raw' + ' transcript\n');
  try { scan(fixture); assert.fail('raw transcript fixture passed'); } catch (error) { if (error.message === 'raw transcript fixture passed') throw error; }
}
try {
  if (process.argv.includes('--self-test')) {
    selfTest();
    process.stdout.write('public material scanner and negative fixtures: PASS\n');
  } else {
    scan(root);
    process.stdout.write('public material scanner: PASS\n');
  }
} catch (error) {
  process.stderr.write(`public material scanner failed: ${error.message}\n`);
  process.exit(1);
}
