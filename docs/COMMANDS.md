# Command reference

> **Version boundary:** the clean-v4 Buyer stop, NetBird gateway, and supervised
> targeted-zero setup below apply to `v0.1.0-preview.11` when its non-draft prerelease archive
> and checksum are published.

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

Preview.11 Buyers do not pass a zero-price flag. An operator-approved
zero-price offer is already bound to its designated Buyer and appears only in
that Buyer's `offers` result. See [Targeted zero-price test](TARGETED_ZERO_TEST.md).

## Provider

The supported Preview.11 supervised path is:

| Command | Purpose |
| --- | --- |
| `join` | Redeem one Provider invitation and write the local credential |
| `inventory` | Inspect locally visible CPU, RAM, disk, and optional GPU resources |
| `identity-init` | Create the execution node's local signing identity |
| `setup` | Submit bounded capacity and the operator-issued designated-Buyer zero authorization |
| `offer-status` | Read one owned offer's lifecycle receipt |
| `offer-unlist` | Stop new orders for one owned unaccepted offer |
| `offer-retire` | Retire one eligible unlisted offer and environment |
| `serve` | Run the outbound resident agent |
| `status` | Read local agent status |
| `drain` | Stop accepting new work before maintenance |

Use `punch-provider <command> --help` from the installed release for exact
flags. The Provider cannot approve its own identity, authorize a free offer, or
publish an offer.

The supervised zero-price setup uses `--price-minor 0` together with both
`--targeted-zero-authorization-id` and `--targeted-buyer-actor-id`. Omitting
either binding or pairing them with a non-zero price fails closed. The Punch
operator supplies that single-use authorization.

For 2–8 GPUs, `setup` requires aligned comma-separated `--gpu-uuids` and
`--gpu-cdis`, plus `--gpu-communication SAME_NODE|P2P_REQUIRED`. Single-GPU
and CPU-only forms remain supported. See [Preview.5](PREVIEW5.md).

Provider setup creates the immutable offer request. There is no separate public
offer-publish command. Deterministic validation and operator approval must pass
before the offer becomes `LISTED`.

### Provider offer lifecycle

`offer-status`, `offer-unlist`, and `offer-retire` are included in the supervised Preview.11 release source. They are absent from published
`v0.1.0-preview.9` and must not be used until the matching Preview.11 archive
is published. They do not alter the Buyer command surface.

All three require `--machine-id`, `--state-dir`, `--agent-config`, and
`--offer-id`. `offer-unlist` and `offer-retire` also require a stable
`--idempotency-key`. The complete lifecycle and archive-release gate are in
[Provider offer lifecycle](OFFER_LIFECYCLE_PREVIEW.md).

## Output and idempotency

Use `--json` for automation where supported. Never parse human-formatted output
in an agent or script.

Preserve every setup and order reference until the operation reaches a known
terminal result. After a timeout, retry with the same reference. Do not create
a new reference merely because the first response was interrupted.

## Proof boundary

Preview.9 has one owner-operated Provider-to-Buyer NetBird SSH and Buyer-stop
proof. Preview.11 Buyer bootstrap remains gated until isolated Linux/x64
acceptance. Neither proves payment settlement, refunds, arbitrary external
Providers, multi-Provider scheduling, or general availability. The historical
generated pre-release reference in
[NEXT_COMMAND_REFERENCE.md](NEXT_COMMAND_REFERENCE.md) remains non-authoritative
for the current release; [PREVIEW11.md](PREVIEW11.md) governs Preview.11.
