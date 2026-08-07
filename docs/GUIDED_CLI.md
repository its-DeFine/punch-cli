# Guided `punch` home

> **Release boundary:** this page documents the gated Preview.12 candidate. It
> is not installable until the exact Preview.12 archive and checksum are
> published in a non-draft prerelease.

Run `punch` in a terminal to open the interactive home. It is a continuous,
local navigation layer over the existing role commands, not a one-time setup
wizard. Every later launch reads only the owner-controlled local Punch profile
and the authenticated status of jobs created from that profile.

- Before join, the home offers the existing Buyer or Provider join flow.
- A joined Buyer sees offers, local orders, profile information, and direct
  status/connect/stop actions for locally recorded active contracts.
- A joined Provider without a locally recorded offer sees setup or may record
  an existing owned offer ID locally; after that, the home shows the existing
  machine status, offer status, unlist, and retire actions.

The Buyer reviews the complete selected offer before confirming an order. The
home can select an existing owned Ed25519 key pair or, with explicit approval,
create a protected local key. It stores only key paths; it never reads or
prints the private key. A stable order reference is written locally before the
order request, so an ambiguous response can be retried with the same reference.

Buyer join preserves the documented NetBird bootstrap. If NetBird is missing,
the home explains the privileged install step and asks for confirmation; it
does not hide sudo, create a second enrollment code, or bypass a failed setup.

For scripts and automation, keep using `punch-buyer ...` and
`punch-provider ...`, or use the equivalent `punch buyer ...` and
`punch provider ...` forwarding forms. Exit codes are preserved. Autonomous
use must follow the separate custody, approval, retry, and state rules in the
[Punch agent runbook](AGENT_RUNBOOK.md); it must not answer the human home's
interactive prompts.
