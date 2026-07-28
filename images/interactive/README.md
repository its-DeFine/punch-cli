# Punch interactive runtime image

This directory is the public, reviewable build context for the fixed Punch
interactive runtime. It is not the Punch control plane and contains no
marketplace, database, payment, administrator, invitation, or credential code.

The image accepts one canonical Ed25519 public key from the Provider agent and
runs a non-root SSH service bound only to the container loopback interface.
Punch reaches it through a fixed stdio bridge. It publishes no port and does not
expose the Provider address or Docker socket to a Buyer.

Official releases are published for `linux/amd64` as
`ghcr.io/its-define/punch-interactive`. Provider configuration must use the
immutable digest reported by the successful publish workflow, never a mutable
tag. Do not build or substitute a different image for a Punch pilot.

Pull the image by its registry digest. Docker then reports a local content ID
with `docker image inspect --format '{{.Id}}' IMAGE@sha256:REGISTRY_DIGEST`.
Punch binds `approvedBaseImage` to that exact local `sha256:` image ID; the
registry digest and local image ID must not be treated as interchangeable.
