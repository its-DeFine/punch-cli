# Platform support

Platform support is declared per release because the Buyer CLI and Provider agent have different operating-system requirements.

## Buyer

Preview.11 Buyer bootstrap supports only Linux on x86-64 with glibc 2.28 or
newer. Other operating systems fail closed before NetBird installation.

The bundled Linux runtime requires `GLIBC_2.28`, `GLIBCXX_3.4.21`, and `CXXABI_1.3.9`. No distribution or kernel baseline is claimed beyond those verified ABI requirements.

## Provider

The initial Provider preview targets Linux on x86-64 with glibc 2.28 or newer and:

- Docker Engine available through the local Unix socket.
- An operator able to supervise `punch-provider serve` directly or install the
  reviewed Preview.9 reference service.
- NetBird enrolled by the operator for contract-scoped gateway access; no
  public Provider SSH port is required.
- Optional NVIDIA GPU support only when the host driver and NVIDIA Container Toolkit are already compatible with the published release requirements.

CPU-only Providers are first-class. A GPU is not required to join or offer CPU capacity.

The current GPU compatibility class is `NVIDIA_CUDA_12_8_1_V2`. It uses the
release's exact digest-pinned CUDA 12.8.1 validation image and requires Linux
NVIDIA driver `570.124.06` or newer. Certified architectures are CUDA compute
capabilities 8.9 (Ada) and 12.0 (Blackwell). A matching driver version or GPU family name is
not sufficient by itself: the exact published image must pass its CUDA canary
against every selected GPU UUID/CDI identity before `setup` creates an offer.
Unsupported drivers, architectures, or failed canaries stop before offer
creation. Certification of 12.0 is based on a single-GPU RTX 5080 canary and
does not claim multi-GPU P2P support. Other architectures remain unsupported
until their own real-node promotion gate passes.

Preview.11 supplies a reference service definition but does not install or
enable it. Operator-reviewed service activation is supported only for the
supervised pilot.

## Release authority

The asset table and checksums on a GitHub Release are authoritative for that version. A platform listed here but absent from a release's verified assets is not supported by that release.
