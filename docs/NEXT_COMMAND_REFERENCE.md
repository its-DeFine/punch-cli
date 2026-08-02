# Next gated command reference

This generated reference is a `GATED_UNRELEASED` public contract. It is
derived from the manager-approved sanitized handoff and the separate trust
registry fixture, whose `releaseAuthority` is `false`. It proves only
`LOCAL_DETERMINISTIC_PASS`; it does not prove a published artifact,
provenance, deployment, or live Buyer/Provider E2E.

Do not use these commands against live systems until a release-specific
artifact and authority are published. Current released guidance remains in
[Command reference](COMMANDS.md), [Buyer guide](BUYER.md), and [Provider guide](PROVIDER.md).

<!-- GENERATED CLI CONTRACT:BEGIN -->
<!-- proof: LOCAL_DETERMINISTIC_PASS -->
<!-- authority: MANAGER_APPROVED_HANDOFF_ONLY; release-authority: false -->
<!-- contract-digest: ed2258c6839d161c0111c2d386a1f79ef67f23de31feb9a9265e645c88341e7f -->
<!-- artifact-digest: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa -->
{
  "schemaVersion": "punch.public-cli-contract.v1",
  "contractDigest": "ed2258c6839d161c0111c2d386a1f79ef67f23de31feb9a9265e645c88341e7f",
  "proofLabel": "LOCAL_DETERMINISTIC_PASS",
  "releaseStatus": "GATED_UNRELEASED",
  "authority": "MANAGER_APPROVED_HANDOFF_ONLY",
  "artifactId": "punch-public-safe-contract-fixture",
  "artifactDigest": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "provider": {
    "executable": "punch-provider",
    "booleanFlags": [
      "help",
      "json",
      "all-gpus"
    ],
    "commands": [
      {
        "name": "join",
        "flags": [
          "invitation",
          "punch-origin",
          "credential-file"
        ],
        "synopsis": "join --invitation ABSOLUTE_JSON --punch-origin ORIGIN --credential-file ABSOLUTE_JSON"
      },
      {
        "name": "rejoin",
        "flags": [
          "invitation",
          "punch-origin",
          "credential-file"
        ],
        "synopsis": "rejoin --invitation ABSOLUTE_JSON --punch-origin ORIGIN --credential-file ABSOLUTE_JSON"
      },
      {
        "name": "inventory",
        "flags": [
          "observed-at"
        ],
        "synopsis": "inventory [--observed-at ISO_TIMESTAMP]"
      },
      {
        "name": "identity-init",
        "flags": [
          "state-dir",
          "machine-id"
        ],
        "synopsis": "identity-init --state-dir DIR --machine-id ID"
      },
      {
        "name": "setup",
        "flags": [
          "machine-id",
          "state-dir",
          "agent-config",
          "idempotency-key",
          "cpu-cores",
          "all-gpus",
          "gpu-units",
          "gpu-uuid",
          "gpu-cdi",
          "gpu-uuids",
          "gpu-cdis",
          "gpu-communication",
          "vram-mib",
          "ram-mib",
          "disk-gib",
          "window-seconds",
          "price-usdc-cents"
        ],
        "synopsis": "setup --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --idempotency-key KEY"
      },
      {
        "name": "withdraw",
        "flags": [
          "machine-id",
          "state-dir",
          "agent-config",
          "offer-id",
          "offer-digest",
          "idempotency-key"
        ],
        "synopsis": "withdraw --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID [--offer-digest SHA256] --idempotency-key KEY"
      },
      {
        "name": "serve",
        "flags": [
          "machine-id",
          "state-dir",
          "agent-config",
          "interval-ms"
        ],
        "synopsis": "serve --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON [--interval-ms N]"
      },
      {
        "name": "status",
        "flags": [
          "state-dir",
          "machine-id"
        ],
        "synopsis": "status --state-dir DIR --machine-id ID"
      },
      {
        "name": "drain",
        "flags": [
          "state-dir"
        ],
        "synopsis": "drain --state-dir DIR"
      }
    ],
    "flow": [
      "join",
      "inventory",
      "identity-init",
      "setup",
      "serve",
      "status",
      "drain"
    ],
    "setupCreatesOffer": true,
    "publicOfferVerb": null
  },
  "buyer": {
    "executable": "punch-buyer",
    "booleanFlags": [
      "help",
      "json",
      "yes",
      "dry-run"
    ],
    "commands": [
      {
        "name": "join",
        "flags": [
          "config",
          "invitation",
          "json"
        ],
        "synopsis": "join --invitation ABSOLUTE_JSON --config ABSOLUTE_PUBLIC_CONFIG"
      },
      {
        "name": "offers",
        "flags": [
          "config",
          "json"
        ],
        "synopsis": "offers --config ABSOLUTE_PUBLIC_CONFIG"
      },
      {
        "name": "order",
        "flags": [
          "config",
          "offer-id",
          "request-file",
          "order-ref",
          "ssh-public-key-file",
          "json"
        ],
        "synopsis": "order --offer-id ID|--request-file ABSOLUTE_JSON --order-ref REF --config ABSOLUTE_PUBLIC_CONFIG"
      },
      {
        "name": "status",
        "flags": [
          "config",
          "job-id",
          "json"
        ],
        "synopsis": "status --job-id JOB_ID --config ABSOLUTE_PUBLIC_CONFIG"
      },
      {
        "name": "output",
        "flags": [
          "config",
          "job-id",
          "task-id",
          "output",
          "json"
        ],
        "synopsis": "output --job-id JOB_ID --task-id TASK_ID --output ABSOLUTE_FILE --config ABSOLUTE_PUBLIC_CONFIG"
      },
      {
        "name": "ssh",
        "flags": [
          "config",
          "job"
        ],
        "synopsis": "ssh --job JOB_ID --config ABSOLUTE_PUBLIC_CONFIG"
      },
      {
        "name": "stop",
        "flags": [
          "config",
          "job",
          "json"
        ],
        "synopsis": "stop --job JOB_ID --config ABSOLUTE_PUBLIC_CONFIG"
      }
    ],
    "flow": [
      "join",
      "offers",
      "order",
      "status",
      "ssh",
      "stop"
    ],
    "stopCommand": "stop"
  }
}
<!-- GENERATED CLI CONTRACT:END -->
