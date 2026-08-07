# Preview.12 guided Punch home and agent contract

> **GATED_UNRELEASED:** `v0.1.0-preview.12` is not installable until GitHub
> publishes a non-draft Linux/x64 prerelease with the matching archive and
> `SHA256SUMS` asset.

Preview.12 adds a continuous, state-aware `punch` home on top of the existing
Buyer and Provider commands. It does not change Control lifecycle semantics,
offer eligibility, invitation authority, NetBird policy, payment behavior, or
the direct non-interactive command surface inherited from Preview.11.

## Human guided flow

- First launch selects Buyer or Provider and guides the existing join boundary.
- A joined Buyer can inspect eligible offers, review full offer details, confirm
  an order, select an existing Ed25519 key or explicitly generate a protected
  local key, and then use status, connect, stop, orders, and profile actions.
- A joined Provider can use the existing setup/adoption, machine status,
  offer-status, offer-unlist, and offer-retire commands. The accepted-contract
  and terminal-retirement guardrails are unchanged.
- Later launches return to the relevant state-aware home; this is not a
  one-shot setup wizard.

The home stores only owner-controlled local profile data and key paths. It does
not read or print SSH private keys. Privileged NetBird installation remains an
explicit confirmation, and unsupported platforms fail closed.

## Automation contract

Scripts and agents keep using `punch buyer ... --json` and
`punch provider ... --json` (or the direct role binaries). The dedicated
[agent runbook](AGENT_RUNBOOK.md) binds allowed commands to required reads,
approval and custody boundaries, exact retry keys, expected states, and
terminal cleanup. An autonomous agent must not answer the interactive home's
prompts.

## Compatibility and proof boundary

Preview.12 remains Linux/x64, invitation-only, owner-targeted `$0`, and
supervised. Payment settlement, payouts, refunds, public free offers, and
self-service Provider onboarding remain disabled.

Focused guided-CLI tests exercise the human navigation layer against the
existing role commands. A disposable autonomous acceptance separately proves
the direct Buyer and Provider command path, approval denials, idempotent
retries, guardrails, and terminal cleanup. Preview.11's accepted NetBird/SSH
data-plane proof remains the separate network seam; it does not prove this
candidate's guided UI network path. Exact Preview.12 archive acceptance remains
pending until the release candidate archive is built and verified.

The machine-readable [Preview.12 runtime contract](preview12-runtime-contract.json)
binds the exact private release source, immutable images, and these unchanged
pilot boundaries.
