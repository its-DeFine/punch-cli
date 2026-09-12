# Security model

## Trust boundaries

- Invitations are single-use, role-bound secrets.
- Buyer sessions and Provider credentials are stored only in private local files.
- The supported configuration uses the official public Punch HTTPS endpoint; changing it redirects credentials and is security-sensitive.
- Provider agents and NetBird peers initiate outbound connections; no public
  Provider SSH port is required.
- Buyers never receive the public Provider address, host credential, or
  container-runtime access.

## Container restrictions

The public-preview Provider path accepts only Punch-approved image digests and bounded structured workload input. A Buyer cannot supply:

- An arbitrary image, entry point, command, or Docker flag.
- Host mounts, host networking, privileged mode, added Linux capabilities, or arbitrary device paths.
- An unbounded CPU, RAM, PID, writable-storage, or GPU request.

When a GPU is assigned, the lease uses a stable GPU UUID and CDI identity rather than a positional index.

## Local privilege

Access to the Docker Unix socket is normally equivalent to host-root authority.
Run the Provider agent only on a dedicated or appropriately isolated node.
The released Preview.19.5 Provider flow installs and manages the machine-scoped
service through the supervised `setup` and `service-install` lifecycle. The
reviewed direct command is `punch-provider service-install --machine-id
MACHINE_ID --state-dir STATE_DIR --yes`; `service-start` and `service-status`
then address that machine-scoped unit by machine ID. Review its Docker authority
and host isolation before use. Do not expose a Docker-compatible API over TCP or
give Buyers access to the Unix socket.

## File permissions

- Secret directories: `0700`.
- Invitations, credentials, sessions, private keys, and secret-bearing configuration: `0600`.
- Secret-bearing files must be regular files, not symlinks.

The CLI must fail closed when these requirements are not satisfied. Never place secrets directly in command-line arguments when a file option exists.

## Network privacy

Cloudflare terminates the public Punch hostname. Contract-scoped SSH uses
NetBird between the Buyer environment and the Provider's overlay-only Punch
gateway. Neither transport is marketplace authority or makes a compromised
Provider or Buyer trustworthy. Authentication, contract-generation binding,
container limits, revocation, and lifecycle cleanup remain required.

## Preview limitations

The public repository and documentation are not a security certification. The
repository's security and release tests are scoped checks of documented
boundaries and artifact behavior; they are not a formal independent security
audit. No saved database-role audit PASS is claimed. The invitation-only
preview supports only the documented capacity and workload classes. Real-funds
or production availability must be announced explicitly for a specific
release; do not infer it from the presence of a command.
