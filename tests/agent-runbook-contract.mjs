import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const root = new URL("../", import.meta.url);
const text = (file) => readFileSync(new URL(file, root), "utf8");
const json = (file) => JSON.parse(text(file));

const runbook = text("docs/AGENT_RUNBOOK.md");
const contract = json("tests/fixtures/public-safe-contract.v1.json");

const requiredBuyer = ["join", "offers", "order", "status", "ssh", "stop"];
const requiredProvider = [
  "join", "inventory", "identity-init", "setup", "serve", "status", "drain",
  "offer-status", "offer-unlist", "offer-retire",
];

test("agent runbook uses only authoritative direct command names", () => {
  const buyerCommands = new Set(contract.publicCli.buyer.commands.map(({ name }) => name));
  const providerCommands = new Set(contract.publicCli.provider.commands.map(({ name }) => name));
  for (const command of requiredBuyer) {
    assert.equal(buyerCommands.has(command), true, `authoritative Buyer command missing: ${command}`);
    assert.equal(runbook.includes(`punch buyer ${command}`), true);
  }
  for (const command of requiredProvider) {
    assert.equal(providerCommands.has(command), true, `authoritative Provider command missing: ${command}`);
    assert.equal(runbook.includes(`punch provider ${command}`), true);
  }
  assert.doesNotMatch(runbook, /punch (?:buyer|provider) (?:approve|invite-create|admin|settle|refund)\b/);
});

test("agent runbook fixes approval, custody, idempotency, and state gates", () => {
  for (const required of [
    "APPROVAL_REQUIRED", "never read, print", "ORDER_REF", "same `ORDER_REF`",
    "ACTIVE", "accessEffective: true", "CLEANUP_COMPLETED", "RELEASED",
    "LISTED", "UNLISTED", "RETIRED", "signed lifecycle failure",
    "preserve the returned JSON `code`", "Human path: punch", "Autonomous path",
  ]) assert.match(runbook, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
});

test("agent runbook keeps prior network proof separate from candidate parity", () => {
  assert.match(runbook, /intentionally does\s+not repeat NetBird enrollment or SSH/);
  assert.match(runbook, /separate real NetBird\/SSH data-plane proof/);
  assert.match(runbook, /does not prove this candidate's\s+guided UI network path/);
});
