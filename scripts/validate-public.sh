#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$repo_dir"

sh -n install.sh uninstall.sh packaging/punch-buyer packaging/punch-provider \
  images/interactive/punch-interactive images/interactive/punch-ssh-stdio \
  images/validation/validate.sh images/workload/workload.sh \
  tests/buyer-stop-contract.sh tests/docs-contract.sh \
  tests/install-uninstall.sh tests/interactive-image-contract.sh \
  tests/interactive-image-runtime-canary.sh tests/validate-without-rg.sh

node --test tests/preview9-release-contract.mjs tests/preview11-release-contract.mjs

for required in packaging/THIRD_PARTY_NOTICES.template.md packaging/third_party/ws-8.21.1/LICENSE; do
  [ -s "$required" ] || {
    printf 'required public licensing template is missing: %s\n' "$required" >&2
    exit 1
  }
done

for preview11_requirement in \
  'GATED_UNRELEASED' \
  'one-off, ephemeral setup key' \
  'NetBird dashboard, NetBird login' \
  'PENDING_EXACT_ARCHIVE_ACCEPTANCE' \
  'offer-unlist'; do
  grep -F -- "$preview11_requirement" docs/PREVIEW11.md docs/preview11-runtime-contract.json > /dev/null || {
    printf 'preview.11 release contract missing required public statement: %s\n' "$preview11_requirement" >&2
    exit 1
  }
