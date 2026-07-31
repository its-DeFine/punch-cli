#!/bin/sh
set -eu
printf '%s' "${PUNCH_INPUT_BASE64:?}" | base64 -d > /work/input.json
[ "$(wc -c < /work/input.json)" -le 8192 ]
if [ -z "${PUNCH_GPU_CDI:-}" ] && [ -z "${PUNCH_GPU_CDIS_BASE64:-}" ]; then
  [ -z "${NVIDIA_VISIBLE_DEVICES:-}" ]
  printf '%s\n' '{"schemaVersion":"punch.validation.cpu.v1","outcome":"PASS"}'
  exit 0
fi
if [ -n "${PUNCH_GPU_CDI:-}" ]; then
  GPU_UUID="${NVIDIA_VISIBLE_DEVICES:?}"
  [ "$PUNCH_GPU_CDI" = "nvidia.com/gpu=$GPU_UUID" ]
  VISIBLE_UUIDS=$(/usr/bin/nvidia-smi --query-gpu=uuid --format=csv,noheader,nounits)
  [ "$VISIBLE_UUIDS" = "$GPU_UUID" ]
  PUNCH_GPU_COMMUNICATION=SAME_NODE /punch/cuda-probe
  printf '{"schemaVersion":"punch.validation.gpu.v1","outcome":"PASS","uuid":"%s","cdiDevice":"%s"}\n' \
    "$GPU_UUID" "$PUNCH_GPU_CDI"
  exit 0
fi

case "${PUNCH_GPU_COMMUNICATION:-}" in SAME_NODE|P2P_REQUIRED) ;; *) exit 1 ;; esac
VISIBLE_UUIDS=$(/usr/bin/nvidia-smi --query-gpu=uuid --format=csv,noheader,nounits | LC_ALL=C sort)
EXPECTED_UUIDS=$(printf '%s' "${NVIDIA_VISIBLE_DEVICES:?}" | tr ',' '\n' | LC_ALL=C sort)
[ "$VISIBLE_UUIDS" = "$EXPECTED_UUIDS" ]

GPU_JSON='['
CDI_JSON='['
SEPARATOR=''
OLD_IFS=$IFS
IFS=,
for GPU_UUID in $NVIDIA_VISIBLE_DEVICES; do
  case "$GPU_UUID" in GPU-[A-Za-z0-9-]*) ;; *) exit 1 ;; esac
  GPU_CDI="nvidia.com/gpu=$GPU_UUID"
  GPU_JSON="${GPU_JSON}${SEPARATOR}{\"uuid\":\"${GPU_UUID}\",\"cdiDevice\":\"${GPU_CDI}\"}"
  CDI_JSON="${CDI_JSON}${SEPARATOR}\"${GPU_CDI}\""
  SEPARATOR=','
done
IFS=$OLD_IFS
GPU_JSON="${GPU_JSON}]"
CDI_JSON="${CDI_JSON}]"
[ "$(printf '%s' "$PUNCH_GPU_CDIS_BASE64" | base64 -d)" = "$CDI_JSON" ]
/punch/cuda-probe
if [ "$PUNCH_GPU_COMMUNICATION" = P2P_REQUIRED ]; then P2P=true; else P2P=false; fi
printf '{"schemaVersion":"punch.validation.gpu-bundle.v1","outcome":"PASS","gpus":%s,"communicationClass":"%s","p2pVerified":%s}\n' \
  "$GPU_JSON" "$PUNCH_GPU_COMMUNICATION" "$P2P"
