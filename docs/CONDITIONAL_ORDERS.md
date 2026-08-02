# Conditional multi-GPU orders

Preview.5 lets a Buyer submit one immediate order containing ranked hardware
alternatives. Punch fulfills at most one complete alternative atomically or
rejects the request. It does not combine separately offered GPUs.

Example request file:

```json
{
  "schemaVersion": "punch.conditional-order.v1",
  "mode": "INTERACTIVE",
  "requirements": {
    "minimumCpuCores": 32,
    "minimumRamMiB": 131072,
    "minimumDiskGiB": 1000
  },
  "windowSeconds": 3600,
  "asset": "USDC",
  "alternatives": [
    {
      "gpuModel": "NVIDIA GeForce RTX 5090",
      "gpuCount": 5,
      "minimumVramPerGpuMiB": 32768,
      "communicationClass": "P2P_REQUIRED",
      "maxPriceMinor": 6000000
    },
    {
      "gpuModel": "NVIDIA GeForce RTX 4090",
      "gpuCount": 5,
      "minimumVramPerGpuMiB": 24576,
      "communicationClass": "P2P_REQUIRED",
      "maxPriceMinor": 4000000
    }
  ],
  "selectionPolicy": "PREFERENCE_THEN_PRICE",
  "expiresAt": "2026-08-01T12:00:00.000Z"
}
```

Submit it with one durable order reference:

```bash
punch-buyer order \
  --config /absolute/path/.config/punch/buyer/buyer.json \
  --request-file /absolute/path/conditional-order.json \
  --order-ref buyer-order-20260801-001 \
  --ssh-public-key-file /absolute/path/id_ed25519.pub \
  --json
```

`INTERACTIVE` requires the SSH public key. `WORKLOAD` rejects it. Retry an
ambiguous response only with the identical request and `--order-ref`.

Matching is deterministic: earlier alternatives win; then lower price; then
stable offer ID and offer digest. CPU, RAM, disk, duration, asset, GPU
count/model/per-GPU VRAM, communication class, payout rail, and availability
must all match. The selected bundle is leased all-or-nothing by exact GPU
UUID/CDI identity.

`SAME_NODE` does not promise direct GPU peer access. `P2P_REQUIRED` is eligible
only after the digest-pinned validation container proves CUDA peer access and
peer copies for the exact offered bundle.

This is not a durable standing queue. If no offer currently matches, Punch
creates neither an order nor a payment. A future queue requires a verified
maximum funding commitment; preview.5 does not create unfunded queued demand.

`USDC` and `maxPriceMinor` are request-schema fields. They do not by themselves
prove a testnet or real-USDC funding, settlement, or payout path.
