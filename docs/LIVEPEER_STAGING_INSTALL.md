# Livepeer staging compatibility

> **STAGING ONLY.** This page documents optional Livepeer commands shipped in
> the version-matched Preview.19.5 CLI bundle. Payment execution remains a
> staging boundary and this page is not a settlement or production onboarding
> instruction.

Use [Installation and updates](INSTALL.md) for the normal public release
install and upgrade path. Install only from a matching non-draft release and
verify the archive against its same-release `SHA256SUMS`; this source page is not
install authority.

## Native runtime and custody boundary

The Preview.19.5 CLI does not ship the go-livepeer native orchestrator, a payer
signer, or a wallet. `attach-existing` requires an operator-provisioned native
orchestrator/runner endpoint compatible with the Punch adapter; the Punch
Provider and adapter remain separate components. The accepted staging native
artifact is build `31bb2224`, published in the [matching native
release](https://github.com/its-DeFine/go-livepeer/releases/tag/punch-livepeer-0.9.2-31bb2224-staging.1),
with binary SHA-256
`a19eb753e22e697cb09e3907beb8ec3146354297baabd5cb599add942188fc92`. Use that
asset only after the release is non-draft and its exact archive and checksum are
present. The tested target is Linux amd64 with glibc 2.35 or newer (Ubuntu
24.04). After downloading `livepeer-punch-0.9.2-31bb2224-linux-amd64.tar.gz`
from that release, verify and extract it before checking the executable:

```bash
NATIVE_ARCHIVE=livepeer-punch-0.9.2-31bb2224-linux-amd64.tar.gz
NATIVE_SHA256=a60a2e3ff3ccf5596fcb48d5ef3786919d78e8753e03a4d81d9015ccb7ca6ee9
NATIVE_DIR=/absolute/path/livepeer-0.9.2-31bb2224
printf '%s  %s\n' "$NATIVE_SHA256" "$NATIVE_ARCHIVE" | sha256sum -c -
mkdir -p "$NATIVE_DIR"
tar -xzf "$NATIVE_ARCHIVE" -C "$NATIVE_DIR"
"$NATIVE_DIR/livepeer" --version
```

The same executable can run as the orchestrator or as a separately configured
remote signer; the Punch runner/adapter is an external HTTP service. The
orchestrator operator retains its own keystore, while payer/signer custody
remains a separate remote authority. Do not replace a healthy native node or
alter its configuration during active jobs.

## Initial attach-existing setup

After an enrolled Provider has its existing identity and credential, create the
staging configuration and offer with one stable setup reference. Use private,
absolute paths for the state, credential, and runtime files:

```bash
STATE_DIR=/absolute/path/punch-provider-state
CREDENTIAL_FILE=/absolute/path/punch-provider-credential.private.json
RUNTIME_FILE=/absolute/path/livepeer-runtime.json
CONTROL_ORIGIN=https://CONTROL_ORIGIN
MACHINE_ID=PROVIDER_MACHINE_ID
SETUP_REF=STABLE_SETUP_REFERENCE

punch-provider setup \
  --machine-id "$MACHINE_ID" \
  --state-dir "$STATE_DIR" \
  --punch-origin "$CONTROL_ORIGIN" \
  --credential-file "$CREDENTIAL_FILE" \
  --idempotency-key "$SETUP_REF" \
  --livepeer-runtime-file "$RUNTIME_FILE" \
  --yes --json
punch-provider service-install --machine-id "$MACHINE_ID" --state-dir "$STATE_DIR" --yes --json
punch-provider service-start --machine-id "$MACHINE_ID" --yes --json
punch-provider service-status --machine-id "$MACHINE_ID" --json
```

`service-install` receives the custom `--state-dir`; the generated
machine-scoped unit is then addressed by `--machine-id` for the documented
`service-start` and `service-status` commands.

The supported MVP keeps the existing native orchestrator and Punch adapter in
the same host and network namespace over loopback; workload containers remain
isolated. The cross-namespace SSH bridges used by the Run40 fixture are test
plumbing, not part of the public installation path.

`setup` uses the existing machine identity and credential; the idempotency key
must stay unchanged for an exact retry. Its default Livepeer mode is
`attach-existing`, pointing at an operator-provisioned native endpoint.

## Upgrade or runtime-only change

For a verified package upgrade, use the normal installer activation path. It
preserves the existing identity, credential, state, configuration, and offers:

```bash
VERIFIED_RELEASE_DIR=/absolute/path/punch-cli-0.1.0-preview.19.5-linux-x64
(
  cd "$VERIFIED_RELEASE_DIR"
  ./install.sh --role provider --prefix "$HOME/.local"
)
```

To change only the Livepeer runtime in an existing generated Provider config,
use `config-update`; it writes a digest-named backup and does not restart the
service:

```bash
EXPECTED_CONFIG_SHA256=EXPECTED_LOWERCASE_SHA256
punch-provider config-update \
  --state-dir "$STATE_DIR" \
  --livepeer-runtime-file "$RUNTIME_FILE" \
  --expected-config-sha256 "$EXPECTED_CONFIG_SHA256" \
  --yes --json
```

Review the receipt, then explicitly restart the existing service with the
verified bundle. `config-update` preserves identity, credential, state, and
offers; it does not create onboarding, replace native or payer/signer custody,
or issue or redeem payment tickets.

Production deployment configuration keeps Control payment behavior
`PAYMENT_DISABLED`. Native binary and payer/signer custody remain outside the
CLI, and this staging page does not change the public onboarding path.
