# Provider offer lifecycle preview

> **GATED_UNRELEASED Preview.10+ candidate:** `offer-status`, `offer-unlist`, and `offer-retire` are not in the published `v0.1.0-preview.9` archive.
> No source commit, private runtime proof, or Preview.10 documentation makes these commands installed or supported.

This candidate does not change the published Preview.9 Provider surface or any
Buyer command, order, access, stop, or cleanup behavior.

## Intended Provider-only contract

An authenticated owning Provider will use these commands with an exact offer
ID:

| Command | Intended result |
| --- | --- |
| `punch-provider offer-status` | Read the Provider-owned offer's lifecycle status. |
| `punch-provider offer-unlist --idempotency-key KEY` | Change a `LISTED` offer to `UNLISTED` only when it has no accepted obligation. |
| `punch-provider offer-retire --idempotency-key KEY` | Irreversibly retire an eligible `UNLISTED` offer and its environment. |

The planned JSON status receipt uses schema version
`punch.provider-offer-lifecycle.v1` and includes `offerId`, `environmentId`,
`state`, `environmentState`, and `capacityReserved`. Mutation receipts also
include a stable `operationId` and `replayed` flag. Ownership failure is
non-enumerating: it returns `NOT_FOUND` rather than revealing another
Provider's offer.

Use one stable idempotency key per mutation. Reusing it with different request content fails with `IDEMPOTENCY_CONFLICT`. The exact replay returns the original durable receipt.

## Safety rules

The future lifecycle is one way:

```text
LISTED -> UNLISTED -> RETIRED
```

Unlisting removes an offer from Buyer discovery and rejects new orders with the
existing non-enumerating not-found behavior. It is rejected without mutation if
a direct order, reservation, contract, Provider task, access authorization, or lifecycle operation is nonterminal. It never stops, revokes, fences, or cleans up an accepted contract.

Order acceptance and unlisting share an offer version fence. If they race, one
wins: either the order is accepted and unlisting is rejected as active, or
unlisting wins and the new order is rejected. A Provider cannot use unlisting
to invalidate an accepted Buyer contract.

Retirement is separate from unlisting. It requires `UNLISTED`, zero reserved
capacity, terminal direct lifecycle records, and fenced access. It retains auditable terminal offer and environment rows; it does not delete, relist, or recreate either record.

## Release gate

This candidate stays gated until all of the following bind to the same
Preview.10-or-later release:

1. A matching private runtime artifact implements the contract.
2. Focused integration proof covers Provider ownership/non-enumeration,
   idempotent replay, order-versus-unlist serialization, active-obligation
   rejection without mutation, and retirement only after terminal fenced
   dependencies and released capacity.
3. A release-bound public archive exposes the exact commands and passes the
   public documentation drift gate.

Until then, use only the commands in the installed release's `--help` output.
This page is a fail-closed candidate contract, not a Preview.9 or Preview.10
deployment or release claim.
