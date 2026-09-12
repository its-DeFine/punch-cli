# Punch CLI

Punch CLI is the public command-line interface for the invite-only Punch Compute network.

It provides a guided `punch` entry point and two role-specific commands:

- `punch-buyer` — discover offers, order compute, inspect jobs, open brokered SSH sessions, and download output.
- `punch-provider` — join as a provider and run the supervised setup that
  verifies the host, enrolls narrow access, proves the execution surface, and
  starts the resident provider service.

The documented preview configuration uses the public Punch HTTPS endpoint. Buyers are not given a provider IP address, Docker socket, or host credential. Providers connect outbound to Punch.

> **Public preview:** The repository is public, but the network remains invitation-only. A public repository does not make the service, payments, or capacity generally available.

`Preview.19.5` is the current Ubuntu 24.04 LTS Linux/x64 public candidate
bundle. Its build receipt records
`punch-cli-0.1.0-preview.19.5-linux-x64.tar.gz` with SHA-256
`d18f8e6586f6333610f3ef33e13c27c571dbc30bdbf34f7038908283069892ae`. The
source checkout alone is not install authority. It is not a published or
installable release. Install the 19.5 bundle only from a matching non-draft
GitHub release and verify its same-release `SHA256SUMS`.

The previous [`v0.1.0-preview.19.4`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.19.4) release remains published.
Its exact archive `punch-cli-0.1.0-preview.19.4-linux-x64.tar.gz` has SHA-256
`ae7bfbb5c9e9b278e45e025853f35833997525b595a5ab6abaef54544f7450ac`. Its contract page retains the explicit new-offer terms and
pre-activation readback. The current candidate remains a free pilot without
billing or commercial SLA guarantees.

The 19.5 archive is the public CLI bundle and ships optional Livepeer
commands. Those commands remain staging-only and require an operator-provisioned
attach-existing native endpoint; native and payer/signer custody remain outside
the public CLI. The public production deployment configuration keeps Control
payment behavior `PAYMENT_DISABLED`. See [Livepeer staging compatibility](docs/LIVEPEER_STAGING_INSTALL.md).
Install the 19.5 bundle only from a matching non-draft release with its exact
archive and same-release `SHA256SUMS`; the source checkout is not install authority.

[`v0.1.0-preview.18`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.18)
is historical release provenance, not the current install target.
Its archive SHA-256 is `d144fd266328c022ef2601feb871ff62396a293d5e35e7130a3880cc0cdaf423`.
Preview.18 preserved guided
Provider and Buyer onboarding from `punch`, adds explicit Provider offer
selection and sequential replacement, and prepares a contract-bound,
copy-ready Buyer SSH command without spawning SSH. Optional OSC 52 clipboard
delivery requires explicit consent and always retains the visible command.
Publication alone is not `OWNER-READY`; that requires the separate clean
Provider and Buyer acceptance in the [Preview.18 flow](docs/PREVIEW18.md).

`v0.1.0-preview.17`, `v0.1.0-preview.16`, `v0.1.0-preview.15`, `v0.1.0-preview.14`,
`v0.1.0-preview.13`, `v0.1.0-preview.12`, and `v0.1.0-preview.11` remain
immutable historical releases. Preview.16 lacks the guided Buyer `sudo -n true`
capability probe before interactive fallback; use Preview.18 for guided Buyer
join. Preview.15 lacks the equivalent guided Provider probe repaired in
Preview.16.
Preview.12 must not be used for Provider serving because its archive contains
the documented ESM/CommonJS packaging defect. Use only release assets together
with the matching immutable image set in
[Release and verification policy](docs/RELEASES.md).

## What is public

- Installation and update tooling.
- Buyer and provider command documentation.
- Public configuration and protocol boundaries.
- Security model and operational requirements.
- Release checksums and verification instructions.

## What is not in this repository

- Punch Control, marketplace, database, or administrator code.
- Invitation minting, settlement, payout, or custody logic.
- Provider signing keys, buyer sessions, invitations, or credentials.
- Deployment infrastructure, internal endpoints, proof artifacts, or production configuration.
- The proprietary Buyer CLI and Provider Agent implementations distributed in release artifacts.

