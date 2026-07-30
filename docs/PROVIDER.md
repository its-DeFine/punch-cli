# Provider guide

> **Preview.4 documentation:** this page applies to the published
> `v0.1.0-preview.4` package.

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

Punch publishes fixed validation, workload, and interactive runtimes. Their
build contexts are public under `images/`, but the Control implementation
remains private. Always pull the release by the exact registry digest; do not
use a workflow tag or substitute a locally rebuilt image.

The registry digest and Docker's local image ID are two different immutable
identities. Pull with the registry reference, then record the exact local image
ID:

```bash
docker pull 'ghcr.io/its-define/punch-validation@sha256:b6691b0f0e0e78c9bfddbe2d327b68340e57d76b563bddbf748eed2019496d6d'
docker pull 'ghcr.io/its-define/punch-workload@sha256:7d2860d642cdb898d1125da58191c58812dec18d3b1da348dd73b44f2982b627'
docker pull 'ghcr.io/its-define/punch-interactive@sha256:8734a58eea53ca64690b4cbc94cc1e4b15af4407730c2352a81b2958e3d021e4'
```

Verify the expected local IDs in the [release matrix](RELEASES.md) with
`docker image inspect --format '{{.Id}}' REGISTRY_REFERENCE`. The Provider
configuration uses these local IDs, not registry references or mutable tags.
The complete image-policy block for `v0.1.0-preview.4` is:

```json
{
  "VALIDATION": {
    "image": "sha256:12c26a0cf669d421791291bd321548ca336b8ec0d976dabc8fd95ebe84df6c42",
    "command": ["/punch/validate"],
    "inputKeys": ["nonce"]
  },
  "WORKLOAD": {
    "image": "sha256:afa534cb00b77ff9a7ca69c9ce750ee2fd41ce3e5bda710473c1f1952198cb96",
    "command": ["/punch/run"],
    "inputKeys": ["nonce", "window_seconds"]
  },
  "INTERACTIVE": {
    "protocol": "PUNCH_INTERACTIVE_V1",
    "approvedBaseImage": "sha256:2f13a113c8dd5d3c2ddb38f2e1cee7d4aaa2f7ba3c157de7743bb8d1276ea33b",
    "command": ["/usr/local/bin/punch-interactive"],
    "inputKeys": [],
    "seccompProfile": "builtin",
    "seccompProfileDigest": "aa305575d85c2445b2b61555bfee2fb0a2260f671d7000e9b40849e2ed8317f5",
    "appArmorProfile": "docker-default",
    "appArmorProfileDigest": "98eb02dfa81397d55e75c3890266de0ea2e058d2061c6da140d7369824b1c38a"
  }
}
```

The complete `agent.json` has exactly four top-level fields. `providerPayout`
contains only a payout rail and public recipient address; it never contains a
private key, seed phrase, signer, or wallet credential:

```json
{
  "publicOrigin": "https://api-punch.embody.zone",
  "credentialFile": "/absolute/path/.config/punch/provider/credential.json",
  "providerPayout": {
    "rail": "SABLIER_USDC",
    "recipient": "0x1111111111111111111111111111111111111111"
  },
  "imagePolicies": {
    "VALIDATION": {
      "image": "sha256:12c26a0cf669d421791291bd321548ca336b8ec0d976dabc8fd95ebe84df6c42",
      "command": ["/punch/validate"],
      "inputKeys": ["nonce"]
    },
    "WORKLOAD": {
      "image": "sha256:afa534cb00b77ff9a7ca69c9ce750ee2fd41ce3e5bda710473c1f1952198cb96",
      "command": ["/punch/run"],
      "inputKeys": ["nonce", "window_seconds"]
    },
    "INTERACTIVE": {
      "protocol": "PUNCH_INTERACTIVE_V1",
      "approvedBaseImage": "sha256:2f13a113c8dd5d3c2ddb38f2e1cee7d4aaa2f7ba3c157de7743bb8d1276ea33b",
      "command": ["/usr/local/bin/punch-interactive"],
      "inputKeys": [],
      "seccompProfile": "builtin",
      "seccompProfileDigest": "aa305575d85c2445b2b61555bfee2fb0a2260f671d7000e9b40849e2ed8317f5",
      "appArmorProfile": "docker-default",
      "appArmorProfileDigest": "98eb02dfa81397d55e75c3890266de0ea2e058d2061c6da140d7369824b1c38a"
    }
  }
}
```

