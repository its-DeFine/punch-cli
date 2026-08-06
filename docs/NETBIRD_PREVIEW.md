# NetBird connectivity in Preview.9

> **Supervised pilot:** this transport is part of `v0.1.0-preview.9` only with
> its matching clean-v4 runtime and release archive.

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
- NetBird management tokens and setup keys never appear in CLI arguments, logs,
  public configuration, or lifecycle receipts.

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

The proof used the configured NetBird workspace path available during the
owner-operated pilot. It does not independently certify every NAT combination,
relay region, or self-hosted NetBird topology.
