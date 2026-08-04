# Command reference

> **Version boundary:** `withdraw`, `--all-gpus`, `rejoin`, `providerPayout`,
> `--price-usdc-cents`, and the atomic multi-GPU flags below apply to
> `v0.1.0-preview.8` when its
> non-draft prerelease archive and checksum are published.

Punch exposes two role-specific commands. The invitation and server-side identity determine what a user may do; installing both commands does not grant both roles.

All paths containing invitations, sessions, credentials, identities, or configuration must be absolute paths in private directories.

## Buyer

```text
punch-buyer join|offers|order|status|output|ssh \
  --config ABSOLUTE_PUBLIC_CONFIG [command flags]
```

| Command | Purpose | Important flags |
| --- | --- | --- |
| `join` | Redeem one Buyer invitation and create a local session | `--invitation`, `--json` |
| `offers` | List capacity currently available to this Buyer | `--json` |
| `order` | Create or replay an idempotent direct or conditional order | exactly one of `--offer-id` or `--request-file`, `--order-ref`, optional `--ssh-public-key-file`, `--json` |
| `status` | Read the current job state | `--job-id`, `--json` |
| `ssh` | Carry SSH bytes as OpenSSH's `ProxyCommand` | `--job` |
| `output` | Download and verify a completed task output | `--job-id`, `--task-id`, `--output`, `--json` |

Every Buyer command requires `--config`. See the complete workflow in [Buyer guide](BUYER.md).

There is no Buyer `stop` or `cancel` command in this public command contract.
`ssh` is only OpenSSH `ProxyCommand` transport with `--config` and `--job`;
closing the OpenSSH client ends that client connection, not the Punch job
lifecycle. Do not infer an early-termination API from a private canary or from
an SSH disconnect.

`TARGETED_ZERO_TEST` is not a released Buyer or Provider command. See the
[targeted zero-price test contract](TARGETED_ZERO_TEST.md). Do not invent a
zero-price flag or treat the public reference schema as an enabled runtime.

The next gated setup-as-offer and Buyer-stop reference is maintained in
[NEXT_COMMAND_REFERENCE.md](NEXT_COMMAND_REFERENCE.md); it does not change the
current released command surface above.

The approved asynchronous stop behavior for that next gated reference is
defined in [the public-safe stop contract](PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md).

## Provider

The supported public-preview path is:

| Command | Purpose |
| --- | --- |
| `join` | Redeem one Provider invitation and write the local credential |
| `rejoin` | Replace an expired pre-enrollment credential using one fresh Provider invitation |
| `inventory` | Inspect locally visible, allocatable CPU, RAM, disk, and optional GPU resources |
| `identity-init` | Create the execution node's local signing identity |
| `setup` | Submit bounded capacity, explicit whole-window USDC-cent pricing, and the configured payout binding for validation |
| `withdraw` | Pause one owned, unreserved listed offer without deleting its audit history or re-registering the Provider |
| `serve` | Run the outbound resident agent |
| `status` | Read local agent status |
| `drain` | Stop accepting new work before maintenance |

Use `punch-provider <command> --help` from the installed release for the exact flags supported by that version. The provider cannot approve its own identity or offer.

For 2–8 GPUs, `setup` requires aligned comma-separated `--gpu-uuids` and
`--gpu-cdis`, plus `--gpu-communication SAME_NODE|P2P_REQUIRED`. Single-GPU
and CPU-only forms remain supported. See the [Preview.5 contract](PREVIEW5.md).

For a dedicated whole-node offer, `--all-gpus` derives the complete locally
visible UUID/CDI set, GPU count, and aggregate VRAM. It defaults a multi-GPU
bundle to `SAME_NODE`; specify `--gpu-communication P2P_REQUIRED` only when the
workload requires proven peer access. The shortcut is explicit so a shared host
does not advertise devices merely because they are visible.

Normal renewal, setup rollover, serving, draining, and withdrawal reuse the
same Provider and machine identities. A new immutable offer uses a fresh setup
reference, not a new invitation or re-registration. `withdraw` needs the offer
ID and a stable idempotency key. `--offer-digest` is optional: when omitted,
Control transactionally binds the current immutable digest; when supplied, it
also enforces a strict stale-version check.

## Output formats

Use `--json` for automation where the command supports it. Treat fields not documented for a release as unstable. Never parse human-formatted output in an agent or script.

## Idempotency

Preserve every setup, withdrawal, and order reference until the operation reaches a known terminal result. After a timeout, retry the same action with the same reference. If `PROVIDER_REJOIN_REQUIRED` is returned, obtain a fresh replacement invitation, run `rejoin`, and then retry the exact prior setup reference. Do not generate a new reference merely because the first response was interrupted.

## Current proof boundary

The documented Buyer commands and schemas do not prove a released archive, an
external Provider/Buyer lifecycle, or a testnet/real-USDC settlement. In
particular, an exact-runtime/private canary that exercises access or terminal
cleanup is not a released public `punch-buyer` workflow. Treat `USDC`, price,
and payout fields as protocol terms unless a release-specific settlement proof
and authorization say otherwise.
