# Executable public-docs boundary

## Status

This source-derived executable-docs framework remains `GATED_UNRELEASED` and
non-authoritative. It is preserved as the deterministic pre-release contract
mechanism. The separately released Preview.9 surface and live-proof boundary
are governed by [PREVIEW9.md](PREVIEW9.md) and its runtime contract; this page
does not override them.

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
The approved asynchronous stop projection is documented in
[the public-safe stop contract](PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md)
and its [operation schema](schemas/buyer-stop-operation.v1.json).

## Historical generated contract

The generated contract introduced the Buyer `stop` operation now carried by
Preview.9. Provider `setup` creates the offer; there is no new Provider `offer`
verb. The generated file remains non-release evidence and is kept to detect
source/docs drift.

The approved stop handoff makes the operation asynchronous: POST writes a
durable `PREPARED` journal intent and immediately returns `202 ACCEPTANCE_PENDING`;
canonical lifecycle acceptance runs in the background.
The CLI polls the Buyer-bound GET route using `retryAfterMs`; GET without a
prior journal is a non-mutative `404`, while GET with `PREPARED` may resume the
same operation. `200` is terminal success after cleanup and capacity release;
`409` is a definitive sanitized terminal failure. A `202` stop operation does
not become `BUYER_STOP_TIMEOUT`. `503` is a generic retryable projection
timeout outside `punch.buyer-stop-operation.v1`, reserved for failure before the
durable intent can begin. An `IN_PROGRESS` `PROVIDER_CLEANUP` projection may use
`cleanupState: "PENDING"`; terminal success uses `"RELEASED"`.
An exact retry returns the same operation ID instead of creating another stop.
The server's compact Buyer/job projection has a bounded 30-second deadline; a
slower read fails retryably without claiming a new operation or unknown
terminal outcome. CLI request attempts remain bounded to 10 seconds within a
300-second overall reconciliation deadline. After an ambiguous POST `524` or
local timeout, GET is polled first; only sanitized GET `404` permits retrying
the identical POST. Malformed or rebound projections fail closed as
`BUYER_PROTOCOL_INVALID`.

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
