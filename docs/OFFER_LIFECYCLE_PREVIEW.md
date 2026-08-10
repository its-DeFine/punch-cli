# Provider offer lifecycle preview

> **Preview.18 release boundary:** `offer-list`, `offer-status`,
> `offer-unlist`, `offer-retire`, and `offer-replace` are usable only from the
> matching non-draft
> [`v0.1.0-preview.18`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.18)
> archive, SHA-256
> `d144fd266328c022ef2601feb871ff62396a293d5e35e7130a3880cc0cdaf423`,
> after its same-release
> `SHA256SUMS` verifies. This source page alone is not install authority.

Preview.18 preserves the original Preview.14 unlist/retire safety contract and
adds authenticated offer enumeration, explicit guided selection, and one
sequential replacement after retirement. It does not change Buyer access,
Stop, or cleanup authority.

## Provider-only contract

An authenticated owning Provider uses these commands with its exact machine
and offer bindings:

| Command | Intended result |
| --- | --- |
| `punch-provider offer-list --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON` | List every offer owned by the exact Provider machine with ID, state, core characteristics, and predecessor binding. |
| `punch-provider offer-status --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID` | Read the Provider-owned offer's lifecycle status. |
| `punch-provider offer-unlist --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY` | Change a `LISTED` offer to `UNLISTED` only when it has no accepted obligation. |
| `punch-provider offer-retire --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY` | Irreversibly retire an eligible `UNLISTED` offer and its environment. |
| `punch-provider offer-replace --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id RETIRED_ID --idempotency-key KEY --yes` | Preserve one retired predecessor, create a distinct exact-term successor, reuse/start the service, and activate it through `LISTED`. |

The list receipt uses `punch.provider-offer-list.v1` and returns at most the
owned machine's bounded offer rows. The JSON status receipt uses schema version
`punch.provider-offer-lifecycle.v1` and includes `offerId`, `environmentId`,
`state`, `environmentState`, and `capacityReserved`. Mutation receipts also
include a stable `operationId` and `replayed` flag. Ownership failure is
non-enumerating: it returns `NOT_FOUND` rather than revealing another
Provider's offer.

Replacement returns a distinct successor offer ID, preserves the predecessor,
and reuses the same environment ID and setup reference. Use one stable
idempotency key per mutation. Reusing it with different request content fails with
`IDEMPOTENCY_CONFLICT`. Exact replay returns the original durable receipt.

## Safety rules

Each offer lifecycle is one way:

```text
LISTED -> UNLISTED -> RETIRED
```

A retired record never moves back to `LISTED`. Replacement creates a new
successor:

```text
RETIRED predecessor --replace--> distinct PENDING_AGENT successor -> LISTED
```

Unlisting removes an offer from Buyer discovery and rejects new orders with the
existing non-enumerating not-found behavior. It is rejected without mutation if
a direct order, reservation, contract, Provider task, access authorization, or lifecycle operation is nonterminal. It never stops, revokes, fences, or cleans up an accepted contract.

Unlisting also does not uninstall or stop the supervised Provider service. The
service remains runnable for accepted obligations and for one later successor.

Order acceptance and unlisting share an offer version fence. If they race, one
wins: either the order is accepted and unlisting is rejected as active, or
unlisting wins and the new order is rejected. A Provider cannot use unlisting
to invalidate an accepted Buyer contract.

Retirement is separate from unlisting. It requires `UNLISTED`, zero reserved
capacity, terminal direct lifecycle records, and fenced access. It retains auditable terminal offer and environment rows; it does not delete, relist, or recreate either record.

Replacement is permitted only when the predecessor is `RETIRED` and no other
nonterminal offer exists for that Provider machine. It clones the predecessor's
exact capacity, target Buyer, window, and price; these are not user inputs. The
retired predecessor remains auditable, and a pending successor is resumed
instead of duplicated. Preview.18 does not support concurrent multiple offers,
multiple local Provider profiles, or multi-machine orchestration.

The guided home always shows the authenticated offer list and requires the
Provider to select an eligible offer for status, unlist, retire, or replacement.
It never acts ambiguously on an implicit first offer.

## Release binding

The matching Preview.18 release must bind all of the following:

1. A matching private runtime artifact implements the contract.
2. Focused integration proof covers Provider ownership/non-enumeration,
   idempotent replay, order-versus-unlist serialization, active-obligation
   rejection without mutation, service continuity after unlist, retirement
   only after terminal fenced dependencies and released capacity, predecessor
   preservation, exact-term cloning, and one distinct `LISTED` successor.
3. A release-bound public archive exposes the exact commands and passes the
   public documentation drift gate.

Use only the commands in the installed release's `--help` output. This page is
a fail-closed command contract, not a deployment or self-service onboarding
claim.
