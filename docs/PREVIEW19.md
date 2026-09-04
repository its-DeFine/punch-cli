# Punch Preview.19.1

Preview.19.1 is the corrected public packaging revision of the Preview.19
zero-price resource and lifecycle contract for the Punch Compute pilot.
Providers offer bounded CPU, RAM, quota-backed workspace disk, and optional GPU
capacity; Buyers can order, use, extend, transfer, and stop that capacity.
Payment settlement is disabled for this preview.

## Release binding

This public closure is paired with release-builder source commit
`95b529135133253a3395bfa61e2402f14631379e`, tree
`e7fb2148499f5f82ac96da7a83182aaf5387fa90`, and release
`0.1.0-preview.19.1`. It contains public launchers, documentation, Provider
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

## Proof boundary

Source checks, released-archive checks, and live Provider-to-Buyer proof are
separate claims. This source closure does not claim live AWS Control readiness,
payment settlement, arbitrary networking, or general availability.
