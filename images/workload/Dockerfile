FROM alpine@sha256:7c8cb692ae09657cbc4a3f3cbd0e8d5a2690ba38386aaaf252dbb060bf5eb2e6
COPY workload.sh /punch/run
COPY THIRD_PARTY_NOTICES.md /usr/share/doc/punch/THIRD_PARTY_NOTICES.md
RUN chmod 0555 /punch/run

LABEL org.opencontainers.image.source="https://github.com/its-DeFine/punch-cli" \
      org.punch.workload.protocol="PUNCH_WORKLOAD_V1"

USER 65532:65532
STOPSIGNAL SIGTERM
ENTRYPOINT ["/punch/run"]
