# Preview.10 supervised Buyer bootstrap

> **GATED_UNRELEASED:** `v0.1.0-preview.10` is not installable until GitHub
> publishes a non-draft Linux/x64 prerelease with a matching archive and
> `SHA256SUMS` asset.

Preview.10 keeps the Preview.9 clean-v4, owner-targeted zero-price lifecycle and
adds supervised NetBird bootstrap to `punch-buyer join`. Payment settlement,
payouts, refunds, public free offers, and self-service Provider onboarding stay
disabled.

## Buyer join contract

On Linux/x64, `join` first validates the Punch invitation. It then checks for
the official NetBird client. If NetBird is missing, the CLI explains the
privileged change and requires interactive confirmation or the explicit
automation flag `--yes` before downloading the official installer. It never
runs an unauthenticated `curl | sh` pipeline.

After Buyer authentication, Control may issue one one-off, ephemeral setup key
bound to that approved Buyer and the existing narrow Buyer group. The CLI gives
the key to NetBird through a private mode-`0600` temporary file, verifies
startup connectivity, and immediately removes the local file. The Buyer does
not need a NetBird dashboard, NetBird login, or second enrollment code. Setup
key values must not appear in command arguments, public configuration, output,
or logs. A consumed enrollment cannot mint a second peer.

Unsupported platforms and declined privileged installation fail closed before
any package change. If enrollment fails, retry the exact same Punch invitation;
do not obtain or paste a setup key manually.

## Proof boundary

The machine-readable [Preview.10 runtime contract](preview10-runtime-contract.json)
binds private runtime commit `99fe8c30863ec331228c5f3696ecdbecb99d7b5d`,
Linux/x64, the existing immutable images, and this bootstrap contract. Focused
local tests are not a live Buyer acceptance. The release remains gated until an
isolated Linux/x64 Buyer completes join, discovery, targeted `$0` order,
brokered SSH, Buyer stop, revocation, and cleanup with the exact archive.
