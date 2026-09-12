# Livepeer staging compatibility

> **STAGING ONLY / UNRELEASED.** This page describes optional Livepeer commands
> for a version-matched staging bundle. It is not a public release, payment,
> settlement, or production onboarding instruction.

Use [Installation and updates](INSTALL.md) for the normal public release
install and upgrade path. Verify the archive against the same-release
`SHA256SUMS` before extraction; Preview.19.5 is not an install target until its
public archive, checksum, and release binding are published.

## Attach-existing boundary

A matching staging bundle may expose the following operator commands:

```text
punch profile create provider NAME --livepeer-runtime-file ABSOLUTE_JSON --yes --json
punch-provider setup --machine-id ID --state-dir DIR --credential-file ABSOLUTE_JSON \
  --livepeer-runtime-file ABSOLUTE_JSON --yes --json
punch-provider service-install --machine-id ID --state-dir DIR --yes --json
punch-provider service-start --machine-id ID --yes --json
punch-provider service-status --machine-id ID --json
```

Use the bundled help from that exact staging bundle to confirm flags before
running them. The default integration is `attach-existing`: its runtime file
points to an operator-provisioned native endpoint, while native binary and
payer/signer custody remain outside the CLI. The setup path preserves the
existing identity, state, configuration, and offers.

Production deployment configuration keeps Control payment behavior
`PAYMENT_DISABLED`. This staging page does not enable payment, issue or redeem
tickets, replace a native service, or change the public onboarding path.
