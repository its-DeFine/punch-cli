# Preview.7 release contract

> **Invitation-only preview:** use `v0.1.0-preview.7` only when its non-draft
> GitHub prerelease provides the Linux/x64 archive and checksum together with
> the immutable image matrix in [RELEASES.md](RELEASES.md).

## Exact multi-GPU validation

Preview.7 compares the selected and observed GPU UUIDs as canonical sets. The
validation container still requires the exact same UUIDs and CDI identities;
only enumeration order is ignored. A missing, duplicated, substituted, or
additional GPU still fails before an offer becomes available.

## Provider setup rollover

A Provider with a completed setup that has subsequently been refreshed may use
a new setup reference without deleting or rebinding its prior journal. Punch
accepts rollover only when the refreshed state remains cryptographically bound
to the same machine identity, organization, immutable capacity and terms, and
offer. Drift, signature failure, a pending setup, or a conflicting archive
fails closed.

Setup and resident refresh share one Linux advisory lock. Concurrent setup
attempts return a bounded busy error instead of overwriting the journal; the
kernel releases the lock automatically if the process exits.

## Compatibility and retained behavior

- Preview.7 keeps the Preview.6 Buyer and Provider command surface.
- Preview.6 registry-digest handling remains unchanged.
- CPU-only, single-GPU, and atomic 2–8 GPU offers remain supported.
- `SAME_NODE` and `P2P_REQUIRED` retain their Preview.5 meanings.
- The CUDA compatibility class advances to `NVIDIA_CUDA_12_8_1_V2`; its exact
  validation manifest certifies compute capabilities 8.9 and 12.0 under the
  fail-before-offer canary policy listed in [RELEASES.md](RELEASES.md).

No release claim is made from source alone. Installation is supported only
from the published archive after verifying `SHA256SUMS`.
