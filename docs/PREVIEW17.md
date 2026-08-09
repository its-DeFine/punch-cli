# Preview.17 guided Buyer authorization repair

> **Status: `PUBLISHED_PRERELEASE`.** Preview.17 is published for Linux/x64 at
> [`v0.1.0-preview.17`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.17).
> Install authority comes only from that matching non-draft GitHub prerelease
> after verifying the exact archive against its same-release `SHA256SUMS`; this
> page does not authorize a source checkout or different bytes.

Preview.17 preserves the guided Provider onboarding implementation described in
[Guided `punch` home](GUIDED_CLI.md) and repairs the equivalent sudo capability
probe in guided Buyer join. The direct command surface is unchanged.

## Guided Buyer authorization repair

After the Buyer confirms the documented join and a dependency install is
required, the guided CLI first probes passwordless capability with
`sudo -n true`. A successful probe proceeds without an unnecessary password
prompt. If the probe is unavailable, the CLI falls back to interactive
`sudo -v`; failed authorization stops before dependency installation or join.
Direct non-interactive Buyer join still requires cached `sudo`.

## Preserved guided Provider contract

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

Preview.17 remains invitation-only and owner-targeted `$0`. Payment, settlement, payout, and refund
behavior is not enabled or accepted. Provider onboarding is not self-approving:
the public request only creates the waiting projection, and `INVITE_READY`
records supervised approval without removing the separate owner-delivered
invitation boundary.

No Provider receives a NetBird management credential, Control administrator
credential, Buyer secret, Provider host SSH credential, or public host address.
Buyer SSH remains contract-scoped through the approved transport. Stable
`punch.*.preview14.v1` JSON identifiers may remain in compatible receipts; they
are protocol schema versions, not the Preview.17 package version.

## Exact release binding

The published artifact binds private commit
`5a2e9d4f4e4e38ce4dcd782891533a67c2a51768`, tree
`2e4439d38ded6679afbafc4ad2e16cb282308eb7`, and deterministic Control
archive
`sha256:33fcb27b312c346540075df64a8598133eb32b1bdce81378cb3b22026d5f8d1e`.
Its 43,804,706-byte public archive is
`sha256:76648c0bd4d9b96399fe52b553151ad8594e49af9c46aba565e23217ee56f10c`;
the same-release `SHA256SUMS` is
`sha256:807ba2bac9b9d8324dc7aac9942d92f4f5ad2a366c590a023df58d747b0eed52`.
The immutable packaged `RELEASE-BINDING.json` is
`sha256:cf655a61bec9aca787a3fc2773d182b0900228b035606ea88328d1d8928fa801`,
the packaged `BUILD-MANIFEST.txt` is
`sha256:e5af88ad7d85ed956d97473787647b1bacf2cdfb5a1f5fa7bcddf049940a14ed`,
and the embedded `RELEASE-CONTRACT.json` is
`sha256:2445353d76428057401481243edfa58e9fc37f4cd9a478a3a1a9b0a7bf6252ad`.

The static v1 [command-contract template](preview17-public-command-contract.template.json)
preserves its four `PENDING_DETERMINISTIC_BUILD` sentinels. The separate
[bound command contract](preview17-public-command-contract.json) and generated
[command reference](PREVIEW17_COMMAND_REFERENCE.md) declare the public commands
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
