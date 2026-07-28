# Security model

## Trust boundaries

- Invitations are single-use, role-bound secrets.
- Buyer sessions and Provider credentials are stored only in private local files.
- The supported configuration uses the official public Punch HTTPS endpoint; changing it redirects credentials and is security-sensitive.
- Provider agents initiate outbound connections; no inbound Provider port is required for Punch.
- Buyers never receive the Provider address or container-runtime access.

## Container restrictions

The public-preview Provider path accepts only Punch-approved image digests and bounded structured workload input. A Buyer cannot supply:

- An arbitrary image, entry point, command, or Docker flag.
- Host mounts, host networking, privileged mode, added Linux capabilities, or arbitrary device paths.
- An unbounded CPU, RAM, PID, writable-storage, or GPU request.

When a GPU is assigned, the lease uses a stable GPU UUID and CDI identity rather than a positional index.

## Local privilege

Access to the Docker Unix socket is normally equivalent to host-root authority. Run the Provider agent only under the reviewed release service definition and on a node dedicated or appropriately isolated for providing compute. Do not expose a Docker-compatible API over TCP and do not give Buyers access to the Unix socket.

## File permissions

- Secret directories: `0700`.
- Invitations, credentials, sessions, private keys, and secret-bearing configuration: `0600`.
- Secret-bearing files must be regular files, not symlinks.

The CLI must fail closed when these requirements are not satisfied. Never place secrets directly in command-line arguments when a file option exists.

## Network privacy

Cloudflare terminates the public Punch hostname. This hides the Provider execution node from Buyers, but it does not make a compromised Provider or Buyer trustworthy. Authentication, authorization, container limits, and lifecycle cleanup remain required.

## Preview limitations

The public repository and documentation are not a security certification. The invitation-only preview supports only the documented capacity and workload classes. Real-funds or production availability must be announced explicitly for a specific release; do not infer it from the presence of a command.
