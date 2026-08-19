# Guided `punch` home

> **Release boundary:** this page documents the Preview.19.1 Linux/x64 public
> source contract. Install only from the matching archive after its same-release
> `SHA256SUMS` verifies; this source page alone is not install authority.
> Preview.19.1 preserves the Preview.19 behavior and corrects the packaged
> documentation and provenance binding.

> **Previous published boundary:** Preview.19 remains bound to its Linux/x64
> [`v0.1.0-preview.19`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.19)
> archive, SHA-256 `6d5d8f34d640643ca604bc61f5ae7ee8270617ecac0b06299d064eed38724484`.

> **Earlier published boundary:** Preview.18 remains bound to its Linux/x64
> [`v0.1.0-preview.18`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.18)
> archive, SHA-256 `d144fd266328c022ef2601feb871ff62396a293d5e35e7130a3880cc0cdaf423`.

Run `punch` in a terminal to open the interactive home. It is a continuous,
local navigation layer over the existing role commands, not a one-time setup
wizard. Every later launch reads only the owner-controlled local Punch profile
and the authenticated status of jobs created from that profile.

- Before Buyer join, the home offers the existing Buyer join flow. Before
  Provider join, it creates the machine identity and public onboarding packet;
  the supervised operator binds the invitation to that packet.
- A joined Buyer sees offers, local orders, profile information, and direct
  status/SSH-preparation/stop actions for locally recorded active contracts.
- A joined Provider without a locally recorded offer sees readiness and one
  complete setup action. Setup proposes bounded capacity from real inventory,
  asks before the overall operation and again before any privileged dependency
  install, persists one stable setup reference, and continues in that same CLI
  session through NetBird enrollment, immutable image/readiness proof,
  generated config, hardened service start, and `LISTED`.
- A configured Provider sees machine readiness and the authenticated offer
  list, selects an exact offer for status/unlist/retire, can create or resume
  one sequential replacement after retirement, and retains supervised-service
  start/stop/status/log actions. Foreground `serve` remains a direct diagnostic
  command rather than the normal home path.

The Buyer reviews the complete selected offer before confirming an order. The
guided path accepts only an explicitly eligible, targeted offer whose
`priceMinor` is canonical numeric +0; any missing, string, nested,
nonzero, or negative-zero value stops before key selection or local order
creation. No payment setup or transaction is attempted. The
home can select an existing owned Ed25519 key pair or, with explicit approval,
create a protected local key. It stores only key paths; it never reads or
prints the private key. A stable order reference is written locally before the
order request, so an ambiguous response can be retried with the same reference.

Buyer join preserves the documented NetBird bootstrap. If NetBird is missing,
the home explains the privileged install step and asks for confirmation; it
may show the normal TTY `sudo` prompt, but it does not hide the privilege
boundary, create a second enrollment code, or bypass a failed setup. Join is
resumable until the exact Buyer/NetBird binding is confirmed.

Preview.18 repairs guided Buyer authorization without changing the direct
command surface: after join confirmation it first probes passwordless
capability with `sudo -n true`, then falls back to interactive `sudo -v` only
when needed. Failed authorization stops before dependency installation or join.

Provider setup similarly owns its narrow one-time NetBird bootstrap. It does
not ask the Provider for a setup key or management login. It also pulls the
authenticated immutable images, runs the pre-list proof while the offer is
`PENDING_AGENT`, generates the private agent config, installs/starts systemd,
and waits for a fresh heartbeat before reporting `LISTED`.

Guided TTY setup may prompt for `sudo` only after the reviewed dependency plan
is confirmed. Direct non-interactive setup requires explicit confirmation and
cached `sudo`; otherwise it fails with a recovery instruction. Neither path
requires manual `serve`, a copied agent config, or a separate NetBird command.

Preview.16 repaired guided Provider authorization without changing the direct
command surface: after plan confirmation it first probes passwordless capability with
`sudo -n true`, then falls back to interactive `sudo -v` only when needed. A
failed fallback stops before dependency installation.

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

Supervised approval of another Provider is append-only. It binds a distinct
actor, machine, invitation, offer authority, and narrow route while preserving
every existing Provider and Buyer authority and durable record.

