#!/usr/bin/env bash
# Build + run host bootstrap smoke in a local Debian 12 container.
# Native arch by default; optional multi-arch via buildx.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${DOOMBOX_HOST_TEST_IMAGE:-heyeddi/doombox-host-smoke:bookworm}"
NAME="${DOOMBOX_HOST_TEST_NAME:-doombox-host-smoke}"
# Comma-separated platforms, e.g. linux/amd64,linux/arm64 — requires docker buildx + qemu
PLATFORMS="${DOOMBOX_TEST_PLATFORMS:-}"

log() { printf '==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

command -v docker >/dev/null || die "docker not found on this machine"

run_one() {
  local platform="${1:-}"
  local tag="${IMAGE}"
  local cname="${NAME}"
  local build_args=( -t "${tag}" -f "${ROOT}/test/Dockerfile" "${ROOT}" )
  local run_args=( --rm --name "${cname}" --hostname box )

  if [[ -n "${platform}" ]]; then
    local slug
    slug="$(printf '%s' "${platform}" | tr '/' '-')"
    tag="${IMAGE}-${slug}"
    cname="${NAME}-${slug}"
    build_args=( --platform "${platform}" -t "${tag}" -f "${ROOT}/test/Dockerfile" "${ROOT}" )
    run_args=( --rm --name "${cname}" --hostname box --platform "${platform}" )
    log "Platform ${platform}"
  fi

  log "Building ${tag}"
  if [[ -n "${platform}" ]]; then
    docker buildx build --load "${build_args[@]}"
  else
    docker build "${build_args[@]}"
  fi

  docker rm -f "${cname}" >/dev/null 2>&1 || true

  local extra=()
  local env_args=(-e DOOMBOX_TEST_MODE=container)
  if [[ "${DOOMBOX_TEST_WITH_DOCKER:-0}" == "1" ]]; then
    log "DinD mode: privileged + DOOMBOX_TEST_WITH_DOCKER=1"
    extra+=(--privileged)
    env_args+=(-e DOOMBOX_TEST_WITH_DOCKER=1)
  fi

  log "Running smoke container ${cname}"
  docker run "${run_args[@]}" \
    "${extra[@]}" \
    "${env_args[@]}" \
    "${tag}"
}

if [[ -n "${PLATFORMS}" ]]; then
  log "Multi-arch smoke: ${PLATFORMS}"
  IFS=',' read -r -a plats <<< "${PLATFORMS}"
  for p in "${plats[@]}"; do
    p="$(echo "${p}" | tr -d ' ')"
    [[ -n "${p}" ]] || continue
    run_one "${p}"
  done
else
  run_one ""
fi

log "Host container smoke finished OK (arches tested: ${PLATFORMS:-native})"
