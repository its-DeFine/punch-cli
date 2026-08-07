# Release and verification policy

## Current status

This repository is the public documentation and distribution surface for Punch CLI. The network remains invitation-only. Do not treat an unpublished tag, source checkout, or draft release as an installable CLI.

This source checkout contains documentation, installers, launchers, and image
contexts, not a versioned proprietary runtime archive or its checksum manifest.
The GitHub release assets are the installable surface.

`v0.1.0-preview.9` remains the supported Linux/x64 supervised-pilot package only when
GitHub shows its non-draft prerelease with both versioned archive and checksum
assets. This source commit alone is not an installable release. The package
must be used with this exact public image set:

| Kind | Immutable policy and runtime reference |
| --- | --- |
| `VALIDATION` | `ghcr.io/its-define/punch-validation@sha256:d7de3c3549c2e36c1f5ef5237a671c7f06e44eb101c17be2faeca12a267adf86` |
| `WORKLOAD` | `ghcr.io/its-define/punch-workload@sha256:16fdfad931a97834bbe89c6a66724405e502535b9f8c35a971e91ed07b1242ce` |
| `INTERACTIVE` | `ghcr.io/its-define/punch-interactive@sha256:ba8c40d0e2610c43f306db04e3235442606bbec2fdcb3d37c745b23ecdaf9311` |

These references identify the published `linux/amd64` images. Pull and place
the same complete reference in `agent.json`. Never substitute Docker's local
`.Id`: classic and containerd image stores report different local identities
for the same OCI manifest.

## Preview.10 gate

Preview.10 is `GATED_UNRELEASED`. It becomes installable only when a non-draft
GitHub prerelease publishes the matching Linux/x64 archive and `SHA256SUMS`, and
the exact archive passes isolated Buyer acceptance. Its private runtime binding
is release source `681fc45f56d17515a3202ce27de6006181a5ba6b`, tree
`0ec00e7b08d4e52b7d874bce8f7ae1fadd48be06`, and proven runtime/builder commit
`76041898382f764d3404ecb12112b684bafad1af`.

Preview.10 adds role-aware Buyer NetBird bootstrap to `join`: explicit consent
before any privileged client installation, one one-off ephemeral enrollment
bound to the approved Buyer and narrow Buyer group, private setup-key-file
delivery, startup connectivity verification, and immediate local key removal.
The Buyer needs no NetBird dashboard, login, or second code. The payment and
Provider-governance boundaries below remain unchanged. See
[Preview.10](PREVIEW10.md) and its
[runtime contract](preview10-runtime-contract.json).

Preview.10 also includes Provider-owned `offer-status`, `offer-unlist`, and
`offer-retire`. A focused disposable PostgreSQL integration passes their
ownership/non-enumeration, replay, order-versus-unlist, and terminal-retirement
contract. That proof is not a release artifact or exact archive acceptance.
The commands remain unavailable until the same non-draft release publishes the
matching archive and checksum assets.

Preview.9 adds the clean-v4 supervised lifecycle: operator-approved Provider
onboarding, owner-targeted zero-price offers, idempotent Buyer order recovery,
contract-scoped NetBird SSH, released Buyer stop, access revocation, signed
cleanup, and capacity release. It carries a reference Provider service and
agent configuration but does not install or enable them automatically.

Once published, a release archive's `SHA256SUMS` asset is authoritative for its
exact bytes. Before publication, the release gate must verify the extracted
archive, its bundled CLI behavior, strict parser checks, and installation and
uninstallation with the exact bundled runtime. Source-level fixtures and an
image-workflow definition do not substitute for those archive checks or prove
an external lifecycle or settlement.

Preview.9 does not activate payment, payout, settlement, or refunds. Its zero
price is accepted only with a single-use owner authorization bound to the exact
Provider, machine, capacity, window, and designated Buyer. The Buyer has no
zero-price flag, the Provider cannot issue the authorization, and the offer is
not publicly claimable. See [Targeted zero-price test](TARGETED_ZERO_TEST.md).

The machine-readable [Preview.9 runtime contract](preview9-runtime-contract.json)
binds the frozen lifecycle proof and image set. One owner-operated RTX 5080
Provider-to-Buyer canary proved exact order replay, NetBird-backed brokered SSH,
Buyer stop, active-session closure, fresh-access denial, signed cleanup, and
capacity release. It does not prove general external-provider readiness or any
financial behavior.

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
