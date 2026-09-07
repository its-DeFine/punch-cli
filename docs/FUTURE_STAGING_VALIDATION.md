# Future compute — staging validation checkpoint

September7,2026. **Staging only; no public binary release, billing or production
promotion.** Companion Control PR57 and CLI documentation PR15 contain the
feature and usage guide. Use an explicitly feature-matched staging build.

## Measured paths

- Three Ubuntu24 Provider environments and two Buyers: simultaneous CPU/GPU
  use, sequential use, capacity-conflict denial and Buyer isolation.
- Future acceptance binds exact resource/GPU/network terms; one full contiguous
  claim runs via native SSH/CUDA and exports a byte-exact result.
- Pre-activation rollover, owned job interruption, remaining-time recovery,
  fixture compensation and idempotent recovery replay.
- NONE outbound denial; a separate CPU spot RESEARCH_EGRESS job permits DNS/
  HTTPS but denies HTTP/private-network/metadata/other-Provider access.
- Real600-second expiry closes existing SSH, rejects fresh access and cleans up.
- Retire/create followed by periodic setup refresh preserves the successor and
  its GPU binding, including compatibility with a retired legacy offer.

GPU hardware tested: RTX5080. The GPU Ubuntu24 system container shares a host
kernel; CPU Providers/Buyers use Ubuntu24 VMs. These are not five-distribution
or multi-physical-GPU reliability results. Timings are individual observations,
not p95 or a statistically established success rate.

## Marketplace and acceptance

The Atumera staging page reads `GET /api/v0/marketplace/offers` without Buyer
credentials. Only public LISTED/non-targeted offers are projected: resource
quantities/model, network mode, fixture price, advisory availability, public
future terms and the original terms digest. Private actors/machines/addresses,
GPU UUIDs/CDI, jobs and credentials are omitted. Private Buyer API routes still
require authentication. The catalog route is absent when staging future
contracts are disabled.

The browser never accepts a contract or purchases compute. Review the terms,
choose a unique reference, copy the CLI command, replace its absolute config
and public-key paths, then run the authenticated CLI described in
`FUTURE_COMPUTE_STAGING.md`. CLI acceptance and claim remain separate actions.
Repeated copies/retries of the same intended acceptance should retain the same
reference; a new intended acceptance needs a new reference.

The checkbox is a non-binding preview control, not legal acceptance. Native
acceptance binds the exact terms digest. All amounts are test fixtures and no
card, recharge, payment, refund or cash credit is implemented in this stage.

## Release boundary

Control native/public-catalog checkpoint: source `ac947e1`. Website checkpoint:
`8a879b2`. These source identities are not replacements for receiving the
matched binary/configuration from the staging operator. The currently published
public CLI must not be assumed to include these changes.

Commercial/entity/jurisdiction decisions and final legal review remain required
before production. No provider is being asked to upgrade from this draft alone.
