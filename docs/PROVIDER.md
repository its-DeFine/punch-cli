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

## Runtime images

Punch publishes the fixed interactive runtime at
`ghcr.io/its-define/punch-interactive`. The image build context is public under
`images/interactive/`, but the Control implementation remains private. Always
pull the release by the exact registry digest supplied by Punch; do not use the
workflow tag and do not substitute a locally rebuilt image.

The registry digest and Docker's local image ID are two different immutable
identities. Pull with the registry reference, then record the exact local image
ID:

```bash
docker pull 'ghcr.io/its-define/punch-interactive@sha256:REGISTRY_DIGEST'
docker image inspect \
  --format '{{.Id}}' \
  'ghcr.io/its-define/punch-interactive@sha256:REGISTRY_DIGEST'
```

Punch places the resulting `sha256:LOCAL_IMAGE_ID` in
`imagePolicies.INTERACTIVE.approvedBaseImage`. Do not put the registry reference
or a tag in that field. A Punch-supplied interactive policy has this exact
shape; it appears alongside the separately supplied `VALIDATION` and `WORKLOAD`
policies:

```json
{
  "protocol": "PUNCH_INTERACTIVE_V1",
  "approvedBaseImage": "sha256:LOCAL_IMAGE_ID",
  "command": ["/usr/local/bin/punch-interactive"],
  "inputKeys": [],
  "seccompProfile": "builtin",
  "seccompProfileDigest": "aa305575d85c2445b2b61555bfee2fb0a2260f671d7000e9b40849e2ed8317f5",
  "appArmorProfile": "docker-default",
  "appArmorProfileDigest": "98eb02dfa81397d55e75c3890266de0ea2e058d2061c6da140d7369824b1c38a"
}
```

Do not invent or edit this block by hand for a live Provider. Punch must supply
it only after the image and local runtime preflight have been verified.

The interactive image runs as UID/GID `65532:65532`, binds SSH only to container
loopback, and publishes no port. The Provider Docker daemon must pass the Punch
preflight for user-namespace remapping, cgroup v2 private namespaces, default
seccomp, and AppArmor before an interactive workload is accepted.

Before setup, verify that Docker reports all four required security options and
cgroup v2:

```bash
docker info --format '{{json .SecurityOptions}}'
docker info --format '{{.CgroupVersion}}'
```

The security options must include `name=userns`, `name=cgroupns`,
`name=seccomp,profile=builtin`, and `name=apparmor`; the cgroup version must be
`2`. Enabling user-namespace remapping changes Docker's storage namespace and
normally requires a Docker restart. Preserve existing images and containers and
use a reviewed, host-specific rollback procedure; the public CLI does not make
that privileged change.

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
