# NetBird connectivity in Preview.11

> **Supervised pilot:** the Buyer-bootstrap transport is part of
> `v0.1.0-preview.11` only with its matching clean-v4 runtime and release
> archive. Until that archive is published, it is `GATED_UNRELEASED`.

NetBird supplies encrypted peer connectivity, NAT traversal, and relay fallback
between the Buyer environment and the Provider's Punch gateway. Punch remains
authoritative for invitations, offers, orders, contract generation, access
duration, stop, and cleanup. NetBird never becomes marketplace authority.

## Network boundary

- Provider and Buyer peers initiate outbound connections; the Provider exposes
  no public SSH port.
- The Provider's Punch gateway binds only to its verified NetBird overlay IP on
  TCP `22222` and forwards bytes to the contract's container attachment.
- The gateway never forwards to host SSH and never exposes Docker.
- The workspace default full-mesh policy must be disabled.
- A contract grant is limited to its designated Buyer and Provider groups,
  gateway port, and contract generation.
- NetBird management tokens and setup-key values never appear in CLI arguments,
  logs, public configuration, or lifecycle receipts. Buyer `join` uses a private
  mode-`0600` setup-key file and removes it after connectivity verification.

## Buyer enrollment boundary

Control issues enrollment only after Punch Buyer authentication. It is one-off,
ephemeral, bound to the approved Buyer and existing narrow Buyer group, and
cannot create a second peer after consumption. The CLI verifies NetBird startup
connectivity. The Buyer needs no NetBird dashboard, login, or separate code.

## Access lifecycle

The Provider first proves the container and gateway ready. Only then does Punch
publish `accessEffective: true` and start the access window. Buyer stop fences
new access before Provider cleanup. The Provider closes active gateway streams,
removes the container/listener, signs the close receipt, and releases capacity.
Delayed or replayed events cannot reopen an older contract generation.

## Established proof

The Preview.9 canary used separate Provider and Buyer environments. SSH and a
harmless GPU command succeeded while the contract was active. Buyer stop closed
the existing session; a fresh connection was rejected; exact stop replay was
safe; and cleanup removed the gateway listener and workload.

That proof predates automatic Buyer bootstrap. Preview.11 remains gated until
the exact archive completes isolated Linux/x64 Buyer acceptance. Neither proof
certifies every NAT combination, relay region, or self-hosted NetBird topology.