Replace the absolute credential path and the synthetic payout recipient with
the Provider's intended public EVM address. Keep the file mode `0600`. Do not
edit image IDs or policy fields; stop if an inspect result differs from the
release matrix. A Provider using the separately approved `LIVEPEER_OPS` rail
uses `{ "rail": "LIVEPEER_OPS", "recipient": null }` instead.

Choose the rail for the intended workload mode. `SABLIER_USDC` is the
test-settlement rail for brokered interactive/SSH orders. `LIVEPEER_OPS` is for
bounded non-interactive workloads. The payout rail is immutable once the offer
is created, and a Buyer request for the other mode is rejected with
`PAYOUT_RAIL_MISMATCH`.

If `providerPayout.rail` is `SABLIER_USDC`, complete the full interactive
security preflight below **before running `setup`**. Setup creates the offer;
there is no later Provider-side acceptance gate before a compatible Buyer can
order it. Do not publish a Sablier-backed offer from a node that has not passed
all four Docker checks. `LIVEPEER_OPS` setup for bounded non-interactive work
may proceed without user-namespace remapping.

The interactive image runs as UID/GID `65532:65532`, binds SSH only to container
loopback, and publishes no port. The Provider Docker daemon must pass the Punch
preflight for user-namespace remapping, cgroup v2 private namespaces, default
seccomp, and AppArmor before an interactive workload is accepted.

Provider setup for `LIVEPEER_OPS`, `VALIDATION`, and bounded non-interactive
`WORKLOAD` execution do not require user-namespace remapping. Before
`SABLIER_USDC` setup, verify that Docker reports all four required security
options and cgroup v2:

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

Punch supplies a single-use invitation. The operator prepares an agent
configuration containing only the public origin, credential path, public payout
binding, and allowlisted image policies. The invitation is secret-bearing. The
agent configuration contains no private key or credential, but it is local
operator configuration and must not be committed.

## 3. Join

```bash
punch-provider join \
  --invitation /absolute/path/to/provider-invitation.json \
  --punch-origin https://api-punch.embody.zone \
  --credential-file /absolute/path/.config/punch/provider/credential.json \
  --json
```

If setup returns `PROVIDER_REJOIN_REQUIRED`, stop retries and obtain one fresh
replacement invitation from Punch. Keep the machine identity, state directory,
credential path, and original setup reference unchanged, then run:

```bash
punch-provider rejoin \
  --invitation /absolute/path/to/replacement-provider-invitation.json \
  --punch-origin https://api-punch.embody.zone \
  --credential-file /absolute/path/.config/punch/provider/credential.json \
  --json
```

`rejoin` is not a second identity. It is accepted only for a fresh invitation
bound by Punch to the same active Provider actor. Do not manually remove the
credential or pending setup journal.

## 4. Inspect local inventory

```bash
punch-provider inventory
```

GPU is optional. CPU-only capacity is valid. GPU offers use a stable GPU UUID and CDI identity, never only an index.

## 5. Create the machine identity

Choose one stable, non-secret machine identifier and reuse it unchanged for
`identity-init`, `setup`, `serve`, and `status`. It must start with a letter or
digit, contain at most 128 characters, and use only letters, digits, `.`, `_`,
`:`, `/`, or `-`:

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
  --window-seconds 3600 --price-usdc-cents 34
```

`--price-usdc-cents` is the positive integer number of USDC cents for the
complete `--window-seconds` interval. The example means USD 0.34 for one hour.
The CLI converts 34 cents to `340000` six-decimal USDC base units before the
immutable offer, buyer funding, accounting, and Sablier instruction use that
one amount. A five-minute window cannot express exactly USD 0.34 per
hour using whole cents, so use a one-hour window for that price. The public
preview uses test settlement only unless Punch separately announces and
authorizes a real-funds release.

Pricing and the payout binding become immutable offer terms. Do not copy a
sample value or synthetic recipient into an offer. The CLI submission is not a
substitute for reading fees, payout timing, tax treatment, cancellation, and
dispute terms.

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
