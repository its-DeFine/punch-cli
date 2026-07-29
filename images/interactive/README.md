# Punch interactive runtime image

This directory is the public, reviewable build context for the fixed Punch
interactive runtime. It is not the Punch control plane and contains no
marketplace, database, payment, administrator, invitation, or credential code.

The image accepts one canonical Ed25519 public key from the Provider agent and
runs a non-root SSH service bound only to the container loopback interface.
Punch reaches it through a fixed stdio bridge. It publishes no port and does not
expose the Provider address or Docker socket to a Buyer.

The fixed bridge waits for the container-local SSH listener with a bounded
retry window. It still fails closed when the listener does not become ready;
it never falls back to a host port or a provider address.

Official releases are published for `linux/amd64` as
`ghcr.io/its-define/punch-interactive`. Provider configuration must use the
immutable digest reported by the successful publish workflow, never a mutable
tag. Do not build or substitute a different image for a Punch pilot.

The current `v0.1.0-preview.3` and candidate `v0.1.0-preview.4` compatible registry reference is
`ghcr.io/its-define/punch-interactive@sha256:8734a58eea53ca64690b4cbc94cc1e4b15af4407730c2352a81b2958e3d021e4`.
Its expected local image ID is
`sha256:2f13a113c8dd5d3c2ddb38f2e1cee7d4aaa2f7ba3c157de7743bb8d1276ea33b`.

Pull the image by its registry digest. Docker then reports a local content ID
with `docker image inspect --format '{{.Id}}' IMAGE@sha256:REGISTRY_DIGEST`.
Punch binds `approvedBaseImage` to that exact local `sha256:` image ID; the
registry digest and local image ID must not be treated as interchangeable.
