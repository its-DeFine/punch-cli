# Punch Preview.19.2

Preview.19.2 is the corrected public packaging revision of the Preview.19
zero-price resource and lifecycle contract for the Punch Compute pilot.
Providers offer bounded CPU, RAM, quota-backed workspace disk, and optional GPU
capacity; Buyers can order, use, extend, transfer, and stop that capacity.
Payment settlement is disabled for this preview.

## Release binding

This page describes the Preview.19.2 public release-bound artifact. The final
Linux/x64 archive used for scoped acceptance is bound to runtime source
`9d7e73f`, public packaging source `77cd9f5`, and archive SHA-256
`689ab42998509b5335663d174b616fc76a42022380529e2a3c0e08345f5ec8b3`; verify
that exact archive against the matching same-release `SHA256SUMS` before
installation. The archive's `RELEASE-CONTRACT.json` and
`RELEASE-BINDING.json` carry the complete release binding. This page does not duplicate a commit
or tree, or private runtime identifier beyond these short release references.

The release archive contains public launchers, documentation, Provider
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

Multiple simultaneous contracts on one machine share the configured gateway
port but have separate workload bindings and SSH keys. Use the matching
Preview.19.2 Linux/x64 archive on both Buyer and Provider for this path;
contract selection is automatic in `punch-buyer ssh`. Stopping one contract
must not interrupt another.

Scoped live acceptance of the final archive passed on Ubuntu 24.04 LTS for the
invitation-only, zero-price path: two same-machine concurrent jobs each using
1 CPU, 1 GiB RAM, and 4 GiB workspace disk ran within the 9 GiB budget.
Per-contract SSH markers remained isolated; a direct connection with the wrong
Buyer key and cross-contract status/stop attempts were denied. Stopping
contract A preserved contract B's held SSH session, and stopping B then closed
that session. In this run, Control reported 26 terminal contracts, 26 released
reservations, and 22 access-fenced records; two approved Buyers, zero Provider
containers, no `22222` listener, and an exact XFS project hard limit of zero.
The results are run-scoped acceptance evidence, not a statistical 100% claim.

## Proof boundary

Source checks, released-archive checks, and live Provider-to-Buyer proof remain
separate claims. The measured acceptance above is limited to the Ubuntu 24.04
LTS invitation-only, zero-price path; it does not claim paid settlement,
arbitrary networking, broad GPU coverage, or general availability.
