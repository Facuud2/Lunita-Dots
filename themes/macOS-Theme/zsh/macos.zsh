# ==============================================================================
# 🍎 macOS Terminal Environment & Utilities for Zsh
# Provides authentic macOS tools, login banner, aliases, and behaviors
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Authentic macOS Login Banner
# ------------------------------------------------------------------------------
if [[ -o interactive ]] && [[ -z "$LUNITA_MACOS_BANNER_DONE" ]]; then
  export LUNITA_MACOS_BANNER_DONE=1
  _macos_stamp="$HOME/.cache/lunita_macos_lastlogin"
  _macos_now=$(date +"%a %b %e %T")
  _macos_tty=$(tty 2>/dev/null | sed 's|/dev/||')
  [[ -z "$_macos_tty" ]] && _macos_tty="ttys001"

  if [[ -f "$_macos_stamp" ]]; then
    _macos_prev=$(cat "$_macos_stamp" 2>/dev/null)
  fi
  [[ -z "$_macos_prev" ]] && _macos_prev="$_macos_now"

  echo "Last login: ${_macos_prev} on ${_macos_tty}"
  mkdir -p "$HOME/.cache"
  echo "$_macos_now" >| "$_macos_stamp" 2>/dev/null
  unset _macos_stamp _macos_now _macos_tty _macos_prev
fi

# ------------------------------------------------------------------------------
# 2. macOS Environment Variables
# ------------------------------------------------------------------------------
export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# ------------------------------------------------------------------------------
# 3. macOS Native Commands Emulation
# ------------------------------------------------------------------------------

# open: Open files, directories or URLs using default GUI apps or specific app (-a)
open() {
  if [[ "$1" == "-a" ]]; then
    shift
    local app="$1"
    shift
    nohup "$app" "$@" &>/dev/null &
  elif [[ "$#" -eq 0 ]]; then
    nohup xdg-open . &>/dev/null &
  else
    for target in "$@"; do
      nohup xdg-open "$target" &>/dev/null &
    done
  fi
}

# pbcopy & pbpaste: macOS Clipboard Integration
if command -v wl-copy &>/dev/null; then
  alias pbcopy='wl-copy'
  alias pbpaste='wl-paste'
elif command -v xclip &>/dev/null; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# sw_vers: Print macOS Darwin / Sequoia system build info
sw_vers() {
  local kernel_ver=$(uname -r)
  echo "ProductName:		macOS"
  echo "ProductVersion:		15.1 (Sequoia - Lunita Edition)"
  echo "BuildVersion:		24B83 (${kernel_ver})"
}

# brew: Homebrew command wrapper translated to yay / pacman
brew() {
  local cmd="$1"
  case "$cmd" in
    install)
      shift
      if command -v yay &>/dev/null; then
        yay -S "$@"
      else
        sudo pacman -S "$@"
      fi
      ;;
    uninstall|remove)
      shift
      if command -v yay &>/dev/null; then
        yay -Rns "$@"
      else
        sudo pacman -Rns "$@"
      fi
      ;;
    update)
      if command -v yay &>/dev/null; then
        yay -Sy
      else
        sudo pacman -Sy
      fi
      ;;
    upgrade)
      if command -v yay &>/dev/null; then
        yay -Syu
      else
        sudo pacman -Syu
      fi
      ;;
    search)
      shift
      if command -v yay &>/dev/null; then
        yay -Ss "$@"
      else
        pacman -Ss "$@"
      fi
      ;;
    info)
      shift
      if command -v yay &>/dev/null; then
        yay -Si "$@"
      else
        pacman -Si "$@"
      fi
      ;;
    list)
      pacman -Qe
      ;;
    doctor)
      echo "Your system is ready to brew (running Lunita macOS Theme)."
      ;;
    *)
      echo "🍎 Homebrew macOS Wrapper for Lunita-Dots"
      echo "Usage: brew [install|uninstall|update|upgrade|search|info|list|doctor]"
      ;;
  esac
}

# flushdns: Flush local DNS resolver cache
flushdns() {
  if command -v resolvectl &>/dev/null; then
    resolvectl flush-caches 2>/dev/null && echo "macOS DNS cache flushed successfully."
  elif command -v systemd-resolve &>/dev/null; then
    sudo systemd-resolve --flush-caches 2>/dev/null && echo "macOS DNS cache flushed successfully."
  else
    echo "DNS cache flushed."
  fi
}

# afplay: macOS Audio Player
if command -v mpv &>/dev/null; then
  alias afplay='mpv --no-video'
fi

# say: macOS Text-to-Speech
if command -v spd-say &>/dev/null; then
  alias say='spd-say'
fi

# Finder shortcut
alias finder='open .'

# macfetch: Fastfetch with official Apple logo
alias macfetch='fastfetch --logo Apple'
alias fastfetch='fastfetch --logo Apple'
