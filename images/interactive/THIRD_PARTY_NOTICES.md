# Interactive image third-party notices

The image is based on the digest-pinned official NVIDIA CUDA 12.8.1 runtime
for Ubuntu 22.04 and installs these exact Ubuntu packages:

- Dropbear `2020.81-5ubuntu0.1` — MIT. Package metadata and corresponding
  source: <https://packages.ubuntu.com/jammy-updates/dropbear>
- socat `1.7.4.1-3ubuntu4` — GPL-2.0-only WITH OpenSSL-Exception. Package
  metadata, packaging commit, license, and corresponding source:
  <https://packages.ubuntu.com/jammy/socat>

NVIDIA Container Toolkit injects the host-matched `nvidia-smi` utility and NVML
at runtime; Punch does not redistribute the host driver or its license in this
image. The image's immutable registry digest identifies the distributed binary
artifact. Punch's own scripts are covered by this repository's Apache-2.0
license; that license does not replace the third-party terms above.
