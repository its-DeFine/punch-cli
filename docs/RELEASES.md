# Release and verification policy

## Current status

This repository is the public documentation and distribution surface for Punch CLI. The network remains invitation-only. Do not treat an unpublished tag, source checkout, or draft release as an installable CLI.

## Release contents

An installable release must contain:

- Versioned Buyer and Provider packages for each supported platform.
- `SHA256SUMS` covering every downloadable package.
- Installation and uninstallation scripts.
- The Apache-2.0 source license and notices for public components.
- A separate notice and license for any proprietary Provider-agent artifact.
- Release notes identifying protocol, configuration, and platform compatibility.
- Strict command-parser regression tests that reject unknown and duplicate flags.
- Release-specific tests for invitation handling, output verification, brokered SSH proxying, Provider drain semantics, and fail-closed configuration.

## Verification

Download packages and `SHA256SUMS` from the same GitHub Release. Verify before installation:

```bash
sha256sum -c SHA256SUMS --ignore-missing
```

On macOS, use `shasum -a 256` when `sha256sum` is unavailable and compare the full digest exactly.

A checksum proves that a download matches the release manifest; it does not independently prove who produced it. Cryptographic signing or build attestation, when available, will be documented in the specific release. Do not assume either exists when it is not listed.

## Compatibility

Preview releases may change command or configuration schemas. Keep the Buyer and Provider on versions listed as compatible with the public Punch endpoint. Never downgrade by replacing only one executable inside an installed release.

## Rollback

Installers must keep identity, credential, session, and state files outside the versioned program directory. Rolling back the program must not copy, rewrite, or downgrade those files. Provider operators must drain before changing a running agent version.
