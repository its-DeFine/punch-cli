#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

require() {
  file=$1
  text=$2
  grep -F -- "$text" "$file" > /dev/null || {
    printf 'interactive image contract missing from %s: %s\n' "$file" "$text" >&2
    exit 1
  }
}

dockerfile=images/interactive/Dockerfile
require "$dockerfile" 'FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04@sha256:4a801ef9232d2b05e69df4eb8aa054dbbe2824e5499e1e6e857320bb01ac41a9'
require "$dockerfile" 'dropbear=2020.81-5ubuntu0.1'
require "$dockerfile" 'socat=1.7.4.1-3ubuntu4'
require "$dockerfile" 'NVIDIA_DRIVER_CAPABILITIES=compute,utility'
require "$dockerfile" 'USER 65532:65532'
require "$dockerfile" 'ENTRYPOINT ["/usr/local/bin/punch-interactive"]'
require "$dockerfile" 'STOPSIGNAL SIGTERM'
if grep -Eq '(^|[[:space:]])apk([[:space:]]|$)|alpine@sha256:' "$dockerfile"; then
  printf '%s\n' 'interactive image still uses the Alpine/musl package path' >&2
  exit 1
fi

require images/interactive/punch-ssh-stdio 'exec /usr/bin/socat STDIO TCP4:127.0.0.1:2222'
require images/interactive/punch-interactive 'exec /usr/sbin/dropbear -F'
require images/interactive/README.md 'NVIDIA_DRIVER_CAPABILITIES'
require images/interactive/README.md '570.124.06'
require images/interactive/README.md 'repository@sha256:manifest'
require images/interactive/THIRD_PARTY_NOTICES.md 'nvidia-smi'
require tests/interactive-image-runtime-canary.sh '--device "$PUNCH_GPU_CDI"'
require tests/interactive-image-runtime-canary.sh '--env NVIDIA_DRIVER_CAPABILITIES=compute,utility'
require tests/interactive-image-runtime-canary.sh '/usr/bin/nvidia-smi'
require tests/interactive-image-runtime-canary.sh '--query-gpu=uuid,driver_version'
require tests/interactive-image-runtime-canary.sh 'driver_floor=570.124.06'
require tests/interactive-image-runtime-canary.sh 'version_at_least'
require tests/interactive-image-runtime-canary.sh 'driver version below floor'
if grep -F 'NVIDIA_VISIBLE_DEVICES' tests/interactive-image-runtime-canary.sh > /dev/null; then
  printf '%s\n' 'interactive image CDI canary must not combine device CDI with NVIDIA_VISIBLE_DEVICES' >&2
  exit 1
fi

printf '%s\n' 'interactive image static contract: PASS'
