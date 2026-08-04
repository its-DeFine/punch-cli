FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04@sha256:4a801ef9232d2b05e69df4eb8aa054dbbe2824e5499e1e6e857320bb01ac41a9

ENV DEBIAN_FRONTEND=noninteractive \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
      dropbear=2020.81-5ubuntu0.1 \
      socat=1.7.4.1-3ubuntu4 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 65532 punch \
    && useradd --uid 65532 --gid 65532 --home-dir /workspace --shell /bin/sh --no-create-home punch \
    && install -d -o 65532 -g 65532 -m 0700 /workspace

COPY punch-interactive /usr/local/bin/punch-interactive
COPY punch-ssh-stdio /usr/local/bin/punch-ssh-stdio
COPY THIRD_PARTY_NOTICES.md /usr/share/doc/punch/THIRD_PARTY_NOTICES.md
RUN chmod 0555 /usr/local/bin/punch-interactive /usr/local/bin/punch-ssh-stdio

LABEL org.opencontainers.image.source="https://github.com/its-DeFine/punch-cli" \
      org.punch.interactive.protocol="PUNCH_INTERACTIVE_V1" \
      org.punch.interactive.bridge="/usr/local/bin/punch-ssh-stdio" \
      org.punch.interactive.base="nvidia/cuda:12.8.1-runtime-ubuntu22.04@sha256:4a801ef9232d2b05e69df4eb8aa054dbbe2824e5499e1e6e857320bb01ac41a9" \
      org.punch.interactive.cuda-runtime="12.8.1" \
      org.punch.interactive.driver-floor="570.124.06" \
      org.punch.interactive.package-pins="dropbear=2020.81-5ubuntu0.1;socat=1.7.4.1-3ubuntu4" \
      org.punch.interactive.nvidia-capabilities="compute,utility"

USER 65532:65532
WORKDIR /workspace
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/punch-interactive"]
