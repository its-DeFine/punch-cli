import assert from "node:assert/strict";
import { createHash } from "node:crypto";
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
    privateReleaseSource: {
      commit: "803305b295771e54186f5a2ea7a862b9ef04f6c4",
      tree: "847886f38766d5e2723ae376e54a4211390db6b7",
    },
    provenRuntimeCommit: "76041898382f764d3404ecb12112b684bafad1af",
    platform: "linux-x64",
    accessTransport: "NETBIRD_CONTRACT_SCOPED_GATEWAY",
    buyerNetBirdBootstrap: "PUNCH_JOIN_ONE_OFF_NARROW_GROUP",
    privilegedInstallConfirmationRequired: true,
    gatewayPort: 22222,
    offerPolicy: "OWNER_TARGETED_ZERO_ONLY",
    priceMinor: 0,
    paymentSettlementEnabled: false,
    selfServiceProviderOnboarding: false,
    providerOfferLifecycle: {
      schemaVersion: "punch.provider-offer-lifecycle.v1",
      commands: ["offer-status", "offer-unlist", "offer-retire"],
      focusedIntegrationProof: "DISPOSABLE_POSTGRES_PASS_1_OF_1",
      exactArchiveAcceptance: "PENDING",
    },
    liveProof: "PENDING_EXACT_ARCHIVE_ACCEPTANCE",
    images,
  });
  assert.match(text("docs/PREVIEW10.md"), /GATED_UNRELEASED/);
  assert.match(text("docs/PREVIEW10.md"), /one-off, ephemeral setup key/);
  assert.match(text("docs/PREVIEW10.md"), /does\s+not need a NetBird dashboard/);
  assert.match(text("docs/PREVIEW10.md"), /offer-unlist/);
  assert.match(text("docs/PREVIEW10.md"), /exact archive acceptance/);
});

test("Current Buyer docs require confirmation and keep setup-key values out of argv", () => {
  const docs = `${text("docs/BUYER.md")}\n${text("docs/INSTALL.md")}\n${text("docs/NETBIRD_PREVIEW.md")}`;
  for (const required of ["--yes", "mode-`0600`", "Linux/x64"]) {
    assert.match(docs, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
  }
  assert.match(docs, /startup\s+connectivity/);
  assert.doesNotMatch(docs, /--setup-key\s+[A-Za-z0-9_-]+/);
});

test("Preview.10 Provider offer lifecycle reference binds the approved release source", () => {
  const handoff = json("tests/fixtures/public-safe-contract.v1.json");
  const binding = handoff.buildBinding;
  const source = "private-release-source:803305b295771e54186f5a2ea7a862b9ef04f6c4:tree:847886f38766d5e2723ae376e54a4211390db6b7:runtime:76041898382f764d3404ecb12112b684bafad1af";
  assert.deepEqual(binding.sourceIdentity, { kind: "DECLARED", value: source });
  assert.equal(binding.providerEntrypointDigest, "3177704343e41e084e4a7f7da161a875458a32c0d6ba007babb338ba3647b4f7");
  assert.equal(binding.buyerEntrypointDigest, "8e7e5eb51e71bd76ac31886e0904290b615a96424d41120b156165fdb8d3d7fb");
  assert.equal(binding.artifactDigest, createHash("sha256").update([
    binding.sourceIdentity.kind,
    binding.sourceIdentity.value,
    binding.providerEntrypointDigest,
    binding.buyerEntrypointDigest,
  ].join("\0")).digest("hex"));
  const commands = handoff.publicCli.provider.commands.map(({ name, flags }) => [name, flags]);
  assert.deepEqual(commands.slice(-3), [
    ["offer-status", ["machine-id", "state-dir", "agent-config", "offer-id"]],
    ["offer-unlist", ["machine-id", "state-dir", "agent-config", "offer-id", "idempotency-key"]],
    ["offer-retire", ["machine-id", "state-dir", "agent-config", "offer-id", "idempotency-key"]],
  ]);
});
