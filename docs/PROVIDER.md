# Provider guide

> **Preview.9 supervised pilot:** this page applies to `v0.1.0-preview.9` only
> when its non-draft prerelease archive and checksum are published for Linux/x64.

The Provider agent runs on the execution node and connects outbound to Punch.
The Provider does not expose a public SSH port or Docker socket. Preview.9 uses
a Punch gateway bound only to the Provider's NetBird overlay address on TCP
`22222`.

Provider onboarding is operator-supervised. A Provider cannot approve itself,
issue a targeted-zero authorization, or publish a public free offer.

## 1. Host requirements

- Linux x64 with glibc 2.28 or newer.
- Docker Engine available through its local Unix socket only.
- cgroup v2, builtin seccomp, and `docker-default` AppArmor for interactive
  workloads; private user namespaces according to the pilot host policy.
- For GPU offers, a compatible NVIDIA driver/toolkit and stable UUID/CDI
  identity matching the advertised device.
- NetBird installed and enrolled by the Punch operator on interface `wt0`.
- A dedicated mode-`0700` state directory and enough disk for the pinned images
  plus one bounded workload.

The exact Preview.9 images are:

```text
ghcr.io/its-define/punch-validation@sha256:d7de3c3549c2e36c1f5ef5237a671c7f06e44eb101c17be2faeca12a267adf86
ghcr.io/its-define/punch-workload@sha256:16fdfad931a97834bbe89c6a66724405e502535b9f8c35a971e91ed07b1242ce
ghcr.io/its-define/punch-interactive@sha256:ba8c40d0e2610c43f306db04e3235442606bbec2fdcb3d37c745b23ecdaf9311
```

Pull and inspect those complete `repository@sha256:manifest` references. Never
substitute a mutable tag or Docker-local image ID.

## 2. Prepare private state

```bash
sudo install -d -m 0700 -o punch-provider -g punch-provider /var/lib/punch-provider
sudo install -d -m 0700 -o punch-provider -g punch-provider /var/lib/punch-provider/clean-v4
chmod 0600 /absolute/path/to/provider-invitation.json
```

The release archive carries:

```text
provider/provider-agent.example.json
provider/punch-provider.service
```

The operator copies the configuration template to an owner-only path, replaces
only the Provider-specific credential path and verified NetBird overlay IP,
and preserves all image digests and `cleanStateProviderTaskSlice: true`.
Never copy another Provider's credential, identity, overlay IP, peer/group ID,
Buyer binding, or setup key.

## 3. Join and initialize the machine

```bash
punch-provider join \
  --invitation /absolute/path/to/provider-invitation.json \
  --punch-origin https://api-punch.embody.zone \
  --credential-file /var/lib/punch-provider/clean-v4/provider-credential.private.json \
  --json

punch-provider inventory --json

punch-provider identity-init \
  --state-dir /var/lib/punch-provider \
  --machine-id MACHINE_ID
```

Invitations are single-use. Preserve the resulting credential, machine ID,
identity key, and state directory. Do not delete local state to bypass a
rejection.

## 4. NetBird operator step

The Provider operator enrolls the peer with a fresh one-time setup key, verifies
its peer identity and overlay address, and places only that peer in the assigned
Provider group. The setup key is staged in a mode-`0600` file and never placed
in chat, Git, logs, shell history, a service argument, or the agent config.
The Provider never receives the NetBird management token.

The Punch workspace must not have a default full-mesh policy. Contract-scoped
policy grants are managed by Punch, not by the Provider CLI.

## 5. Submit the supervised offer

The operator supplies a fresh single-use authorization ID and its exact Buyer
actor binding. A one-GPU example is:

```bash
punch-provider setup \
  --machine-id MACHINE_ID \
  --state-dir /var/lib/punch-provider \
  --agent-config /absolute/path/to/provider-agent.json \
  --idempotency-key STABLE_SETUP_REFERENCE \
  --cpu-cores 4 --ram-mib 8192 --disk-gib 40 \
  --gpu-units 1 --vram-mib VRAM_MIB \
  --gpu-uuid GPU_UUID --gpu-cdi CDI_DEVICE \
  --window-seconds 1200 --price-minor 0 \
  --targeted-zero-authorization-id AUTHORIZATION_ID \
  --targeted-buyer-actor-id BUYER_ACTOR_ID \
  --json
```

Zero price is rejected unless both bindings are present. The offer remains
unavailable until deterministic validation passes on the exact GPU/CDI and
pinned images and the operator approves listing. The authorization cannot be
used to create a publicly claimable free offer.

## 6. Run the resident agent

Direct supervised execution:

```bash
punch-provider serve \
  --machine-id MACHINE_ID \
  --state-dir /var/lib/punch-provider \
  --agent-config /absolute/path/to/provider-agent.json \
  --interval-ms 1000
```

For supervised service operation, review the supplied unit, ensure the
`punch-provider` user has only the required local Docker access, and create
`/etc/punch-provider.env`:

```text
PUNCH_MACHINE_ID=MACHINE_ID
PUNCH_AGENT_CONFIG=/absolute/path/to/provider-agent.json
```

The unit does not enroll NetBird, create credentials, or install itself.

## 7. Acceptance checklist

Before retaining a Provider, prove:

- the designated Buyer alone discovers the offer;
- exact order replay returns the same contract;
- the Provider automatically starts the pinned container and gateway;
- Buyer status reaches `ACTIVE` with `accessEffective: true`;
- a separate Buyer environment connects with OpenSSH and a harmless GPU command
  returns the expected UUID/model;
- Buyer stop closes an existing session and an exact retry is safe;
- fresh SSH is rejected after stop;
- signed cleanup removes the container and TCP `22222` listener and releases
  capacity.

## 8. Drain and rollback

```bash
punch-provider drain \
  --state-dir /var/lib/punch-provider
```

Keep the agent running until Control observes the drain and there is no active
lease. Stop the service, restore the previously verified CLI version and its
matching agent configuration, reload systemd, and restart. Never roll back
credentials, identity keys, state directories, invitations, setup keys, or
NetBird management material with program files.

Preview.9 is zero-price only. Payment, settlement, payout, refunds, and paid
offer economics are outside this release's acceptance boundary.

`offer-status`, `offer-unlist`, and `offer-retire` are not Preview.9 commands.
They are included in the supervised Preview.10 release source, but must not be
used until its matching archive is published. See [Provider offer
lifecycle](OFFER_LIFECYCLE_PREVIEW.md).
