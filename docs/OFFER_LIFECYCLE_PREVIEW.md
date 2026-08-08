# Provider offer lifecycle preview

> **Preview.14 release source — gated and not published:** `offer-status`,
> `offer-unlist`, and `offer-retire` are included in the supervised Preview.14
> runtime source and reviewed Preview.14 command map. They are not in the published `v0.1.0-preview.9` archive
> and are not installed or supported until
> the matching non-draft Preview.14 archive and `SHA256SUMS` are published.

This Preview.14 release source does not change the published Preview.9 Provider
surface or any Buyer command, order, access, stop, or cleanup behavior.

## Provider-only contract

An authenticated owning Provider will use these commands with an exact offer
ID:

| Command | Intended result |
| --- | --- |
| `punch-provider offer-status --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID` | Read the Provider-owned offer's lifecycle status. |
| `punch-provider offer-unlist --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY` | Change a `LISTED` offer to `UNLISTED` only when it has no accepted obligation. |
| `punch-provider offer-retire --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY` | Irreversibly retire an eligible `UNLISTED` offer and its environment. |

The JSON status receipt uses schema version
`punch.provider-offer-lifecycle.v1` and includes `offerId`, `environmentId`,
`state`, `environmentState`, and `capacityReserved`. Mutation receipts also
include a stable `operationId` and `replayed` flag. Ownership failure is
non-enumerating: it returns `NOT_FOUND` rather than revealing another
Provider's offer.

Use one stable idempotency key per mutation. Reusing it with different request content fails with `IDEMPOTENCY_CONFLICT`. The exact replay returns the original durable receipt.

## Safety rules

The lifecycle is one way:

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

This source stays gated until all of the following bind to the same Preview.14
release:

1. A matching private runtime artifact implements the contract.
2. Focused integration proof covers Provider ownership/non-enumeration,
   idempotent replay, order-versus-unlist serialization, active-obligation
   rejection without mutation, and retirement only after terminal fenced
   dependencies and released capacity.
3. A release-bound public archive exposes the exact commands and passes the
   public documentation drift gate.

Until then, use only the commands in the installed release's `--help` output.
This page is a fail-closed release-source contract, not a Preview.9 or
Preview.14 deployment or release claim.
