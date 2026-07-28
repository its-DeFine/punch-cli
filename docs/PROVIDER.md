# Provider guide

The Provider CLI is `punch-provider`. The resident agent runs on the local execution node and connects outbound to the HTTPS origin in its agent configuration. Use only the official origin supplied with the release or invitation.

The preview supports allowlisted immutable workload images and bounded structured inputs. It does not accept arbitrary images, commands, mounts, host networking, privileged containers, added capabilities, or arbitrary device paths.

## 1. Host requirements

- A supported Linux system; see [Platform support](PLATFORMS.md).
- Docker Engine available through the local Unix socket.
- Sufficient CPU, RAM, and disk for the offered capacity.
- Optional NVIDIA GPU, driver, Container Toolkit, and stable GPU UUID/CDI identity.
- A dedicated private state directory.

The Provider CLI does not configure a remote Docker endpoint and must never expose the Docker socket over TCP. Access to the Docker Unix socket is normally equivalent to host-root authority. During the preview, operate the agent as an owner-supervised foreground process on a dedicated or equivalently isolated execution node. Do not place unrelated user data or credentials on that node.

## 2. Prepare state

```bash
install -d -m 0700 "$HOME/.config/punch/provider"
install -d -m 0700 "$HOME/.local/state/punch-provider"
chmod 0600 /absolute/path/to/provider-invitation.json
```

Punch supplies an invitation and an agent configuration containing only the public origin, credential path, and allowlisted image policies. Both files are secret-bearing pilot material and must not be committed.

## 3. Join

```bash
punch-provider join \
  --invitation /absolute/path/to/provider-invitation.json \
  --punch-origin https://api-punch.embody.zone \
  --credential-file /absolute/path/.config/punch/provider/credential.json \
  --json
```

## 4. Inspect local inventory

```bash
punch-provider inventory
```

GPU is optional. CPU-only capacity is valid. GPU offers use a stable GPU UUID and CDI identity, never only an index.

## 5. Create the machine identity

Use the machine identifier assigned by Punch:

```bash
punch-provider identity-init \
  --state-dir /absolute/path/.local/state/punch-provider \
  --machine-id MACHINE_ID
```

The private Ed25519 identity stays on the execution node and must remain mode `0600` inside a mode-`0700` state directory.

## 6. Submit setup and capacity

CPU-only example:

```bash
punch-provider setup \
  --machine-id MACHINE_ID \
  --state-dir /absolute/path/.local/state/punch-provider \
  --agent-config /absolute/path/.config/punch/provider/agent.json \
  --idempotency-key UNIQUE_SETUP_REFERENCE \
  --cpu-cores 4 --gpu-units 0 --vram-mib 0 \
  --ram-mib 8192 --disk-gib 40 \
  --window-seconds 300 --price-minor PRICE_MINOR
```

`PRICE_MINOR` is an integer value in the asset and unit basis stated by the current invitation/pilot terms. Do not copy a sample economic value into a real offer. The CLI submission is not a substitute for reading fees, payout timing, tax treatment, cancellation, and dispute terms.

GPU example adds:

```bash
--gpu-units 1 --vram-mib VRAM_MIB \
--gpu-uuid GPU_UUID --gpu-cdi CDI_DEVICE
```

Never offer more capacity than the inventory reports as safely allocatable.

## 7. Run the agent in the supervised foreground

```bash
punch-provider serve \
  --machine-id MACHINE_ID \
  --state-dir /absolute/path/.local/state/punch-provider \
  --agent-config /absolute/path/.config/punch/provider/agent.json \
  --interval-ms 1000
```

The current preview archive supports only owner-supervised foreground operation of `punch-provider serve`. It does not supply or install a service definition and makes no privileged or system-service changes. Unattended or background Provider operation is unsupported until a separately reviewed, release-specific service definition is published. Do not invent a root wrapper or grant broader system access. Accept Provider operation only if the node's isolation makes the Docker-socket authority acceptable.

Read local state while the agent remains running:

```bash
punch-provider status \
  --state-dir /absolute/path/.local/state/punch-provider \
  --machine-id MACHINE_ID
```

Local status is not proof that Punch Control has accepted the latest heartbeat or drain state.

## 8. Drain

Request local draining before maintenance:

```bash
punch-provider drain \
  --state-dir /absolute/path/.local/state/punch-provider
```

`drain` writes local `DRAINING` intent only. Keep the resident agent running, wait for Punch Control to observe the state, and verify there is no active lease before maintenance. Draining does not itself stop the agent, terminate work, or authorize deletion of customer state.
