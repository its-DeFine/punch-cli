# Provider offer lifecycle preview

> **Preview.19.2 release boundary:** Provider offer lifecycle is available only
> from the matching Linux/x64 archive after its same-release `SHA256SUMS`
> verifies. This source page alone is not install authority.

> **Previous published boundary:** Preview.19 remains bound to its Linux/x64
> [`v0.1.0-preview.19`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.19)
> archive, SHA-256 `6d5d8f34d640643ca604bc61f5ae7ee8270617ecac0b06299d064eed38724484`.

> **Earlier published boundary:** Preview.18 remains bound to its Linux/x64
> [`v0.1.0-preview.18`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.18)
> archive, SHA-256 `d144fd266328c022ef2601feb871ff62396a293d5e35e7130a3880cc0cdaf423`.

Preview.19.2 adds resource-aware offer creation to the original unlist/retire
contract. Control assigns each Provider machine an offer-slot limit, while the
machine's signed inventory defines its aggregate CPU, GPU, VRAM, RAM, and disk
pool. Multiple offers are allowed only while both limits remain satisfied. It
does not change Buyer access, Stop, or cleanup authority.

For workspace capacity, quota-backed disk capacity comes from
the dedicated XFS `prjquota` (or `pquota`) filesystem mounted exactly at
`/var/lib/punch/workspaces`: `floor(total filesystem bytes / 2^30)`, not root
free space or current workspace free blocks. Root space for images is checked
separately. Existing nonterminal offers, including unlisted offers, retain
their allocations; eligible retirement releases them. A nominal 10 GiB device
whose formatted filesystem exposes 9.937 GiB therefore has a 9 GiB offer budget:
4+4 GiB fits, while 4+6 GiB is rejected (and 2+8 GiB does not fit). Setup and
resident refresh reject a missing dedicated quota mount. The generic
`inventory` diagnostic is not an admission receipt. In scoped live acceptance
on Ubuntu 24.04 LTS using the invitation-only, zero-price path, two
same-machine concurrent 1 CPU/1 GiB/4 GiB jobs ran within that budget. The
capacity checks are run-scoped evidence, not a statistical 100% claim or a
general-availability promise.

## Provider-only contract

An authenticated owning Provider uses these commands with its exact machine
and offer bindings:

| Command | Intended result |
| --- | --- |
| `punch-provider offer-create --machine-id ID --state-dir DIR [--agent-config ABSOLUTE_JSON] [--idempotency-key KEY] --cpu-cores N --gpu-units N --vram-mib N --ram-mib N --disk-gib N --yes` | Create and activate one distinct offer within the machine's remaining slot and verified resource capacity. |
| `punch-provider offer-list --machine-id ID --state-dir DIR [--agent-config ABSOLUTE_JSON]` | List every offer owned by the exact Provider machine with ID, state, core characteristics, and predecessor binding. |
| `punch-provider offer-status --machine-id ID --state-dir DIR [--agent-config ABSOLUTE_JSON] --offer-id ID` | Read the Provider-owned offer's lifecycle status. |
| `punch-provider offer-unlist --machine-id ID --state-dir DIR [--agent-config ABSOLUTE_JSON] --offer-id ID [--idempotency-key KEY]` | Change a `LISTED` offer to `UNLISTED` only when it has no accepted obligation. |
| `punch-provider offer-retire --machine-id ID --state-dir DIR [--agent-config ABSOLUTE_JSON] --offer-id ID [--idempotency-key KEY]` | Irreversibly retire an eligible `UNLISTED` offer, releasing its slot and resources while the machine remains ready. |
| `punch-provider offer-replace --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id RETIRED_ID --idempotency-key KEY --yes` | Compatibility shortcut for an exact-term successor; normal new allocation uses `offer-create`. |

Provider extension operations are separate from offer lifecycle and use the
canonical generated agent config:

| Command | Intended result |
| --- | --- |
| `punch-provider extension-propose --contract-id ID --duration-seconds N --idempotency-key KEY --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON` | Propose a bounded zero-price extension for an owned contract. |
| `punch-provider extension-inbox --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON` | List extension proposals for owned contracts. |
| `punch-provider extension-accept --proposal-id ID --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON` | Accept one owned pending extension proposal. |
| `punch-provider extension-reject --proposal-id ID --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON` | Reject one owned pending extension proposal. |

