# Troubleshooting

## Invitation rejected

- Confirm that the invitation matches the command role.
- Confirm that the file is mode `0600` inside a mode-`0700` directory.
- Do not retry an invitation already redeemed by another machine or user.
- If exposure is possible, stop and request revocation rather than testing the secret repeatedly.

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
