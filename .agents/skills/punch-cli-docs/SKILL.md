---
name: punch-cli-docs
description: Update Punch public CLI documentation from verified command behavior and keep proof claims within the released artifact boundary.
---

# Punch CLI documentation

Use this skill when CLI commands, flags, lifecycle behavior, images, or release proof change.

1. Identify the exact runtime/release artifact whose behavior is being documented. Source notes or a private canary are not a released public command contract.
2. Capture `--help` and focused behavior from that exact artifact. Never copy credentials, invitations, private paths, logs, or internal configuration into this repository.
3. Update only the affected guide, command reference, troubleshooting text, and release boundary.
4. Keep these states distinct: candidate source, published prerelease, external lifecycle proof, interactive SSH proof, Buyer stop/revocation, and payment settlement.
5. Run `./tests/validate-without-rg.sh`. The GitHub `validate` workflow runs the same gate on every push and pull request.

If the exact artifact is unavailable or the docs would claim behavior not present in the public CLI, fail closed and report the missing artifact instead of guessing.
