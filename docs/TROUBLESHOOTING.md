# Troubleshooting

> **Version boundary:** the `rejoin` and USDC-cent setup guidance on this page
> applies to the published `v0.1.0-preview.5` package.

## Invitation rejected

- Confirm that the invitation matches the command role.
- Confirm that the file is mode `0600` inside a mode-`0700` directory.
- Do not retry an invitation already redeemed by another machine or user.
- If exposure is possible, stop and request revocation rather than testing the secret repeatedly.

## Provider setup requires rejoin

`PROVIDER_REJOIN_REQUIRED` means the current Provider session cannot renew for
setup, normally because it expired before the first machine enrollment. Keep
the machine identity, credential path, state directory, and original setup
reference. Request one fresh replacement Provider invitation, run
`punch-provider rejoin`, and retry that exact setup reference. Do not delete
local files, create a new machine ID, or retry the consumed invitation.

`rejoin` is only for a Provider that has not yet enrolled its machine. An
already enrolled resident Provider renews through its machine credential; do
not request or use an invitation to bypass that proof. If an enrolled `serve`
process reports a renewal failure, preserve its credential, machine identity,
renewal journal, and setup state, stop retrying, and contact Punch support with
the public error code.

## Provider price looks incorrect

The public setup flag is `--price-usdc-cents`, and it prices the complete
`--window-seconds` interval. `--window-seconds 3600 --price-usdc-cents 34`
means USD 0.34 for one hour. Do not pass six-decimal USDC base units to this
flag.

## Interactive preflight reports missing userns

`LIVEPEER_OPS` setup, validation, and bounded non-interactive workloads may
continue without userns remapping. `SABLIER_USDC` setup and interactive
brokered SSH remain unavailable until a reviewed maintenance procedure enables
userns and the complete Docker security preflight passes. Do not make an
unscheduled Docker storage migration on a shared host.

## Public endpoint unavailable

Confirm that `https://api-punch.embody.zone` is reachable over HTTPS. Do not replace it with a Provider IP, database address, local gateway, or container-runtime endpoint.

## Order response timed out

Retry the exact order using the same `--order-ref`. A timeout does not prove that the server failed to commit the order. Creating a new reference can create a second request.

## Provider inventory is smaller than expected

Punch reports resources visible and safely allocatable on the local execution node, not every physical resource in the wider machine or hypervisor. GPU inventory is optional and uses stable UUID/CDI identity.

## Provider cannot access Docker

Do not expose Docker over TCP or add an unreviewed root helper. Verify the release's documented local Unix-socket service setup. If it cannot be satisfied with least privilege, stop and contact Punch support.

## Job is not billable yet

An offer, reservation, prepared container, or running process does not alone start paid time. Paid time starts only when Punch verifies `READY`.

## Brokered SSH is not ready

Check `punch-buyer status` for `state: ACCESS_SCHEDULED` and
`accessEffective: true`, confirm the order was bound to the matching Ed25519
public key, and keep the job-specific known-hosts file. Do not substitute a
Provider IP, publish a container port, expose Docker, or disable host-key
checking to bypass a readiness or identity failure.

## Safe support bundle

Before sharing diagnostics, remove invitations, session or credential files, private keys, provider addresses, workload content, and environment variables. Prefer command version, operating system, architecture, public error code, and a synthetic reproduction.
