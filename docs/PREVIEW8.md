# Preview.8 release contract

> **Invitation-only preview:** use `v0.1.0-preview.8` only when its non-draft
> GitHub prerelease provides the Linux/x64 archive and checksum together with
> the immutable image matrix in [RELEASES.md](RELEASES.md).

## Whole-node GPU setup

`--all-gpus` is an explicit shortcut for a dedicated execution node. It derives
the complete locally visible GPU UUID/CDI set, GPU count, and aggregate observed
VRAM. Multi-GPU bundles default to `SAME_NODE`; `P2P_REQUIRED` remains an
explicit stronger topology requirement. Punch never silently advertises all
visible GPUs because a shared node may already use some devices elsewhere.

## Offer lifecycle UX

An enrolled Provider reuses the same Provider and machine identities for
session renewal, serving, draining, setup rollover, and withdrawal. A fresh
setup reference creates another immutable offer; it does not require another
invitation or re-registration.

`withdraw` pauses one exact owned offer only while it remains unreserved and
`LISTED`. It preserves audit history. Control serializes withdrawal with Buyer
purchase, so whichever transaction reserves or pauses the offer first wins and
capacity already reserved for a Buyer cannot be withdrawn. The offer digest is
bound transactionally by Control; an optional explicit digest adds a strict
stale-version check.

## Retained safety and compatibility

- Preview.8 retains Preview.7 setup rollover, advisory locking, GPU-set
  canonicalization, and the `NVIDIA_CUDA_12_8_1_V2` compatibility class.
- CPU-only, single-GPU, manual atomic 2–8 GPU selection, `SAME_NODE`, and
  `P2P_REQUIRED` remain supported.
- Provider claim and relay polling use bounded timeouts. Mutating setup and
  withdrawal requests remain idempotent and use stable operator references.
- Public Provider errors expose only bounded codes and status metadata, never
  raw upstream bodies or credentials.

No release claim is made from source alone. Installation is supported only
from the published archive after verifying `SHA256SUMS`.
