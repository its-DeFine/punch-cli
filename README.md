# Punch CLI

Punch CLI is the public command-line interface for the invite-only Punch Compute network.

It provides two commands:

- `punch-buyer` — discover offers, order compute, inspect jobs, open brokered SSH sessions, and download output.
- `punch-provider` — join as a provider, inventory the local execution node, publish bounded capacity, and run the resident provider agent.

The documented preview configuration uses the public Punch HTTPS endpoint. Buyers are not given a provider IP address, Docker socket, or host credential. Providers connect outbound to Punch.

> **Public preview:** The repository is public, but the network remains invitation-only. A public repository does not make the service, payments, or capacity generally available.

The current supported external-pilot package is `v0.1.0-preview.3` for
Linux/x64. Use only the matching immutable image set in
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

1. Download `v0.1.0-preview.3` for Linux/x64 from the repository's Releases page and verify its checksum.
2. Obtain a single-use Buyer or Provider invitation from Punch.
3. Install the matching CLI from that verified release; see [Installation](docs/INSTALL.md).
4. Follow the [Buyer guide](docs/BUYER.md) or [Provider guide](docs/PROVIDER.md).

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
- [Command reference](docs/COMMANDS.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Security model](docs/SECURITY.md)
- [Platform support](docs/PLATFORMS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Release and verification policy](docs/RELEASES.md)

## Licensing

The public documentation, installer, and launcher source in this repository are licensed under Apache-2.0. Proprietary Punch Buyer CLI and Provider Agent bundles are **not** covered by Apache-2.0. Their archives carry `PROPRIETARY-ARTIFACT-NOTICE.txt`; authorization and use are governed by the applicable Punch invitation or pilot agreement delivered separately.

## Security reports

Do not open a public issue for a suspected vulnerability or leaked invitation. Follow [SECURITY.md](SECURITY.md).
