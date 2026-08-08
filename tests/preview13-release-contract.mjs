import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const json = (path) => JSON.parse(readFileSync(new URL(`../${path}`, import.meta.url), "utf8"));
const text = (path) => readFileSync(new URL(`../${path}`, import.meta.url), "utf8");

test("Preview.13 binds the exact Provider serve fix and unchanged pilot boundary", () => {
  const contract = json("docs/preview13-runtime-contract.json");
  assert.equal(contract.schemaVersion, "punch.preview13-runtime-contract.v1");
  assert.equal(contract.releaseVersion, "0.1.0-preview.13");
  assert.deepEqual(contract.privateReleaseSource, {
    commit: "7af5f302db2076cfde14c69baf1e5d8b1d4017ab",
    tree: "b20ce13f3ad534d4766880feb11284a3e161a24e",
  });
  assert.equal(contract.platform, "linux-x64");
  assert.equal(contract.offerPolicy, "OWNER_TARGETED_ZERO_ONLY");
  assert.equal(contract.priceMinor, 0);
  assert.equal(contract.paymentSettlementEnabled, false);
  assert.equal(contract.selfServiceProviderOnboarding, false);
  assert.equal(contract.providerServePackaging.moduleFormat, "ESM_WITH_NODE_CREATE_REQUIRE_BRIDGE");
  assert.equal(contract.providerServePackaging.regressionProof, "BUNDLED_PROVIDER_RESIDENT_SERVE_PASS");
  assert.equal(contract.liveProof, "PENDING_EXACT_PREVIEW13_ARCHIVE_ACCEPTANCE");
});

test("Preview.13 documents the exact defect, compatibility, and release boundary", () => {
  const docs = text("docs/PREVIEW13.md");
  for (const required of [
    "Dynamic require of \"events\" is not supported", "createRequire", "Linux/x64",
    "Node.js 22.23.1", "owner-targeted `$0`", "Preview.12 must not be used",
    "identities", "credentials", "offers",
  ]) assert.match(docs, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "i"));
});
