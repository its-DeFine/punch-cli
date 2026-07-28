FROM alpine@sha256:7c8cb692ae09657cbc4a3f3cbd0e8d5a2690ba38386aaaf252dbb060bf5eb2e6

RUN apk add --no-cache dropbear=2025.88-r1 socat=1.8.1.3-r0 \
    && addgroup -g 65532 punch \
    && adduser -D -H -u 65532 -G punch -h /workspace -s /bin/sh punch \
    && install -d -o 65532 -g 65532 -m 0700 /workspace

COPY punch-interactive /usr/local/bin/punch-interactive
COPY punch-ssh-stdio /usr/local/bin/punch-ssh-stdio
COPY THIRD_PARTY_NOTICES.md /usr/share/doc/punch/THIRD_PARTY_NOTICES.md
RUN chmod 0555 /usr/local/bin/punch-interactive /usr/local/bin/punch-ssh-stdio

LABEL org.opencontainers.image.source="https://github.com/its-DeFine/punch-cli" \
      org.punch.interactive.protocol="PUNCH_INTERACTIVE_V1" \
      org.punch.interactive.bridge="/usr/local/bin/punch-ssh-stdio" \
      org.punch.interactive.package-pins="dropbear=2025.88-r1;socat=1.8.1.3-r0"

USER 65532:65532
WORKDIR /workspace
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/punch-interactive"]
