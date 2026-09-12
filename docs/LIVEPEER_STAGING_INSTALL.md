# Livepeer staging compatibility

> **STAGING ONLY.** This page documents optional Livepeer integration carried
> by the version-matched Preview.19.5 CLI bundle. Payment execution remains a
> staging boundary and this page is not a settlement or production onboarding
> instruction.

Use [Installation and updates](INSTALL.md) for the normal public release
install and upgrade path. Verify the archive against the same-release
`SHA256SUMS`; Preview.19.5 remains unpublished until its matching public release
assets are released.

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
