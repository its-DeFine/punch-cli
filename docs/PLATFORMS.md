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

The current preview archive does not supply or install a service definition and makes no privileged or system-service changes. Unattended or background Provider operation is unsupported until a separately reviewed, release-specific service definition is published.

## Release authority

The asset table and checksums on a GitHub Release are authoritative for that version. A platform listed here but absent from a release's verified assets is not supported by that release.
