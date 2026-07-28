# Platform support

Platform support is declared per release because the Buyer CLI and Provider agent have different operating-system requirements.

## Buyer

Planned preview packages:

- macOS on Apple silicon.
- Linux on x86-64.

## Provider

The initial Provider preview targets Linux on x86-64 with:

- Docker Engine available through the local Unix socket.
- A supported service manager for the reviewed resident-agent service.
- Optional NVIDIA GPU support only when the host driver and NVIDIA Container Toolkit are already compatible with the published release requirements.

CPU-only Providers are first-class. A GPU is not required to join or offer CPU capacity.

## Release authority

The asset table and checksums on a GitHub Release are authoritative for that version. A platform listed here but absent from a release's verified assets is not supported by that release.
