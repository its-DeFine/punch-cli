# Command reference

> **Version boundary:** this reference describes the Preview.15 Linux/x64
> candidate, currently `GATED_UNRELEASED`. Exact flags are release-bound in the
> pending [Preview.15 command reference](PREVIEW15_COMMAND_REFERENCE.md) and
> apply only after its matching archive and `SHA256SUMS` are published in a
> non-draft release. Preview.14 remains the current published release.

Punch exposes two role-specific commands. The invitation and server-side
identity determine what a user may do; installing both commands does not grant
both roles. Secret-bearing paths must be absolute paths in private directories.

Preview.15 adds a state-aware `punch` home without removing either role
command. Its release boundary and behavior are documented in
[Guided `punch` home](GUIDED_CLI.md).

## Buyer

```text
punch-buyer doctor|join|offers|order|status|output|ssh|stop \
  --config ABSOLUTE_PUBLIC_CONFIG [command flags]
```

| Command | Purpose | Important flags |
| --- | --- | --- |
| `doctor` | Inspect supported platform and Buyer NetBird dependency/connectivity state | `--json` |
| `join` | Redeem one Buyer invitation, bootstrap NetBird, and create a local session | `--invitation`, optional explicit install confirmation `--yes`, `--json` |
| `offers` | List capacity visible to this Buyer | `--json` |
| `order` | Create or replay an idempotent direct or conditional order | exactly one of `--offer-id` or `--request-file`, `--order-ref`, optional `--ssh-public-key-file`, `--json` |
| `status` | Read the current job state and access readiness | `--job-id`, `--json` |
| `ssh` | Carry SSH bytes as OpenSSH's `ProxyCommand` | `--job` |
| `stop` | Reconcile one idempotent Buyer-owned stop through cleanup | `--job`, optional `--json` |
| `output` | Download and verify a completed task output | `--job-id`, `--task-id`, `--output`, `--json` |

Every Buyer command requires `--config`. `ssh` ends only the local connection;
use `stop` to terminate the Punch lifecycle. Exact order and stop retries
reconcile the same contract or operation.

Preview.15 Buyers do not pass a zero-price flag. An operator-approved
zero-price offer is already bound to its designated Buyer and appears only in
that Buyer's `offers` result. See [Targeted zero-price test](TARGETED_ZERO_TEST.md).

## Provider

The Preview.15 public Provider commands are:

| Command | Purpose |
| --- | --- |
| `prepare-host` | Inspect the host and optionally apply only the exact consented dependency plan |
| `identity-init` | Create the local signing identity and public onboarding packet before invitation issuance |
| `onboarding-request` | Submit the signed public-only onboarding request with the selected capacity |
| `onboarding-status` | Read the durable onboarding projection, including `WAITING_FOR_INVITE` or `INVITE_READY` |
| `join` | Redeem the Provider invitation bound to that public packet and write the local credential |
| `overview` | Read Provider, onboarding, offer, contract, capacity, service, and recovery status |
| `doctor` | Report platform, dependency, NetBird, pinned-image, and supervised-service readiness |
| `inventory` | Inspect locally visible CPU, RAM, disk, and optional GPU resources |
| `setup` | Run the complete resumable Provider bootstrap and activate the authorized offer |
| `service-install` | Advanced recovery: install/enable the generated machine-scoped service |
| `service-start` / `service-stop` | Explicitly start or stop the supervised service |
| `service-status` / `service-logs` | Read supervised service state or bounded logs |
| `offer-status` | Read one owned offer's lifecycle receipt |
| `offer-unlist` | Stop new orders for one owned unaccepted offer |
| `offer-retire` | Retire one eligible unlisted offer and environment |
| `serve` | Run the outbound agent in foreground diagnostic mode |
| `status` | Read local agent status |
| `drain` | Stop accepting new work before maintenance |