## Preview.19 Provider offer handling

The Provider home renders each owned offer with its ID, state, CPU, RAM, disk,
GPU count, window, price, and targeted status. Status, unlist, and retire never
act on an implicit first offer: the Provider selects one eligible offer.
Unlisting prevents new orders but leaves the supervised service installed and
runnable and does not alter accepted contracts. Retirement is terminal for the
selected offer.

When no nonterminal offer remains, **Create replacement offer** preserves the
retired predecessor and clones its exact capacity, target, window, and price
into one distinct successor. The existing service is reused and the guided
flow waits for `LISTED`. A `PENDING_AGENT` successor is resumed rather than
duplicated. Preview.19 permits one nonterminal offer per machine; it does not
claim concurrent multi-offer or multi-profile orchestration.

## Preview.19 Buyer SSH preparation

After status is `ACTIVE` with `accessEffective: true`, choose **Prepare SSH command**.
Punch validates the selected private key, fixed OpenSSH client,
authenticated contract gateway, one NetBird route/source, and exact persistent
and live Buyer firewall policy. If one scoped TCP exception is required, Punch
shows the destination, port, interface, and rule and asks for explicit consent.
It does not apply broad Docker, network, or private-range cleanup.

On success Punch prints one shell-quoted command bound to the existing Buyer
config, selected key, active contract, per-contract known-hosts file, forced
TTY, batch mode, fixed ProxyCommand, and `punch@punch-job`. It does not launch
SSH or the proxy. Copy the visible command, exit Punch, and run it from the
Buyer VM shell. Gateway reachability and key exchange begin only then.

The optional OSC 52 prompt is default-no. After explicit consent it copies
only the just-generated command. `SENT` means a terminal request was emitted,
not acknowledged; `UNSUPPORTED`, decline, or failure leaves the visible
command as the fallback. `exit` or Ctrl-D returns to the Buyer VM but does not
stop the contract; use **Stop** for revocation and cleanup.

For scripts and automation, keep using `punch-buyer ...` and
`punch-provider ...`, or use the equivalent `punch buyer ...` and
`punch provider ...` forwarding forms. Exit codes are preserved. Autonomous
use must follow the separate custody, approval, retry, and state rules in the
[Punch agent runbook](AGENT_RUNBOOK.md); it must not answer the human home's
interactive prompts.

## Preview.19 interactive Provider onboarding contract

> **Published contract.** This flow is bound to the matching non-draft
> Preview.19.1 archive and `SHA256SUMS`; it cannot be installed from this source
> checkout or inferred from another preview.

The Preview.18 interactive Provider onboarding contract is carried forward
here and extended for Preview.19; this source page alone is not installable.

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
   `WAITING_FOR_INVITE` and preserves that state across relaunch. Following
   supervised approval, signed status may advance to `INVITE_READY`. The home
   then imports only the owner-delivered, mode-`0600` one-time invitation and
   resumes the same identity and request; status never carries the invitation
   secret, and no server handoff or placeholder flags have to be inferred.
5. **Automatic setup through listing.** After invitation confirmation, the CLI
   resumes the authenticated join, uses trusted Control-derived configuration,
   completes NetBird enrollment, generates local config, installs and validates
   the service with approval for consequential local changes, validates the
   selected capacity, and activates the bounded offer through `LISTED`.
6. **One status and recovery surface.** Subsequent interactive homes show the
   Provider and onboarding state, offer/listing state, orders and contracts,
   selected capacity, service health, and a clear recovery action when work is
   required.


## Preview.19 resource and marketplace choices

The Provider chooses bounded CPU, RAM, quota-backed workspace disk, and zero or
more GPUs with exact UUID/CDI identities. The signed snapshot also records the
pinned researcher image and `NONE` or `RESEARCH_EGRESS` outbound policy. The
Buyer sees capacity and the fixed or ranged duration before confirming an order.

`resales`, `resale-create`, `resale-claim`, `resale-cancel`,
`extension-exercise`, `extension-propose`, `extension-inbox`,
`extension-accept`, and `extension-reject` preserve the same owner gates,
idempotency rules, and zero-settlement boundary.
