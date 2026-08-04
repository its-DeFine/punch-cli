#!/bin/sh
set -eu

: "${PUNCH_INTERACTIVE_IMAGE:?set PUNCH_INTERACTIVE_IMAGE to an immutable repository@sha256:digest}"
: "${PUNCH_GPU_CDI:?set PUNCH_GPU_CDI to nvidia.com/gpu=GPU-UUID}"
: "${PUNCH_GPU_UUID:?set PUNCH_GPU_UUID to the selected GPU UUID}"

case "$PUNCH_INTERACTIVE_IMAGE" in
  *@sha256:[0-9a-fA-F]*) : ;;
  *) printf '%s\n' 'PUNCH_INTERACTIVE_IMAGE must be an immutable repository@sha256:digest' >&2; exit 64 ;;
esac
case "$PUNCH_GPU_CDI" in
  nvidia.com/gpu=GPU-*) : ;;
  *) printf '%s\n' 'PUNCH_GPU_CDI must be nvidia.com/gpu=GPU-UUID' >&2; exit 64 ;;
esac
case "$PUNCH_GPU_UUID" in
  GPU-*) : ;;
  *) printf '%s\n' 'PUNCH_GPU_UUID must be a GPU UUID' >&2; exit 64 ;;
esac

driver_floor=570.124.06

strip_leading_zeroes() {
  value=$1
  while [ "${value#0}" != "$value" ] && [ "$value" != "0" ]; do
    value=${value#0}
  done
  printf '%s' "$value"
}

version_at_least() {
  actual=$1
  required=$2
  case "$actual" in
    ''|*[!0-9.]*) return 1 ;;
  esac
  case "$required" in
    ''|*[!0-9.]*) return 1 ;;
  esac

  saved_ifs=$IFS
  IFS=.
  set -- $actual
  actual_count=$#
  actual_major=$(strip_leading_zeroes "${1:-}")
  actual_minor=$(strip_leading_zeroes "${2:-}")
  actual_patch=$(strip_leading_zeroes "${3:-}")
  set -- $required
  required_count=$#
  required_major=$(strip_leading_zeroes "${1:-}")
  required_minor=$(strip_leading_zeroes "${2:-}")
  required_patch=$(strip_leading_zeroes "${3:-}")
  IFS=$saved_ifs

  [ "$actual_count" -eq 3 ] && [ "$required_count" -eq 3 ] || return 1
  [ "$actual_major" -gt "$required_major" ] && return 0
  [ "$actual_major" -lt "$required_major" ] && return 1
  [ "$actual_minor" -gt "$required_minor" ] && return 0
  [ "$actual_minor" -lt "$required_minor" ] && return 1
  [ "$actual_patch" -ge "$required_patch" ]
}

observed=$(docker run --rm \
  --read-only --network none --cap-drop ALL \
  --security-opt no-new-privileges \
  --device "$PUNCH_GPU_CDI" \
  --env NVIDIA_DRIVER_CAPABILITIES=compute,utility \
  --user 65532:65532 \
  --entrypoint /usr/bin/nvidia-smi \
  "$PUNCH_INTERACTIVE_IMAGE" \
  --query-gpu=uuid,driver_version --format=csv,noheader,nounits)

observed_uuid=${observed%%,*}
observed_driver=${observed#*,}
observed_uuid=$(printf '%s' "$observed_uuid" | tr -d '[:space:]')
observed_driver=$(printf '%s' "$observed_driver" | tr -d '[:space:]')

[ "$observed_uuid" = "$PUNCH_GPU_UUID" ] || {
  printf 'selected GPU mismatch: expected %s, observed %s\n' "$PUNCH_GPU_UUID" "$observed_uuid" >&2
  exit 1
}

version_at_least "$observed_driver" "$driver_floor" || {
  printf 'driver version below floor: required %s, observed %s\n' "$driver_floor" "$observed_driver" >&2
  exit 1
}

printf '%s\n' 'interactive image GPU runtime canary: PASS'