The normal Provider path is `punch`, then **Provider**. Use
`punch-provider --help` and the release-bound
[Preview.15 Provider command reference](PREVIEW15_COMMAND_REFERENCE.md#provider)
only for advanced automation or recovery flags. The Provider cannot approve its
own identity, authorize a free offer, or publish an offer.

The advanced direct setup form is:

```text
punch-provider setup --machine-id ID --state-dir DIR --punch-origin ORIGIN
  --credential-file ABSOLUTE_JSON --idempotency-key KEY
  [capacity flags] [--install-dependencies] [--yes]
  [--activation-timeout-seconds N] [--json]
```

Setup obtains the Buyer, offer, owner-targeted `$0` authorization, price, and
access window from authenticated Control. Providers do not normally retype
those values. `--agent-config` and matching authorization fields are advanced
exact-match recovery/diagnostic overrides only; they cannot widen authority.
The public identity packet precedes invitation issuance; it contains no private
key. The maximum authorized window is `259200` seconds.

Before setup has generated `STATE_DIR/provider-agent.json`, `doctor` also needs
the approved `--punch-origin` and private `--credential-file`. After generation,
it reuses that canonical config.

For 2–8 GPUs, `setup` requires aligned comma-separated `--gpu-uuids` and
`--gpu-cdis`, plus `--gpu-communication SAME_NODE|P2P_REQUIRED`. Single-GPU
and CPU-only forms remain supported. See [Preview.5](PREVIEW5.md).

Provider setup has no separate public offer-publish command. It checks or,
after explicit consent, installs the reviewed dependencies; pulls immutable
images; runs the real local pre-list container/SSH/cleanup proof; creates the
non-discoverable `PENDING_AGENT` offer; consumes one machine/setup-bound
NetBird enrollment; writes the canonical private config; installs and starts
systemd; and activates `LISTED` only after a fresh signed heartbeat.
This is one guided/direct CLI session. Guided TTY use may prompt for `sudo`
after consent; direct non-interactive use requires explicit confirmation and
cached `sudo`. Normal onboarding does not require `serve` or manual config.

Punch supports multiple independently supervised Provider machines and offers.
Each order still reserves one eligible offer. An ineligible offer is not
orderable through either the guided or direct Buyer command.

### Provider offer lifecycle

`offer-status`, `offer-unlist`, and `offer-retire` were published in Preview.14
and remain in the Preview.15 candidate. The Preview.15 forms remain unavailable
until its matching archive is published and do not alter the Buyer command
surface.

All three require `--machine-id`, `--state-dir`, `--agent-config`, and
`--offer-id`. `offer-unlist` and `offer-retire` also require a stable
`--idempotency-key`. The complete lifecycle and archive-release gate are in
[Provider offer lifecycle](OFFER_LIFECYCLE_PREVIEW.md).

### Machine-readable results

- Provider `identity-init` returns the public onboarding packet before an
  invitation is issued. Provider `join` returns `joined` and `credentialFile`.
  `inventory` returns
  `schemaVersion`, `observedAt`, `source`, `cpu`, `gpus`, `memoryMiB`,
  `storage`, `os`, `runtime`, and `capabilities`. `identity-init` returns
  `machineId`, `credentialId`, `fingerprint`, and `publicKeyPem`.
- Provider `doctor` returns `schemaVersion`, `manifest`, `distribution`,
  `dependencyReady`, `bootstrapReady`, `imagesReady`, `serviceReady`, and
  `checks`.
- Provider `setup` returns `schemaVersion`, `state`, `machineId`, `offerId`,
  `setupRef`, `netbird`, `agentConfig`, `service`, and `activation`; success is
  accepted only as `punch.provider-setup.preview14.v1` with `state: "LISTED"`.
- Provider service actions return `schemaVersion`, `action`, `unit`, `state`,
  and bounded `output`. Offer status returns `schemaVersion`, `offerId`,
  `state`, `environmentId`, `environmentState`, and `capacityReserved`;
  mutations also return `operationId` and `replayed`.
- Buyer `join` returns `joined`, `replayed`, `sessionFile`, `expiresAt`, and
  `netBird: "CONNECTED"`; retries reconcile the same local join until the exact
  NetBird binding is confirmed. Buyer `output` returns `outputFile` and `bytes`.
  Buyer `stop` returns the durable operation identity/state plus the fields
  appropriate to its pending, success, or failure phase.
- Buyer `offers`, `order`, and `status` are authenticated Control projections,
  not a locally invented schema. The guided home renders only present safe
  fields and labels missing values as unavailable.

## Output and idempotency

Use `--json` for automation where supported. Never parse human-formatted output
in an agent or script.

Preserve every setup and order reference until the operation reaches a known
terminal result. After a timeout, retry with the same reference. Do not create
a new reference merely because the first response was interrupted.

## Proof boundary

Historical previews have owner-operated Provider-to-Buyer NetBird SSH and
Buyer-stop proof. Preview.15 still requires exact-archive clean-host acceptance;
it does not prove payment settlement, refunds, arbitrary external Providers,
multi-Provider scheduling, or general availability. Its release-bound generated
reference is [PREVIEW15_COMMAND_REFERENCE.md](PREVIEW15_COMMAND_REFERENCE.md).
