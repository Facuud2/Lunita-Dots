#!/usr/bin/env bash
# ==============================================================================
# store-wrapper.sh - Interceptor para cliphist store con registro de timestamp
# ==============================================================================

set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist"
mkdir -p "$CACHE_DIR"
TSV_FILE="$CACHE_DIR/timestamps.tsv"

# Enviar entrada estándar a cliphist store
cliphist store "$@" || true

# Extraer el ID recién asignado y registrar la fecha/hora en segundos epoch
LATEST_LINE=$(cliphist list | head -n 1 || true)
if [ -n "$LATEST_LINE" ]; then
    ITEM_ID=$(echo "$LATEST_LINE" | cut -f1)
    if [ -n "$ITEM_ID" ]; then
        NOW=$(date +%s)
        printf "%s\t%s\n" "$ITEM_ID" "$NOW" >> "$TSV_FILE"
    fi
fi