done
node_marker_count=$(awk '
  {
    line = $0
    while ((position = index(line, "NODE_VERSION")) != 0) {
      count++
      line = substr(line, position + length("NODE_VERSION"))
    }
  }
  END { print count + 0 }
' packaging/THIRD_PARTY_NOTICES.template.md)
[ "$node_marker_count" -eq 1 ] || {
  printf '%s\n' 'third-party notices template must contain exactly one Node version marker' >&2
  exit 1
}
rendered_notices=$(sed 's/NODE_VERSION/v0.0.0-test/' packaging/THIRD_PARTY_NOTICES.template.md)
if printf '%s\n' "$rendered_notices" | grep -Eq 'NODE_VERSION|must be replaced|must be copied|before release|public source repository'; then
  printf '%s\n' 'rendered third-party notices contain a placeholder or build instruction' >&2
  exit 1
fi
grep -F 'Copyright (c) 2016 Luigi Pinca and contributors' packaging/third_party/ws-8.21.1/LICENSE > /dev/null || {
  printf '%s\n' 'ws 8.21.1 license template is incomplete' >&2
  exit 1
}

for preview5_requirement in \
  'Invitation-only preview' \
  '--gpu-units' \
  '--gpu-uuids' \
  '--gpu-cdis' \
  '--gpu-communication' \
  'SAME_NODE' \
  'P2P_REQUIRED' \
  '2 through 8' \
  'comma-separated list with' \
  '131072' \
  'memoryMiB' \
  '--cpu-cores' \
  'not an enforceable per-container VRAM quota' \
  'name=userns'; do
  grep -F -- "$preview5_requirement" docs/PREVIEW5.md > /dev/null || {
    printf 'preview.5 release contract missing required public statement: %s\n' "$preview5_requirement" >&2
    exit 1
  }
done

for preview6_requirement in \
  'Invitation-only preview' \
  'repository@sha256:manifest' \
  'Classic Docker' \
  'containerd image store' \
  'exact `RepoDigests` entry' \
  'fails before execution'; do
  grep -F -- "$preview6_requirement" docs/PREVIEW6.md > /dev/null || {
    printf 'preview.6 release contract missing required public statement: %s\n' "$preview6_requirement" >&2
    exit 1
  }
done

for preview7_requirement in \
  'Invitation-only preview' \
  'canonical sets' \
  'cryptographically bound' \
  'Linux advisory lock' \
  'kernel releases the lock automatically' \
  'fails closed'; do
  grep -F -- "$preview7_requirement" docs/PREVIEW7.md > /dev/null || {
    printf 'preview.7 release contract missing required public statement: %s\n' "$preview7_requirement" >&2
    exit 1
  }
done

for preview8_requirement in \
  'Invitation-only preview' \
  '--all-gpus' \
  'does not require another' \
  'unreserved' \
  'serializes withdrawal with Buyer' \
  'optional explicit digest' \
  'bounded timeouts' \
  'raw upstream bodies'; do
  grep -F -- "$preview8_requirement" docs/PREVIEW8.md > /dev/null || {
    printf 'preview.8 release contract missing required public statement: %s\n' "$preview8_requirement" >&2
    exit 1
  }
done

for preview9_requirement in \
  'Invitation-only supervised pilot' \
  'clean-v4' \
  'NetBird' \
  'TCP `22222`' \
  'punch-buyer stop' \
  'Exact order and stop retries' \
  'no payment settlement' \
  'self-service Provider onboarding'; do
  grep -F -- "$preview9_requirement" docs/PREVIEW9.md > /dev/null || {
    printf 'preview.9 release contract missing required public statement: %s\n' "$preview9_requirement" >&2
    exit 1
  }
done

for release_requirement in \
  'd7de3c3549c2e36c1f5ef5237a671c7f06e44eb101c17be2faeca12a267adf86' \
  '16fdfad931a97834bbe89c6a66724405e502535b9f8c35a971e91ed07b1242ce' \
  'ba8c40d0e2610c43f306db04e3235442606bbec2fdcb3d37c745b23ecdaf9311' \
  "Docker's local" \
  'first external' \
  'still pending'; do
  grep -F -- "$release_requirement" docs/RELEASES.md > /dev/null || {
    printf 'current release matrix missing required statement: %s\n' "$release_requirement" >&2
    exit 1
  }
done

validation_registry_digest='d7de3c3549c2e36c1f5ef5237a671c7f06e44eb101c17be2faeca12a267adf86'
for release_doc in docs/RELEASES.md docs/PROVIDER.md; do
  grep -F -- "$validation_registry_digest" "$release_doc" > /dev/null || {
    printf 'validation registry digest is missing from %s\n' "$release_doc" >&2
    exit 1
  }
  if grep -Eq 'dbdb9592f29d460c8e1661b001320561466a3220956ccb06598298fae3386fee|4f173299eed9021b7dee6b4af21146af618e86d9ce4bb6583e2945ee18e952b1|0ea3a3ca041c5b90cc47e0213b366660bbff4f2a74ba7b61d1442d627abea3b1|dc656cb034ade77b0d2d770147aed4317c2296e899f37cbb3e81b5c43d38a769' "$release_doc"; then
    printf 'stale validation image identity remains in %s\n' "$release_doc" >&2
    exit 1
  fi
done

for active_release_doc in \
  README.md docs/ARCHITECTURE.md docs/BUYER.md docs/COMMANDS.md \
  docs/CONDITIONAL_ORDERS.md docs/INSTALL.md docs/INVITATIONS.md \
  docs/PLATFORMS.md docs/PREVIEW7.md docs/PREVIEW8.md docs/PROVIDER.md docs/RELEASES.md docs/SECURITY.md \
  docs/TROUBLESHOOTING.md images/interactive/README.md; do
  if grep -Eq '0ea3a3ca041c5b90cc47e0213b366660bbff4f2a74ba7b61d1442d627abea3b1|dc656cb034ade77b0d2d770147aed4317c2296e899f37cbb3e81b5c43d38a769' "$active_release_doc" > /dev/null; then
    printf 'retired validation digest remains in active guidance: %s\n' "$active_release_doc" >&2
    exit 1
  fi
done

for current_boundary_doc in docs/COMMANDS.md docs/INVITATIONS.md docs/PROVIDER.md docs/TROUBLESHOOTING.md; do
  grep -F 'non-draft prerelease archive' "$current_boundary_doc" > /dev/null && \
    grep -F 'checksum are published' "$current_boundary_doc" > /dev/null || {
    printf 'preview.9 publication boundary is missing from %s\n' "$current_boundary_doc" >&2
    exit 1
  }
done

for active_provider_doc in docs/RELEASES.md docs/PROVIDER.md images/interactive/README.md; do
  if grep -Eq 'sha256:d98d77b84dd6bffa6c9bafc32ac5693213573698c8b38fbd9d8c100d8da579ac|sha256:6a17d1cbe32e821df44369d372bb52981c4707515edc825cfbcefdf2333bd930|sha256:2f13a113c8dd5d3c2ddb38f2e1cee7d4aaa2f7ba3c157de7743bb8d1276ea33b' "$active_provider_doc"; then
    printf 'Docker-local image ID remains in active release guidance: %s\n' "$active_provider_doc" >&2
    exit 1
  fi
done

for interactive_requirement in \
  'v0.1.0-preview.9' \
  'ghcr.io/its-define/punch-interactive@sha256:ba8c40d0e2610c43f306db04e3235442606bbec2fdcb3d37c745b23ecdaf9311' \
  'repository@sha256:manifest' \
  'must never be copied'; do
  grep -F -- "$interactive_requirement" images/interactive/README.md > /dev/null || {
    printf 'interactive image guidance missing preview.9 requirement: %s\n' "$interactive_requirement" >&2
    exit 1
  }
done

for validation_requirement in \
  'PUNCH_GPU_CDI' \
  'PUNCH_GPU_CDIS_BASE64' \
  'PUNCH_GPU_COMMUNICATION' \
  'punch.validation.gpu-bundle.v1' \
  'cudaDeviceCanAccessPeer' \
  'cudaMemcpyPeer'; do
  if ! grep -F -- "$validation_requirement" images/validation/validate.sh images/validation/probe.cu > /dev/null; then
    printf 'preview.5 validation source missing required contract element: %s\n' "$validation_requirement" >&2
    exit 1
  fi
done

grep -F 'VISIBLE_UUIDS=$(/usr/bin/nvidia-smi --query-gpu=uuid --format=csv,noheader,nounits | LC_ALL=C sort)' \
  images/validation/validate.sh > /dev/null || {
  printf '%s\n' 'multi-GPU validation does not canonicalize observed UUID order' >&2
  exit 1
}
grep -F 'EXPECTED_UUIDS=$(printf '\''%s'\'' "${NVIDIA_VISIBLE_DEVICES:?}" | tr '\'','\'' '\''\n'\'' | LC_ALL=C sort)' \
  images/validation/validate.sh > /dev/null || {
  printf '%s\n' 'multi-GPU validation does not canonicalize selected UUID order' >&2
  exit 1
}
observed_uuid_fixture=$(printf '%s\n' GPU-b GPU-a GPU-c | LC_ALL=C sort)
selected_uuid_fixture=$(printf '%s' 'GPU-c,GPU-b,GPU-a' | tr ',' '\n' | LC_ALL=C sort)
[ "$observed_uuid_fixture" = "$selected_uuid_fixture" ] || {
  printf '%s\n' 'order-independent exact UUID fixture failed' >&2
  exit 1
}

