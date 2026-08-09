# Preview.16 command reference

> **Status: `PUBLISHED_PRERELEASE`.** The exact private runtime source,
> deterministic Control archive, public archive, `SHA256SUMS`, runtime-contract
> digest, and canonical packaged CLI surface are bound below. Install authority
> comes only from the matching non-draft GitHub prerelease after checksum
> verification.
> This static v1 binding covers the declared public command, flag, and workflow
> surface, not exhaustive mechanical semantic/output parity; exact-artifact E2E
> remains the release authority.

<!-- GENERATED PREVIEW16 COMMAND REFERENCE:BEGIN -->
<!-- contract-sha256: sha256:628b9b2cf0db08d0ec1229f8009905b563651fa83a227c4ec5032467a2df34c6 -->
<!-- private-runtime-commit: c0cabb6f18e7eba6c3c9910abe4e76ad814c05d2 -->
<!-- private-runtime-tree: 7d67f0967ac2cfab5b47a92716fe5bbda069d08e -->
<!-- control-archive-sha256: sha256:ba7d8c32ba2cdad2d7bdef32739ca4d8b2a1d03c26f0b5a4c946249d68f3b28b -->
<!-- release-archive-sha256: sha256:49d1dba584c52de7e0b75dc77a2b9572c3a31ef417575e8c80a5f6e16422da17 -->
<!-- sha256sums-sha256: sha256:83258b75849ac55f8a03637d66fd9b6b4f9548071185d65f3d90632ff8391617 -->
<!-- runtime-contract-sha256: sha256:d6a8ada6063a997a2bd510e1ccdc8898fe4ad61e52159d92e09dff7e05490318 -->
<!-- packaged-cli-surface-sha256: sha256:8d9de3adaf3e0753c87d12f9b1300fda60f74727e5638dfa93ed161ebee2db2a -->
# Preview.16 generated command reference

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
| `punch-provider offer-status` | Read one owned clean-state offer receipt. | `--machine-id` (required), `--state-dir` (required), `--agent-config` (required), `--offer-id` (required), `--json` |
| `punch-provider offer-unlist` | Prevent new orders for one owned offer without altering accepted contracts. | `--machine-id` (required), `--state-dir` (required), `--agent-config` (required), `--offer-id` (required), `--idempotency-key` (required), `--json` |
| `punch-provider offer-retire` | Retire an eligible unlisted offer after terminal obligations and fenced access. | `--machine-id` (required), `--state-dir` (required), `--agent-config` (required), `--offer-id` (required), `--idempotency-key` (required), `--json` |

Workflow: `prepare-host` → `identity-init` → `onboarding-request` → `onboarding-status` → `join` → `overview` → `doctor` → `setup` → `service-status` → `offer-status`.

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
- Multiple supervised Providers are supported; each order requires one eligible offer.
- Authorized access windows are capped at 259200 seconds.
- Payment settlement is disabled for this preview.

<!-- GENERATED PREVIEW16 COMMAND REFERENCE:END -->
