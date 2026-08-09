# Guided `punch` home

> **Release boundary:** this page documents the gated Preview.14 candidate. It
> is not installable until the exact Preview.14 archive and checksum are
> published in a non-draft prerelease.

Run `punch` in a terminal to open the interactive home. It is a continuous,
local navigation layer over the existing role commands, not a one-time setup
wizard. Every later launch reads only the owner-controlled local Punch profile
and the authenticated status of jobs created from that profile.

- Before Buyer join, the home offers the existing Buyer join flow. Before
  Provider join, it creates the machine identity and public onboarding packet;
  the supervised operator binds the invitation to that packet.
- A joined Buyer sees offers, local orders, profile information, and direct
  status/connect/stop actions for locally recorded active contracts.
- A joined Provider without a locally recorded offer sees readiness and one
  complete setup action. Setup proposes bounded capacity from real inventory,
  asks before the overall operation and again before any privileged dependency
  install, persists one stable setup reference, and continues in that same CLI
  session through NetBird enrollment, immutable image/readiness proof,
  generated config, hardened service start, and `LISTED`.
- A configured Provider sees machine readiness, machine and offer status,
  unlist/retire, and supervised-service start/stop/status/log actions. Foreground
  `serve` remains a direct diagnostic command rather than the normal home path.

The Buyer reviews the complete selected offer before confirming an order. The
home can select an existing owned Ed25519 key pair or, with explicit approval,
create a protected local key. It stores only key paths; it never reads or
prints the private key. A stable order reference is written locally before the
order request, so an ambiguous response can be retried with the same reference.

Buyer join preserves the documented NetBird bootstrap. If NetBird is missing,
the home explains the privileged install step and asks for confirmation; it
may show the normal TTY `sudo` prompt, but it does not hide the privilege
boundary, create a second enrollment code, or bypass a failed setup. Join is
resumable until the exact Buyer/NetBird binding is confirmed.

Provider setup similarly owns its narrow one-time NetBird bootstrap. It does
not ask the Provider for a setup key or management login. It also pulls the
authenticated immutable images, runs the pre-list proof while the offer is
`PENDING_AGENT`, generates the private agent config, installs/starts systemd,
and waits for a fresh heartbeat before reporting `LISTED`.

Guided TTY setup may prompt for `sudo` only after the reviewed dependency plan
is confirmed. Direct non-interactive setup requires explicit confirmation and
cached `sudo`; otherwise it fails with a recovery instruction. Neither path
requires manual `serve`, a copied agent config, or a separate NetBird command.

The Buyer home renders the selected offer's returned capacity, duration, price,
availability, and eligibility before final confirmation. It stores the stable
order reference before submission. The home refuses confirmation for an
ineligible offer; the direct order route also rejects it. Authorized windows
are bounded to at most `259200` seconds. Job status renders returned lifecycle state,
phase, access readiness, contract/task/generation, history, and sanitized
failure action where present; absent fields remain explicitly unavailable.

Multiple supervised Providers may be active. The home lists their separately
eligible offers, while each order still reserves exactly one offer/machine and
does not reveal a Provider host address.

For scripts and automation, keep using `punch-buyer ...` and
`punch-provider ...`, or use the equivalent `punch buyer ...` and
`punch provider ...` forwarding forms. Exit codes are preserved. Autonomous
use must follow the separate custody, approval, retry, and state rules in the
[Punch agent runbook](AGENT_RUNBOOK.md); it must not answer the human home's
interactive prompts.

## Unreleased interactive Provider onboarding implementation contract

> **UNRELEASED IMPLEMENTATION CONTRACT**
> **Release authority: false.** This flow is not present in
> `v0.1.0-preview.14` or its published archive. It describes behavior being
> implemented for a later release candidate and does not change the shipped
> Preview.14 commands or release record.

The normal Provider journey starts from one obvious interactive entry point:
run `punch`, then select **Provider**. Direct `punch-provider ...` commands
remain an advanced, non-interactive path; a Provider following the guided path
does not need to discover or assemble them.

The guided flow proceeds in this order:

1. **Preflight before identity.** The CLI inspects the host and reports whether
   it is ready before it creates a Provider identity or sends an onboarding
   request. If reviewed prerequisites are missing, it shows the
   exact dependency-install plan and asks for explicit consent to that plan
   before making any privileged change. A declined or failed plan leaves the
   identity boundary uncrossed and provides a recovery action.
2. **Friendly Provider choices.** The CLI asks for a human-facing Provider
   label, CPU, RAM, disk, and which detected GPUs to make available. It does not
   ask the Provider to construct or paste a Punch origin, filesystem or
   credential path, machine ID, GPU UUID, CDI selector, setup reference, or raw
   setup flag.
3. **Explicit identity boundary.** The CLI explains the durable local state and
   public request it is about to create, then requires confirmation. Only after
   that confirmation does it generate and retain the private identity locally
   and submit a signed, public-only onboarding request. Private key material and
   internal credentials are never sent or displayed.
4. **Durable wait and resume.** After the request is accepted, the home displays
   `WAITING_FOR_INVITE` and preserves that state across relaunch. The Provider
   returns to the same `punch` flow and supplies the one-time invitation artifact
   when it arrives; no server handoff or placeholder flags have to be inferred.
5. **Automatic setup through listing.** After invitation confirmation, the CLI
   resumes the authenticated join, uses trusted Control-derived configuration,
   completes NetBird enrollment, generates local config, installs and validates
   the service with approval for consequential local changes, validates the
   selected capacity, and activates the bounded offer through `LISTED`.
6. **One status and recovery surface.** Subsequent interactive homes show the
   Provider and onboarding state, offer/listing state, orders and contracts,
   selected capacity, service health, and a clear recovery action when work is
   required.
