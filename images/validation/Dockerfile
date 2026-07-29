FROM nvidia/cuda:13.0.2-devel-ubuntu24.04@sha256:0eee3094c71518ad31d011a594ae6ed6de72959ee07e318cb31cffe71690e90c AS build
COPY probe.cu /src/probe.cu
RUN nvcc -O2 -o /punch-cuda-probe /src/probe.cu

FROM nvidia/cuda:13.0.2-runtime-ubuntu24.04@sha256:121b25126d81cddeae4c048aa46e94050514ca6b8609a124027b38073e7ef4b6
COPY --from=build /punch-cuda-probe /punch/cuda-probe
COPY validate.sh /punch/validate
COPY THIRD_PARTY_NOTICES.md /usr/share/doc/punch/THIRD_PARTY_NOTICES.md
RUN chmod 0555 /punch/validate /punch/cuda-probe

LABEL org.opencontainers.image.source="https://github.com/its-DeFine/punch-cli" \
      org.punch.validation.protocol="PUNCH_VALIDATION_V1"

USER 65532:65532
STOPSIGNAL SIGTERM
ENTRYPOINT ["/punch/validate"]
