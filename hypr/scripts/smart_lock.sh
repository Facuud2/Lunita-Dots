#!/bin/bash

umask 077

runtime_root="${XDG_RUNTIME_DIR:-/tmp}"
lock_mutex="${runtime_root}/hypr_smart_lock.lock"

# 1. Prevent multiple concurrent lock attempts / race conditions
exec 9>"$lock_mutex"
if ! flock -n 9; then
    exit 0
fi

# 2. Check if hyprlock or prelock is already running
if pidof hyprlock >/dev/null 2>&1 || pidof prelock >/dev/null 2>&1; then
    exit 0
fi

# 3. Check if session is already locked in Hyprland
if [[ "$(hyprctl locked 2>/dev/null)" == "true" ]]; then
    exit 0
fi

unlock_file="/tmp/prelock_unlocked"
prelock_bin="$HOME/.local/bin/prelock"
stock_hyprlock_bin="${HYPRLOCK_STOCK_BIN:-/usr/bin/hyprlock}"

prelock_pid=""
ready_dir=""
ready_fifo=""

close_ready_channel() {
    if [[ -n "${ready_fd:-}" ]]; then
        exec {ready_fd}>&-
        unset ready_fd
    fi
    [[ -n "$ready_fifo" ]] && rm -f -- "$ready_fifo"
    [[ -n "$ready_dir" ]] && rmdir -- "$ready_dir" 2>/dev/null || true
    ready_fifo=""
    ready_dir=""
}

stop_prelock_hidden() {
    local pid="${prelock_pid:-}"
    [[ -n "$pid" ]] || return

    prelock_pid=""
    if kill -0 "$pid" 2>/dev/null; then
        kill -TERM "$pid" 2>/dev/null || true
    fi
    wait "$pid" 2>/dev/null || true
}

fade_prelock_visible() {
    local pid="${prelock_pid:-}"
    [[ -n "$pid" ]] || return

    if kill -0 "$pid" 2>/dev/null; then
        touch "$unlock_file"
    fi
    wait "$pid" 2>/dev/null || true
    prelock_pid=""
    rm -f "$unlock_file"
}

cleanup() {
    close_ready_channel
    stop_prelock_hidden
    rm -f "$unlock_file"
}

trap cleanup EXIT

launch_prelock() {
    local prelock_output=""
    local anim="${1:-classic}"

    if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
        prelock_output="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.monitor // empty' 2>/dev/null)"
    fi

    ready_dir="$(mktemp -d "$runtime_root/prelock-ready.XXXXXX" 2>/dev/null)"
    if [[ -n "$ready_dir" ]] && mkfifo -m 600 "$ready_dir/ready" &&
        exec {ready_fd}<>"$ready_dir/ready"; then
        ready_fifo="$ready_dir/ready"
        PRELOCK_OUTPUT="$prelock_output" PRELOCK_READY_FIFO="$ready_fifo" \
            "$prelock_bin" "$anim" &
        prelock_pid=$!
        if IFS= read -r -t 4 -u "$ready_fd"; then
            close_ready_channel
            return 0
        fi
        close_ready_channel
        return 1
    fi

    close_ready_channel
    PRELOCK_OUTPUT="$prelock_output" "$prelock_bin" "$anim" &
    prelock_pid=$!
    sleep 1.2
    return 0
}

run_locker() {
    local status=0
    local locker="$stock_hyprlock_bin"

    if [[ ! -x "$locker" ]]; then
        printf 'smart_lock: hyprlock is unavailable: %s\n' "$locker" >&2
        fade_prelock_visible
        return 127
    fi

    # Run hyprlock in foreground
    "$locker"
    status=$?

    # Upon successful unlock (hyprlock exited cleanly):
    # Reproduce the unlock animation (lock unlatches, rings expand, and blur dissolves)
    fade_prelock_visible
    return "$status"
}

rm -f "$unlock_file"

# Auto-sync wallpaper and matugen colors if wallpaper changed
if command -v awww >/dev/null 2>&1; then
    curr_wall=$(awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
    if [ -n "$curr_wall" ] && [ -f "$curr_wall" ]; then
        if [ ! -f "$HOME/.config/hypr/current_wallpaper.png" ] || [ "$curr_wall" -nt "$HOME/.config/hypr/current_wallpaper.png" ]; then
            cp "$curr_wall" "$HOME/.config/hypr/current_wallpaper.png"
            if command -v matugen >/dev/null 2>&1; then
                matugen image "$curr_wall" --source-color-index 0 >/dev/null 2>&1
            fi
        fi
    fi
fi

# Launch prelock animation (candado cerrándose)
launch_prelock "${1:-classic}"

# Run hyprlock session lock
run_locker
exit_code=$?

# Untrap and exit cleanly
trap - EXIT
exit "$exit_code"
