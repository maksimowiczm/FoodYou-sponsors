set shell := ["bash", "-uc"]

default:
    @just --list

sign file key:
    @[[ -f "{{ file }}" ]] || { echo "Error: {{ file }} not found" >&2; exit 1; }
    @[[ -r "{{ key }}" ]] || { echo "Error: {{ key }} not readable" >&2; exit 1; }
    @file="{{ file }}"; \
    key="{{ key }}"; \
    sig="${file}.sig"; \
    if ! openssl pkeyutl -sign -inkey "$key" -rawin -in "$file" | base64 > "$sig"; then \
      echo "Error: failed to sign $file" >&2; \
      rm -f "$sig"; \
      exit 1; \
    fi; \
    echo "Signature: $sig"

minify json:
    @[[ -f "{{ json }}" ]] || { echo "Error: {{ json }} not found" >&2; exit 1; }
    @tmp="{{ json }}.tmp"; \
    if ! jq -cS . "{{ json }}" > "$tmp"; then \
      echo "Error: failed to minify {{ json }}" >&2; \
      rm -f "$tmp"; \
      exit 1; \
    fi; \
    mv "$tmp" "{{ json }}"; \
    echo "Replaced with minified JSON: {{ json }}"