grep -Fx 'FROM nvidia/cuda:12.8.1-devel-ubuntu22.04@sha256:a99a1860ba8e2916e5c3e73b72ec4c4301653a84586e05bfc9a2aa2d58027e97 AS build' \
  images/validation/Dockerfile > /dev/null || {
  printf '%s\n' 'validation build image is not pinned to the supported CUDA 12.8.1 digest' >&2
  exit 1
}
grep -Fx 'FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04@sha256:4a801ef9232d2b05e69df4eb8aa054dbbe2824e5499e1e6e857320bb01ac41a9' \
  images/validation/Dockerfile > /dev/null || {
  printf '%s\n' 'validation runtime image is not pinned to the supported CUDA 12.8.1 digest' >&2
  exit 1
}
grep -F 'NVIDIA CUDA 12.8.1 Ubuntu 22.04' images/validation/THIRD_PARTY_NOTICES.md > /dev/null || {
  printf '%s\n' 'validation third-party notice does not match the pinned CUDA base' >&2
  exit 1
}

for compatibility_requirement in \
  '"schemaVersion": "punch.gpu-compatibility.v1"' \
  '"class": "NVIDIA_CUDA_12_8_1_V2"' \
  '"minimumLinuxDriver": "570.124.06"' \
  '"certifiedComputeCapabilities": ["8.9", "12.0"]' \
  '"certificationRule": "EXACT_IMAGE_CANARY_BEFORE_OFFER"' \
  '"unsupportedBehavior": "FAIL_BEFORE_OFFER"'; do
  grep -F -- "$compatibility_requirement" images/validation/compatibility-policy.json > /dev/null || {
    printf 'validation compatibility policy missing required statement: %s\n' "$compatibility_requirement" >&2
    exit 1
  }
done
grep -F 'org.punch.compatibility.class="NVIDIA_CUDA_12_8_1_V2"' images/validation/Dockerfile > /dev/null || exit 1
grep -F 'org.punch.compatibility.driver-floor="570.124.06"' images/validation/Dockerfile > /dev/null || exit 1
grep -F 'org.punch.compatibility.certified-compute-capabilities="8.9,12.0"' images/validation/Dockerfile > /dev/null || exit 1
grep -F 'EXACT_IMAGE_CANARY_BEFORE_OFFER' docs/RELEASES.md docs/PLATFORMS.md images/validation/compatibility-policy.json > /dev/null || exit 1

./tests/interactive-image-contract.sh
./tests/buyer-stop-contract.sh

for file in README.md SECURITY.md CONTRIBUTING.md docs/*.md packaging/*.md; do
  sed -n 's/.*](\([^#][^)]*\.md\)).*/\1/p' "$file" | while IFS= read -r target; do
    case "$target" in
      /*) resolved=$target ;;
      *) resolved=$(dirname "$file")/$target ;;
    esac
    [ -f "$resolved" ] || {
      printf 'broken Markdown link in %s: %s\n' "$file" "$target" >&2
      exit 1
    }
  done
done

node scripts/validate-targeted-zero-contract.js --self-test
node scripts/generate-command-reference.mjs \
  --contract tests/fixtures/public-safe-contract.v1.json \
  --binding tests/fixtures/public-safe-contract-binding.v1.json \
  --target docs/NEXT_COMMAND_REFERENCE.md
node scripts/scan-public-material.mjs
node scripts/scan-public-material.mjs --self-test
node scripts/run-docs-smoke.mjs --self-test
node scripts/generate-command-reference.mjs --self-test

./tests/install-uninstall.sh
./tests/docs-contract.sh
printf '%s\n' 'public repository validation: PASS'
