FROM pytorch/pytorch@sha256:c16f4c749e2d9e96878875cdf6cc45cddda1d1a36fddd371dd6f2360f1b6e2a2

ARG DEBIAN_FRONTEND=noninteractive
RUN sed -i -E 's#http://(archive|security).ubuntu.com/ubuntu/#https://snapshot.ubuntu.com/ubuntu/20260812T000000Z/#g' /etc/apt/sources.list \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -y --no-install-recommends \
      ca-certificates=20260601~22.04.1 \
      curl=7.81.0-1ubuntu1.25 \
      dropbear-bin=2020.81-5ubuntu0.1 \
      git=1:2.34.1-1ubuntu1.17 \
      socat=1.7.4.1-3ubuntu4 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 65532 punch \
    && useradd --uid 65532 --gid 65532 --no-create-home --home-dir /workspace --shell /bin/bash punch \
    && install -d -o 65532 -g 65532 -m 0700 /workspace /tmp/punch-runtime

COPY punch-researcher /usr/local/bin/punch-researcher
COPY punch-ssh-stdio /usr/local/bin/punch-ssh-stdio
COPY smoke.py /opt/punch/smoke.py
RUN chmod 0555 /usr/local/bin/punch-researcher /usr/local/bin/punch-ssh-stdio /opt/punch/smoke.py \
    && python -c 'import torch; assert torch.__version__ == "2.7.1+cu128"'

LABEL org.opencontainers.image.source="https://github.com/its-DeFine/punch-cli" \
      org.punch.researcher.protocol="PUNCH_RESEARCHER_V2" \
      org.punch.researcher.bridge="/usr/local/bin/punch-ssh-stdio" \
      org.punch.researcher.workspace="quota-backed-provider-mount" \
      org.punch.researcher.framework="pytorch=2.7.1+cu128" \
      org.punch.researcher.network-policies="NONE;RESEARCH_EGRESS"

USER 65532:65532
WORKDIR /workspace
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/punch-researcher"]
