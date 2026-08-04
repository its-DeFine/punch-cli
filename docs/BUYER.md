# Buyer guide

The Buyer CLI is `punch-buyer`. The preview configuration below points it to the official public Punch HTTPS address. The CLI sends the Buyer session to the configured HTTPS origin, so changing that origin is a security-sensitive trust decision.

> **Current command and proof boundary:** the available Buyer CLI schema exposes
> `join`, `offers`, `order`, `status`, `output`, and `ssh` only. There is no
> released Buyer `stop` or `cancel` command. Until a non-draft release archive
> and checksum are published, this is a candidate workflow, not proof of a
> downloadable package, an external Provider/Buyer run, or testnet/real-USDC
> settlement.

The next gated public-safe stop contract is documented in
[PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md](PUNCH_PUBLIC_SAFE_ASYNC_STOP_CONTRACT_20260804.md).
It is source-derived from the manager-approved private handoff and does not
change the current released command surface by itself.

## 1. Prepare private configuration

Create a private directory:

```bash
install -d -m 0700 "$HOME/.config/punch/buyer"
```

Create `buyer.json` with the public origin and an absolute session-file path:

```json
{
  "schemaVersion": "punch.buyer-public-config.v1",
  "publicOrigin": "https://api-punch.embody.zone",
  "sessionFile": "/absolute/path/.config/punch/buyer/session.json"
}
```

Protect both the directory and configuration file:

```bash
chmod 0700 "$HOME/.config/punch/buyer"
chmod 0600 "$HOME/.config/punch/buyer/buyer.json"
chmod 0600 /absolute/path/to/buyer-invitation.json
```

## 2. Join

```bash
punch-buyer join \
  --config /absolute/path/.config/punch/buyer/buyer.json \
  --invitation /absolute/path/to/buyer-invitation.json \
  --json
```

The CLI stores the resulting session reference in the configured private path. Do not move or edit it manually.

## 3. List offers

```bash
punch-buyer offers \
  --config /absolute/path/.config/punch/buyer/buyer.json \
  --json
```

## 4. Order compute

Choose a unique order reference and preserve it. If a request times out, retry only with the identical reference.

```bash
punch-buyer order \
  --config /absolute/path/.config/punch/buyer/buyer.json \
  --offer-id OFFER_ID \
  --order-ref YOUR_UNIQUE_ORDER_REFERENCE \
  --json
```

For brokered SSH access, bind an Ed25519 public key when ordering:

```bash
punch-buyer order \
  --config /absolute/path/.config/punch/buyer/buyer.json \
  --offer-id OFFER_ID \
  --order-ref YOUR_UNIQUE_ORDER_REFERENCE \
  --ssh-public-key-file /absolute/path/to/id_ed25519.pub \
  --json
```

To request one of several acceptable hardware bundles, use one conditional
request file instead of `--offer-id`:

```bash
punch-buyer order \
  --config /absolute/path/.config/punch/buyer/buyer.json \
  --request-file /absolute/path/conditional-order.json \
  --order-ref YOUR_UNIQUE_ORDER_REFERENCE \
  --ssh-public-key-file /absolute/path/to/id_ed25519.pub \
  --json
```

Punch selects at most one complete alternative atomically. This is an immediate
match, not an unfunded standing queue. See [Conditional orders](CONDITIONAL_ORDERS.md).

Record the job identifier returned by the order result. A successful order does
not itself prove that access is ready, that a container is running, or that a
payment has settled.

## 5. Status

```bash
punch-buyer status \
  --config /absolute/path/.config/punch/buyer/buyer.json \
  --job-id JOB_ID \
  --json
```

The preview lifecycle records paid time from the first verified `READY`, not from offer listing or container preparation. The offer and the applicable commercial terms control actual price, charges, cancellation, and refund rights.

For interactive jobs, wait until status reports `state: ACCESS_SCHEDULED` and
`accessEffective: true` before opening SSH. Do not bypass this check with a
Provider address or direct container connection.

