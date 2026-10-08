# ==============================================================================
# 🌙 Lunita Dynamic Theme for Oh-My-Zsh
# Detecta automáticamente el tema visual activo de Lunita-Dots
# y carga el prompt correspondiente (pills, macos, etc.)
# ==============================================================================

_lunita_current_theme="lunita-default"

if [[ -f "$HOME/.config/lunita/current_theme" ]]; then
  _lunita_current_theme=$(tr -d '[:space:]' < "$HOME/.config/lunita/current_theme")
elif [[ -f "/mnt/Desarrollo/Lunita-Dots/.lunita-theme" ]]; then
  _lunita_current_theme=$(tr -d '[:space:]' < "/mnt/Desarrollo/Lunita-Dots/.lunita-theme")
fi

case "$_lunita_current_theme" in
  macOS-Theme|macos)
    if [[ -f "${ZSH_CUSTOM:-$ZSH/custom}/themes/macos.zsh-theme" ]]; then
      source "${ZSH_CUSTOM:-$ZSH/custom}/themes/macos.zsh-theme"
    elif [[ -f "${0:A:h}/macos.zsh-theme" ]]; then
      source "${0:A:h}/macos.zsh-theme"
    fi
    ;;
  *)
    if [[ -f "${ZSH_CUSTOM:-$ZSH/custom}/themes/pills.zsh-theme" ]]; then
      source "${ZSH_CUSTOM:-$ZSH/custom}/themes/pills.zsh-theme"
    elif [[ -f "${0:A:h}/pills.zsh-theme" ]]; then
      source "${0:A:h}/pills.zsh-theme"
    fi
    ;;
esac
