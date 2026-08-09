# Preview.14 Provider reliability gate

> **Status: `PUBLISHED_PRERELEASE`.** Preview.14 is published for Linux/x64 at
> [`v0.1.0-preview.14`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.14).
> Install only the matching archive and same-release `SHA256SUMS`; this page does
> not authorize a source checkout, guessed flag, or an earlier preview command.

Preview.14 is reserved for the minimum Provider-readiness correction identified
by the first external Provider-to-Buyer attempt. Its release may proceed only
after a clean Linux/x64 Provider host proves the real lifecycle:

```text
Provider identity + public onboarding packet
  -> bound invitation + join
  -> explicit dependency consent
  -> immutable image pull + digest verification
  -> host/GPU/CDI validation
  -> interactive container + SSH readiness + stop/clean proof
  -> LISTED
  -> Buyer discovery + explicit order approval
  -> provisioning progress + access-effective connection
  -> Buyer stop + access fence + cleanup + capacity release
```

The Provider must not be listed merely because it joined, reported inventory,
or started a resident process. `LISTED` requires the exact pinned images and
the real local container/SSH cleanup canary for the advertised execution
surface. A failure must identify its stage and a documented recovery action;
it must not silently wait for a Buyer contract to expire.

## Clean-host bootstrap and guided home

The archive installer installs Punch only. The first `punch` launch reads local
authenticated state and presents the appropriate Buyer or Provider home; it
does not implement separate business logic. Guided choices invoke the same
direct commands that scripts and autonomous agents use. The generated command
reference is the only public source of exact command names, flags, JSON shapes,
and automation confirmation behavior.

For a Provider, local identity creation and its public onboarding packet precede
the bound invitation and join. The normal setup operation is one resumable
guided/direct CLI session. Before any
host mutation it displays the dependency plan and requires explicit consent for
supported Linux/x64 dependency installation. Docker, NetBird, or NVIDIA
container-toolkit installation may be offered only when required by the
selected execution surface. Guided TTY use may invoke the visible `sudo` prompt
after consent; direct non-interactive use needs explicit confirmation and a
cached `sudo` authorization. The reviewed Docker boundary requires
`userns-remap=default`; setup preserves unrelated daemon settings, validates the
merged configuration, and restores the prior file if activation fails. Punch
never silently replaces a driver or kernel, reboots the host, or changes
unrelated Docker daemon policy.

Provider setup starts in `PENDING_AGENT` and records identity, dependency,
image, exact-machine, pre-list proof, and supervised-service progress there.
Only a fresh signed pre-list proof and service-readiness confirmation may
advance the offer to `LISTED`. A failed or interrupted setup remains visible and
resumable from its last safe checkpoint; it never creates a duplicate identity,
agent, container, or offer.

The Provider home must show setup phase, readiness, offer state, supervised
service state, last heartbeat, safe last failure, verification result, and the
allowed recovery action. Foreground serving remains a diagnostic mode; the
supervised service is the normal resident mode. Recovery uses the same durable
journal and labelled resource adoption rule as the lifecycle, so a restart
either resumes one owned attempt or reports a safe terminal failure.

Resident recovery is bound to the completed setup baseline and the expected
durable lifecycle task: it fails closed on a drifted or incomplete setup rather
than reconstructing an offer or changing its immutable terms. An authenticated
interactive session ends at its authorized access deadline and cleans up its
exact owned execution; expiry never extends access through recovery.

The machine-readable clean-host evidence format is
[`punch.preview14-clean-host-e2e-report.v1`](schemas/preview14-clean-host-e2e-report.v1.json).
The summary binds the exact bytes of its companion
[`punch.preview14-clean-host-e2e-execution-receipt.v1`](schemas/preview14-clean-host-e2e-execution-receipt.v1.json)
by SHA-256. The companion retains only sanitized correlated assertions for
setup replay, order and restart idempotency, real Buyer SSH, terminal stop
replay, zero-state cleanup, and archive/no-substitution provenance.
The release gate rejects a source CLI, fake Docker/fetch/SSH seam, in-memory
Control substitute, missing archive checksum, incomplete stop fence, or a
report or receipt containing credential/private-host material. Verification
requires both files; this parser is an evidence gate, not a runtime emulator.

The companion
[`punch.preview14-public-command-contract.v1`](schemas/preview14-public-command-contract-format.v1.json)
generates the release-bound Provider and Buyer reference. CI will reject a
changed command/schema contract until its generated reference is updated from
the same bound contract. The command contract additionally binds the exact
archive, `SHA256SUMS`, runtime contract, and canonical packaged command surface.
The checked-in [command-contract template](preview14-public-command-contract.template.json)
records the expected inputs extracted from the candidate help and guided UX,
but keeps every artifact hash explicitly `PENDING_DETERMINISTIC_BUILD`; it is
not release authority. The separate
[bound command contract](preview14-public-command-contract.json) records the
exact archive, sums, runtime contract, and packaged surface used to generate the
[reference](PREVIEW14_COMMAND_REFERENCE.md). Those exact bytes are published in
the non-draft Preview.14 prerelease; any different archive remains unauthorized.

This static v1 binding covers the declared public command, flag, and workflow
surface; it is not exhaustive mechanical semantic/output parity. Exact-artifact
E2E remains the release authority.

The normal Provider sequence is `identity-init`/public packet → bound invitation
→ `join` → `doctor`/`inventory` → `setup`. One `setup` session owns dependency
consent/install, exact image/readiness proof,
`PENDING_AGENT`, bound NetBird enrollment, config generation, systemd,
heartbeat, and `LISTED`. `service-*`, `serve`, and `--agent-config` remain
direct recovery/diagnostic surfaces; they are not extra normal onboarding steps.

Buyer join resumes the same stored attempt until the exact NetBird peer binding
is proven. Punch may supervise multiple approved Providers, each with isolated
identity, offer, capacity, and access bindings. One order selects one eligible
offer; ineligible offers fail closed. The maximum authorized access window is
`259200` seconds.

## Public boundary

- Linux/x64 only unless the exact published archive documents another platform.
- Buyer and Provider retain distinct invitation/identity authority. No secret,
  private key, session, enrollment material, Docker socket, or Provider host
  address belongs in docs or ordinary CLI output.
- Any privileged dependency change requires explicit user confirmation. A
  non-interactive invocation must fail rather than silently changing the host
  unless the exact released command contract documents its confirmation flag.
- The supervised pilot remains invitation-only and owner-targeted `$0` only.
  Payment, settlement, payout, and refund behavior are not an acceptance claim.

## Required release proof

The published archive, its `SHA256SUMS` line, the generated command reference,
the exact private runtime binding, and a clean-host report must agree on one
Preview.14 release. Unit tests, a package smoke, a source checkout, and an
in-memory fixture are valuable regression evidence but do not substitute for
this clean-host lifecycle acceptance.
