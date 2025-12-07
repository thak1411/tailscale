#!/bin/sh
set -eu

log() {
  echo "[tailscale-tso] $*"
}

CONTAINERBOOT="/usr/local/bin/containerboot"
BOOT_PID=""

disable_tso() {
  # Wait for the tailscale interface to appear before disabling TSO.
  for i in $(seq 1 60); do
    if ip link show tailscale0 >/dev/null 2>&1; then
      if ethtool -K tailscale0 tso off 2>/dev/null; then
        log "TSO disabled on tailscale0"
      else
        log "ethtool failed to toggle TSO; continuing without exiting"
      fi
      return
    fi
    sleep 1
  done
  log "tailscale0 did not appear within 60s; skipped TSO toggle"
}

shutdown() {
  if [ -n "$BOOT_PID" ] && kill -0 "$BOOT_PID" 2>/dev/null; then
    kill -TERM "$BOOT_PID" 2>/dev/null || true
    wait "$BOOT_PID" 2>/dev/null || true
  fi
  exit 0
}

trap shutdown INT TERM

"$CONTAINERBOOT" "$@" &
BOOT_PID=$!

disable_tso &

wait "$BOOT_PID"