The list receipt uses `punch.provider-offer-list.v1` and returns at most the
owned machine's bounded offer rows. The JSON status receipt uses schema version
`punch.provider-offer-lifecycle.v1` and includes `offerId`, `environmentId`,
`state`, `environmentState`, and `capacityReserved`. Mutation receipts also
include a stable `operationId` and `replayed` flag. Ownership failure is
non-enumerating: it returns `NOT_FOUND` rather than revealing another
Provider's offer.

Creation returns a distinct offer ID and preserves every existing offer. The
requested resources must fit both the admin-assigned slot limit and the signed
physical resource pool. Replacement remains a compatibility shortcut that
preserves its predecessor and reuses the same environment ID and setup reference.

Setup's canonical `STATE_DIR/provider-agent.json` is reused automatically;
`--agent-config` is only an advanced exact-match override. Create stores one
automatic retry identity in `STATE_DIR/offer-create.pending.json`. After an
ambiguous failure, rerunning the same inputs resumes that operation instead of
creating a duplicate; a different intent fails closed while it is pending.
Unlist and retire derive deterministic operation identities from the machine,
offer, and action. An explicit `--idempotency-key` is an optional advanced
override for these three commands. Reusing any key with different request
content fails with `IDEMPOTENCY_CONFLICT`; exact replay returns the original durable receipt.
Compatibility-only replace retains its explicit key and config.

## Safety rules

Each offer lifecycle is one way:

```text
LISTED -> UNLISTED -> RETIRED
```

A retired record never moves back to `LISTED`. Normal creation and the
compatibility replacement shortcut both create distinct records:

```text
READY machine --create within limits--> distinct PENDING_AGENT offer -> LISTED
RETIRED predecessor --replace compatibility--> distinct PENDING_AGENT successor -> LISTED
```

Unlisting removes an offer from Buyer discovery and rejects new orders with the
existing non-enumerating not-found behavior. It retains that offer's slot and
resource allocation. It is rejected without mutation if a direct order,
reservation, contract, Provider task, access authorization, or lifecycle
operation is nonterminal. It never stops, revokes, fences, or cleans up an
accepted contract.

Unlisting also does not uninstall or stop the supervised Provider service. The
service remains runnable for accepted obligations and later offers on the same
machine.

Order acceptance and unlisting share an offer version fence. If they race, one
wins: either the order is accepted and unlisting is rejected as active, or
unlisting wins and the new order is rejected. A Provider cannot use unlisting
to invalidate an accepted Buyer contract.

Retirement is separate from unlisting. It requires `UNLISTED`, zero reserved
capacity, terminal lifecycle records for that offer, and fenced access. It
retains the auditable terminal offer row, releases only that offer's slot and
resources, and leaves the machine environment `READY`; it deletes nothing.

Creation is permitted whenever the number of non-retired offers is below the
admin-assigned slot limit and the sum of their resource vectors plus the new
request fits the machine's verified physical resource pool. The same aggregate
resource check runs again when a Buyer order is accepted, preventing concurrent
offers or orders from oversubscribing the machine. Replacement remains only an
exact-term compatibility shortcut.

The guided home always shows the authenticated offer list and requires the
Provider to select an eligible offer for status, unlist, retire, or replacement.
Creation is explicit and requires a full requested resource vector. It never
acts ambiguously on an implicit first offer.

## Release binding

The matching Preview.19 release must bind all of the following:

1. A matching private runtime artifact implements the contract.
2. Focused integration proof covers Provider ownership/non-enumeration,
   idempotent replay, slot/resource exhaustion, unlist retaining allocation,
   order-versus-unlist serialization, active-obligation rejection without
   mutation, retirement freeing only the target offer's allocation while the
   machine remains ready, aggregate Buyer-order capacity enforcement, and one
   distinct `LISTED` record per successful create.
3. A release-bound public archive exposes the exact commands and passes the
   public documentation drift gate.

Use only the commands in the installed release's `--help` output. This page is
a fail-closed command contract, not a deployment or self-service onboarding
claim.


## Preview.19 resale and extension operations

Buyer `resales`, `resale-create`, `resale-claim`, and `resale-cancel` expose only
authenticated owner projections. A resale keeps the signed resource snapshot
and transfer policy and never exposes a Provider address or creates a second
active environment.

The extension commands are `extension-exercise`, `extension-propose`,
`extension-inbox`, `extension-accept`, and `extension-reject`. Every extension
is zero-price, bounded by the signed option and maximum uses, and idempotent. An
expired or exhausted contract is not revived by replay.
