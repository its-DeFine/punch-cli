#!/bin/sh
set -eu
printf '%s' "${PUNCH_INPUT_BASE64:?}" | base64 -d > /work/input.json
[ "$(wc -c < /work/input.json)" -le 8192 ]
if [ -z "${PUNCH_GPU_CDI:-}" ]; then
  [ -z "${NVIDIA_VISIBLE_DEVICES:-}" ]
  printf '%s\n' '{"schemaVersion":"punch.validation.cpu.v1","outcome":"PASS"}'
  exit 0
fi
GPU_UUID="${NVIDIA_VISIBLE_DEVICES:?}"
[ "$PUNCH_GPU_CDI" = "nvidia.com/gpu=$GPU_UUID" ]
VISIBLE_UUIDS=$(/usr/bin/nvidia-smi --query-gpu=uuid --format=csv,noheader,nounits)
[ "$VISIBLE_UUIDS" = "$GPU_UUID" ]
/punch/cuda-probe
printf '{"schemaVersion":"punch.validation.gpu.v1","outcome":"PASS","uuid":"%s","cdiDevice":"%s"}\n' \
  "$GPU_UUID" "$PUNCH_GPU_CDI"
