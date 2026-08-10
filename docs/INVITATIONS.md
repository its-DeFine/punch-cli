# Invitations and credentials

> **Version boundary:** this page describes the Preview.18 invitation-only flow.
> Use it only with the published Linux/x64
> [`v0.1.0-preview.18`](https://github.com/its-DeFine/punch-cli/releases/tag/v0.1.0-preview.18)
> archive, SHA-256 `d144fd266328c022ef2601feb871ff62396a293d5e35e7130a3880cc0cdaf423`,
> after its same-release checksum verifies, and only with an invitation bound to the
> exact public identity packet and installed release role. This source page is
> not install authority.

Punch Compute is invitation-only during the public preview.

## Roles

- A **Buyer invitation** can create one Buyer session.
- A **Provider invitation** can create one Provider credential.
- The invitation role is fixed by Punch Control. A CLI flag cannot change it.

Preview.18 Provider onboarding first submits a signed public-only request and
shows `WAITING_FOR_INVITE`. That request is not an invitation and cannot approve
the Provider. After supervised approval, signed status may advance to
`INVITE_READY`; that state contains no invitation secret. The guided `punch`
flow resumes the same request and local identity only after it imports the
owner-delivered one-time Provider invitation from an owned mode-`0600` file.

Supervised approval of another Provider is append-only. It creates a distinct
Provider actor, machine, invitation, offer authority, and narrow route and must
preserve every existing Provider and Buyer authority. The public CLI cannot
select replacement authority, mutate Control administration, or obtain another
Provider's invitation.

## Single use

An invitation contains an identifier and redemption secret. It is redeemed once. Retrying a successfully redeemed invitation must not create a second identity or credential.

A failed or interrupted join does not authorize deleting local identity or
setup state. Preserve the invitation, credential path, machine identity, and
setup reference and return the sanitized public error code to the Punch
operator. The operator decides whether the same idempotent operation can be
reconciled or a fresh invitation is required.

An enrolled Provider does not redeem another invitation merely to create
another offer. Fresh setup references reuse the existing Provider and machine
identities.

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
- Delete or rename Provider state merely to bypass a join or setup rejection.

## Public endpoint

The official preview origin is:

```text
https://api-punch.embody.zone
```

The CLI accepts a configured HTTPS DNS origin and sends credentials to it. Do not substitute another origin unless Punch has authenticated that exact change. Buyers and Providers do not need a direct provider IP or database address.

## Loss or exposure

Stop before redemption and request revocation through the private channel that supplied the invitation. Deleting a local file alone does not revoke server-side authority.
