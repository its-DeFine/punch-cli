# Platform support

Platform support is declared per release because the Buyer CLI and Provider agent have different operating-system requirements.

## Buyer

Planned preview packages:

- macOS on Apple silicon.
- Linux on x86-64 with glibc 2.28 or newer.

The bundled Linux runtime requires `GLIBC_2.28`, `GLIBCXX_3.4.21`, and `CXXABI_1.3.9`. No distribution or kernel baseline is claimed beyond those verified ABI requirements.

## Provider

The initial Provider preview targets Linux on x86-64 with glibc 2.28 or newer and:

- Docker Engine available through the local Unix socket.
- An operator able to supervise `punch-provider serve` as a foreground process.
- Optional NVIDIA GPU support only when the host driver and NVIDIA Container Toolkit are already compatible with the published release requirements.

CPU-only Providers are first-class. A GPU is not required to join or offer CPU capacity.

The initial GPU compatibility class is `NVIDIA_CUDA_12_8_1_V1`. It uses the
release's exact digest-pinned CUDA 12.8.1 validation image and requires Linux
NVIDIA driver `570.124.06` or newer. The first certified architecture is CUDA
compute capability 8.9 (Ada). A matching driver version or GPU family name is
not sufficient by itself: the exact published image must pass its CUDA canary
against every selected GPU UUID/CDI identity before `setup` creates an offer.
Unsupported drivers, architectures, or failed canaries stop before offer
creation. Other architectures remain unsupported until their own real-node
promotion gate passes.

The current preview archive does not supply or install a service definition and makes no privileged or system-service changes. Unattended or background Provider operation is unsupported until a separately reviewed, release-specific service definition is published.

## Release authority

The asset table and checksums on a GitHub Release are authoritative for that version. A platform listed here but absent from a release's verified assets is not supported by that release.
