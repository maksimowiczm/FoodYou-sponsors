#!/usr/bin/env bash
set -euo pipefail

readonly REQUIRED_CMDS=(jq openssl base64)

check_deps() {
  for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "Error: $cmd is not installed" >&2
      exit 1
    fi
  done
}

check_args() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <file.json> <private.pem>" >&2
    exit 1
  fi

  if [[ ! -f $1 ]]; then
    echo "Error: $1 not found" >&2
    exit 1
  fi

  if [[ ! -r $2 ]]; then
    echo "Error: $2 not readable" >&2
    exit 1
  fi
}

sign() {
  local json="$1"
  local key="$2"
  local min="${json%.json}.min.json"
  local sig="${json%.json}.sig"

  if ! jq -cS . "$json" > "$min"; then
    echo "Error: failed to minify $json" >&2
    rm -f "$min"
    exit 1
  fi

  if ! openssl pkeyutl -sign -inkey "$key" -rawin -in "$min" | base64 > "$sig"; then
    echo "Error: failed to sign $min" >&2
    rm -f "$sig"
    exit 1
  fi

  echo "Minified: $min"
  echo "Signature: $sig"
}

check_deps
check_args "$@"
sign "$1" "$2"