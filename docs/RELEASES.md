# Release and verification policy

## Current status

This repository is the public documentation and distribution surface for Punch CLI. The network remains invitation-only. Do not treat an unpublished tag, source checkout, or draft release as an installable CLI.

The current supported external-pilot package is `v0.1.0-preview.4` for
Linux/x64. It must be used with this exact public image set:

| Kind | Immutable registry reference | Expected local image ID |
| --- | --- | --- |
| `VALIDATION` | `ghcr.io/its-define/punch-validation@sha256:b6691b0f0e0e78c9bfddbe2d327b68340e57d76b563bddbf748eed2019496d6d` | `sha256:12c26a0cf669d421791291bd321548ca336b8ec0d976dabc8fd95ebe84df6c42` |
| `WORKLOAD` | `ghcr.io/its-define/punch-workload@sha256:7d2860d642cdb898d1125da58191c58812dec18d3b1da348dd73b44f2982b627` | `sha256:afa534cb00b77ff9a7ca69c9ce750ee2fd41ce3e5bda710473c1f1952198cb96` |
| `INTERACTIVE` | `ghcr.io/its-define/punch-interactive@sha256:8734a58eea53ca64690b4cbc94cc1e4b15af4407730c2352a81b2958e3d021e4` | `sha256:2f13a113c8dd5d3c2ddb38f2e1cee7d4aaa2f7ba3c157de7743bb8d1276ea33b` |

These identities are for the published `linux/amd64` images. Pull by registry
digest and verify the local image ID before placing it in `agent.json`.

The `v0.1.0-preview.4` release adds deterministic pre-enrollment credential replacement through
`punch-provider rejoin`, explicit Sablier payout binding, unambiguous
whole-window USDC-cent pricing, and public-safe setup recovery codes. It removes
the ambiguous public `--price-minor` flag; use `--price-usdc-cents`.

The published `v0.1.0-preview.4` package passed checksum verification, extracted-archive installation,
strict parser checks, and uninstallation. The public images passed isolated
runtime smokes; the validation image additionally passed an exact UUID/CDI GPU
smoke on a Provider node. Two full private-pilot interactive lifecycles passed
with the same final product behavior before this public artifact set was
published. That is not a claim that those earlier lifecycles used this release
download.

## Preview.5 release gate

`v0.1.0-preview.5` is not yet an installable package. Its multi-GPU offer
contract is fixed in [PREVIEW5.md](PREVIEW5.md), but that contract is not a
registry reference, release tag, package archive, or compatibility promise for
preview.4.

Before it can become the current supported package, the release operator must:

1. Build the proprietary runtime packages in the private canonical release
   process; this public repository must not build or contain those artifacts.
2. From the intended public source revision, run the manually dispatched image
   workflows for `linux/amd64`. Those workflows build each candidate, run their
   bounded runtime smoke, and publish only a candidate tag.
3. On suitable NVIDIA hardware, run the release-specific validation smoke using
   the proposed multi-GPU UUID/CDI selection. For `P2P_REQUIRED`, prove the
   required all-direction CUDA peer path; a same-host allocation is not that
   proof.
4. Record the resulting immutable registry digest and Docker local image ID for
   every image in this matrix, then verify the released package against that
   final matrix. Do not substitute a workflow tag, a locally rebuilt image, or
   an earlier validation-image digest.
5. Produce the versioned archives, `SHA256SUMS`, release notes, parser
   regression results, and public-surface validation; only then publish the tag
   and non-draft GitHub Release together.

Until every item is complete, operators must continue using the published
preview.4 package and its image matrix above.

## Release contents

An installable release must contain:

- Versioned Buyer and Provider packages for each supported platform.
- `SHA256SUMS` covering every downloadable package.
- Installation and uninstallation scripts.
- The Apache-2.0 source license and notices for public components.
- `PROPRIETARY-ARTIFACT-NOTICE.txt` for any proprietary Buyer CLI or Provider Agent bundle. Apache-2.0 does not cover that bundle; authorization and use are governed by the applicable Punch invitation or pilot agreement delivered separately.
- A concise third-party notices manifest naming the exact bundled Node.js version and `ws` 8.21.1.
- The official distribution `LICENSE` copied unchanged from the exact bundled Node.js release.
- The MIT `LICENSE` for the bundled `ws` 8.21.1 dependency.
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
