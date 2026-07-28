# Installation and updates

Punch CLI installable packages are distributed only through versioned GitHub Releases. A source checkout of this repository contains documentation and installer source, not the proprietary Provider agent. Do not install a binary received through chat, email, or an unverified mirror.

## Supported preview platforms

See [Platform support](PLATFORMS.md). Provider execution is currently limited to supported Linux nodes. Buyer support may cover additional platforms release by release.

## Install from a release

1. Open a published, non-draft release from this repository's **Releases** page.
2. Download exactly one archive for your operating system and architecture.
3. Download `SHA256SUMS` from the same release.
4. Locate the line whose filename exactly matches the chosen archive and verify its full digest.
5. Verify any signature or attestation only by the release-specific procedure; its presence is never implied.
6. Extract the verified archive and run its included installer with the desired role.

```bash
sha256sum -c SHA256SUMS --ignore-missing
./install.sh --role buyer
# or
./install.sh --role provider
```

The checksum command must report the exact downloaded archive as `OK`. An empty result or a check of a different filename is a failure. On macOS, use `shasum -a 256 ARCHIVE` and compare the complete digest to the exact matching line in `SHA256SUMS`.

Release packages carry their supported runtime privately under the Punch installation directory; the installer does not add a system-wide Node installation.

## Default locations

User installation:

```text
~/.local/bin/punch-buyer
~/.local/bin/punch-provider
~/.local/share/punch-cli/<version>/
~/.config/punch/
```

Provider service installation may additionally use a dedicated system account and state directory. The release-specific provider installer must show every privileged change before applying it.

## Update

Install the new verified version. The installer changes the command links only after all files and checksums have validated. It must not overwrite invitation, session, identity, credential, or state files.

## Uninstall

Use the release's `uninstall.sh`. Provider operators must drain active capacity before stopping or removing an agent. Uninstalling the CLI does not revoke a server-side identity; request revocation separately when required.

## No `curl | sh`

During the invitation-only preview, download and inspect installation scripts before running them. Documentation will not ask users to pipe an unauthenticated network response directly into a shell.
