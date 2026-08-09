# Preview.15 Provider guide

> **Status: `PUBLISHED_PRERELEASE`.** Use only the published Linux/x64
> [`v0.1.0-preview.15`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.15)
> archive and its same-release `SHA256SUMS`. Do not use a source checkout,
> private build, guessed URL, or earlier archive for this guided flow. The
> network remains invitation-only and owner-targeted `$0`; publication does not
> authorize self-service approval.

The Provider agent runs on the execution node and connects outbound to Punch.
It does not expose a public SSH port, host SSH, or Docker over the Internet. Contract SSH is
served by a gateway bound to the Provider's narrow NetBird overlay address on
TCP `22222`.

Provider onboarding remains supervised. A Provider cannot approve itself,
choose a Buyer, issue a targeted-zero authorization, or create a publicly
claimable free offer.

## Published release and installation

On an Ubuntu 22.04 or 24.04 Linux/x64 host, download the two exact assets from
the same non-draft release, verify the checksum, and install the Provider role:

```bash
curl -fLO https://github.com/its-DeFine/punch-cli/releases/download/v0.1.0-preview.15/punch-cli-0.1.0-preview.15-linux-x64.tar.gz
curl -fLO https://github.com/its-DeFine/punch-cli/releases/download/v0.1.0-preview.15/SHA256SUMS
sha256sum -c SHA256SUMS --ignore-missing
tar -xzf punch-cli-0.1.0-preview.15-linux-x64.tar.gz
cd punch-cli-0.1.0-preview.15-linux-x64
./install.sh --role provider
export PATH="$HOME/.local/bin:$PATH"
```

Require the exact Preview.15 archive line to report `OK`. A missing release,
asset, checksum line, or `OK` result is a hard stop. Its published SHA-256 is
`672b8998f9465a1a49fe9eb1cb54df934ee11199250f549e1317c2450a2bd468`.
Before onboarding, confirm the installed release surface:

```bash
punch --help
punch-provider --help
punch-provider inventory --json
```

`--help` and `inventory` are read-only: they do not create a Provider identity,
submit onboarding, redeem an invitation, install dependencies, create an offer,
or start a service.

**State-creating boundary:** the normal guided path begins with read-only host
preflight, then explains the durable local identity and public onboarding
request before asking for explicit confirmation. Decline that confirmation to
leave the identity boundary uncrossed. After confirmation, the CLI creates the
private local identity and public-only request and stops at
`WAITING_FOR_INVITE`. Following supervised approval, signed status may show
`INVITE_READY`, but the owner-delivered one-time Provider invitation must still
be an owned mode-`0600` file before the guided home imports it. Never substitute
guessed invitation or configuration values.

