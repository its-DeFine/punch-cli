# Preview.18 command reference

> **Status: `PUBLISHED_PRERELEASE`.** The exact private runtime source,
> deterministic Control archive, public archive, `SHA256SUMS`, runtime-contract
> digest, and canonical packaged CLI surface are bound below. Install authority
> comes only from the matching non-draft GitHub prerelease after checksum
> verification.
> This static v1 binding covers the declared public command, flag, and workflow
> surface, not exhaustive mechanical semantic/output parity; exact-artifact E2E
> remains the release authority.

<!-- GENERATED PREVIEW18 COMMAND REFERENCE:BEGIN -->
<!-- contract-sha256: sha256:0f3d966a57d4a30b151470b7e208f25a206d07d781906753b4a7b67e5ac125cd -->
<!-- private-runtime-commit: 4e4aae1bb335092d69dc467a74651ad9527c4c17 -->
<!-- private-runtime-tree: a0fbb1491130d179b602c64e9b7fe170c7011de6 -->
<!-- control-archive-sha256: sha256:fcaa8d0c28d48f68bf940811457cfcd2ff594c9d14139dae33301749d6c0ae5a -->
<!-- release-archive-sha256: sha256:d144fd266328c022ef2601feb871ff62396a293d5e35e7130a3880cc0cdaf423 -->
<!-- sha256sums-sha256: sha256:094b1acb686b7daec071af97370be749b003579343e432c8c026dc80980d4da7 -->
<!-- runtime-contract-sha256: sha256:2d98a4ccdf3cc33936f7bc2f1b7856229f86fb12c9e473a4145c2e452593e94d -->
<!-- packaged-cli-surface-sha256: sha256:29f38b0fe4011ce91106ffff66c06b7710f2e24a77b78738e0d4abeb4529c50f -->
# Preview.18 generated command reference

> This reference is generated from the release-bound public command contract. It is not release authority without the matching published archive and `SHA256SUMS`.

## Provider

| Command | Purpose | Flags |
| --- | --- | --- |
| `punch-provider prepare-host` | Inspect the supported host and optionally apply only the exact reviewed dependency plan after explicit consent. | `--machine-id` (required), `--agent-config`, `--observed-at`, `--install-dependencies`, `--plan-digest`, `--yes`, `--json` |
| `punch-provider identity-init` | Create the machine-bound signing identity and public onboarding packet before invitation issuance. | `--state-dir` (required), `--machine-id` (required), `--json` |
| `punch-provider onboarding-request` | Submit the signed public-only Provider onboarding request after explicit identity consent. | `--machine-id` (required), `--state-dir` (required), `--punch-origin` (required), `--provider-label` (required), `--idempotency-key` (required), `--cpu-cores` (required), `--gpu-units` (required), `--vram-mib` (required), `--ram-mib` (required), `--disk-gib` (required), `--json` |
| `punch-provider onboarding-status` | Read the signed onboarding projection and preserve WAITING_FOR_INVITE or INVITE_READY across relaunch. | `--machine-id` (required), `--state-dir` (required), `--punch-origin` (required), `--request-ref` (required), `--json` |
| `punch-provider join` | Redeem the Provider invitation bound to the public identity packet and install the private credential reference. | `--invitation` (required), `--punch-origin` (required), `--credential-file` (required), `--json` |
| `punch-provider overview` | Read the authenticated Provider, onboarding, offer, contract, capacity, and service recovery projection. | `--machine-id` (required), `--state-dir` (required), `--punch-origin` (required), `--credential-file` (required), `--json` |
| `punch-provider doctor` | Inspect clean-host platform, dependencies, NetBird, images, and service readiness. | `--machine-id` (required), `--state-dir` (required), `--agent-config`, `--punch-origin`, `--credential-file`, `--json` |
| `punch-provider inventory` | Read locally observed CPU, GPU, memory, storage, OS, runtime, and capabilities. | `--observed-at`, `--json` |
| `punch-provider setup` | In one confirmed CLI session, install required dependencies, enroll NetBird, prove readiness, start the hardened service, and activate the authenticated offer. | `--machine-id` (required), `--state-dir` (required), `--punch-origin` (required), `--credential-file` (required), `--idempotency-key` (required), `--offer-id`, `--window-seconds`, `--price-minor`, `--targeted-zero-authorization-id`, `--targeted-buyer-actor-id`, `--cpu-cores`, `--gpu-units`, `--gpu-uuid`, `--gpu-cdi`, `--gpu-uuids`, `--gpu-cdis`, `--gpu-communication`, `--vram-mib`, `--ram-mib`, `--disk-gib`, `--install-dependencies`, `--yes`, `--activation-timeout-seconds`, `--agent-config`, `--json` |
| `punch-provider service-install` | Advanced recovery: install and enable the generated machine-scoped service. | `--machine-id` (required), `--state-dir` (required), `--yes`, `--json` |
| `punch-provider service-start` | Start the supervised Provider service. | `--machine-id` (required), `--yes`, `--json` |
| `punch-provider service-stop` | Stop the supervised Provider service without cancelling accepted contracts. | `--machine-id` (required), `--yes`, `--json` |
| `punch-provider service-status` | Read the machine-scoped supervised service state. | `--machine-id` (required), `--json` |
| `punch-provider service-logs` | Read a bounded sanitized service log tail. | `--machine-id` (required), `--lines`, `--json` |
| `punch-provider serve` | Run the Provider agent in foreground diagnostic mode. | `--machine-id` (required), `--state-dir` (required), `--agent-config` (required), `--interval-ms` |
| `punch-provider status` | Read local machine identity and service state. | `--state-dir` (required), `--machine-id` (required), `--json` |
| `punch-provider drain` | Set the local Provider service state to DRAINING. | `--state-dir` (required), `--json` |
| `punch-provider offer-list` | List every offer owned by this Provider machine with lifecycle state and bounded core characteristics. | `--machine-id` (required), `--state-dir` (required), `--agent-config` (required), `--json` |
| `punch-provider offer-status` | Read one owned clean-state offer receipt. | `--machine-id` (required), `--state-dir` (required), `--agent-config` (required), `--offer-id` (required), `--json` |
| `punch-provider offer-unlist` | Prevent new orders for one owned offer without altering accepted contracts. | `--machine-id` (required), `--state-dir` (required), `--agent-config` (required), `--offer-id` (required), `--idempotency-key` (required), `--json` |
| `punch-provider offer-retire` | Retire an eligible unlisted offer after terminal obligations and fenced access. | `--machine-id` (required), `--state-dir` (required), `--agent-config` (required), `--offer-id` (required), `--idempotency-key` (required), `--json` |
| `punch-provider offer-replace` | Create and activate one distinct successor for an eligible retired offer while preserving the predecessor and exact terms. | `--machine-id` (required), `--state-dir` (required), `--agent-config` (required), `--offer-id` (required), `--idempotency-key` (required), `--activation-timeout-seconds`, `--yes`, `--json` |