## Quick start

1. Read the [Preview.19.5 runtime contract](docs/preview19-runtime-contract.json) and the matching release notes.
2. When a matching non-draft Preview.19.5 release is published, download its archive and `SHA256SUMS`, then verify the checksum.
3. Install the matching role from that verified release; see [Installation](docs/INSTALL.md).
4. Run `punch` for the normal guided Provider or Buyer journey and follow the version-matched [Provider guide](docs/PROVIDER.md) or [Buyer guide](docs/BUYER.md).
5. Cross the documented identity/join/setup boundary only after supervised onboarding is approved.

```bash
punch-buyer --help
punch-provider --help
```

The invitation determines the authorized role. Selecting a different command locally cannot change server-side permissions.

If the Releases page has no compatible published asset, the public CLI is not yet installable on that platform. Do not build or copy proprietary CLI artifacts from another repository.

## Documentation

- [Installation and updates](docs/INSTALL.md)
- [Invitations and credentials](docs/INVITATIONS.md)
- [Buyer guide](docs/BUYER.md)
- [Provider guide](docs/PROVIDER.md)
- [Future compute staging note](docs/FUTURE_COMPUTE_STAGING.md) (staging-only, unreleased)
- [Livepeer staging compatibility](docs/LIVEPEER_STAGING_INSTALL.md) (staging-only)
- [Conditional multi-GPU orders](docs/CONDITIONAL_ORDERS.md)
- [Command reference](docs/COMMANDS.md)
- [Autonomous agent runbook](docs/AGENT_RUNBOOK.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Security model](docs/SECURITY.md)
- [Platform support](docs/PLATFORMS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Release and verification policy](docs/RELEASES.md)
- [Preview.19.2 Ubuntu Provider candidate](docs/PREVIEW19.md)
- [Preview.9 clean-v4 supervised pilot](docs/PREVIEW9.md)
- [Preview.11 supervised Buyer bootstrap](docs/PREVIEW11.md) (gated and unreleased)
- [Preview.12 guided Punch home](docs/PREVIEW12.md) (superseded for Provider serving)
- [Preview.13 Provider serve packaging correction](docs/PREVIEW13.md)
- [Preview.14 Provider readiness and release flow](docs/PREVIEW14.md)
- [Preview.15 historical guided Provider onboarding](docs/PREVIEW15.md)
- [Preview.16 historical guided Provider sudo repair](docs/PREVIEW16.md)
- [Preview.18 Provider lifecycle, Buyer SSH handoff, and owner-readiness flow](docs/PREVIEW18.md) (historical)
- [Preview.17 guided Buyer sudo repair and historical flow](docs/PREVIEW17.md)
- [Provider offer lifecycle](docs/OFFER_LIFECYCLE_PREVIEW.md) (published in Preview.14; unavailable in Preview.9)
- [NetBird connectivity](docs/NETBIRD_PREVIEW.md)
- [Preview.8 Provider offer and whole-node GPU UX contract](docs/PREVIEW8.md)
- [Targeted zero-price test contract](docs/TARGETED_ZERO_TEST.md) (supervised Preview.9 only)
- [Executable public-docs boundary](docs/EXECUTABLE_DOCS.md) (gated and unreleased)
- [Preview.7 GPU validation and setup recovery contract](docs/PREVIEW7.md)
- [Preview.6 Docker-store compatibility contract](docs/PREVIEW6.md)
- [Preview.5 atomic multi-GPU contract](docs/PREVIEW5.md)

## Licensing

The public documentation, installer, and launcher source in this repository are licensed under Apache-2.0. Proprietary Punch Buyer CLI and Provider Agent bundles are **not** covered by Apache-2.0. Their archives carry `PROPRIETARY-ARTIFACT-NOTICE.txt`; authorization and use are governed by the applicable Punch invitation or pilot agreement delivered separately.

## Security reports

Do not open a public issue for a suspected vulnerability or leaked invitation. Follow [SECURITY.md](SECURITY.md).
