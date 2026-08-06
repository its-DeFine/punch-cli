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

test("Preview.9 public runtime contract is exact and zero-settlement", () => {
  assert.deepEqual(json("docs/preview9-runtime-contract.json"), {
    schemaVersion: "punch.preview9-runtime-contract.v1",
    releaseVersion: "0.1.0-preview.9",
    provenRuntimeCommit: "f1cad6a577926eae7f1487595b4193e66d5563ff",
    platform: "linux-x64",
    accessTransport: "NETBIRD_CONTRACT_SCOPED_GATEWAY",
    gatewayPort: 22222,
    offerPolicy: "OWNER_TARGETED_ZERO_ONLY",
    priceMinor: 0,
    paymentSettlementEnabled: false,
    selfServiceProviderOnboarding: false,
    liveProof: "ONE_OWNER_OPERATED_PROVIDER_BUYER_E2E_PASS",
    images,
  });
});

test("Provider templates select the clean task slice and overlay-only gateway", () => {
  const config = json("packaging/clean-v4/provider-agent.example.json");
  assert.equal(config.cleanStateProviderTaskSlice, true);
  assert.equal(config.normalizedProviderTaskSlice, undefined);
  assert.deepEqual(config.netBirdGateway, {
    enabled: true,
    interfaceName: "wt0",
    netBirdOverlayIp: "REPLACE_WITH_PROVIDER_NETBIRD_OVERLAY_IP",
    gatewayPort: 22222,
  });
  assert.equal(config.imagePolicies.VALIDATION.image, images.validation);
  assert.equal(config.imagePolicies.WORKLOAD.image, images.workload);
  assert.equal(config.imagePolicies.INTERACTIVE.approvedBaseImage, images.interactive);

  const service = text("packaging/clean-v4/punch-provider.service");
  assert.match(service, /^User=punch-provider$/m);
  assert.match(service, /^After=.*netbird\.service$/m);
  assert.match(service, /--agent-config \$\{PUNCH_AGENT_CONFIG\}/);
  assert.match(service, /^ReadWritePaths=\/var\/lib\/punch-provider$/m);
  assert.doesNotMatch(service, /\/bin\/(?:ba)?sh|-c /);
});

test("Targeted-zero v2 matches reusable designated-Buyer offer semantics", () => {
  const contract = json("docs/schemas/targeted-zero-test-public.v2.json");
  assert.equal(contract.releaseStatus, "SUPERVISED_PREVIEW9_ONLY");
  assert.equal(contract.providerAuthorization.singleUse, true);
  assert.equal(contract.buyerVisibility, "TARGET_ONLY");
  assert.equal(contract.consumption, "SINGLE_USE_SETUP_AUTHORIZATION_REUSABLE_TARGETED_OFFER");
  assert.equal(contract.moneyEffects, "NONE");
  assert.equal(contract.sablier, "NONE");
  assert.equal(json("docs/schemas/targeted-zero-test-public.v1.json").releaseStatus, "GATED_UNRELEASED");
});

test("Current docs expose stop and preserve pilot boundaries", () => {
  for (const required of ["punch-buyer stop", "netBirdGateway", "no payment settlement"]) {
    assert.match(`${text("docs/BUYER.md")}\n${text("docs/PREVIEW9.md")}`, new RegExp(required));
  }
  for (const forbidden of ["publicly available free offer", "payment settlement is enabled", "Provider receives the NetBird management token"]) {
    assert.doesNotMatch(`${text("docs/PREVIEW9.md")}\n${text("docs/PROVIDER.md")}`, new RegExp(forbidden, "i"));
  }
});
