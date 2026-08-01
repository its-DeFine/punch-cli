# Invitations and credentials

> **Version boundary:** Provider `rejoin` applies to `v0.1.0-preview.8` when
> its non-draft prerelease archive and checksum are published.

Punch Compute is invitation-only during the public preview.

## Roles

- A **Buyer invitation** can create one Buyer session.
- A **Provider invitation** can create one Provider credential.
- The invitation role is fixed by Punch Control. A CLI flag cannot change it.

## Single use

An invitation contains an identifier and redemption secret. It is redeemed once. Retrying a successfully redeemed invitation must not create a second identity or credential.

A Provider session can expire before the first machine enrollment completes.
That does not authorize deleting local identity or setup state. When the CLI
returns `PROVIDER_REJOIN_REQUIRED`, Punch issues one fresh invitation bound to
the same active Provider actor. The operator runs `punch-provider rejoin`; the
CLI atomically replaces only the expired credential and preserves the exact
pending setup reference. The original invitation remains consumed.

An enrolled Provider does not redeem another invitation merely to create or
withdraw another offer. Normal session renewal and fresh setup references reuse
the existing Provider and machine identities.

## File handling

As an operator requirement, invitation, session, credential, and private-key directories must be owned by the current user and mode `0700`. Secret-bearing files must be regular, non-symlink files owned by the current user with mode `0600`. Release implementations must fail closed on their documented checks; operators must verify the full boundary instead of assuming every platform check is automatic.

```bash
install -d -m 0700 "$HOME/.config/punch/buyer"
install -d -m 0700 "$HOME/.config/punch/provider"
chmod 0600 /absolute/path/to/invitation.json
```

Never:

- Paste an invitation into a shell history, issue, screenshot, or chat.
- Commit invitation or credential files.
- Copy Provider credentials to a Buyer machine.
- Reuse one invitation for another person or execution node.
- Delete or rename Provider state merely to bypass `PROVIDER_REJOIN_REQUIRED`.

## Public endpoint

The official preview origin is:

```text
https://api-punch.embody.zone
```

The CLI accepts a configured HTTPS DNS origin and sends credentials to it. Do not substitute another origin unless Punch has authenticated that exact change. Buyers and Providers do not need a direct provider IP or database address.

## Loss or exposure

Stop before redemption and request revocation through the private channel that supplied the invitation. Deleting a local file alone does not revoke server-side authority.
