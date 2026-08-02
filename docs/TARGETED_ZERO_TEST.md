# Targeted zero-price test contract

## Status and release boundary

`TARGETED_ZERO_TEST` is a gated, unreleased capability. The public repository
contains only this public-safe contract and its reference schema;
`docs/schemas/targeted-zero-test-public.v1.json` is not a matching private
runtime artifact and does not enable the capability. No public release, live
offer, payment, Sablier stream, or Buyer/Provider run is claimed.

The capability may be enabled only by an owner-controlled release carrying a
matching runtime artifact and explicit authorization. A source checkout,
candidate schema, test result, or documentation change must not be treated as
that authorization.

The public reference is deliberately protocol-level. It does not publish
private routes, actor identifiers, credentials, internal storage, or
implementation-specific CLI flags. The installed matching artifact's
`--help` and generated schema will be authoritative for exact command syntax.

## Provider experience

An authenticated Provider may create this mode only with a server-issued,
single-use authorization ID and the designated Buyer actor. The authorization
binds the exact Provider actor and machine, target Buyer, capacity/window
limits, expiry, and an immutable authorization digest. The Provider cannot
make an ordinary paid offer targeted or zero-priced by changing a price field.

The authorization is checked and consumed atomically with the first successful
order. A withdrawn, expired, already-consumed, mismatched, or unverifiable
authorization fails closed without creating or changing capacity. A consumed
zero-test offer never relists.

## Buyer experience

Only the designated authenticated Buyer can discover and order the offer.
Every other Buyer, including a direct probe using the offer ID, receives the
same generic not-found outcome. The target, expiry, unused state, immutable
digest, and order binding are rechecked during order creation.

The designated Buyer uses the normal interactive lifecycle: order, readiness,
brokered SSH, Buyer stop, cleanup, relay revocation, and lease release. Stop
ends access and requires cleanup; it is not a Sablier cancellation.

## Single-use and expiry rules

- The same Buyer with the same order reference and identical payload may
  replay the exact existing contract result.
- A different order reference, Buyer, payload, or authorization digest fails
  without capacity or payment mutation.
- Expiry and withdrawal are fail-closed, including when they race with order
  creation.
- Concurrent orders can consume at most one authorization.

## Zero-value semantics

`TARGETED_ZERO_TEST` creates no payment authorization, tender, ledger money
line, token transaction, Sablier stream, payout instruction, refund, or
cancellation. The lifecycle records explicit zero-test authorization and
termination audit states instead of synthetic money or settlement evidence.
Paid offers retain their positive-price, payment, accounting, and Sablier
invariants unchanged.

## Focused docs-following test plan

Before any owner considers enabling the capability, the matching runtime
artifact must prove, with deterministic tests, target-only visibility and
generic direct-ID rejection; exact replay; cross-Buyer rejection; expiry;
withdrawal-before-order; atomic single-use races; no relist; zero money
effects; normal provisioning, SSH, stop, relay-revocation, cleanup, and lease
release; plus unchanged paid behavior. The public docs gate checks only the
public contract/schema boundary. It does not substitute for those private
runtime tests or live journey proof.

The public release gate must fail closed if the reference schema, this
contract, or any later generated public artifact disagrees with the required
mode, status, one-use, target-only, expiry, replay, no-funds, no-Sablier, and
unreleased semantics.

The reference schema's release-gate values are `punch.targeted-zero-test.v1`,
`TARGETED_ZERO_TEST`, `GATED_UNRELEASED`, `TARGET_ONLY`,
`GENERIC_NOT_FOUND`, `NONE`, and `NOT_ESTABLISHED`.
