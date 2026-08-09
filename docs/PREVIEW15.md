# Preview.15 guided Provider onboarding release gate

> **Status: `PUBLISHED_PRERELEASE`.** Preview.15 is published for Linux/x64 at
> [`v0.1.0-preview.15`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.15).
> Install authority comes only from that matching non-draft GitHub prerelease
> after verifying the exact archive against its same-release `SHA256SUMS`; this
> page does not authorize a source checkout or different bytes.

Preview.15 promotes the guided Provider onboarding implementation described in
[Guided `punch` home](GUIDED_CLI.md). The normal Provider entry is `punch`, then
**Provider**. Direct `punch-provider ...` commands remain an advanced automation
and recovery surface; external Providers do not need to assemble their flags.

## Guided Provider contract

The released flow must preserve this order:

1. Inspect the supported host before identity creation. If prerequisites are
   missing, show the exact reviewed dependency plan and require explicit
   consent before any privileged change. Direct non-interactive installation
   additionally requires cached `sudo`.
2. Ask only for a friendly Provider label and bounded CPU, RAM, disk, and GPU
   choices. Machine identity, state paths, Punch origin, credential paths, GPU
   UUID/CDI bindings, and setup references remain trusted internal values.
3. Explain the durable local identity boundary and require confirmation. Only
   then create the owner-private signing identity and send its signed public
   onboarding packet with the selected capacity. Private keys and credentials
   are never transmitted or displayed.

The public onboarding packet is approval input only; it is not an invitation
or credential.
4. Persist and display `WAITING_FOR_INVITE`. The public request does not issue
   or contain an invitation. After supervised approval, the signed status may
   advance to `INVITE_READY`; the guided home then imports only the
   owner-delivered, mode-`0600` one-time invitation and resumes the same identity
   and request. The status itself does not contain or reveal the invitation.
5. Complete authenticated join, NetBird enrollment, generated configuration,
   immutable image pull + digest verification, pre-list validation, supervised
   service installation/start, and bounded offer activation. The offer remains
   `PENDING_AGENT` until the proof and fresh service heartbeat permit `LISTED`.
6. Render one authenticated overview of onboarding, offer/listing status,
   contracts, selected capacity, service health, and one safe recovery action.

Multiple approved Providers may exist, but every Buyer order still binds one
eligible offer and one machine, and ineligible offers fail closed. Access
windows remain capped at `259200` seconds.
Punch may supervise multiple approved Providers without widening any one
machine or offer authority.

## Unchanged policy boundary

Preview.15 remains invitation-only and owner-targeted `$0`. Payment, settlement, payout, and refund
behavior is not enabled or accepted. Provider onboarding is not self-approving:
the public request only creates the waiting projection, and `INVITE_READY`
records supervised approval without removing the separate owner-delivered
invitation boundary.

No Provider receives a NetBird management credential, Control administrator
credential, Buyer secret, Provider host SSH credential, or public host address.
Buyer SSH remains contract-scoped through the approved transport. Stable
`punch.*.preview14.v1` JSON identifiers may remain in compatible receipts; they
are protocol schema versions, not the Preview.15 package version.

## Exact release binding

This artifact-source candidate binds private commit
`7867a5f101180b231e24d2b87bc4e86ef90b9b38`, tree
`7ded34759e139fb54b3f15fabf8992bdd3943628`, 44,037,198-byte deterministic Control archive
`sha256:11271fd5454c993b6389af9c1833d0e9c380b2ea7fd6ffde731d02cec4cda0e3`,
and Control checksum manifest
`sha256:26477622f39de3324443d45bdbba2d34967c8a50f4658a1491054ad60f75a8d0`.
Public archive hashes remain `PENDING_DETERMINISTIC_BUILD` until the CLI is
built twice from this exact source and Control binding.

The static v1 [command-contract template](preview15-public-command-contract.template.json)
and pending [command reference](PREVIEW15_COMMAND_REFERENCE.md) declare the
public commands and flags. They do not introduce or promote another metadata
framework and are not exhaustive mechanical semantic/output parity. The exact
packaged help and real acceptance remain authoritative.

## Release acceptance

Release requires all of the following, with no unresolved error:

- deterministic Control and public archives built twice with byte-identical
  archive, binding, manifest, and sums;
- archive member, path, permission, checksum, installer, and uninstaller safety;
- a genuinely clean Provider Linux/x64 VM installing only the public archive
  and completing the guided preflight, identity consent, onboarding request,
  `WAITING_FOR_INVITE`, `INVITE_READY`, secure invitation import, setup replay,
  service restart, and `LISTED` path;
- an independent genuinely clean Buyer Linux/x64 VM installing the same public
  archive and completing join/replay, eligible discovery, one `$0` order/replay,
  real OpenSSH, stop/replay, post-stop rejection, cleanup, and capacity release;
- a real local container/SSH cleanup canary and a bound sanitized report plus
  execution receipt; and
- rejection of every fake Docker/fetch/SSH seam, in-memory Control substitute,
  source CLI, mock SSH, or dependency-injection shortcut.

Local tests, a source checkout, a Provider-only pass, a Buyer-only pass, or a
published archive alone is not owner readiness. Only the released archive and
version-matched docs passing both independent clean journeys can be reported
`OWNER-READY`.
