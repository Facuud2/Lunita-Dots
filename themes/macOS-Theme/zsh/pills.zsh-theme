# Custom Pills Theme for Oh-My-Zsh
# Designed for Kitty + Hyprland + Matugen pair programming workflow

autoload -Uz add-zsh-hook
zmodload zsh/datetime 2>/dev/null

_pills_cmd_start=""
_pills_last_duration=0

_pills_format_duration() {
  local d=$1
  if (( d < 60 )); then
    echo "${d}s"
  elif (( d < 3600 )); then
    echo "$(( d / 60 ))m$(( d % 60 ))s"
  else
    echo "$(( d / 3600 ))h$(( (d % 3600) / 60 ))m"
  fi
}

_pills_format_dir() {
  local p="${1/#$HOME/~}"
  local -a parts=("${(@s:/:)p}")
  if (( ${#parts} > 2 )); then
    echo ".../${parts[-2]}/${parts[-1]}"
  else
    echo "$p"
  fi
}

_pills_preexec() {
  _pills_cmd_start=${EPOCHSECONDS:-$SECONDS}
}

_pills_precmd() {
  local exit_code=$?

  if [[ -n "$_pills_cmd_start" ]]; then
    _pills_last_duration=$(( ${EPOCHSECONDS:-$SECONDS} - _pills_cmd_start ))
    unset _pills_cmd_start
  else
    _pills_last_duration=0
  fi

  # macOS Cupertino colors
  local pill_bg="#F5F5F7"
  local pill_fg="#1D1D1F"
  local accent="#007AFF"
  local err_color="#FF3B30"

  if [[ -f "$HOME/.oh-my-zsh/custom/zsh-colors.zsh" ]]; then
    source "$HOME/.oh-my-zsh/custom/zsh-colors.zsh" 2>/dev/null
    pill_bg="${PROMPT_PILL_BG:-$pill_bg}"
    pill_fg="${PROMPT_PILL_FG:-$pill_fg}"
    accent="${PROMPT_ACCENT:-$accent}"
    err_color="${PROMPT_ERROR:-$err_color}"
  fi

  local dur_str="$(_pills_format_duration $_pills_last_duration)"
  local dir_str="$(_pills_format_dir "$PWD")"

  # Pill 1: Duration
  local time_pill="%F{${pill_bg}}%K{${pill_bg}}%F{${pill_fg}}%B${dur_str}%b%k%F{${pill_bg}}%f"

  # Pill 2: Directory with folder icon
  local dir_pill="%F{${pill_bg}}%K{${pill_bg}}%F{${pill_fg}}%B📁 ${dir_str}%b%k%F{${pill_bg}}%f"

  # Optional Git branch pill if inside a repo
  local git_pill=""
  if type git &>/dev/null; then
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
      git_pill=" %F{${accent}}%K{${accent}}%F{${pill_fg}}%B ${branch}%b%k%F{${accent}}%f"
    fi
  fi

  # Line 2 prompt symbol
  local status_sym
  if (( exit_code == 0 )); then
    status_sym="%F{#ffffff}%B●%b%f %F{${accent}}▶%f "
  else
    status_sym="%F{${err_color}}%B✖%b%f %F{${accent}}▶%f "
  fi

  PROMPT="${time_pill} ${dir_pill}${git_pill}"$'\n'"${status_sym}"
}

add-zsh-hook preexec _pills_preexec
add-zsh-hook precmd _pills_precmd
