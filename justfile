required_cmds := "jq openssl base64"

default:
    @just --list

check-deps:
    @for cmd in {{ required_cmds }}; do \
      if ! command -v "$cmd" >/dev/null 2>&1; then \
        echo "Error: $cmd is not installed" >&2; \
        exit 1; \
      fi; \
    done
    @echo "All required commands are available."

sign json key: check-deps
    @[[ -f "{{ json }}" ]] || { echo "Error: {{ json }} not found" >&2; exit 1; }
    @[[ -r "{{ key }}" ]] || { echo "Error: {{ key }} not readable" >&2; exit 1; }
    @json="{{ json }}"; \
    key="{{ key }}"; \
    min="${json%.json}.min.json"; \
    sig="${json%.json}.json.sig"; \
    if ! jq -cS . "$json" > "$min"; then \
      echo "Error: failed to minify $json" >&2; \
      rm -f "$min"; \
      exit 1; \
    fi; \
    if ! openssl pkeyutl -sign -inkey "$key" -rawin -in "$min" | base64 > "$sig"; then \
      echo "Error: failed to sign $min" >&2; \
      rm -f "$sig"; \
      exit 1; \
    fi; \
    echo "Minified: $min"; \
    echo "Signature: $sig"
