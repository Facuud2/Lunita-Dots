#!/usr/bin/env bash
# ==============================================================================
# 🔒 Lunita Smart Lock Controller
# ==============================================================================

umask 077

runtime_root="${XDG_RUNTIME_DIR:-/tmp}"
lock_mutex="${runtime_root}/hypr_smart_lock.lock"

# 1. Prevent multiple concurrent lock attempts / race conditions
exec 9>"$lock_mutex"
if ! flock -n 9; then
    exit 0
fi

# 2. Check if lockscreen is already running
if pgrep -f "quickshell.*lockscreen" >/dev/null 2>&1 || pidof hyprlock >/dev/null 2>&1; then
    exit 0
fi

# 3. Check if session is already locked in Hyprland
if [[ "$(hyprctl locked 2>/dev/null)" == "true" ]]; then
    exit 0
fi

# 4. Auto-sync wallpaper if changed
if command -v awww >/dev/null 2>&1; then
    curr_wall=$(awww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)
    if [ -n "$curr_wall" ] && [ -f "$curr_wall" ]; then
        if [ ! -f "$HOME/.config/hypr/current_wallpaper.png" ] || [ "$curr_wall" -nt "$HOME/.config/hypr/current_wallpaper.png" ]; then
            cp "$curr_wall" "$HOME/.config/hypr/current_wallpaper.png"
        fi
    fi
fi

# Pre-cache media art for instantaneous lockscreen rendering
if [ -x "$HOME/.config/hypr/scripts/lock_media.sh" ]; then
    "$HOME/.config/hypr/scripts/lock_media.sh" art >/dev/null 2>&1 &
fi

mode="${1:-auto}"
qs_lock_dir="$HOME/.config/quickshell/lockscreen"

# 1. Prioritize theme's native Quickshell Lockscreen (si el tema lo implementa)
if [ "$mode" != "hyprlock" ] && [ "$mode" != "prelock" ] && command -v quickshell >/dev/null 2>&1 && [ -f "$qs_lock_dir/shell.qml" ]; then
    quickshell -p "$qs_lock_dir"
    status=$?
    if [ $status -eq 0 ]; then
        exit 0
    fi
fi

# 2. Hyprlock / Prelock flow
prelock_bin="$HOME/.local/bin/prelock"
if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    unlock_file="$XDG_RUNTIME_DIR/prelock_unlocked"
else
    unlock_file="/tmp/prelock_unlocked_$(id -u)"
fi
stock_hyprlock_bin="/usr/bin/hyprlock"
companion_bin="$HOME/.local/libexec/prelock/hyprlock-prelock"

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

stop_prelock() {
    local pid="${prelock_pid:-}"
    [[ -n "$pid" ]] || return

    prelock_pid=""
    if kill -0 "$pid" 2>/dev/null; then
        kill -TERM "$pid" 2>/dev/null || true
    fi
    wait "$pid" 2>/dev/null || true
}

fade_prelock() {
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
    stop_prelock
    rm -f "$unlock_file"
}

trap cleanup EXIT

# Iniciar Prelock si está disponible
if [ -x "$prelock_bin" ]; then
    anim="classic"
    if [ "$mode" != "auto" ] && [ "$mode" != "hyprlock" ] && [ "$mode" != "prelock" ]; then
        anim="$mode"
    fi

    ready_dir="$(mktemp -d "$runtime_root/prelock-ready.XXXXXX" 2>/dev/null)"
    if [[ -n "$ready_dir" ]] && mkfifo -m 600 "$ready_dir/ready" &&
        exec {ready_fd}<>"$ready_dir/ready"; then
        ready_fifo="$ready_dir/ready"
        PRELOCK_READY_FIFO="$ready_fifo" "$prelock_bin" "$anim" &
        prelock_pid=$!
        IFS= read -r -t 3 -u "$ready_fd" || true
        close_ready_channel
    else
        "$prelock_bin" "$anim" &
        prelock_pid=$!
        sleep 0.8
    fi
fi

# Seleccionar binario de hyprlock (companion parcheado si existe, o stock)
locker="$stock_hyprlock_bin"
if [ -x "$companion_bin" ]; then
    locker="$companion_bin"
fi

"$locker"
status=$?

fade_prelock
trap - EXIT
exit "$status"
