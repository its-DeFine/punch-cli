# Executable public-docs boundary

## Status

The executable Provider/Buyer walkthrough is `GATED_UNRELEASED`. This public
checkout contains only structural formats, deterministic validators, and
sanitized fixture tests. It does not contain a trusted runtime artifact,
private contract handoff, credentials, routes, identities, or live proof.

The generated CLI reference is valid only when an exact runtime-artifact
contract is bound to a reviewed trust-registry entry. A generated contract is
never authority by itself. The binding must match the contract, source, and
entrypoint digests and a fixed interpreter and execution path; dirty, hidden,
ambiguous, substituted, or changed inputs fail closed.

The public format descriptions are [CLI contract](schemas/public-cli-contract-format.v1.json),
[artifact trust registry](schemas/public-artifact-trust-registry.v1.json),
[runtime-artifact binding](schemas/runtime-artifact-binding-format.v1.json), and
[sanitized execution report](schemas/sanitized-execution-report.v1.json). They
describe validation structure, not released command flags.

The exact next-contract reference is [generated here](NEXT_COMMAND_REFERENCE.md).

## Next public contract

The next gated contract includes an explicit Buyer `stop` operation as part of
the public lifecycle. Provider `setup` creates the offer; there is no new
Provider `offer` verb. Exact flags and syntax remain handoff-dependent and
must be generated from the reviewed sanitized private contract, not guessed
from this document.

The required `punch.disposable-pov-report.v1` keeps Provider, Buyer-A, and
Buyer-B environments distinct, uses `UTC+MONOTONIC` timing, captures no input,
keeps child output sanitized in memory, and records 17 steps with 14 required
public child receipts. Its first step records the artifact checksum/install
boundary; installer/uninstaller behavior is proven separately by this
repository's public validation. The remaining steps cover setup-as-offer, discovery, order,
status, brokered SSH with a harmless command, identical retry, successful
stop, post-stop rejection, signed cleanup, lease release, and relay-zero
outcomes. The report verifier is a parser and proof-boundary check only; it is
not a second runtime executor.

Proof labels remain distinct: `LOCAL_DETERMINISTIC_PASS`,
`RUNTIME_ARTIFACT_BOUND_PASS`, `NO_COACHING_E2E_PASS`, `LIVE_E2E_PROVEN`, and
`GATED_UNRELEASED`. No label is inferred from a nearby artifact or UI state.
