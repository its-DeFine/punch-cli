# Punch CLI

Punch CLI is the public command-line interface for the invite-only Punch Compute network.

It provides a guided `punch` entry point and two role-specific commands:

- `punch-buyer` — discover offers, order compute, inspect jobs, open brokered SSH sessions, and download output.
- `punch-provider` — join as a provider and run the supervised setup that
  verifies the host, enrolls narrow access, proves the execution surface, and
  starts the resident provider service.

The documented preview configuration uses the public Punch HTTPS endpoint. Buyers are not given a provider IP address, Docker socket, or host credential. Providers connect outbound to Punch.

> **Public preview:** The repository is public, but the network remains invitation-only. A public repository does not make the service, payments, or capacity generally available.

[`v0.1.0-preview.15`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.15)
is the current published Linux/x64 prerelease. Install only its matching
`punch-cli-0.1.0-preview.15-linux-x64.tar.gz` and `SHA256SUMS` assets; a source
commit alone is not an installable release. Preview.15 promotes guided Provider
onboarding from `punch`, with host preflight before identity, explicit identity
consent, durable `WAITING_FOR_INVITE`, supervised `INVITE_READY`, secure
invitation resume, automatic supervised setup, and one Provider overview.
Publication alone is not `OWNER-READY`; that requires the separate clean
Provider and Buyer acceptance in the [Preview.15 flow](docs/PREVIEW15.md).

`v0.1.0-preview.14`, `v0.1.0-preview.13`, `v0.1.0-preview.12`, and
`v0.1.0-preview.11` remain immutable historical releases. Preview.12 must not be
used for Provider serving because its archive contains the documented
ESM/CommonJS packaging defect. Use only release assets together with the
matching immutable image set in [Release and verification policy](docs/RELEASES.md).

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

1. Download the Preview.15 Linux/x64 archive and `SHA256SUMS` from the [published release](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.15), then verify the checksum.
2. Install the matching role from that verified release; see [Installation](docs/INSTALL.md).
3. For guided Provider onboarding, follow the version-matched [Preview.15 Provider guide](docs/PROVIDER.md). Buyer invitations follow the separate [invitation guide](docs/INVITATIONS.md).
4. Cross the documented identity/join/setup boundary only after supervised onboarding is approved.

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
- [Conditional multi-GPU orders](docs/CONDITIONAL_ORDERS.md)
- [Command reference](docs/COMMANDS.md)
- [Autonomous agent runbook](docs/AGENT_RUNBOOK.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Security model](docs/SECURITY.md)
- [Platform support](docs/PLATFORMS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Release and verification policy](docs/RELEASES.md)
- [Preview.9 clean-v4 supervised pilot](docs/PREVIEW9.md)
- [Preview.11 supervised Buyer bootstrap](docs/PREVIEW11.md) (gated and unreleased)
- [Preview.12 guided Punch home](docs/PREVIEW12.md) (superseded for Provider serving)
- [Preview.13 Provider serve packaging correction](docs/PREVIEW13.md)
- [Preview.14 Provider readiness and release flow](docs/PREVIEW14.md)
- [Preview.15 guided Provider onboarding and owner-readiness flow](docs/PREVIEW15.md)
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
