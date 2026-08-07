# Preview.10 release-source command reference

This generated reference is a `GATED_UNRELEASED` Preview.10 release-source
contract. It is derived from the manager-approved sanitized handoff and the
separate trust-registry fixture, whose `releaseAuthority` is `false`. It proves
only `LOCAL_DETERMINISTIC_PASS`; it does not prove a published archive,
deployment, or exact-archive Buyer/Provider E2E.

The generated `artifactDigest` is a deterministic release-source binding of the
declared source identity and role entrypoint hashes. It is not a `SHA256SUMS`
archive digest.

Do not use these commands until the matching Preview.10 archive and authority
are published. Current released guidance remains in [Command reference](COMMANDS.md),
[Buyer guide](BUYER.md), and [Provider guide](PROVIDER.md).

<!-- GENERATED CLI CONTRACT:BEGIN -->
<!-- proof: LOCAL_DETERMINISTIC_PASS -->
<!-- authority: MANAGER_APPROVED_HANDOFF_ONLY; release-authority: false -->
<!-- contract-digest: 914229300cca2ea126c542ee273a795e7356735a8fb4ea1902642475b5008e52 -->
<!-- artifact-digest: 0a85ef7ecb2d12ae1224fb9b92358b3de5fdeb3aff8fa36d344fca7236b5170f -->
{
  "schemaVersion": "punch.public-cli-contract.v1",
  "contractDigest": "914229300cca2ea126c542ee273a795e7356735a8fb4ea1902642475b5008e52",
  "proofLabel": "LOCAL_DETERMINISTIC_PASS",
  "releaseStatus": "GATED_UNRELEASED",
  "authority": "MANAGER_APPROVED_HANDOFF_ONLY",
  "artifactId": "private-release-source:803305b295771e54186f5a2ea7a862b9ef04f6c4:tree:847886f38766d5e2723ae376e54a4211390db6b7:runtime:76041898382f764d3404ecb12112b684bafad1af",
  "artifactDigest": "0a85ef7ecb2d12ae1224fb9b92358b3de5fdeb3aff8fa36d344fca7236b5170f",
  "provider": {
    "executable": "punch-provider",
    "booleanFlags": [
      "help",
      "json"
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
          "price-minor",
          "targeted-zero-authorization-id",
          "targeted-buyer-actor-id"
        ],
        "synopsis": "setup --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --idempotency-key KEY --price-minor 0 --targeted-zero-authorization-id ID --targeted-buyer-actor-id ID"
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
      },
      {
        "name": "offer-status",
        "flags": [
          "machine-id",
          "state-dir",
          "agent-config",
          "offer-id"
        ],
        "synopsis": "offer-status --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID"
      },
      {
        "name": "offer-unlist",
        "flags": [
          "machine-id",
          "state-dir",
          "agent-config",
          "offer-id",
          "idempotency-key"
        ],
        "synopsis": "offer-unlist --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY"
      },
      {
        "name": "offer-retire",
        "flags": [
          "machine-id",
          "state-dir",
          "agent-config",
          "offer-id",
          "idempotency-key"
        ],
        "synopsis": "offer-retire --machine-id ID --state-dir DIR --agent-config ABSOLUTE_JSON --offer-id ID --idempotency-key KEY"
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
