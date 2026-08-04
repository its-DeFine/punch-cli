# Punch interactive runtime image

This directory is the public, reviewable build context for the fixed Punch
interactive runtime. It is not the Punch control plane and contains no
marketplace, database, payment, administrator, invitation, or credential code.

The image uses the exact digest-pinned NVIDIA CUDA 12.8.1 Ubuntu 22.04
runtime base. NVIDIA Container Toolkit/CDI supplies the host-matched
`nvidia-smi` utility and NVML at runtime; the glibc base makes that injected
utility executable. The image requires `NVIDIA_DRIVER_CAPABILITIES` to include
`utility` and does not bundle host driver libraries or credentials.

The image accepts one canonical Ed25519 public key from the Provider agent and
runs a non-root SSH service bound only to the container loopback interface.
Punch reaches it through a fixed stdio bridge. It publishes no port and does not
expose the Provider address or Docker socket to a Buyer.

The image build pins Dropbear `2020.81-5ubuntu0.1` and socat
`1.7.4.1-3ubuntu4` from Ubuntu 22.04. The interactive GPU compatibility floor
is NVIDIA Linux driver `570.124.06` with CUDA runtime `12.8.1`; the selected
GPU UUID and CDI device must be the same values used by the runtime canary.

The fixed bridge waits for the container-local SSH listener with a bounded
retry window. It still fails closed when the listener does not become ready;
it never falls back to a host port or a provider address.

Official releases are published for `linux/amd64` as
`ghcr.io/its-define/punch-interactive`. Provider configuration must use the
immutable digest reported by the successful publish workflow, never a mutable
tag. Do not build or substitute a different image for a Punch pilot.

The current `v0.1.0-preview.8` compatible registry reference is
`ghcr.io/its-define/punch-interactive@sha256:ba8c40d0e2610c43f306db04e3235442606bbec2fdcb3d37c745b23ecdaf9311`.

That is the already published preview.8 image. The CUDA/glibc interactive
candidate in this checkout is not a release replacement until the publish
workflow reports a new registry manifest digest. Do not update Provider policy
to a local image ID or to the workflow tag.

Pull the image by that complete registry reference and place the same
`repository@sha256:manifest` value in `approvedBaseImage`. Docker-local image
IDs vary between classic and containerd image stores and must never be copied
into Punch policy.

On an NVIDIA Container Toolkit node, the focused canary is:

```bash
PUNCH_INTERACTIVE_IMAGE='ghcr.io/its-define/punch-interactive@sha256:NEW_DIGEST' \
PUNCH_GPU_CDI='nvidia.com/gpu=GPU-UUID' \
PUNCH_GPU_UUID='GPU-UUID' \
./tests/interactive-image-runtime-canary.sh
```

The canary must report exactly the selected UUID from `nvidia-smi`; a missing
utility, driver below the floor, mismatched CDI identity, or failed NVML query
fails before the image is used for an offer.
