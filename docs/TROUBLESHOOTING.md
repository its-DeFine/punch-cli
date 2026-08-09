# Troubleshooting

> **Version boundary:** this page describes the published Preview.17 Linux/x64
> prerelease. Use recovery commands only from its exact non-draft archive after
> verifying the same-release checksum.

## Guided onboarding is waiting

`WAITING_FOR_INVITE` is a normal durable Preview.17 Provider state, not a
failure. Preserve the local identity and onboarding request, then resume the
same `punch` → **Provider** flow when the separately approved invitation
arrives. Do not create another identity or request, guess an invitation, or
switch to raw flags to bypass the approval boundary.

`INVITE_READY` means supervised approval has completed; it does not carry the
invitation secret. Keep the owner-delivered one-time invitation as an owned
mode-`0600` file and let the same guided home import it. If that file is absent
or insecure, preserve state and correct only its custody instead of creating a
replacement identity or request.

## Invitation or setup rejected

- Confirm that the invitation matches the Buyer or Provider role.
- For a Provider, confirm that `identity-init` created the public onboarding
  packet before invitation issuance and that the invitation is bound to the
  same machine identity.
- Confirm that secret files are mode `0600` inside mode-`0700` directories.
- Preserve the same machine identity, credential path, state directory, and
  operation reference.
- Do not delete state, generate a replacement reference, or retry a consumed
  invitation to bypass the rejection.
- Return only the sanitized public error code to the Punch operator.

## Buyer join dependency authorization stopped

After guided Buyer join confirmation, Preview.17 first probes `sudo -n true`.
If that capability is unavailable, it falls back to interactive `sudo -v`.
Failed authorization leaves dependency installation and join unstarted; correct
sudo access and resume the same invitation and local Buyer state. Direct
non-interactive join still requires `--yes` and cached `sudo`.

## Provider setup stopped

Preview.17 setup errors include a sanitized `stage` and `retryable` decision.
Preserve the exact machine identity, state directory, credential, generated
config, and `--idempotency-key`, correct that stage, and retry the same setup.
Do not begin another setup merely because NetBird, image pulling, systemd, or
the first heartbeat was slow.

- `DOCTOR` or `DEPENDENCY_INSTALL`: review `doctor --json`. Dependency changes
  require `--install-dependencies` plus explicit confirmation. Guided TTY setup
  probes `sudo -n true` before falling back to interactive `sudo -v` and
  continues in the same session. Direct non-interactive setup requires cached
  `sudo`; refresh it through the normal operator channel and retry the same
  setup reference. Punch does not replace conflicting versions silently.
- `READINESS_AND_SETUP`: verify immutable registry access and the exact
  advertised GPU/CDI if applicable. Setup's real container/SSH/cleanup canary
  must pass before listing.
- `NETBIRD_ENROLLMENT`: do not paste a setup key or create a dashboard peer.
  Rerun the same setup so Punch can reconcile the one-use bound enrollment.
- `CONFIG_GENERATION`, `SERVICE_START`, `SERVICE_HEARTBEAT`, or
  `OFFER_ACTIVATION`: preserve generated files and inspect
  `service-status`/`service-logs`; retry only when the error is marked
  retryable.

The Buyer, window, offer, zero price, and authorization come from authenticated
Control. Manual `--agent-config`, `--price-minor`,
`--targeted-zero-authorization-id`, or `--targeted-buyer-actor-id` entry is not
the normal recovery path and cannot widen a mismatched binding.

## Public endpoint unavailable

Confirm that `https://api-punch.embody.zone` is reachable over HTTPS. Do not
replace it with a Provider IP, database address, local gateway, or
container-runtime endpoint.

## Order response timed out

Retry the exact order using the same `--order-ref`. The Preview.17 CLI first
reconciles that reference, so an interrupted response does not authorize a
second order or reservation.

## Provider cannot access Docker

Do not expose Docker over TCP or add an unreviewed root helper. Verify the local
Unix-socket access required by the reviewed service user. Stop if least
privilege cannot be maintained.

## Provider service is not ready

Successful setup owns systemd installation and startup. Check only the
machine-scoped service:

```bash
punch-provider service-status --machine-id MACHINE_ID --json
punch-provider service-logs --machine-id MACHINE_ID --lines 80 --json
```

Use `service-start --yes` only after reviewing the consequence. `serve` is a
foreground diagnostic mode; replacing the supervised service with a manual
long-running shell is not normal Preview.17 recovery.

## NetBird or brokered SSH is not ready

- Confirm the Buyer config contains `"netBirdGateway": true`.
- On Linux/x64, rerun the exact same `join` invitation. If the official NetBird
  client is missing, approve the explained install or use `--yes` only when the
  same privileged change has already been reviewed. Join reconciles the stored
  attempt until the exact Buyer/NetBird binding is proven; do not request a
  second Buyer or enrollment.
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

Preview.17 uses owner-targeted zero-price offers. Payment, settlement, payout,
refunds, and paid offer economics were not activated or accepted by this
release. Do not infer financial behavior from the lifecycle result.

## Safe support bundle

Remove invitations, sessions, credentials, private keys, Provider addresses,
NetBird tokens/setup keys, workload content, and environment variables. Prefer
the CLI version, operating system, architecture, correlation/task ID,
lifecycle phase, elapsed time, retryable/terminal classification, and sanitized
public error code.
