# Preview.9 clean-v4 supervised pilot

> **Invitation-only supervised pilot:** `v0.1.0-preview.9` is supported on
> Linux/x64 only when its non-draft GitHub prerelease contains the matching
> archive and `SHA256SUMS` assets.

Preview.9 packages the clean-v4 Provider and Buyer lifecycle proven on one
owner-operated RTX 5080 Provider. It is a tester release, not a general
marketplace or payment release.

## Released lifecycle

The matching release supports this exact supervised flow:

1. An operator approves and onboards one Provider and machine.
2. The Provider creates an immutable zero-price offer using a single-use
   authorization bound to one designated Buyer.
3. That Buyer discovers the offer and submits an idempotent order.
4. The Provider starts the digest-pinned interactive container and exposes a
   contract-scoped gateway only on its NetBird overlay address and TCP `22222`.
5. The Buyer waits for effective access, connects with OpenSSH through
   `punch-buyer ssh`, and uses the bounded container as user `punch`.
6. `punch-buyer stop` durably reconciles the same Buyer/contract operation,
   fences new access, closes active sessions, removes the container and
   listener, records signed cleanup, and releases capacity.

Exact order and stop retries return the existing contract or operation; they do
not create duplicate reservations or cleanup tasks.

## Runtime and image binding

The public contract is machine-readable in
[`preview9-runtime-contract.json`](preview9-runtime-contract.json). It binds:

- private runtime proof commit `f1cad6a577926eae7f1487595b4193e66d5563ff`;
- Linux/x64;
- the three immutable OCI references listed in that contract;
- contract-scoped NetBird gateway access on TCP `22222`;
- owner-targeted zero-price offers only;
- no payment settlement and no self-service Provider onboarding.

The release archive carries a Provider agent configuration template and a
reference systemd unit under `provider/`. The installer does not enable the
unit or enroll NetBird automatically; a Punch operator must render and review
both for each Provider.

## Live proof boundary

On 2026-08-06, the frozen runtime completed one real Provider-to-Buyer canary:

- exact order replay returned the same contract;
- a separate Buyer environment connected over NetBird-backed brokered SSH;
- the container reported the expected RTX 5080 identity;
- Buyer stop closed an existing SSH session and an identical retry returned
  the same terminal operation;
- a fresh post-stop connection was rejected;
- signed cleanup removed the container and gateway listener and released the
  reservation.

This proves the owner-operated supervised path. It does not prove payment,
payout, refunds, arbitrary Providers, multi-Provider scheduling, broad
concurrency, or unattended self-service onboarding.

## Rollback

Drain the Provider and verify that it has no active contract, container, or
gateway listener. Stop the service, restore the previously verified CLI
version and matching agent configuration, reload systemd, and restart. Never
roll back or copy invitations, credentials, identity keys, state directories,
NetBird setup keys, or management material with program files.

If activation fails after an order exists, keep access fenced and finish the
accepted cleanup path before relisting capacity.
