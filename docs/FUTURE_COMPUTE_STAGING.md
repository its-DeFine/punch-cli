# Future compute contracts — staging note

> **STAGING ONLY / UNRELEASED / FIXTURE-ONLY.** This page describes a future
> Punch staging feature. The currently published public binaries and current
> public preview commands do not support it. Use these commands only after
> receiving a version-matched staging build and stage endpoint whose release
> notes explicitly include this feature. This page is not a production or
> payment instruction.

This guide is a draft on branch `feat/future-contracts-staging-20260906`; branch
identity does not mean that the feature is deployed or available.

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
punch-buyer future-contract-rollover --future-contract-id ID --quote --config ABSOLUTE_PUBLIC_CONFIG [--json]
punch-buyer future-contract-rollover --future-contract-id ID --quote-digest SHA256 --config ABSOLUTE_PUBLIC_CONFIG [--json]
punch-buyer future-contract-recover --future-contract-id ID --config ABSOLUTE_PUBLIC_CONFIG [--json]
```

Recovery is bodyless; it takes only the owned future contract ID.

For rollover, inspect the quote's previous/new deadline, extension and fixture-only
zero price; then pass its exact `quoteDigest` to accept. `--quote` is an authenticated
read and does not require execution bootstrap. Acceptance retains that prerequisite.
A quote alone cannot mutate the contract; exact acceptance retries cannot grant
a second extension.

With an already-issued usable Buyer session, `offers`, `future-contracts`, and
`future-contract-show` do not require local NetBird bootstrap. They still use
the configured HTTPS endpoint and authenticated, Buyer-scoped Control routes.
Execution commands, including claim and SSH, retain their bootstrap checks.
This does not bypass account enrollment or grant access to a workload.

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
| `GET /api/v0/buyer/future-contracts/:id/rollover` | none | `200`, deadline/fixture-price quote and `quoteDigest` |
| `POST /api/v0/buyer/future-contracts/:id/rollover` | `accepted: true`, `quoteDigest` | `200`, updated status snapshot; exact accepted-quote replay is safe |
| `POST /api/v0/buyer/future-contracts/:id/recover` | `{}` | `202`, `punch.future-contract-recovery.v1`, `RECOVERY_ACCEPTED` or replay |

The acceptance binds the exact offer terms digest, contract reference, and
Buyer SSH public-key binding. Reusing a reference with changed input is an
idempotency conflict; identical retries return the original result. Future
reads and mutations are scoped to the authenticated Buyer.

### Provider active interruption (staging only)

The matched staging build exposes `PUT
/api/v0/provider/contracts/:id/interruption` to an authenticated Provider only
when future contracts are enabled. Its exact body is `generation` and a signed
`punch.provider-task-failure.v1` `failure` receipt. Remaining time, bonus, and
award fields are not Buyer-supplied. The receipt's signed `observedAt` must fall
inside the active access window and be no later than receipt time. Control
verifies the Provider signature and source task/machine/container binding,
fences gateway access, records `STOPPING`, and queues Provider STOP cleanup.
A successful report returns `202` with `STOPPING`, `stopTaskId`,
`interruptionAt`, and `remainingSeconds`.

Outage timing is Provider-attested, not independently metered. Delayed signed
reports preserve downtime recovery; they remain bound to the same Provider/Buyer
and enforced capacity. No commercial SLA measurement guarantee is claimed.

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

## Recovery status: source semantics implemented; active end-to-end proof pending

The matched staging build accepts `future-contract-recover` only for a committed
future claim whose source execution has a confirmed terminal Provider-caused
failure before usable access, with cleanup completed. The source reservation must
be released and no workload or access window may have started. A qualifying
request awards the accepted future compensation and creates one replacement full
contiguous execution; identical requests replay the same recovery result.

An active interruption follows a separate cleanup gate. After the signed
interruption is accepted, the source contract must reach `FAILED`, Buyer access
must be `FENCED`, and a terminal signed Provider STOP receipt must record cleanup
as completed before the reservation is released and recovery becomes eligible.
The normal STOP success receipt also carries gateway-close and container,
network, temporary-state, and workspace cleanup evidence. Recovery computes
`remainingSeconds` from the signed `interruptionAt` timestamp and adds the
explicit `FIXTURE_ONLY` bonus once at most. The replacement execution gets
`remainingSeconds + bonus`; it is not a second discretionary claim.

This does not resume the interrupted workload or restore a checkpoint, workload
state, input/output data, or lost progress. A stale or missing heartbeat,
buyer-visible SSH disconnect, natural access/runtime expiry, or Buyer stop is
not by itself a qualifying Provider interruption and receives no active-
interruption compensation. Non-Provider, retryable, unresolved, or incomplete-
cleanup outcomes are not eligible. The route and recovery path remain disabled
when the future-contract flag is absent or false, and this feature is staging-
only.

## SLA status: fixture path implemented; commercial policy pending

The staged schema currently permits `slaCompensation.mode: "FIXTURE_ONLY"`
with explicit fixture fields such as `additionalSeconds` and `maxAwards`. That
is validation/test surface, not an approved commercial SLA.

The active-interruption source path records the verified Provider interruption
and, after the cleanup gate, recovers signed remaining time plus one fixture-only
additional-time award at most once. This remains validation/test behavior, not
an approved commercial SLA. Core accounting, access-readiness, capacity,
replay, and incident reports are still pending; the formula, cap, delivery
method, expiry, and repeat-incident rules remain unresolved. No active-
interruption compensation is inferred from heartbeat loss, SSH disconnect,
natural expiry, or Buyer stop. Core reports and internal legal/product drafts
are required before any final approval or publication.

## Verification boundary

This page makes no claim that a stage Control is running, a public binary has
these commands, or external Buyer/NetBird transport or active full E2E has
passed. Controlled staging checks have proven `RESEARCH_EGRESS` public HTTPS+DNS
reachability while public port 80 and host port 443 are denied, and `NONE`
outbound denial with GPU. These are bounded network/runtime checks, not full
contract acceptance, active-interruption recovery, accounting, compensation,
checkpoint, or SLA proof. A matched staging release must provide its own
versioned evidence and limitations. No production or Provider-environment
procedure is described here.
