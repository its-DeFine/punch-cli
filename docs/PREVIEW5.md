# Preview.5 release contract

> **Not yet installable:** `v0.1.0-preview.5` has no published package,
> checksum, tag, or image matrix at this time. This document fixes the intended
> public offer contract for release validation. It does not authorize use of an
> unpublished CLI, candidate workflow tag, or locally rebuilt image. Continue
> to use the published preview.4 package and its release matrix until a
> preview.5 GitHub Release says otherwise.

## Atomic multi-GPU offers

Preview.5 adds one atomic offer class for **2 through 8 GPUs**. It does not
allow a Buyer to combine separately offered GPUs or turn an offer into a
different topology after setup.

For an offer with `--gpu-units` from 2 through 8, all of these flags are
required:

- `--gpu-units` — the number of GPUs in the one atomic offer.
- `--gpu-uuids` — the selected stable GPU UUIDs as a comma-separated list with
  no spaces, in the same order as their CDI identities.
- `--gpu-cdis` — the selected canonical CDI identities as a comma-separated
  list with no spaces, in the same order as their GPU UUIDs.
- `--gpu-communication` — either `SAME_NODE` or `P2P_REQUIRED`.

The UUID and CDI counts must each exactly equal `--gpu-units`; duplicates,
partial selections, whitespace in either list, and a count outside 2 through 8
are invalid. The UUID/CDI order is a binding: the first UUID must correspond to
the first CDI identity, and so on.

`SAME_NODE` proves only that all selected GPUs are exposed together on the same
execution node. `P2P_REQUIRED` additionally requires the complete,
all-direction CUDA peer-access path between every selected GPU. A PCI bus number
may help an operator locate a physical GPU during inventory, but it is not an
offer binding and is not a substitute for the canonical UUID/CDI pair.

Single-GPU offers remain singular: use `--gpu-units 1` with `--gpu-uuid` and
`--gpu-cdi`. CPU-only offers use `--gpu-units 0 --vram-mib 0` and must not carry
any GPU selector or GPU-communication flag.

## Capacity units and VRAM boundary

Use `--cpu-cores`, not `--cpu`: `--cpu-cores 40` advertises 40 CPU cores. RAM
is expressed in mebibytes (MiB): 128 GiB is `--ram-mib 131072`. Use the
allocatable `memoryMiB` observed in `punch-provider inventory` and leave host
and runtime overhead; do not blindly advertise nominal installed RAM. Disk
remains expressed in GiB.

`--vram-mib` is the aggregate VRAM advertised and matched for the selected
GPU offer. It is not an enforceable per-container VRAM quota. Do not promise a
tenant a hard VRAM partition merely because an offer includes this value.

## Image and host-security release boundary

The release-specific validation image must verify the actual selected GPU set
and the requested communication class on suitable NVIDIA hardware before the
final digest is entered in the [release matrix](RELEASES.md). A candidate
workflow tag is not an immutable published release reference.

The existing interactive-host security requirement remains unchanged:
`SABLIER_USDC` setup requires Docker user-namespace remapping in addition to
private cgroup namespaces, default seccomp, AppArmor, and cgroup v2. Docker
must report `name=userns`; enabling it changes Docker storage and normally
restarts Docker. The operator, not Punch CLI, must decide and execute a
reviewed host-specific migration and rollback procedure that preserves existing
images and containers. Non-interactive `LIVEPEER_OPS`, `VALIDATION`, and
bounded `WORKLOAD` do not require user-namespace remapping.
