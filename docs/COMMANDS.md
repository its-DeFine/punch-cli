# Command reference

> **Version boundary:** `rejoin`, `providerPayout`, and
> `--price-usdc-cents` below apply to the published `v0.1.0-preview.4`
> package.

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
| `order` | Create or replay an idempotent order | `--offer-id`, `--order-ref`, optional `--ssh-public-key-file`, `--json` |
| `status` | Read the current job state | `--job-id`, `--json` |
| `ssh` | Carry SSH bytes as OpenSSH's `ProxyCommand` | `--job` |
| `output` | Download and verify a completed task output | `--job-id`, `--task-id`, `--output`, `--json` |

Every Buyer command requires `--config`. See the complete workflow in [Buyer guide](BUYER.md).

## Provider

The supported public-preview path is:

| Command | Purpose |
| --- | --- |
| `join` | Redeem one Provider invitation and write the local credential |
| `rejoin` | Replace an expired pre-enrollment credential using one fresh Provider invitation |
| `inventory` | Inspect locally visible, allocatable CPU, RAM, disk, and optional GPU resources |
| `identity-init` | Create the execution node's local signing identity |
| `setup` | Submit bounded capacity, explicit whole-window USDC-cent pricing, and the configured payout binding for validation |
| `serve` | Run the outbound resident agent |
| `status` | Read local agent status |
| `drain` | Stop accepting new work before maintenance |

Use `punch-provider <command> --help` from the installed release for the exact flags supported by that version. The provider cannot approve its own identity or offer.

## Output formats

Use `--json` for automation where the command supports it. Treat fields not documented for a release as unstable. Never parse human-formatted output in an agent or script.

## Idempotency

Preserve every setup and order reference until the operation reaches a known terminal result. After a timeout, retry the same action with the same reference. If `PROVIDER_REJOIN_REQUIRED` is returned, obtain a fresh replacement invitation, run `rejoin`, and then retry the exact prior setup reference. Do not generate a new reference merely because the first response was interrupted.
