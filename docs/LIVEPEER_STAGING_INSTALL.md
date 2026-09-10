# Livepeer staging install, upgrade, and rollback

> **STAGING ONLY / PRIVATE CANDIDATE / NOT PUBLIC PREVIEW.** The published
> Preview.19.4 archive does not publish this native integration. This page
> records the implemented staging seams and their operator boundaries; it is
> not a production, payment, settlement, or public-release instruction.

Use [Installation and updates](INSTALL.md) for the public installer contract
and [Release and verification policy](RELEASES.md) for the public artifact
boundary. The final private staging bundle must provide the archive-internal
`INSTALL-CANDIDATE-MANIFEST.json`, adjacent `STAGING_ONLY-RECEIPT.json`,
`SHA256SUMS`, and bundled help before these commands become a release-verified
runbook.

## Artifact and verified activation

The owner-approved private handoff must keep these files together:

- the versioned Linux/x64 archive;
- the adjacent `SHA256SUMS` entry for that archive;
- the archive-internal `INSTALL-CANDIDATE-MANIFEST.json` and adjacent
  `STAGING_ONLY-RECEIPT.json`; and
- the final bundled help output.

Verify the archive, its internal candidate manifest, adjacent staging receipt,
and checksum from that handoff before extraction. Do not copy
runtime files from chat, email, an unverified mirror, or the public Preview.19.4
release. The installer activates an already installed, byte-matching verified
release without rebuilding it:

```bash
./install.sh --activate-from ABS_EXTRACTED_VERIFIED_RELEASE_DIR \
  --role provider --prefix ABSOLUTE_PREFIX
```

For a fresh side-by-side install, use the existing role form from `INSTALL.md`:
`./install.sh --role provider --prefix ABSOLUTE_PREFIX`. Activation preserves
the existing state and changes only the owned role links after the installed
payload matches the verified release. The same activation path works with an
older verified archive for rollback.

## Candidate command draft

These commands are from the current private candidate help and remain subject
to final bundled help/hash verification. They require owner-controlled private
paths and an already approved staging handoff:

```text
punch profile create provider NAME --livepeer-runtime-file ABSOLUTE_JSON --yes --json
punch-provider setup --machine-id ID --state-dir DIR --punch-origin ORIGIN \
  --credential-file ABSOLUTE_JSON --idempotency-key KEY \
  --livepeer-runtime-file ABSOLUTE_JSON --yes --json
punch-provider service-install --machine-id ID --state-dir DIR --yes --json
punch-provider service-start --machine-id ID --yes --json
punch-provider service-status --machine-id ID --json
```

The runtime file is a private regular absolute JSON file. The validated staging
shape contains `enabled`, `environment`, loopback `baseUrl`, `appPort`,
`payerActorId`, `payerAddress`, `executionRunnerLabel`, and
`obligationRunnerLabel`, plus optional `nativeServiceMode`. Omit
`nativeServiceMode` for the default `attach-existing` mode. That mode requires
an operator-provisioned paid native endpoint/config: `baseUrl` and `appPort`
must identify the exact supplied endpoint, setup and `service-install` attach to it, and existing
signer custody is preserved. The accepted positive native quote must match the
authoritative payment plan; setup never replaces this service.

For lifecycle-only testing, the runtime may explicitly set this JSON field:

```json
{ "nativeServiceMode": "offchain-fixture" }
```

Only `offchain-fixture` selects the packaged managed Go protocol fixture. It is
staging/offchain-only and cannot satisfy positive-price/native admission, quote
compatibility, payment, or settlement acceptance. In that mode, setup and
`service-install` retain the same Provider user, state, and parent service, then
generate the native unit and its two registrations: one persistent execution
runner and one single-shot obligation runner. The managed unit is linked with
`PartOf`/`WantedBy`; its packaged binary is hash/version checked against the
adjacent manifest and receipt. Use exact receipt unit names; do not guess or
hardcode them.

## Existing native node handoff

The default `attach-existing` path is an existing-node operation. The operator's
existing install/upgrade journey provisions the paid native endpoint/config; no
new Punch command or helper writes a registry, adds a listener, or replaces the
existing binary, config, wallet, unit, or signer. Only the existing native CLI management endpoint is unauthenticated; keep it
loopback-only and do not add or broaden a listener.

Persist the complete existing registry file because native startup reads
`-liveRunnerConfig FILE` once and does not watch it. Preserve its prior bytes
and unrelated entries. After the file is ready, POST to the existing native CLI management port, then query discovery at the exact configured native `baseUrl`:

```sh
curl --fail --silent --show-error \
  --request POST \
  --header 'content-type: application/json' \
  "http://127.0.0.1:<EXISTING_CLI_PORT>/registerLiveRunners" \
  --data-binary @existing-static-registry.json
curl --fail --silent --show-error \
  "${NATIVE_BASE_URL}/discovery"
```

`registerLiveRunners` validates and atomically upserts the full registry,
preserving existing label IDs and active sessions and leaving omitted labels
unchanged. The discovery response must show the exact positive per-runner
provider price required by the accepted native quote. Use the exact native discovery price, currency, and unit for the accepted
`nativeBinding`. Keep the Punch offer price and native quote separately displayed
and bound; do not invent equivalence or perform manual FX conversion. Any
configured conversion inside the existing native node remains its behavior.
An incompatible node uses the operator's existing upgrade process; do not parse
or replace its service definition.

## Local config update and downgrade

`config-update` changes only the canonical local Provider config. It requires a
raw-byte expected digest, `--yes`, and exactly one of the runtime or restore
inputs:

```text
punch-provider config-update --state-dir DIR \
  --livepeer-runtime-file ABSOLUTE_JSON \
  --expected-config-sha256 SHA256 --yes

punch-provider config-update --state-dir DIR \
  --restore-config-backup ABSOLUTE_JSON \
  --expected-config-sha256 SHA256 --yes
```

A successful update creates a digest-named private backup and reports the new
digest. It does not restart or reload a service. Review the result, then use
the existing service lifecycle commands. Before downgrading to an older CLI
that predates `livepeerRuntime`, restore the retained pre-runtime backup first;
otherwise the old CLI must reject the newer config field.

A bounded downgrade is: stop the existing Provider service; for
`offchain-fixture`, disable and stop the receipt-bound managed unit; for the
default `attach-existing` mode, use the operator's existing native-service
rollback procedure without changing its signer custody; restore the retained
config backup; activate the previously verified archive with `--activate-from`;
then run the older artifact's `service-install` and explicit `service-start`.
Preserve the existing identity, offers, credentials, sessions, and state. Do
not create a new identity, replace the paid endpoint, or delete an offer as
part of rollback.

## Acceptance boundary

The implementation has focused local seams for runtime validation, profile/setup
forwarding, native service rendering, CAS config update/restore, and verified
archive activation. Final staging acceptance remains pending until the private
bundle supplies:

- immutable archive, manifest, checksum, and help identities;
- the receipt-bound native unit and runner registrations;
- final candidate provider/native discovery, service restart, stop, and cleanup
  evidence (the separate synthetic service-hook receipt already covers unit
  installation, parent-stop propagation, runner discovery, and cleanup); and
- an owner-approved staging handoff with no production or live-money effect.

Until those receipts exist, this page is a candidate handoff, not an accepted
native release.