Continue with [guided onboarding](#2-guided-provider-onboarding),
the [Preview.15 release flow](PREVIEW15.md), and the exact
[Preview.15 Provider command reference](PREVIEW15_COMMAND_REFERENCE.md#provider).

## 1. Supported host

- Ubuntu 22.04 or 24.04 on Linux x64.
- A private, owner-controlled state directory and sufficient storage for the
  three immutable Punch images plus one bounded workload.
- For GPU capacity, a compatible NVIDIA driver and stable UUID/CDI identity.
  Preview.15 may install the reviewed container toolkit after consent, but it
  never replaces the GPU driver or kernel and never reboots the host.

The exact immutable image identities are:

| Kind | Immutable policy and runtime reference |
| --- | --- |
| `VALIDATION` | `ghcr.io/its-define/punch-validation@sha256:d7de3c3549c2e36c1f5ef5237a671c7f06e44eb101c17be2faeca12a267adf86` |
| `WORKLOAD` | `ghcr.io/its-define/punch-workload@sha256:16fdfad931a97834bbe89c6a66724405e502535b9f8c35a971e91ed07b1242ce` |
| `INTERACTIVE` | `ghcr.io/its-define/punch-interactive@sha256:ba8c40d0e2610c43f306db04e3235442606bbec2fdcb3d37c745b23ecdaf9311` |

## 2. Guided Provider onboarding

Run the state-aware home for the normal path:

```bash
punch
```

Choose **Provider**. The home then:

1. inspects the host before creating identity and shows any missing reviewed
   prerequisites;
2. asks for explicit consent before applying the exact displayed dependency
   plan;
3. asks only for a friendly Provider label and bounded CPU, RAM, disk, and
   detected GPU choices;
4. explains the private local identity boundary and asks for confirmation;
5. creates the identity only after confirmation, sends only the signed public
   onboarding request, and displays durable `WAITING_FOR_INVITE`;
6. displays `INVITE_READY` after supervised approval and resumes the same flow
   only when the owner-delivered mode-`0600` one-time invitation is supplied;
   and
7. completes trusted configuration, authenticated NetBird enrollment,
   pre-list validation, supervised service setup, and bounded activation
   through `LISTED`, then presents the Provider overview.

The guided user does not construct a machine ID, state or credential path,
Punch origin, GPU UUID/CDI selector, setup reference, or raw CLI flag. The CLI
does not ask for a Provider SSH key or SSH file; Buyer contract access is
brokered later. Consequential local install or configuration changes remain
explicit approval boundaries.

## 3. Advanced direct identity and join

The commands in this and later direct sections are for reviewed automation and
recovery. They are not the normal external Provider journey and must not be
used to bypass `WAITING_FOR_INVITE` or the invitation approval boundary.

Keep the invitation, credential, identity, and state directory private. Example
paths are illustrative; the installed process must own them.

```bash
install -d -m 0700 "$HOME/.config/punch/provider"
install -d -m 0700 "$HOME/.local/state/punch-provider"

punch-provider identity-init \
  --state-dir /absolute/path/.local/state/punch-provider \
  --machine-id MACHINE_ID \
  --json
```

Send the resulting public onboarding packet through the supervised onboarding
channel. After Punch returns the invitation bound to that packet:

```bash
chmod 0600 /absolute/path/to/provider-invitation.json

punch-provider join \
  --invitation /absolute/path/to/provider-invitation.json \
  --punch-origin https://api-punch.embody.zone \
  --credential-file /absolute/path/.config/punch/provider/credential.json \
  --json
```

`identity-init` happens before invitation issuance. It creates the local private
signing key and prints a public onboarding packet containing only the machine
identity, credential identifier, fingerprint, and public key. Send only that
public packet through the supervised onboarding channel; never send the private
state directory or key. Punch binds the resulting invitation to that packet,
and `join` rejects a different machine identity.

Invitations are single-use, but join/setup recovery is resumable from the same
local state. Preserve the credential path, machine ID, identity key, state
directory, and every setup reference. Deleting local state is not a valid
recovery action.

## 4. Advanced direct Provider setup

Inspect the exact host first:

```bash
punch-provider doctor \
  --machine-id MACHINE_ID \
  --state-dir /absolute/path/.local/state/punch-provider \
  --punch-origin https://api-punch.embody.zone \
  --credential-file /absolute/path/.config/punch/provider/credential.json \
  --json

punch-provider inventory --json
```

Normal setup takes the observed capacity and one stable idempotency key. One
guided or direct CLI session performs confirmed dependency installation,
immutable image pulls,
the real local pre-list container/SSH/cleanup proof, one-use machine/setup-bound
NetBird enrollment, canonical agent-config generation, hardened systemd
installation/start, fresh signed heartbeat, and offer activation:

```bash
punch-provider setup \
  --machine-id MACHINE_ID \
  --state-dir /absolute/path/.local/state/punch-provider \
  --punch-origin https://api-punch.embody.zone \
  --credential-file /absolute/path/.config/punch/provider/credential.json \
  --idempotency-key STABLE_SETUP_REFERENCE \
  --cpu-cores 4 --ram-mib 8192 --disk-gib 40 \
  --gpu-units 1 --vram-mib VRAM_MIB \
  --gpu-uuid GPU_UUID --gpu-cdi CDI_DEVICE \
  --json
```

For CPU-only capacity use `--gpu-units 0 --vram-mib 0` and omit GPU identity
flags. For 2–8 GPUs, use aligned comma-separated `--gpu-uuids` and
`--gpu-cdis` plus `--gpu-communication SAME_NODE|P2P_REQUIRED`.

If `doctor` reports missing reviewed dependencies, include
`--install-dependencies`. In a guided TTY session Punch shows the exact plan,
asks for confirmation, may prompt for `sudo`, and then continues the same setup
through activation. A direct non-interactive invocation requires both `--yes`
and an already cached `sudo` authorization; it fails with a recovery action
instead of opening a hidden prompt. Consent never authorizes an unlisted
package, driver, kernel, reboot, or unrelated daemon-policy change. The required
Docker user-namespace boundary is `userns-remap=default`; Punch preserves all
other daemon settings and retains an exact rollback artifact when it enables
that setting.

The Buyer identity, owner-targeted `$0` authorization, access window, offer ID,
and price come from authenticated Control. They are not normal Provider input.
The maximum authorized access window is `259200` seconds; a Provider cannot
raise it. Punch may supervise multiple approved Providers, but each machine,
identity, offer, capacity record, NetBird binding, and setup reference remains
independent.
The offer stays `PENDING_AGENT` while setup completes. Only the signed pre-list
proof and a fresh heartbeat from the installed service can move it to `LISTED`.

Successful JSON has schema `punch.provider-setup.preview14.v1` and includes
`state: "LISTED"`, `machineId`, `offerId`, `setupRef`, and bounded `netbird`,
`agentConfig`, `service`, and `activation` receipts. The canonical private
config is generated at `STATE_DIR/provider-agent.json`.

## 5. NetBird and config custody

Normal Preview.15 setup requests one short-lived, single-use enrollment from
Control only after Provider authorization. Punch passes it to NetBird through a
temporary mode-`0600` file, verifies the resulting peer/address binding, records
the non-secret receipt, and removes the one-time material.
The Provider never receives the NetBird management token or pastes a setup key.

Manual NetBird enrollment and manual editing/copying of
`provider-agent.example.json` are obsolete for normal Preview.15 onboarding.
`--agent-config` remains an advanced exact-match recovery/diagnostic override;
it cannot change authenticated image, Buyer, offer, window, price, or
authorization bindings.

## 6. Resident service and recovery

Successful setup installs, enables, starts, and verifies the hardened
machine-scoped systemd service. `serve` remains available for foreground
diagnostics; it and manual config patching are not normal onboarding steps.

```text
punch-provider service-status --machine-id MACHINE_ID --json
punch-provider service-logs --machine-id MACHINE_ID --lines 80 --json
punch-provider service-start --machine-id MACHINE_ID --yes --json
punch-provider service-stop --machine-id MACHINE_ID --yes --json
```

Setup is resumable. Retry the exact `setup` command with the same
`--idempotency-key`; do not create a second identity, peer, config, service, or
offer. Public setup errors use
`punch.provider-error.preview14.v1` with `code`, `stage`, `retryable`, and a
sanitized `error` message.

## 7. Offer lifecycle

```text
punch-provider offer-status --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --json
punch-provider offer-unlist --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY --json
punch-provider offer-retire --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY --json
```

Unlist prevents new orders but cannot revoke or alter an accepted contract.
Retirement requires an already-unlisted offer, terminal contracts, released
capacity, and fenced access. Exact retries return the same durable result.

## 8. Acceptance and rollback

Before retaining a Provider, prove the exact release archive performs:

- setup through `PENDING_AGENT` to `LISTED` on the advertised CPU/GPU surface;
- designated-Buyer discovery and exact order replay;
- automatic container and gateway readiness;
- OpenSSH access from a separate Buyer environment;
- Buyer stop, existing-session closure, and fresh-connection rejection;
- signed cleanup, listener/container removal, and capacity release.

For maintenance, unlist an unaccepted offer or allow accepted contracts to
finish, then retire only after obligations are terminal. Preserve credentials,
identity keys, state, generated config, and receipts across a program rollback.

Preview.15 remains owner-targeted `$0` only. Payment, settlement, payout,
refunds, and paid-offer economics are outside its acceptance boundary.
