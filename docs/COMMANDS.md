# Command reference

> **Version boundary:** this reference describes the `GATED_UNRELEASED`
> Preview.14 candidate. Exact flags become authoritative only when the generated
> reference is bound to the matching non-draft archive and `SHA256SUMS`.

Punch exposes two role-specific commands. The invitation and server-side
identity determine what a user may do; installing both commands does not grant
both roles. Secret-bearing paths must be absolute paths in private directories.

The isolated guided-CLI branch also adds a state-aware `punch` home without
changing either role command. Its release boundary and behavior are documented
in [Guided `punch` home](GUIDED_CLI.md).

## Buyer

```text
punch-buyer join|offers|order|status|output|ssh|stop \
  --config ABSOLUTE_PUBLIC_CONFIG [command flags]
```

| Command | Purpose | Important flags |
| --- | --- | --- |
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

Preview.14 Buyers do not pass a zero-price flag. An operator-approved
zero-price offer is already bound to its designated Buyer and appears only in
that Buyer's `offers` result. See [Targeted zero-price test](TARGETED_ZERO_TEST.md).

## Provider

The Preview.14 public Provider commands are:

| Command | Purpose |
| --- | --- |
| `identity-init` | Create the local signing identity and public onboarding packet before invitation issuance |
| `join` | Redeem the Provider invitation bound to that public packet and write the local credential |
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

Use `punch-provider <command> --help` from the installed release for exact
flags. The Provider cannot approve its own identity, authorize a free offer, or
publish an offer.

The normal direct setup form is:

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

`offer-status`, `offer-unlist`, and `offer-retire` are part of the Preview.14
candidate. They remain unavailable until the matching archive is published and
do not alter the Buyer command surface.

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
Buyer-stop proof. Preview.14 still requires exact-archive clean-host acceptance;
it does not prove payment settlement, refunds, arbitrary external Providers,
multi-Provider scheduling, or general availability. Its release-bound generated
reference is [PREVIEW14_COMMAND_REFERENCE.md](PREVIEW14_COMMAND_REFERENCE.md).
