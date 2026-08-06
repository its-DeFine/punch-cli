# Troubleshooting

> **Version boundary:** this page applies to `v0.1.0-preview.10` when its
> non-draft prerelease archive and checksum are published for Linux/x64.

## Invitation or setup rejected

- Confirm that the invitation matches the Buyer or Provider role.
- Confirm that secret files are mode `0600` inside mode-`0700` directories.
- Preserve the same machine identity, credential path, state directory, and
  operation reference.
- Do not delete state, generate a replacement reference, or retry a consumed
  invitation to bypass the rejection.
- Return only the sanitized public error code to the Punch operator.

## Targeted-zero setup rejected

Preview.9 requires `--price-minor 0`,
`--targeted-zero-authorization-id`, and `--targeted-buyer-actor-id` together.
The authorization must be unexpired, unused, and bound by the operator to the
same Provider, machine, capacity, window, and designated Buyer. The Provider
cannot mint or widen it.

## Public endpoint unavailable

Confirm that `https://api-punch.embody.zone` is reachable over HTTPS. Do not
replace it with a Provider IP, database address, local gateway, or
container-runtime endpoint.

## Order response timed out

Retry the exact order using the same `--order-ref`. The Preview.9 CLI first
reconciles that reference, so an interrupted response does not authorize a
second order or reservation.

## Provider cannot access Docker

Do not expose Docker over TCP or add an unreviewed root helper. Verify the local
Unix-socket access required by the reviewed service user. Stop if least
privilege cannot be maintained.

## NetBird or brokered SSH is not ready

- Confirm the Buyer config contains `"netBirdGateway": true`.
- On Linux/x64, rerun the exact same `join` invitation. If the official NetBird
  client is missing, approve the explained install or use `--yes` only when the
  same privileged change has already been reviewed.
- Do not request, paste, or store a NetBird setup key and do not use a NetBird
  dashboard workaround. Punch issues one one-off enrollment after Buyer auth.
- `NETBIRD_PLATFORM_UNSUPPORTED`, declined install, enrollment rejection, or an
  uncertain enrollment fails closed; return only the sanitized error code.
- Confirm there is no default full-mesh policy.
- Wait for Buyer status `state: ACTIVE` and `accessEffective: true`.
- Use the same private key whose public half was attached to the order.
- Do not expose host SSH, publish a container port, disable host-key checking,
  or bypass Punch with a Provider address.

The Punch gateway uses Provider TCP `22222` only on the NetBird overlay. It does
not use NetBird's host-SSH feature.

## OpenSSH closed but the job is still active

`exit`, a disconnected SSH client, or an interrupted `punch-buyer ssh` process
ends only that local connection. Run:

```bash
punch-buyer stop --config /absolute/path/to/buyer.json --job JOB_ID --json
```

The CLI reconciles the durable stop operation. An exact retry is safe. Terminal
success requires access revocation and released cleanup; a fresh SSH connection
must be rejected.

## Payment or refund question

Preview.10 uses owner-targeted zero-price offers. Payment, settlement, payout,
refunds, and paid offer economics were not activated or accepted by this
release. Do not infer financial behavior from the lifecycle result.

## Safe support bundle

Remove invitations, sessions, credentials, private keys, Provider addresses,
NetBird tokens/setup keys, workload content, and environment variables. Prefer
the CLI version, operating system, architecture, correlation/task ID,
lifecycle phase, elapsed time, retryable/terminal classification, and sanitized
public error code.
