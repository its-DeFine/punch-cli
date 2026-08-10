# Preview.18 Provider lifecycle and Buyer SSH handoff

> **Status: `PUBLISHED_PRERELEASE`.** Preview.18 is installable only from the matching non-draft
> [`v0.1.0-preview.18`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.18)
> after the exact Linux/x64 archive verifies against its same-release
> `SHA256SUMS`; this source commit alone is not install authority.

Preview.18 preserves the Preview.17 guided Provider and Buyer onboarding
contracts and adds the bounded lifecycle and SSH handoff repairs below. Direct
role commands remain available for reviewed automation and recovery; the normal
human path remains `punch`.

## Append-only Provider onboarding

Supervised approval of a new Provider appends one distinct Provider actor,
machine, invitation, offer authority, and narrow route. It does not replace or
delete an existing Provider or Buyer authority. Every request and invitation
remains bound to the same public machine identity, and all prior durable
Provider, Buyer, offer, order, and contract state is preserved.

This is not self-service approval. The public onboarding request still stops at
`WAITING_FOR_INVITE`; `INVITE_READY` still contains no invitation secret;
and the owner-delivered mode-`0600` invitation remains a separate custody
boundary.

## Explicit Provider offer lifecycle

The guided Provider home reads the authenticated offer list and shows each
offer's ID, state, CPU, RAM, disk, GPU count, window, price, and targeted
status. Status, unlist, and retire actions require selection of one exact
eligible offer.

Unlisting removes the selected offer from discovery and prevents new orders.
It does not cancel accepted contracts and leaves the supervised Provider
service installed and runnable. Retirement remains terminal for that offer and
requires an already-unlisted offer, terminal obligations, released capacity,
and fenced access.

After retirement, the Provider may create one sequential replacement. The
retired predecessor remains preserved; the successor receives a distinct
offer ID, clones the predecessor's exact capacity, target, window, and price,
and reuses the same environment ID, setup reference, and supervised service
before it must reach `LISTED`. Preview.18 permits only one nonterminal offer
per Provider machine; it does not claim concurrent multi-offer, multi-profile, or
multi-machine orchestration.

The advanced public command surface adds `offer-list` and `offer-replace`
without changing the existing `offer-status`, `offer-unlist`, or
`offer-retire` semantics.

## Strict guided zero-price order gate

The guided Buyer accepts only an authenticated offer that is all of:

- explicitly eligible for the current Buyer;
- targeted to that Buyer; and
- priced as canonical numeric +0, not a string, missing value,
  nested-only value, nonzero value, or negative zero.

A mismatch stops before SSH-key selection, local order creation, or a Control
order request. No payment setup or transaction is attempted. The direct Control
boundary remains authoritative and owner-targeted `$0` only.

## Scoped Buyer SSH preparation

For an ACTIVE contract with effective access, the guided Buyer action is
**Prepare SSH command**, not an embedded shell. It verifies the selected
owner-private key, fixed OpenSSH client, exact authenticated gateway descriptor,
one NetBird route/source binding, and the persistent/live Buyer firewall order.

If the existing Buyer-local private-range policy blocks the one contract
gateway, Punch displays one exact TCP egress exception and requires explicit
consent. The repair is limited to that destination, port, and NetBird
interface; persistent and live rules must agree. Failed apply restores the
prior policy or reports rollback as unproven and stops.

After the gate passes, Punch prints one shell-quoted command bound to the
existing Buyer config, selected key path, active contract ID, per-contract
known-hosts file, forced TTY, batch mode, fixed ProxyCommand, and
`punch@punch-job`. Punch does not spawn SSH or the proxy. Gateway reachability
and SSH key exchange start only when the owner runs the visible command.

The optional OSC 52 step is default-no and copies only that just-generated
command after explicit consent. `SENT` means the terminal request was emitted,
not acknowledged. Unsupported terminals, multiplexers, decline, or failure
leave the visible command as the safe fallback. No key, invitation, session,
credential, config contents, or arbitrary output is copied.

Exiting the remote shell with `exit` or Ctrl-D returns to the Buyer VM and
does not stop the active contract. Contract revocation and cleanup remain the
separate `Stop` action.

## Unchanged security and product boundary

Preview.18 remains invitation-only, Linux/x64, owner-targeted `$0`, and
contract-scoped over NetBird. It does not enable payment, settlement, payout,
refunds, public Provider addresses, host SSH, Docker exposure, NetBird
management credentials, Control administrator credentials, or self-approved
Provider onboarding.

## Exact release binding

The published artifact binds private source commit
`4e4aae1bb335092d69dc467a74651ad9527c4c17`, tree
`a0fbb1491130d179b602c64e9b7fe170c7011de6`, and deterministic Control
archive
`sha256:fcaa8d0c28d48f68bf940811457cfcd2ff594c9d14139dae33301749d6c0ae5a`.

Its 43,811,105-byte public archive is
`sha256:d144fd266328c022ef2601feb871ff62396a293d5e35e7130a3880cc0cdaf423`;
the same-release `SHA256SUMS` is
`sha256:094b1acb686b7daec071af97370be749b003579343e432c8c026dc80980d4da7`.
The immutable packaged `RELEASE-BINDING.json` is
`sha256:1f5c009a84f15262da8c1075140fcf463229a5d4bf6aa3ad0f2e5844ef5a028a`,
the packaged `BUILD-MANIFEST.txt` is
`sha256:b86cb81697183e31b8fa53529a617be07266e3ad892d50c312bcad09d0de6625`,
and the embedded `RELEASE-CONTRACT.json` is
`sha256:1d7b13e6ce39526cf99b8795291dcb3d0f5e85a76df346d0f60f1066d2d2ebd1`.

The static
[command-contract template](preview18-public-command-contract.template.json)
preserves its four `PENDING_DETERMINISTIC_BUILD` sentinels. The separate
[bound command contract](preview18-public-command-contract.json),
[runtime contract](preview18-runtime-contract.json), and generated
[command reference](PREVIEW18_COMMAND_REFERENCE.md) bind the archive,
`SHA256SUMS`, runtime contract, and canonical packaged CLI surface. The exact
packaged help and clean-host acceptance remain authoritative.

## Release acceptance

Promotion requires byte-identical deterministic builds and independent clean
Provider and Buyer archive-installed journeys. In addition to the Preview.17
proof, acceptance must cover append-only authority preservation; offer
list/select/unlist/service/retire/replacement; strict targeted canonical-zero
rejection; scoped SSH egress consent; visible no-spawn command handoff; optional
OSC 52 fallback; real OpenSSH; Stop/replay; access rejection; cleanup; and
capacity release.

Publication or local tests alone are not `OWNER-READY`.
