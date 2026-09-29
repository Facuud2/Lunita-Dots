# ==============================================================================
# 🍎 macOS Sonoma / Sequoia Theme for Oh-My-Zsh
# Authentic Cupertino aesthetic, Apple typography, Git integration, and timing
# ==============================================================================

autoload -Uz add-zsh-hook
zmodload zsh/datetime 2>/dev/null

_macos_cmd_start=""
_macos_last_duration=0

# Format command execution duration
_macos_format_duration() {
  local d=$1
  if (( d < 60 )); then
    echo "${d}s"
  elif (( d < 3600 )); then
    echo "$(( d / 60 ))m$(( d % 60 ))s"
  else
    echo "$(( d / 3600 ))h$(( (d % 3600) / 60 ))m"
  fi
}

_macos_preexec() {
  _macos_cmd_start=${EPOCHSECONDS:-$SECONDS}
}

_macos_git_info() {
  type git &>/dev/null || return

  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return

  local dirty=""
  local git_flags=""

  # Check if repo has modified or untracked changes
  if [[ -n $(git status --porcelain 2>/dev/null | head -n 1) ]]; then
    dirty="%F{#FF453A}✗%f"
  fi

  # Check ahead / behind upstream
  local ahead behind upstream
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
  if [[ -n "$upstream" ]]; then
    ahead=$(git rev-list --count ${upstream}..HEAD 2>/dev/null)
    behind=$(git rev-list --count HEAD..${upstream} 2>/dev/null)
    (( ahead > 0 )) && git_flags+=" %F{#0A84FF}⇡${ahead}%f"
    (( behind > 0 )) && git_flags+=" %F{#FF453A}⇣${behind}%f"
  fi

  if [[ -n "$dirty" ]]; then
    echo " %F{#8E8E93}on%f %F{#BF5AF2}git:(%F{#32D74B}${branch} ${dirty}%F{#BF5AF2})%f${git_flags}"
  else
    echo " %F{#8E8E93}on%f %F{#BF5AF2}git:(%F{#32D74B}${branch}%F{#BF5AF2})%f${git_flags}"
  fi
}

_macos_precmd() {
  local exit_code=$?

  if [[ -n "$_macos_cmd_start" ]]; then
    _macos_last_duration=$(( ${EPOCHSECONDS:-$SECONDS} - _macos_cmd_start ))
    unset _macos_cmd_start
  else
    _macos_last_duration=0
  fi

  # Apple Cupertino HIG Palette
  local apple_icon="%F{#F5F5F7}%f"
  local user_color="%F{#8E8E93}"
  local path_color="%F{#0A84FF}"
  local success_color="%F{#F5F5F7}"
  local err_color="%F{#FF453A}"
  local reset="%f"

  # Hostname / machine string (customizable, default: macbook)
  local mac_host="${MACOS_HOST:-macbook}"
  local user_str="${user_color}%n@${mac_host}${reset}"

  # Formatted path
  local dir_str="${path_color}%~${reset}"

  # Git status info
  local git_str="$(_macos_git_info)"

  # macOS Prompt character (%)
  local prompt_symbol
  if (( exit_code == 0 )); then
    prompt_symbol="${success_color}%%%f"
  else
    prompt_symbol="${err_color}%%%f"
  fi

  # Style switcher (default: modern)
  # Options:
  #   modern:     user@macbook in ~/dir on git:(main) %
  #   classic:   MacBook-Pro:~ user%
  #   developer: 2-line prompt with execution duration
  local style="${MACOS_PROMPT_STYLE:-modern}"

  if [[ "$style" == "classic" ]]; then
    PROMPT="${mac_host}:%~ %n%# "
    RPROMPT=""
  elif [[ "$style" == "developer" ]]; then
    local dur_str=""
    if (( _macos_last_duration >= 2 )); then
      dur_str=" %F{#8E8E93}[$(_macos_format_duration $_macos_last_duration)]%f"
    fi
    PROMPT="${apple_icon}  ${user_str} ${dir_str}${git_str}${dur_str}"$'\n'"${prompt_symbol} "
    if (( exit_code != 0 )); then
      RPROMPT="%F{#FF453A}exit ${exit_code}%f"
    else
      RPROMPT=""
    fi
  else
    # Default 'modern' macOS prompt
    PROMPT="${apple_icon}  ${user_str} ${dir_str}${git_str} ${prompt_symbol} "
    local rprompt_parts=""
    if (( _macos_last_duration >= 2 )); then
      rprompt_parts="%F{#8E8E93}$(_macos_format_duration $_macos_last_duration)%f"
    fi
    if (( exit_code != 0 )); then
      [[ -n "$rprompt_parts" ]] && rprompt_parts="${rprompt_parts} "
      rprompt_parts="${rprompt_parts}%F{#FF453A}↵ ${exit_code}%f"
    fi
    RPROMPT="${rprompt_parts}"
  fi
}

add-zsh-hook preexec _macos_preexec
add-zsh-hook precmd _macos_precmd