Workflow: `prepare-host` → `identity-init` → `onboarding-request` → `onboarding-status` → `join` → `overview` → `doctor` → `setup` → `service-status` → `offer-list` → `offer-status` → `offer-unlist` → `offer-retire` → `offer-replace`.

## Buyer

| Command | Purpose | Flags |
| --- | --- | --- |
| `punch-buyer doctor` | Inspect supported platform and Buyer NetBird dependency/connectivity state. | `--config` (required), `--json` |
| `punch-buyer join` | Resumably redeem one Buyer invitation, bootstrap narrow NetBird, and finish only after the exact peer binding is confirmed. | `--config` (required), `--invitation` (required), `--yes`, `--json` |
| `punch-buyer offers` | List supervised-Provider offers with their returned visibility and eligibility; ineligible offers cannot be ordered. | `--config` (required), `--json` |
| `punch-buyer order` | Create or reconcile one idempotent direct or conditional order for an eligible offer only. | `--config` (required), `--offer-id`, `--request-file`, `--order-ref` (required), `--ssh-public-key-file`, `--json` |
| `punch-buyer status` | Read lifecycle phase, state, access readiness, history, and safe failure projection. | `--config` (required), `--job-id` (required), `--json` |
| `punch-buyer output` | Download and digest-verify one completed task output. | `--config` (required), `--job-id` (required), `--task-id` (required), `--output` (required), `--json` |
| `punch-buyer ssh` | Carry contract-scoped SSH bytes for OpenSSH ProxyCommand. | `--config` (required), `--job` (required) |
| `punch-buyer stop` | Reconcile one Buyer-owned revocation-first stop through cleanup. | `--config` (required), `--job` (required), `--json` |

Workflow: `doctor` → `join` → `offers` → `order` → `status` → `ssh` → `stop`.

## Security boundary

- Linux/x64 only.
- Privileged dependency changes require explicit confirmation; direct non-interactive installation requires cached sudo.
- Provider onboarding appends distinct approved authority and cannot replace existing Provider or Buyer authority.
- Provider replacement is sequential: one nonterminal offer per machine.
- Guided Buyer ordering accepts only an eligible targeted canonical numeric +0 offer.
- Guided SSH preparation requires exact scoped egress consent, prints a copy-ready command, and never spawns SSH.
- OSC 52 clipboard delivery is explicit-consent-only and retains the visible fallback.
- Authorized access windows are capped at 259200 seconds.
- Payment settlement is disabled for this preview.

<!-- GENERATED PREVIEW18 COMMAND REFERENCE:END -->
