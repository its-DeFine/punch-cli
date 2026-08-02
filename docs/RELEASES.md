# Release and verification policy

## Current status

This repository is the public documentation and distribution surface for Punch CLI. The network remains invitation-only. Do not treat an unpublished tag, source checkout, or draft release as an installable CLI.

This source checkout contains documentation, installers, launchers, and image
contexts, not a versioned proprietary runtime archive or its checksum manifest.
It therefore cannot prove a released command surface, a downloadable package,
an external Provider/Buyer run, or testnet/real-USDC settlement.

`v0.1.0-preview.8` is the supported Linux/x64 external-pilot package only when
GitHub shows its non-draft prerelease with both versioned archive and checksum
assets. This source commit alone is not an installable release. The package
must be used with this exact public image set:

| Kind | Immutable policy and runtime reference |
| --- | --- |
| `VALIDATION` | `ghcr.io/its-define/punch-validation@sha256:d7de3c3549c2e36c1f5ef5237a671c7f06e44eb101c17be2faeca12a267adf86` |
| `WORKLOAD` | `ghcr.io/its-define/punch-workload@sha256:16fdfad931a97834bbe89c6a66724405e502535b9f8c35a971e91ed07b1242ce` |
| `INTERACTIVE` | `ghcr.io/its-define/punch-interactive@sha256:8734a58eea53ca64690b4cbc94cc1e4b15af4407730c2352a81b2958e3d021e4` |

These references identify the published `linux/amd64` images. Pull and place
the same complete reference in `agent.json`. Never substitute Docker's local
`.Id`: classic and containerd image stores report different local identities
for the same OCI manifest.

The `v0.1.0-preview.8` release adds explicit `--all-gpus` whole-node setup,
transactional withdrawal of unreserved listed offers, Provider identity reuse
across offer creation and withdrawal, bounded poll timeouts, and sanitized
public error codes. It retains atomic 2–8 GPU offers bound to aligned UUID/CDI
identities, explicit `SAME_NODE` or all-direction `P2P_REQUIRED` validation,
and Buyer conditional orders with ranked hardware alternatives. It also binds
the complete OCI digest reference across classic Docker and Docker's containerd
image store. It retains
single-GPU, CPU-only, `rejoin`, Sablier payout binding, and whole-window
`--price-usdc-cents` compatibility from preview.4.

Once published, a release archive's `SHA256SUMS` asset is authoritative for its
exact bytes. Before publication, the release gate must verify the extracted
archive, its bundled CLI behavior, strict parser checks, and installation and
uninstallation with the exact bundled runtime. Source-level fixtures and an
image-workflow definition do not substitute for those archive checks or prove
an external lifecycle or settlement.

`SABLIER_USDC`, `USDC`, pricing, and payout fields describe candidate protocol
and configuration terms. They are not evidence of a completed testnet transfer
or a real-USDC payment. No funding, payout, or cancellation claim is made here
without release-specific proof and authorization.

## Multi-GPU proof boundary

The GitHub Actions smoke proves the CPU path and publication identity. A
disposable four-RTX-4090 canary separately proved that the validation image
accepts the exact selected GPU set independently of host enumeration order;
it is not a completed external Provider lifecycle. During Provider setup, Punch keeps the offer
unavailable until the digest-pinned validation container sees the complete
selected UUID/CDI bundle. `P2P_REQUIRED` additionally fails closed unless CUDA
peer access and a peer copy pass in every direction. The first external
eight-GPU Provider proof is therefore still pending and must not be described
as already completed. The exact Preview.7 validation image separately passed a
single-RTX-5080 real-node canary with compute capability 12.0, exact UUID/CDI
binding, bounded resources, and zero-container cleanup. That promotion proof
does not substitute for an external Provider lifecycle or multi-GPU P2P proof.

## GPU compatibility policy

GPU-enabled validation images belong to an immutable compatibility class. The
current class is `NVIDIA_CUDA_12_8_1_V2`: CUDA 12.8.1 on `linux/amd64`, minimum
Linux NVIDIA driver `570.124.06`, with compute capabilities 8.9 (Ada) and 12.0
(Blackwell) certified by real-node canaries. Execution still uses the exact registry
digest listed by the release; the class name is not an image selector and must
never resolve through a mutable tag.

The Provider must run the exact-image CUDA canary against the selected GPU
UUID/CDI set before offer creation. A driver below the floor, an uncertified
architecture, an image mismatch, or a failed compute/topology canary fails
before the offer exists. A new image digest or compatibility baseline creates
a new policy generation and never silently rebinds an existing offer.

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
