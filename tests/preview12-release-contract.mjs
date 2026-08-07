import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const json = (path) => JSON.parse(readFileSync(new URL(`../${path}`, import.meta.url), "utf8"));
const text = (path) => readFileSync(new URL(`../${path}`, import.meta.url), "utf8");

test("Preview.12 binds the exact guided source and unchanged pilot boundary", () => {
  const contract = json("docs/preview12-runtime-contract.json");
  assert.equal(contract.schemaVersion, "punch.preview12-runtime-contract.v1");
  assert.equal(contract.releaseVersion, "0.1.0-preview.12");
  assert.deepEqual(contract.privateReleaseSource, {
    commit: "67b8735939154375fd6da3a44d540631af55777d",
    tree: "ebac3e5a46d7005c8fd898d427b6f508326ab227",
  });
  assert.equal(contract.platform, "linux-x64");
  assert.equal(contract.offerPolicy, "OWNER_TARGETED_ZERO_ONLY");
  assert.equal(contract.priceMinor, 0);
  assert.equal(contract.paymentSettlementEnabled, false);
  assert.equal(contract.selfServiceProviderOnboarding, false);
  assert.deepEqual(contract.guidedCli.roles, ["BUYER", "PROVIDER"]);
  assert.equal(contract.guidedCli.directCommandsPreserved, true);
  assert.equal(contract.liveProof, "PENDING_EXACT_PREVIEW12_ARCHIVE_ACCEPTANCE");
});

test("Preview.12 documents human, autonomous, compatibility, and proof boundaries", () => {
  const docs = `${text("docs/PREVIEW12.md")}\n${text("docs/GUIDED_CLI.md")}\n${text("docs/AGENT_RUNBOOK.md")}`;
  for (const required of [
    "GATED_UNRELEASED", "continuous", "state-aware", "Buyer", "Provider",
    "APPROVAL_REQUIRED", "direct non-interactive command surface",
    "Payment settlement", "Linux/x64", "separate network seam",
  ]) assert.match(docs, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "i"));
});
