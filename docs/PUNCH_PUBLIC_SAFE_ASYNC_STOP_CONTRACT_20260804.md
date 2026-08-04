# Public-safe asynchronous Buyer stop contract

Status: `PRIVATE_RUNTIME_CONTRACT_HANDOFF`; immediate durable-acceptance semantics are
source-derived from the corrected handoff. This additive contract is not a deployment,
release, or live Buyer/Provider proof. The current released preview command
reference remains unchanged until a matching runtime artifact is published.

## Buyer command and routes

```text
punch-buyer stop --config ABSOLUTE_PUBLIC_CONFIG --job JOB_ID [--json]

POST /api/v0/buyer/jobs/{jobId}/stop
Authorization header: installed Buyer session
Content-Type: application/json

{}
```

The body is exact and has no caller-supplied idempotency token. The server
binds one durable stop operation to the authenticated Buyer and job. Its
opaque `operationId` and `correlationId` are deterministic for that Buyer/job
pair, so an exact retry never creates a second operation.

The Buyer status/reconcile route is:

```text
GET /api/v0/buyer/jobs/{jobId}/stop
Authorization header: installed Buyer session
```

POST and GET are prompt operation projections/queue operations. GET polling must not depend on synchronous heavy reconciliation. GET may safely nudge
reconciliation, but the CLI polls the same route using the returned
`retryAfterMs` until a terminal response.

## Sanitized operation projections

The immediate POST and a `PREPARED` GET resume use `202` and this shape:

```json
{
  "schemaVersion": "punch.buyer-stop-operation.v1",
  "operationId": "bso_<opaque-sha256-prefix>",
  "correlationId": "bso_<opaque-sha256-prefix>",
  "contractId": "JOB_ID",
  "state": "ACCEPTANCE_PENDING",
  "phase": "ACCEPTANCE",
  "retryable": true,
  "retryAfterMs": 1000
}
```

POST performs only compact authentication, ownership/eligibility, and relay
validation, then atomically prepares the existing `buyer_cli_operations` journal
with command `buyer interactive stop`, the stable Buyer/job idempotency key, and
a strict request digest. Once that durable `PREPARED` intent write succeeds, it
enqueues or joins canonical lifecycle acceptance and returns promptly with
sanitized `202 ACCEPTANCE_PENDING`; it does not await lifecycle acceptance,
relay revocation, session closure, lifecycle finalization, Provider cleanup, or
capacity release. Retryable persistence/control failures leave the journal
`PREPARED`; definitive acceptance validation/state failures complete the same
row with a safe uppercase failure code.

The phases are `ACCEPTANCE`, `ACCESS_REVOCATION`, `LIFECYCLE_FINALIZATION`,
`PROVIDER_CLEANUP`, and `COMPLETED`. An `IN_PROGRESS` projection in
`PROVIDER_CLEANUP` may include `cleanupState: "PENDING"`. Terminal success uses `200`,
`state: "SUCCEEDED"`, `phase: "COMPLETED"`, `retryable: false`, the safe
`lifecycleState`, `resolution`, and `cleanupState: "RELEASED"`. A lifecycle
`FAILED` state with the Buyer-stop resolution is still a successful Buyer stop
outcome and is not a Provider-fault attribution.

Definitive terminal failure uses `409`, `state: "FAILED"`,
`phase: "TERMINAL_FAILURE"`, `retryable: false`, and a safe uppercase
`reason` code only. A `202` stop operation never surfaces an ambiguous
`BUYER_STOP_TIMEOUT`; the CLI continues reconciliation or reports the definitive
sanitized failure.

Exact retries preserve the same operation identity and terminal result. A
different request body is `400 VALIDATION_ERROR`. Internal binding conflicts
are `409 IDEMPOTENCY_CONFLICT` without stored requests or snapshots. Unknown
jobs and jobs owned by another Buyer both return `404` with
`{"code":"NOT_FOUND"}` and must not reveal whether the job exists.

## Acceptance boundary

The same Buyer/job-bound idempotency key is joined or retried after a lost
response, including after restart, and can create only one durable stop. A `503` is
reserved for failure to obtain the authenticated compact projection
before the durable intent can begin. It is a generic retryable projection
timeout outside `punch.buyer-stop-operation.v1`, never an operation projection
or terminal result. Once `PREPARED` exists, the operation is reconciled through
the same journal and binding.

## Status/reconcile journal boundary

If the exact `buyer_cli_operations` journal entry is absent, GET returns
fail-closed `404` and never creates stop intent, even when the Buyer owns the
job. If the entry is `PREPARED`, GET may re-enqueue the same stable-key
canonical acceptance after a lost response or restart and immediately returns
`202 ACCEPTANCE_PENDING`; it does not await that mutation. If the entry is
`COMPLETED`, GET derives `IN_PROGRESS`, `SUCCEEDED`, or `FAILED` from the
current durable lifecycle projection rather than freezing the acceptance result.

The public response never awaits relay revocation, session closure, lifecycle
finalization, Provider cleanup, or capacity release.

## CLI reconciliation

`stop(jobId)` sends exactly one POST with `{}` and validates the returned
operation projection, including stable `operationId`, `correlationId`, and
`contractId`. For `202 ACCEPTANCE_PENDING` or `202 IN_PROGRESS`, it waits the
bounded `retryAfterMs` and polls the same Buyer-bound GET route until `200
SUCCEEDED` or definitive `409 FAILED`; every response retains the original
operation and contract binding. Each stop HTTP request has a 10-second bound,
separate from the 300-second overall reconciliation deadline.

If the initial POST is transport-ambiguous (`524` or local timeout), the CLI
reconciles with GET first. A found operation is continued; only a sanitized GET
`404` permits retrying the exact same POST `{}`. Ambiguous repeated retries
remain in bounded reconciliation with sanitized retry/backoff and never become
a definitive `NOT_FOUND`. A normal first-POST `404` remains sanitized
`NOT_FOUND`; malformed or rebound projections fail closed as
`BUYER_PROTOCOL_INVALID`.

## Security and reconciliation order

The durable Buyer-stop intent is recorded before asynchronous work and denies
new relay-ticket issuance immediately. Reconciliation performs access
revocation first, closes remaining transport sessions, then finalizes the
Buyer lifecycle stop and performs signed Provider cleanup. Replays after a
lost response or restart use the same Buyer/job-bound keys and idempotent relay
tombstones; they do not duplicate lifecycle mutation, relay revocation,
Provider cleanup, or capacity release.

All public bodies and control events are projections containing only operation
and correlation IDs, job ID, state, phase, retryability, safe reason code,
lifecycle state, resolution, and cleanup state. Never return or log
credentials, ticket secrets, key material, Provider addresses, runtime
sockets, raw errors, raw snapshots, or private filesystem paths. No admin/Provider fallback is compatible with this contract.
