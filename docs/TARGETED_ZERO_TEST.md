# Targeted zero-price test contract

## Status and release boundary

`TARGETED_ZERO_TEST` is released only for the supervised `v0.1.0-preview.9`
pilot with its matching runtime artifact and explicit owner authorization. It
is not a publicly claimable free offer, a general marketplace feature, or a
payment/settlement release.

Only the bootstrap owner administrator may enable this mode and issue its
authorizations. A source checkout, schema, documentation change, or CLI flag is
not authority.

## Provider authorization

An authenticated Provider may create this mode only with a server-issued,
single-use authorization ID and designated Buyer actor. The authorization binds
the exact Provider actor and machine, target Buyer, capacity, access window,
expiry, and immutable authorization digest. The Provider cannot issue or widen
the authorization or make an ordinary offer free by changing its price.

The authorization is checked and consumed during supervised Provider setup. A
withdrawn, expired, consumed, mismatched, or unverifiable authorization fails
closed. Once created, the immutable offer may serve the same designated Buyer
again after a completed cleanup and capacity release; the Provider cannot
retarget it or use the consumed setup authorization to create another offer.

## Buyer experience

Only the designated authenticated Buyer can discover and order the offer.
Every other Buyer, including a direct offer-ID probe, receives the same generic
not-found result. The target, expiry, unused state, immutable digest, and order
binding are rechecked during order creation.

The Buyer uses the normal commands: `offers`, `order`, readiness `status`,
brokered `ssh`, and `stop`. There is no Buyer zero-price or authorization flag.

## Replay and expiry

- The same Buyer, order reference, and payload replay the existing contract.
- A different Buyer, reference, payload, or authorization digest fails without
  a capacity or financial mutation.
- Expiry and withdrawal are fail-closed when racing with order creation.
- Capacity reservation is atomic; a one-capacity pilot machine can run at most
  one contract at a time.
- Exact Buyer-stop retry reconciles the same durable operation.

## Zero-value semantics

`TARGETED_ZERO_TEST` creates no payment authorization, tender, ledger money
line, token transaction, Sablier stream, payout instruction, refund, or payment
cancellation. Stop is lifecycle termination and cleanup, not a financial
settlement operation. Paid-offer economics are outside Preview.9.

## Established proof and remaining boundary

The matching clean-v4 runtime completed one owner-operated Provider-to-Buyer
canary with target-only discovery, exact order replay, pinned-container
provisioning, NetBird-backed brokered SSH, harmless GPU output, Buyer stop,
active-session closure, fresh-access denial, signed cleanup, and capacity
release. No real funds were used.

This proof is limited to one supervised Provider, one designated Buyer, one
RTX 5080, and one concurrent workload. It does not establish self-service
Provider onboarding, public free offers, payment/refund behavior,
multi-Provider scheduling, or general availability.

The Preview.9 reference schema is
`docs/schemas/targeted-zero-test-public.v2.json`. Its release values are
`punch.targeted-zero-test.v2`,
`TARGETED_ZERO_TEST`, `SUPERVISED_PREVIEW9_ONLY`, `TARGET_ONLY`,
`GENERIC_NOT_FOUND`, `NONE`, and
`ONE_OWNER_OPERATED_PROVIDER_BUYER_E2E_PASS`.
