# Release and verification policy

## Current status

This repository is the public documentation and distribution surface for Punch CLI. The network remains invitation-only. Do not treat an unpublished tag, source checkout, or draft release as an installable CLI.

This source checkout contains documentation, installers, launchers, and image
contexts, not a versioned proprietary runtime archive or its checksum manifest.
The GitHub release assets are the installable surface.

[`Preview.19.2`](PREVIEW19.md) is the current Ubuntu 24.04 LTS Linux/x64
public candidate. It is not a published or installable release, and this
source checkout is not install authority. The candidate remains subject to
final acceptance; do not infer completion or publication from this page.
Its exact source and archive identity will be read from the matching archive's
bundled `RELEASE-CONTRACT.json` and `RELEASE-BINDING.json`, together with its
same-release `SHA256SUMS`, after the final rebuild.

Until that candidate is accepted and published, [`v0.1.0-preview.18`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.18)
is the last published Linux/x64 prerelease. The package used this exact public
image set:

| Kind | Immutable policy and runtime reference |
| --- | --- |
| `VALIDATION` | `ghcr.io/its-define/punch-validation@sha256:d7de3c3549c2e36c1f5ef5237a671c7f06e44eb101c17be2faeca12a267adf86` |
| `WORKLOAD` | `ghcr.io/its-define/punch-workload@sha256:16fdfad931a97834bbe89c6a66724405e502535b9f8c35a971e91ed07b1242ce` |
| `INTERACTIVE` | `ghcr.io/its-define/punch-interactive@sha256:ba8c40d0e2610c43f306db04e3235442606bbec2fdcb3d37c745b23ecdaf9311` |

These references identify the published `linux/amd64` images. Pull and place
the same complete reference in `agent.json`. Never substitute Docker's local
`.Id`: classic and containerd image stores report different local identities
for the same OCI manifest.

## Preview.19.2 Ubuntu Provider candidate

Preview.19.2 narrows the candidate Provider target to Ubuntu 24.04 LTS on
Linux/x64 and carries the resource-aware offer lifecycle and contract-scoped
Buyer gateway described in [Preview.19.2](PREVIEW19.md). This section is a
candidate contract only: no release asset, archive digest, or live acceptance
claim is published here. Use the bundled release metadata as the exact source
and archive identity after the final rebuild.

## Preview.18 historical Provider lifecycle and Buyer SSH handoff release

Preview.18 is the last published Linux/x64 prerelease. It preserves the
guided onboarding contract and adds authenticated Provider offer selection,
sequential replacement using the same environment/setup binding, a strict
targeted canonical-zero Buyer gate, scoped SSH egress consent, and a visible
copy-ready SSH command that Punch does not execute. Optional OSC 52 delivery is
affirmative-only and retains the visible fallback; `Stop` remains the distinct
contract revocation and cleanup action.

Install only the exact 43,811,105-byte
`punch-cli-0.1.0-preview.18-linux-x64.tar.gz` whose SHA-256 is
`d144fd266328c022ef2601feb871ff62396a293d5e35e7130a3880cc0cdaf423`
after verifying it against the matching release `SHA256SUMS`. See
[Preview.18](PREVIEW18.md), its
[runtime contract](preview18-runtime-contract.json), and release-bound
[command reference](PREVIEW18_COMMAND_REFERENCE.md).

## Preview.17 historical guided Buyer sudo repair release

Preview.17 is an immutable historical Linux/x64 prerelease. Install authority
comes only from its matching non-draft GitHub prerelease after the exact archive
verifies against the same-release `SHA256SUMS`; source identity or documentation
alone does not authorize installation. Publication alone is not `OWNER-READY`
until the released archive and version-matched docs pass both independent clean
Provider and Buyer journeys.

The guided Provider flow and direct command surface are unchanged. After Buyer
join confirmation, Preview.17 probes passwordless capability with `sudo -n true`
before falling back to interactive `sudo -v`. Failed authorization stops before
dependency installation or join. Direct non-interactive Buyer join continues
to require `--yes` and cached sudo. See [Preview.17](PREVIEW17.md), its
[runtime contract](preview17-runtime-contract.json), and the release-bound
[command reference](PREVIEW17_COMMAND_REFERENCE.md).

## Preview.16 historical guided Provider sudo repair release

Preview.16 is an immutable historical Linux/x64 prerelease. It repaired the
guided Provider passwordless capability probe, but lacks the equivalent Buyer
probe added in Preview.17; use Preview.17 for guided Buyer join. See
[Preview.16](PREVIEW16.md), its
[runtime contract](preview16-runtime-contract.json), and the release-bound
[command reference](PREVIEW16_COMMAND_REFERENCE.md).

## Preview.15 historical guided Provider onboarding release

Preview.15 is an immutable historical Linux/x64 prerelease. It lacks the
Preview.16 guided Provider `sudo -n true` capability probe before interactive
fallback; use Preview.16 or later for guided Provider onboarding.

Preview.15 introduced `punch` then **Provider** as the normal entry point:
preflight before identity, exact dependency-plan consent, friendly capacity
selection, explicit local identity consent, a signed public-only onboarding
request, durable `WAITING_FOR_INVITE`, supervised `INVITE_READY`, secure
owner-delivered invitation import, automatic setup through `LISTED`, and one
authenticated overview. Direct
`punch-provider ...` commands remain advanced automation and recovery surfaces.
See [Preview.15](PREVIEW15.md), its
[runtime contract](preview15-runtime-contract.json), and the release-bound
[command reference](PREVIEW15_COMMAND_REFERENCE.md).

