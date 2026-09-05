# Punch Preview.19.2

Preview.19.2 is the corrected public packaging revision of the Preview.19
zero-price resource and lifecycle contract for the Punch Compute pilot.
Providers offer bounded CPU, RAM, quota-backed workspace disk, and optional GPU
capacity; Buyers can order, use, extend, transfer, and stop that capacity.
Payment settlement is disabled for this preview.

## Release binding

This page describes the Preview.19.2 public contract. For each candidate or
release archive, the exact runtime source, public packaging source, archive
digest, and release binding are carried by its bundled
`RELEASE-CONTRACT.json` and `RELEASE-BINDING.json`; verify the exact archive
against the matching same-release `SHA256SUMS` before installation. This page
does not duplicate a commit, tree, or private runtime identifier; do not infer
release identity from prose here.

A matching archive contains public launchers, documentation, Provider
configuration, and the reviewed Provider-host substrate package. It does not
contain proprietary runtime source, credentials, invitations, or host
addresses.

## Terms

- Public and targeted offers are exactly zero-price (`priceMinor: 0`); no
  payment, wallet, settlement, or refund action is enabled.
- Provider onboarding is supervised: public packet, operator approval, and a
  single-use invitation. A Provider cannot approve itself or widen authority.
- Buyers use the contract-scoped NetBird gateway and never receive a Provider
  address, Docker socket, or host credential.
- The signed `punch.resource-snapshot.v2` binds CPU, RAM, quota workspace,
  GPU UUID/CDI identities, immutable researcher image, and `NONE` or
  `RESEARCH_EGRESS` network policy. The snapshot is checked before start.
- Duration is fixed or ranged, at most 31,536,000 seconds. Extensions are
  bounded, idempotent, and zero-price. Transfer is explicit: clean
  reprovision or experimental stateful mode.

The complete v2 Provider/Buyer command names are in
`docs/preview19-runtime-contract.json`; use the matching archive's `--help`
output for exact flags. Setup-generated Provider configuration is reused by the
offer lifecycle, and create/unlist/retire manage retry identities automatically.
Provider offer lifecycle is append-only and owner-gated. Buyer stop revokes
access and drives cleanup.

With a valid existing Provider identity, a fresh CLI may recover a stale failed
`PENDING` renewal only after authenticated Control proves that the prior request
is expired and `UNCOMMITTED`. The CLI may refresh the signed proof once
automatically. Never reset the identity. A generic HTTP `401`, an ambiguous
response, or a journal already marked committed is not proof of expiry and must
not trigger refresh; preserve local state and use the authoritative recovery
result.

Multiple simultaneous contracts on one machine share the configured gateway
port but have separate workload bindings and SSH keys. Use the matching
Preview.19.2 Linux/x64 archive on both Buyer and Provider for this path;
contract selection is automatic in `punch-buyer ssh`. Stopping one contract
must not interrupt another.

A prior scoped live acceptance record on Ubuntu 24.04 LTS for the invitation-
only, zero-price CPU path recorded two same-machine concurrent jobs each using
1 CPU, 1 GiB RAM, and 4 GiB workspace disk within the 9 GiB budget.
Per-contract SSH markers remained isolated; a direct connection with the wrong
Buyer key and cross-contract status/stop attempts were denied. Stopping
contract A preserved contract B's held SSH session, and stopping B then closed
that session. In this run, Control reported 26 terminal contracts, 26 released
reservations, and 22 access-fenced records; two approved Buyers, zero Provider
containers, no `22222` listener, and an exact XFS project hard limit of zero.
This historical record is separate from existing-state renewal recovery.
Stateful recovery tests cover an existing identity, retired offer, stale
uncommitted renewal, renewed session, capacity refresh and a new listed offer.
The release notes identify the exact archive and its deployment/live acceptance
receipt. Results are run-scoped evidence, not a statistical 100% claim.

## Proof boundary

Source checks, released-archive checks, and live Provider-to-Buyer proof remain
separate claims. The historical acceptance above is limited to the Ubuntu
24.04 LTS invitation-only, zero-price CPU path and does not establish proof for
actual GPU host capacity, paid settlement, arbitrary networking, or general
availability. Use the matching release notes for its final acceptance status;
do not substitute a different archive's results.
