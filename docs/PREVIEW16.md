# Preview.16 guided Provider onboarding release

> **Status: `PUBLISHED_PRERELEASE`.** Preview.16 is published for Linux/x64 at
> [`v0.1.0-preview.16`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.16).
> Install authority comes only from that matching non-draft GitHub prerelease
> after verifying the exact archive against its same-release `SHA256SUMS`; this
> page does not authorize a source checkout or different bytes.

Preview.16 promotes the guided Provider onboarding implementation described in
[Guided `punch` home](GUIDED_CLI.md). The normal Provider entry is `punch`, then
**Provider**. Direct `punch-provider ...` commands remain an advanced automation
and recovery surface; external Providers do not need to assemble their flags.

## Guided Provider contract

The released flow must preserve this order:

1. Inspect the supported host before identity creation. If prerequisites are
   missing, show the exact reviewed dependency plan and require explicit
   consent before any privileged change. Guided authorization first probes
   passwordless capability with `sudo -n true`; only when that is unavailable
   may it fall back to interactive `sudo -v`. Failed authorization stops before
   installation. Direct non-interactive installation still requires cached `sudo`.
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

Preview.16 remains invitation-only and owner-targeted `$0`. Payment, settlement, payout, and refund
behavior is not enabled or accepted. Provider onboarding is not self-approving:
the public request only creates the waiting projection, and `INVITE_READY`
records supervised approval without removing the separate owner-delivered
invitation boundary.

No Provider receives a NetBird management credential, Control administrator
credential, Buyer secret, Provider host SSH credential, or public host address.
Buyer SSH remains contract-scoped through the approved transport. Stable
`punch.*.preview14.v1` JSON identifiers may remain in compatible receipts; they
are protocol schema versions, not the Preview.16 package version.

## Exact release binding

The published artifact binds private commit
`c0cabb6f18e7eba6c3c9910abe4e76ad814c05d2`, tree
`7d67f0967ac2cfab5b47a92716fe5bbda069d08e`, and deterministic Control
archive
`sha256:ba7d8c32ba2cdad2d7bdef32739ca4d8b2a1d03c26f0b5a4c946249d68f3b28b`.
Its 43,804,636-byte public archive is
`sha256:49d1dba584c52de7e0b75dc77a2b9572c3a31ef417575e8c80a5f6e16422da17`;
the same-release `SHA256SUMS` is
`sha256:83258b75849ac55f8a03637d66fd9b6b4f9548071185d65f3d90632ff8391617`.
The immutable packaged `RELEASE-BINDING.json` is
`sha256:83ba50cb6a9669423ffafd1b782639d8ca52526e9bd9159fbc32afee10ed7eaa`,
the packaged `BUILD-MANIFEST.txt` is
`sha256:cffe1fe43c8c67fbf81d688d9332a28c81b528ff93edd37c1dcaad41c6a3d223`,
and the embedded `RELEASE-CONTRACT.json` is
`sha256:1754bfca47aac7b1f9320da7c7c1f6b8a853331b7bfa76de56ebb4c5ab764f4e`.

The static v1 [command-contract template](preview16-public-command-contract.template.json)
preserves its four `PENDING_DETERMINISTIC_BUILD` sentinels. The separate
[bound command contract](preview16-public-command-contract.json) and generated
[command reference](PREVIEW16_COMMAND_REFERENCE.md) declare the public commands
and flags for the published artifact. They do not introduce or promote another
metadata framework and are not exhaustive mechanical semantic/output parity.
The exact packaged help and real acceptance remain authoritative.

## Owner-readiness acceptance

`OWNER-READY` requires all of the following, with no unresolved error:

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
