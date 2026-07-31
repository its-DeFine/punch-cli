FROM nvidia/cuda:12.8.1-devel-ubuntu22.04@sha256:a99a1860ba8e2916e5c3e73b72ec4c4301653a84586e05bfc9a2aa2d58027e97 AS build
COPY probe.cu /src/probe.cu
RUN nvcc -O2 -o /punch-cuda-probe /src/probe.cu

FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04@sha256:4a801ef9232d2b05e69df4eb8aa054dbbe2824e5499e1e6e857320bb01ac41a9
COPY --from=build /punch-cuda-probe /punch/cuda-probe
COPY validate.sh /punch/validate
COPY compatibility-policy.json /punch/compatibility-policy.json
COPY THIRD_PARTY_NOTICES.md /usr/share/doc/punch/THIRD_PARTY_NOTICES.md
RUN chmod 0555 /punch/validate /punch/cuda-probe && chmod 0444 /punch/compatibility-policy.json

LABEL org.opencontainers.image.source="https://github.com/its-DeFine/punch-cli" \
      org.punch.validation.protocol="PUNCH_VALIDATION_V1" \
      org.punch.compatibility.class="NVIDIA_CUDA_12_8_1_V2" \
      org.punch.compatibility.driver-floor="570.124.06" \
      org.punch.compatibility.certified-compute-capabilities="8.9,12.0"

USER 65532:65532
STOPSIGNAL SIGTERM
ENTRYPOINT ["/punch/validate"]
