# Future compute contracts — staging note

> **STAGING ONLY / UNRELEASED / FIXTURE-ONLY.** This page describes a future
> Punch staging feature. The currently published public binaries and current
> public preview commands do not support it. Use these commands only after
> receiving a version-matched staging build and stage endpoint whose release
> notes explicitly include this feature. This page is not a production or
> payment instruction.

This is a public-safe usage guide, not operative platform/provider/buyer terms,
legal advice, or a compliance certification. Those terms remain internal until
the responsible party completes product, privacy, and jurisdiction-specific
review.

## What the staged feature does

A Buyer can accept an eligible future-compute offer, hold one defined execution
for a later exercise window, and claim it through the existing Buyer → Control
→ Provider job path. Staging has no real billing, payment, automatic charge,
refund, or account credit; displayed prices and compensation values are test
fixtures only. Transfer and resale are not part of this first slice.

Each accepted future offer must expose a fixed duration, an exercise window,
the claim-to-access delivery timeout, capacity, resource snapshot, rollover
terms, and the exact terms digest. The initial claim policy is:

```text
mode: SINGLE_FULL_CONTIGUOUS
maxClaims: 1
```

One claim runs as one full contiguous execution. Splitting, pausing, partial
execution, and checkpoint-based continuation are not promised.

## Resource and internet terms

The offer response includes `capacity` and a resource snapshot. A future offer
requires at least one explicit GPU binding. Its frozen future-only `gpuBinding`
contains aggregate `gpuCount` and `vramMiB`, plus each bound GPU's `uuid`,
`cdiDevice`, `model`, and `memoryMiB`. The selected count and summed per-device
memory must match capacity; missing or mismatched model/memory is rejected.
Legacy spot terms remain UUID/CDI-only. The public presentation must show the
approved resource class without exposing provider credentials, private
addresses, or host-control details.

The snapshot's `networkPolicy.outbound` is explicit and has only these stage
values:

- `NONE` — the workload has no outbound internet.
- `RESEARCH_EGRESS` — the workload has restricted outbound access under the
  disclosed policy; this is not an unrestricted-internet promise.

The displayed value and policy revision/restrictions must be reviewed before
acceptance. Buyer authentication, SSH access, and data transfer are separate
from outbound egress. Outbound access does not grant public inbound ports,
provider-host or LAN access, other-tenant access, or network anonymity. A
missing/unknown value is incomplete, not implicitly internet-enabled. No
bandwidth, registry, model-host, or destination guarantee exists unless the
matched stage release states and verifies one.

## Buyer command guide (matched stage build only)

The commands below require an installed Buyer session and an absolute public
configuration file. `--json` is optional. Placeholders are examples, not
credentials or endpoint values. The future commands do not accept `--yes` or a
Buyer-supplied retry key.

```text
punch-buyer offers --config ABSOLUTE_PUBLIC_CONFIG [--json]
punch-buyer future-contracts --config ABSOLUTE_PUBLIC_CONFIG [--json]
punch-buyer future-contract-show --future-contract-id ID --config ABSOLUTE_PUBLIC_CONFIG [--json]
punch-buyer future-contract-accept --offer-id ID --contract-ref REF --terms-digest SHA256_DIGEST --ssh-public-key-file ABSOLUTE_FILE --config ABSOLUTE_PUBLIC_CONFIG [--json]
punch-buyer future-contract-claim --future-contract-id ID --config ABSOLUTE_PUBLIC_CONFIG [--json]
punch-buyer future-contract-rollover --future-contract-id ID --config ABSOLUTE_PUBLIC_CONFIG [--json]
punch-buyer future-contract-recover --future-contract-id ID --config ABSOLUTE_PUBLIC_CONFIG [--json]
```

Recovery is bodyless; it takes only the owned future contract ID.

After a claim returns an ordinary job identifier, use the matched build's
existing `status --job-id ID`, `ssh --job ID`, and `stop --job ID` commands.
Inspect status for access readiness before SSH. A pending claim has no ordinary
job yet; inspect the future-contract status and retry only the identical claim
request while it is being reconciled.

