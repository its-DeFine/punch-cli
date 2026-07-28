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

The two launchers in this directory are the Apache-2.0 templates copied to `payload/bin`. The version-pinned Node runtime and proprietary implementation bundles are supplied by the private release build. The completed archive and every other release asset must be covered by `SHA256SUMS`.

Do not commit generated runtime, implementation bundles, invitations, credentials, or release staging directories to this repository.