## 6. Brokered SSH

`punch-buyer ssh` is a byte-stream proxy for OpenSSH's `ProxyCommand`; it is not an interactive terminal by itself. Use the same private key whose public half was bound to the order, a job-specific private known-hosts file, and the fixed container user `punch`:

```bash
install -d -m 0700 "$HOME/.config/punch/buyer/known-hosts"

ssh -i /absolute/path/to/id_ed25519 \
  -o IdentitiesOnly=yes \
  -o 'ProxyCommand=punch-buyer ssh --config /absolute/path/.config/punch/buyer/buyer.json --job JOB_ID' \
  -o UserKnownHostsFile=/absolute/path/.config/punch/buyer/known-hosts/JOB_ID \
  -o StrictHostKeyChecking=accept-new \
  punch@punch-job
```

The isolated known-hosts file records the ephemeral job container key on first connection. If it changes during the same job generation, stop instead of accepting the replacement. The byte stream is brokered through Punch; the Buyer is not given the provider address or Docker socket.

## 7. Asynchronous Buyer stop (next gated contract)

For an artifact that explicitly carries the approved async-stop contract, use:

```bash
punch-buyer stop \
  --config /absolute/path/.config/punch/buyer/buyer.json \
  --job JOB_ID \
  --json
```

The CLI submits the exact empty-body POST once. The server performs compact
authentication/ownership/eligibility and relay validation, writes a durable
`PREPARED` journal intent, then immediately returns `202 ACCEPTANCE_PENDING`
and enqueues canonical lifecycle acceptance. The CLI waits for `retryAfterMs`
and polls the same Buyer-bound GET route to terminal success or definitive
sanitized failure. Exact retries use the same authenticated Buyer/job-bound
idempotency key; the CLI does not create a new idempotency token or use an
admin/Provider fallback. A `202` stop operation never surfaces an ambiguous
`BUYER_STOP_TIMEOUT`.

GET with no prior journal entry returns `404` and never creates stop intent. GET
with a `PREPARED` entry may resume the same canonical acceptance and immediately
returns `202 ACCEPTANCE_PENDING`; a lost response or restart uses the same
Buyer/job binding. An `IN_PROGRESS` `PROVIDER_CLEANUP` projection may report
`cleanupState: "PENDING"`; terminal success reports `cleanupState: "RELEASED"`.

Each stop HTTP request has a 10-second bound and the full reconciliation has a
300-second deadline. If the initial POST is ambiguous (`524` or local timeout),
poll GET first: continue a found operation, and retry the exact same POST `{}`
only after a sanitized GET `404`. Ambiguous repeated retries remain bounded
with sanitized retry/backoff; malformed or rebound projections fail closed as
`BUYER_PROTOCOL_INVALID`. A `503` projection timeout is a generic retryable
error outside `punch.buyer-stop-operation.v1`, not an operation result.

## 8. Ending only the local SSH connection

Use `exit`, close the OpenSSH client, or interrupt the local SSH process only to
end that local connection. None of those actions calls a Punch job-stop or
cancellation operation, releases capacity, or determines paid time. Do not
invent an HTTP route, connect directly to a Provider, or infer a `punch-buyer
stop` command from an internal test.

The exact-runtime/private canary may exercise Control-owned terminal cleanup and
Provider `STOP` work after its own terminal conditions. That is evidence only
for that controlled canary; it is not a current public Buyer CLI behavior. Use
`punch-buyer status` to observe the documented job state and follow a separately
published support or commercial process for any early-termination question.

## 9. Download output

```bash
punch-buyer output \
  --config /absolute/path/.config/punch/buyer/buyer.json \
  --job-id JOB_ID \
  --task-id TASK_ID \
  --output /absolute/path/to/output.mkv \
  --json
```

The CLI validates the bounded response and content digest before committing the output file.