## Authenticated API shape (stage only)

The stage Control routes use the installed Buyer session as a Bearer credential.
Do not paste session values into documentation, tickets, or shells.

| Method and route | Request body | Response/status |
| --- | --- | --- |
| `GET /api/v0/buyer/offers` | none | Public offer objects, including staged resource and future-term fields when enabled |
| `GET /api/v0/buyer/future-contracts` | none | `200`, `punch.future-contract-list.v1` |
| `POST /api/v0/buyer/future-contracts` | `offerId`, `contractRef`, `termsDigest`, `accepted: true`, `buyerPublicKey`, `buyerPublicKeyFingerprint` | `201` first acceptance; `200` identical replay |
| `GET /api/v0/buyer/future-contracts/:id` | none | `200`, `punch.future-contract-status.v1` |
| `POST /api/v0/buyer/future-contracts/:id/claim` | `{}` | `202`, `punch.future-contract-claim.v1`, accepted or pending |
| `POST /api/v0/buyer/future-contracts/:id/rollover` | `{}` | `200`, updated status snapshot; identical replay is safe |
| `POST /api/v0/buyer/future-contracts/:id/recover` | `{}` | `202`, `punch.future-contract-recovery.v1`, `RECOVERY_ACCEPTED` or replay |

The acceptance binds the exact offer terms digest, contract reference, and
Buyer SSH public-key binding. Reusing a reference with changed input is an
idempotency conflict; identical retries return the original result. Future
reads and mutations are scoped to the authenticated Buyer.

## Three clocks

1. **Exercise window:** when the Buyer may submit the single claim.
2. **Delivery deadline:** claim acceptance until the disclosed claim-to-usable-
   access deadline; queued/provisioning is not verified access.
3. **Runtime:** the fixed contiguous duration after usable access is verified.

Expiry blocks a new claim but does not invalidate an accepted claim that is
still awaiting delivery under its agreed deadline. A matched stage release must
show these clocks separately; do not treat an exercise window as runtime.

## Rollover

Rollover is a new explicit Buyer action and is available only before activation
(the staged route rejects a future contract that already has a claim). It can
be applied at most once and extends the exercise window using the accepted
rollover schedule without duplicating entitlement. The staged fixture is
zero-price; fee, extension, capacity, and commercial policy are not approved
by this page.

## Recovery status: implementing, narrow eligibility

The matched staging build accepts `future-contract-recover` only for a committed
future claim whose source execution has a confirmed terminal Provider-caused
failure before usable access, with cleanup completed. The source reservation must
be released and no workload or access window may have started. A qualifying
request awards the accepted future compensation and creates one replacement full
contiguous execution; identical requests replay the same recovery result.

This is not active-job recovery. It does not resume a running workload, restore a
checkpoint, or promise recovery of checkpoint/lost progress. Buyer-stop,
access-expiry, non-Provider, retryable, unresolved, or incomplete-cleanup
outcomes are not eligible.

## SLA status: pending, not a promise

The staged schema currently permits `slaCompensation.mode: "FIXTURE_ONLY"`
with explicit fixture fields such as `additionalSeconds` and `maxAwards`. That
is validation/test surface, not an approved commercial SLA.

The intended product shape remains pending core accounting, access-readiness,
capacity, replay, and incident reports: when a confirmed Provider-caused SLA
breach occurs, unavailable time must not be consumed **and** additional free
compute must be awarded. The formula, cap, delivery method, expiry, and
repeat-incident rules remain unresolved. Core reports and internal legal/product
drafts are required before any final approval or publication.

## Verification boundary

This page makes no claim that a stage Control is running, a public binary has
these commands, a GPU or egress policy has been tested, or an end-to-end job,
restart, accounting, compensation, recovery, checkpoint, or SLA scenario has
passed. A matched staging release must provide its own versioned evidence and
limitations. No production or Provider-environment procedure is described here.
