# Shared: require physical / non-SSH session for sensitive host tools.
# shellcheck shell=bash

doombox_is_remote_session() {
  [[ -n "${SSH_CONNECTION:-}${SSH_CLIENT:-}${SSH_TTY:-}" ]] && return 0
  return 1
}

# Exit 2 if this looks like SSH/remote. Container smoke may set DOOMBOX_TEST_MODE=container.
doombox_require_physical_console() {
  local tool="${1:-doombox tool}"
  if doombox_is_remote_session; then
    if [[ "${DOOMBOX_TEST_MODE:-}" == "container" ]]; then
      printf 'WARNING: remote markers present but DOOMBOX_TEST_MODE=container — allowing\n' >&2
      return 0
    fi
    cat <<EOF >&2
Refusing ${tool} over a remote session (SSH detected).

This tool is physical-console only (local keyboard / HDMI / serial).
Even if remote admin is enabled, run it at the box — not over SSH.
EOF
    return 2
  fi
  return 0
}
