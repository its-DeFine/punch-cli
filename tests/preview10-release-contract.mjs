import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const json = (path) => JSON.parse(readFileSync(new URL(`../${path}`, import.meta.url), "utf8"));
const text = (path) => readFileSync(new URL(`../${path}`, import.meta.url), "utf8");

const images = {
  validation: "ghcr.io/its-define/punch-validation@sha256:d7de3c3549c2e36c1f5ef5237a671c7f06e44eb101c17be2faeca12a267adf86",
  workload: "ghcr.io/its-define/punch-workload@sha256:16fdfad931a97834bbe89c6a66724405e502535b9f8c35a971e91ed07b1242ce",
  interactive: "ghcr.io/its-define/punch-interactive@sha256:ba8c40d0e2610c43f306db04e3235442606bbec2fdcb3d37c745b23ecdaf9311",
};

test("Preview.10 public contract is exact, gated, and zero-settlement", () => {
  assert.deepEqual(json("docs/preview10-runtime-contract.json"), {
    schemaVersion: "punch.preview10-runtime-contract.v1",
    releaseVersion: "0.1.0-preview.10",
    provenRuntimeCommit: "99fe8c30863ec331228c5f3696ecdbecb99d7b5d",
    platform: "linux-x64",
    accessTransport: "NETBIRD_CONTRACT_SCOPED_GATEWAY",
    buyerNetBirdBootstrap: "PUNCH_JOIN_ONE_OFF_NARROW_GROUP",
    privilegedInstallConfirmationRequired: true,
    gatewayPort: 22222,
    offerPolicy: "OWNER_TARGETED_ZERO_ONLY",
    priceMinor: 0,
    paymentSettlementEnabled: false,
    selfServiceProviderOnboarding: false,
    liveProof: "PENDING_ISOLATED_LINUX_BUYER_ACCEPTANCE",
    images,
  });
  assert.match(text("docs/PREVIEW10.md"), /GATED_UNRELEASED/);
  assert.match(text("docs/PREVIEW10.md"), /one-off, ephemeral setup key/);
  assert.match(text("docs/PREVIEW10.md"), /does\s+not need a NetBird dashboard/);
});

test("Current Buyer docs require confirmation and keep setup-key values out of argv", () => {
  const docs = `${text("docs/BUYER.md")}\n${text("docs/INSTALL.md")}\n${text("docs/NETBIRD_PREVIEW.md")}`;
  for (const required of ["--yes", "mode-`0600`", "Linux/x64"]) {
    assert.match(docs, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
  }
  assert.match(docs, /startup\s+connectivity/);
  assert.doesNotMatch(docs, /--setup-key\s+[A-Za-z0-9_-]+/);
});
