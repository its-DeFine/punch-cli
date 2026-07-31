# Preview.6 release contract

> **Invitation-only preview:** use `v0.1.0-preview.6` only when its non-draft
> GitHub prerelease provides the Linux/x64 archive and checksum together with
> the immutable image matrix in [RELEASES.md](RELEASES.md).

## Docker image-store compatibility

Preview.6 fixes the runtime identity boundary exposed by Docker's two image
stores. Classic Docker reports the image configuration digest as `.Id`, while
Docker's containerd image store may report the OCI manifest digest. Those
local values are not portable configuration.

Provider policy, Control tasks, and Docker create/inspect now bind the complete
canonical `repository@sha256:manifest` reference. The runtime accepts the image
only when Docker resolves that exact reference to either the same manifest ID
or an exact `RepoDigests` entry, and container readback must bind the same
reference plus Docker's resolved local ID. A mutable tag, bare repository,
wrong registry digest, or mismatched container readback fails before execution.

## Compatibility and retained behavior

- Preview.6 keeps the Preview.5 Buyer and Provider command surface.
- CPU-only, single-GPU, and atomic 2–8 GPU offers remain supported.
- `SAME_NODE` and `P2P_REQUIRED` retain their Preview.5 meanings.
- The CUDA compatibility class and immutable validation/workload image
  manifests are unchanged.
- Existing Preview.5 configuration that copied Docker-local image IDs must be
  replaced with the exact registry references in [PROVIDER.md](PROVIDER.md)
  before setup or serve.

No release claim is made from source alone. Installation is supported only
from the published archive after verifying `SHA256SUMS`.
