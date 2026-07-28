# Release package layout

The public repository does not build the proprietary runtime artifacts. A release process operating from the private canonical source supplies them and produces one archive per supported platform.

The extracted archive passed to `install.sh` must have this layout:

```text
VERSION
install.sh
uninstall.sh
LICENSE
NOTICE
PROPRIETARY-ARTIFACT-NOTICE.txt
THIRD_PARTY_NOTICES.md
third_party/
  node/
    LICENSE
  ws/
    LICENSE
payload/
  bin/
    punch-buyer
    punch-provider
  lib/
    punch-buyer.mjs
    punch-provider.mjs
  runtime/
    bin/node
```

The two launchers in this directory are the Apache-2.0 templates copied to `payload/bin`. The version-pinned Node runtime and proprietary implementation bundles are supplied by the private release build.

Before packaging, the release process must:

1. Render `THIRD_PARTY_NOTICES.md` from `THIRD_PARTY_NOTICES.template.md`, replacing `NODE_VERSION` with the exact bundled Node.js version.
2. Copy the official `LICENSE` file unchanged from that exact Node.js distribution to `third_party/node/LICENSE`.
3. Copy `third_party/ws-8.21.1/LICENSE` from this directory unchanged to `third_party/ws/LICENSE` for the bundled `ws` 8.21.1 dependency.
4. Fail if the manifest still contains `NODE_VERSION` or any required license file is absent.

The completed archive and every other release asset must be covered by `SHA256SUMS`.

Do not commit generated runtime, implementation bundles, invitations, credentials, or release staging directories to this repository.
