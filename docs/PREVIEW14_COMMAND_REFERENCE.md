# Preview.14 command reference

> **Status: `GATED_UNRELEASED`.** The reviewed command map is bound to private
> runtime commit `ff99837cfa9fd7ff0683335cd5dd917db3dad90a`, tree
> `e753ee79e69678e495c133fb503bddbe2d9544dc`, and deterministic Control archive
> `sha256:9853db9ad522df45f237519909166b195258b43fc9102049659c8f37c91288d6`.
> The deterministic public archive, `SHA256SUMS`, runtime-contract digest, and
> canonical packaged CLI surface are now bound below. Publication remains gated;
> these bytes are not installable until the matching non-draft prerelease exists.
> This static v1 binding covers the declared public command, flag, and workflow
> surface, not exhaustive mechanical semantic/output parity; exact-artifact E2E
> remains the release authority.

<!-- GENERATED PREVIEW14 COMMAND REFERENCE:BEGIN -->
<!-- contract-sha256: sha256:ff7989632a7610bb7635a8508967e7b52310c70964e7433dde95a34f36f596f7 -->
<!-- private-runtime-commit: ff99837cfa9fd7ff0683335cd5dd917db3dad90a -->
<!-- private-runtime-tree: e753ee79e69678e495c133fb503bddbe2d9544dc -->
<!-- control-archive-sha256: sha256:9853db9ad522df45f237519909166b195258b43fc9102049659c8f37c91288d6 -->
<!-- release-archive-sha256: sha256:bea2829770919a68ac3f0bf69f4a5d510875fca65efe742027a822b214d587ce -->
<!-- sha256sums-sha256: sha256:04c3800011fb5041fa81abc858a3493199b26135fcdee68d90603951f261fd11 -->
<!-- runtime-contract-sha256: sha256:99a294c6c2db751bb10e8d281604205f8fb78f35180d741a387d894bb961c0fc -->
<!-- packaged-cli-surface-sha256: sha256:d90f5d73e3838ff0ed391033dc71ecb751861243ad0d4806c3bdaa5d95b347b9 -->
# Preview.14 generated command reference

> This reference is generated from the release-bound public command contract. It is not release authority without the matching published archive and `SHA256SUMS`.

## Provider

| Command | Purpose | Flags |
| --- | --- | --- |
| `punch-provider identity-init` | Create the machine-bound signing identity and public onboarding packet before invitation issuance. | `--state-dir` (required), `--machine-id` (required), `--json` |
| `punch-provider join` | Redeem the Provider invitation bound to the public identity packet and install the private credential reference. | `--invitation` (required), `--punch-origin` (required), `--credential-file` (required), `--json` |
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

Workflow: `identity-init` → `join` → `doctor` → `setup` → `service-status` → `offer-status`.

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

<!-- GENERATED PREVIEW14 COMMAND REFERENCE:END -->