## Preview.10 superseded

Preview.10 was never publicly promoted: exact archive acceptance found that the
Provider rejected documented `--offer-id`. Its immutable tags, private
prerelease, and unpromoted public draft remain historical records; Preview.11
supersedes it.

## Preview.11 gate

Preview.11 is `GATED_UNRELEASED`. It becomes installable only when a non-draft
GitHub prerelease publishes the matching Linux/x64 archive and `SHA256SUMS`, and
the exact archive passes isolated Buyer acceptance. Its private runtime binding
is release source `0e615565780e60c49fd1c5fc6d1d07940e1d4be4`, tree
`1b78916a4896459365b7ad3439a5e67bb5794f99`, and proven runtime/builder commit
`76041898382f764d3404ecb12112b684bafad1af`.

Preview.11 adds role-aware Buyer NetBird bootstrap to `join`: explicit consent
before any privileged client installation, one one-off ephemeral enrollment
bound to the approved Buyer and narrow Buyer group, private setup-key-file
delivery, startup connectivity verification, and immediate local key removal.
The Buyer needs no NetBird dashboard, login, or second code. The payment and
Provider-governance boundaries below remain unchanged. See
[Preview.11](PREVIEW11.md) and its
[runtime contract](preview11-runtime-contract.json).

Preview.11 also includes Provider-owned `offer-status`, `offer-unlist`, and
`offer-retire`. A focused disposable PostgreSQL integration passes their
ownership/non-enumeration, replay, order-versus-unlist, and terminal-retirement
contract. That proof is not a release artifact or exact archive acceptance.
The commands remain unavailable until the same non-draft release publishes the
matching archive and checksum assets.

## Preview.12 gate

Preview.12 is `GATED_UNRELEASED`. It adds the continuous state-aware `punch`
home and the dedicated autonomous-agent runbook while preserving every
Preview.11 lifecycle, access, zero-price, and settlement boundary. Its exact
private release source is commit
`67b8735939154375fd6da3a44d540631af55777d`, tree
`ebac3e5a46d7005c8fd898d427b6f508326ab227`. See
[Preview.12](PREVIEW12.md) and its
[runtime contract](preview12-runtime-contract.json).

It becomes installable only after the matching Linux/x64 archive and
`SHA256SUMS` are published in a non-draft prerelease. Guided and autonomous
local acceptance does not replace the separate Preview.11 NetBird/SSH proof
or constitute exact Preview.12 archive acceptance.

## Preview.14 historical Provider readiness release

Preview.14 is a published Linux/x64 prerelease, not permission to install a
source checkout or infer a command or flag from an earlier preview. Its public
command reference is bound to the exact Linux/x64 archive, `SHA256SUMS`, runtime
contract, and canonical packaged CLI surface now present in the non-draft
prerelease. The release gate also required an independent
clean-host Provider-to-Buyer lifecycle report, including real image pulls,
container SSH readiness, Buyer stop/revocation, cleanup, and capacity release.

The Preview.14 provider setup state is `PENDING_AGENT` until a fresh signed
pre-list proof and supervised service readiness can advance it to `LISTED`.
Normal setup owns dependency consent/install, immutable image proof, one-use
Provider NetBird enrollment, canonical config generation, hardened systemd
installation/start, and the activation heartbeat in one confirmed CLI session.
Provider identity and its public onboarding packet precede the bound invitation.
Buyer join resumes until the exact NetBird binding is confirmed. Guided TTY use
may prompt for `sudo`; direct non-interactive setup requires cached `sudo`.
Multiple supervised Providers are supported, every order requires an eligible
offer, and the authorized window is capped at `259200` seconds. Manual NetBird setup and a
hand-written `--agent-config` are not the normal Preview.14 path.
The release retains the supervised invitation-only, owner-targeted `$0`
policy; it does not activate payment, payout, settlement, or refunds. See
[Preview.14](PREVIEW14.md) and its
[runtime contract](preview14-runtime-contract.json).

The Preview.14 release was additionally blocked unless the packaged Provider help, packaged
Buyer help, release-contract command lists, generated public command contract,
and guided forwarding surface describe the same commands and flags.

## Preview.13 Provider serve correction

Preview.13 supersedes Preview.12 for Provider serving. Preview.12's immutable
Provider bundle terminates at startup with `Dynamic require of "events" is not
supported`. Preview.13 adds the Node ESM `createRequire` bridge required by the
bundled CommonJS `ws` dependency and adds a resident-serve regression gate.

The exact private release source is commit
`7af5f302db2076cfde14c69baf1e5d8b1d4017ab`, tree
`b20ce13f3ad534d4766880feb11284a3e161a24e`. The release preserves Preview.12
identities, credentials, state directories, offers, command semantics, and all
invitation-only, owner-targeted zero-price, NetBird, and no-settlement
boundaries. See [Preview.13](PREVIEW13.md) and its
[runtime contract](preview13-runtime-contract.json).

It is installable only when the non-draft GitHub prerelease publishes the
matching Linux/x64 archive and `SHA256SUMS` and the exact shipped archive passes
the documented install, Provider serve, and zero-residual acceptance.

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
