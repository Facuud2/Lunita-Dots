#!/usr/bin/env bash
# ==============================================================================
# 🌙 LUNITA THEME MANAGER CLI
# Gestor central de temas para Lunita-Dots
# ==============================================================================

set -e

# Detectar directorio raíz canónico del repositorio Lunita-Dots
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
DOTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
THEMES_DIR="$DOTS_DIR/themes"
STATE_FILE="$DOTS_DIR/.lunita-theme"
USER_STATE_DIR="$HOME/.config/lunita"
USER_STATE_FILE="$USER_STATE_DIR/current_theme"

# Colores y estilo
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
MAGENTA="\033[35m"
RESET="\033[0m"

info() { echo -e "${CYAN}ℹ${RESET} $1"; }
success() { echo -e "${GREEN}✓${RESET} $1"; }
warn() { echo -e "${YELLOW}⚠${RESET} $1"; }
error() { echo -e "${RED}✗${RESET} $1" >&2; }

# Obtener nombre del tema activo actual
get_current_theme() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE" | tr -d '[:space:]'
    elif [ -f "$USER_STATE_FILE" ]; then
        cat "$USER_STATE_FILE" | tr -d '[:space:]'
    else
        echo "lunita-default"
    fi
}

# ------------------------------------------------------------------------------
# Comando: LIST
# ------------------------------------------------------------------------------
cmd_list() {
    local current
    current="$(get_current_theme)"
    
    echo -e "${BOLD}${MAGENTA}🌙 Lunita-Dots — Temas Disponibles${RESET}"
    echo "=================================================="

    if [ ! -d "$THEMES_DIR" ]; then
        error "No se encontró el directorio de temas en $THEMES_DIR"
        exit 1
    fi

    for theme_path in "$THEMES_DIR"/*; do
        if [ -d "$theme_path" ]; then
            local theme_id
            theme_id="$(basename "$theme_path")"
            local theme_json="$theme_path/theme.json"
            local theme_name="$theme_id"
            local theme_desc="Sin descripción disponible"
            local theme_author="Desconocido"
            local theme_ver="1.0"

            if [ -f "$theme_json" ] && command -v jq &>/dev/null; then
                theme_name="$(jq -r '.name // "'"$theme_id"'"' "$theme_json")"
                theme_desc="$(jq -r '.description // "Sin descripción"' "$theme_json")"
                theme_author="$(jq -r '.author // "Desconocido"' "$theme_json")"
                theme_ver="$(jq -r '.version // "1.0"' "$theme_json")"
            fi

            if [ "$theme_id" = "$current" ]; then
                echo -e "${GREEN}${BOLD}● $theme_name${RESET} (${CYAN}$theme_id${RESET}) ${GREEN}${BOLD}[ACTIVO]${RESET}"
            else
                echo -e "○ ${BOLD}$theme_name${RESET} (${CYAN}$theme_id${RESET})"
            fi
            echo -e "  ${YELLOW}Versión:${RESET} $theme_ver | ${YELLOW}Autor:${RESET} $theme_author"
            echo -e "  ${BOLD}Descripción:${RESET} $theme_desc"
            echo ""
        fi
    done
}

# ------------------------------------------------------------------------------
# Comando: CURRENT
# ------------------------------------------------------------------------------
cmd_current() {
    local current
    current="$(get_current_theme)"
    local theme_dir="$THEMES_DIR/$current"
    local theme_json="$theme_dir/theme.json"

    echo -e "${BOLD}${MAGENTA}🌙 Tema Activo:${RESET} ${GREEN}${BOLD}$current${RESET}"
    echo "--------------------------------------------------"

    if [ -f "$theme_json" ] && command -v jq &>/dev/null; then
        local name author desc
        name="$(jq -r '.name // "'"$current"'"' "$theme_json")"
        author="$(jq -r '.author // "Desconocido"' "$theme_json")"
        desc="$(jq -r '.description // "Sin descripción"' "$theme_json")"
        
        echo -e "${BOLD}Nombre:${RESET} $name"
        echo -e "${BOLD}Autor:${RESET}  $author"
        echo -e "${BOLD}Detalles:${RESET} $desc"
        echo ""
        echo -e "${BOLD}Componentes configurados:${RESET}"
        jq -r '.components | to_entries[] | "  - \(.key): \(.value)"' "$theme_json" 2>/dev/null || true
    else
        echo "Ruta: $theme_dir"
    fi
}

# ------------------------------------------------------------------------------
# Función auxiliar: Crear enlace simbólico seguro
# ------------------------------------------------------------------------------
link_component() {
    local src="$1"
    local dest="$2"

    if [ ! -e "$src" ]; then
        # Si el componente no existe en el tema pero el enlace actual apunta a themes/, desenlazarlo
        if [ -L "$dest" ]; then
            local current_target
            current_target="$(readlink -f "$dest" 2>/dev/null || true)"
            if [[ "$current_target" == "$THEMES_DIR"* ]]; then
                rm -f "$dest"
                info "Componente no presente en '$target': desenlazado $dest"
            fi
        fi
        return 0
    fi

    # Si el destino ya existe y NO es un enlace simbólico, respaldarlo una sola vez
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        local backup="${dest}.bak-$(date +%Y%m%d%H%M%S)"
        warn "Respaldando directorio existente: $dest -> $backup"
        mv "$dest" "$backup"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src" "$dest"
    success "Enlazado: $dest -> $src"
}

# ------------------------------------------------------------------------------
# Comando: APPLY / SET
# ------------------------------------------------------------------------------
cmd_apply() {
    local target="$1"

    if [ -z "$target" ]; then
        error "Debes especificar el identificador del tema. Ejemplo: lunita-theme apply lunita-default"
        exit 1
    fi

    local target_dir="$THEMES_DIR/$target"
    if [ ! -d "$target_dir" ]; then
        error "El tema '$target' no existe en $THEMES_DIR"
        echo "Usa 'lunita-theme list' para ver los temas disponibles."
        exit 1
    fi

    info "Aplicando tema: ${BOLD}$target${RESET}..."

    # 1. Enlazar componentes del tema hacia ~/.config
    mkdir -p "$HOME/.config" "$USER_STATE_DIR"

    # Enlazar AGS (si existe en el tema, ej: lunita-default)
    if [ -d "$target_dir/ags" ]; then
        link_component "$target_dir/ags" "$HOME/.config/ags"
    elif [ -L "$HOME/.config/ags" ] || [ -d "$HOME/.config/ags" ]; then
        rm -rf "$HOME/.config/ags"
    fi

    # Enlazar Eww (si existe en el tema)
    if [ -d "$target_dir/eww" ]; then
        link_component "$target_dir/eww" "$HOME/.config/eww"
    elif [ -L "$HOME/.config/eww" ] || [ -d "$HOME/.config/eww" ]; then
        rm -rf "$HOME/.config/eww"
    fi

    # Enlazar Hyprland (Siempre apuntar a core/hypr que es la base maestra real del sistema)
    if [ -d "$DOTS_DIR/core/hypr" ]; then
        link_component "$DOTS_DIR/core/hypr" "$HOME/.config/hypr"
    fi

    # Enlazar Kitty
    link_component "$target_dir/kitty" "$HOME/.config/kitty"

    # Enlazar Neovim
    link_component "$target_dir/nvim" "$HOME/.config/nvim"

    # Enlazar Wlogout
    link_component "$target_dir/wlogout" "$HOME/.config/wlogout"

    # Enlazar Quickshell (dock, bar, launcher y hyprquickpaper)
    if [ -d "$target_dir/quickshell/dock" ]; then
        link_component "$target_dir/quickshell/dock" "$HOME/.config/quickshell/dock"
    elif [ -L "$HOME/.config/quickshell/dock" ]; then
        rm -f "$HOME/.config/quickshell/dock"
    fi
    if [ -d "$target_dir/quickshell/bar" ]; then
        link_component "$target_dir/quickshell/bar" "$HOME/.config/quickshell/bar"
    elif [ -L "$HOME/.config/quickshell/bar" ]; then
        rm -f "$HOME/.config/quickshell/bar"
    fi
    if [ -d "$target_dir/quickshell/launcher" ]; then
        link_component "$target_dir/quickshell/launcher" "$HOME/.config/quickshell/launcher"
    elif [ -L "$HOME/.config/quickshell/launcher" ]; then
        rm -f "$HOME/.config/quickshell/launcher"
    fi
    if [ -d "$target_dir/quickshell/spotlight" ]; then
        link_component "$target_dir/quickshell/spotlight" "$HOME/.config/quickshell/spotlight"
    elif [ -L "$HOME/.config/quickshell/spotlight" ]; then
        rm -f "$HOME/.config/quickshell/spotlight"
    fi
    if [ -d "$target_dir/quickshell/notifications" ]; then
        link_component "$target_dir/quickshell/notifications" "$HOME/.config/quickshell/notifications"
    elif [ -L "$HOME/.config/quickshell/notifications" ]; then
        rm -f "$HOME/.config/quickshell/notifications"
    fi
    if [ -d "$target_dir/quickshell/osd" ]; then
        link_component "$target_dir/quickshell/osd" "$HOME/.config/quickshell/osd"
    elif [ -L "$HOME/.config/quickshell/osd" ]; then
        rm -f "$HOME/.config/quickshell/osd"
    fi
    if [ -d "$target_dir/quickshell/hyprquickpaper" ]; then
        link_component "$target_dir/quickshell/hyprquickpaper" "$HOME/.config/quickshell/hyprquickpaper"
    elif [ -L "$HOME/.config/quickshell/hyprquickpaper" ]; then
        rm -f "$HOME/.config/quickshell/hyprquickpaper"
    fi
    if [ -d "$target_dir/quickshell/lockscreen" ]; then
        link_component "$target_dir/quickshell/lockscreen" "$HOME/.config/quickshell/lockscreen"
    elif [ -L "$HOME/.config/quickshell/lockscreen" ]; then
        rm -f "$HOME/.config/quickshell/lockscreen"
    fi
    if [ -d "$target_dir/quickshell/widgets" ]; then
        link_component "$target_dir/quickshell/widgets" "$HOME/.config/quickshell/widgets"
    elif [ -L "$HOME/.config/quickshell/widgets" ]; then
        rm -f "$HOME/.config/quickshell/widgets"
    fi

    # Enlazar Dolphin y KDE Globals
    link_component "$target_dir/dolphin/dolphinrc" "$HOME/.config/dolphinrc"
    link_component "$target_dir/dolphin/user-places.xbel" "$HOME/.local/share/user-places.xbel"
    if [ -f "$target_dir/kdeglobals" ]; then
        link_component "$target_dir/kdeglobals" "$HOME/.config/kdeglobals"
    fi

    # Enlazar propiedades de vista de Dolphin (previews habilitados)
    mkdir -p "$HOME/.local/share/dolphin/view_properties/global"
    link_component "$target_dir/dolphin/view_properties/global/.directory" "$HOME/.local/share/dolphin/view_properties/global/.directory"

    # Enlazar Qt6ct (config, colors y qss)
    link_component "$target_dir/qt6ct/qt6ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
    if [ -d "$target_dir/qt6ct/colors" ]; then
        mkdir -p "$HOME/.config/qt6ct/colors"
        for c in "$target_dir/qt6ct/colors"/*; do
            [ -f "$c" ] && ln -sf "$c" "$HOME/.config/qt6ct/colors/$(basename "$c")"
        done
    fi
    if [ -d "$target_dir/qt6ct/qss" ]; then
        mkdir -p "$HOME/.config/qt6ct/qss"
        for q in "$target_dir/qt6ct/qss"/*; do
            [ -f "$q" ] && ln -sf "$q" "$HOME/.config/qt6ct/qss/$(basename "$q")"
        done
    fi

    # Enlazar ajustes de cursor y GTK
    link_component "$target_dir/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
    link_component "$target_dir/gtk-3.0/bookmarks" "$HOME/.config/gtk-3.0/bookmarks"
    link_component "$target_dir/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
    link_component "$target_dir/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
    link_component "$target_dir/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
    link_component "$target_dir/icons/default/index.theme" "$HOME/.icons/default/index.theme"
    link_component "$target_dir/xresources/.Xresources" "$HOME/.Xresources"

    # Enlazar Zsh prompt y configuraciones personalizadas del tema
    if [ -d "$HOME/.oh-my-zsh/custom" ]; then
        mkdir -p "$HOME/.oh-my-zsh/custom/themes"
        for th in "$target_dir/zsh"/*.zsh-theme; do
            if [ -f "$th" ]; then
                local th_name="$(basename "$th")"
                ln -sf "$th" "$HOME/.oh-my-zsh/custom/themes/$th_name"
                success "Prompt Zsh ($th_name) enlazado en ~/.oh-my-zsh/custom/themes/"
            fi
        done
        for zs in "$target_dir/zsh"/*.zsh; do
            if [ -f "$zs" ]; then
                local zs_name="$(basename "$zs")"
                ln -sf "$zs" "$HOME/.oh-my-zsh/custom/$zs_name"
                success "Script auxiliar Zsh ($zs_name) enlazado en ~/.oh-my-zsh/custom/"
            fi
        done
        if [ ! -f "$target_dir/zsh/macos.zsh" ] && [ -L "$HOME/.oh-my-zsh/custom/macos.zsh" ]; then
            rm -f "$HOME/.oh-my-zsh/custom/macos.zsh"
        fi
    fi

    # Enlazar wrapper de Dolphin
    if [ -f "$DOTS_DIR/scripts/dolphin" ]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$DOTS_DIR/scripts/dolphin" "$HOME/.local/bin/dolphin"
    fi

    # Enlazar Cliphist
    link_component "$target_dir/cliphist" "$HOME/.config/cliphist"

    # Enlazar Vesktop (Discord)
    if [ -f "$target_dir/vesktop/themes/lunita.theme.css" ]; then
        mkdir -p "$HOME/.config/vesktop/themes"
        link_component "$target_dir/vesktop/themes/lunita.theme.css" "$HOME/.config/vesktop/themes/lunita.theme.css"
    fi

    # Enlazar servicios systemd de usuario
    if [ -d "$target_dir/systemd/user" ]; then
        mkdir -p "$HOME/.config/systemd/user"
        for s in "$target_dir/systemd/user"/*; do
            if [ -f "$s" ]; then
                link_component "$s" "$HOME/.config/systemd/user/$(basename "$s")"
            fi
        done
        systemctl --user daemon-reload 2>/dev/null || true
    fi

    # 2. Guardar estado
    echo "$target" > "$STATE_FILE"
    echo "$target" > "$USER_STATE_FILE"

    # 3. Asegurar binarios y desktop entry en PATH y XDG
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/scalable/apps"
    ln -sf "$DOTS_DIR/scripts/lunita-theme.sh" "$HOME/.local/bin/lunita-theme"
    if [ -f "$DOTS_DIR/scripts/lunita-theme-selector" ]; then
        ln -sf "$DOTS_DIR/scripts/lunita-theme-selector" "$HOME/.local/bin/lunita-theme-selector"
    fi
    if [ -f "$DOTS_DIR/scripts/lunita-launcher" ]; then
        ln -sf "$DOTS_DIR/scripts/lunita-launcher" "$HOME/.local/bin/lunita-launcher"
    fi
    if [ -f "$DOTS_DIR/scripts/lunita-spotlight" ]; then
        ln -sf "$DOTS_DIR/scripts/lunita-spotlight" "$HOME/.local/bin/lunita-spotlight"
    fi
    if [ -f "$DOTS_DIR/scripts/lunita-notify" ]; then
        ln -sf "$DOTS_DIR/scripts/lunita-notify" "$HOME/.local/bin/lunita-notify"
    fi
    if [ -f "$DOTS_DIR/scripts/lunita-osd" ]; then
        ln -sf "$DOTS_DIR/scripts/lunita-osd" "$HOME/.local/bin/lunita-osd"
    fi
    if [ -f "$DOTS_DIR/scripts/lunita-quickshell" ]; then
        ln -sf "$DOTS_DIR/scripts/lunita-quickshell" "$HOME/.local/bin/lunita-quickshell"
    fi
    if [ -f "$DOTS_DIR/core/lunita-theme-selector.desktop" ]; then
        ln -sf "$DOTS_DIR/core/lunita-theme-selector.desktop" "$HOME/.local/share/applications/lunita-theme-selector.desktop"
    fi
    if [ -f "$DOTS_DIR/core/lunita-theme-selector.svg" ]; then
        ln -sf "$DOTS_DIR/core/lunita-theme-selector.svg" "$HOME/.local/share/icons/hicolor/scalable/apps/lunita-theme-selector.svg"
    fi

    # 4. Sincronización y recarga/detención de componentes en ejecución
    info "Sincronizando componentes visuales..."

    # Gestión de Eww
    if [ -d "$target_dir/eww" ]; then
        if pgrep -x eww > /dev/null; then
            eww reload 2>/dev/null || true
            success "Eww recargado."
        elif [ -x "$target_dir/eww/scripts/launch.sh" ]; then
            "$target_dir/eww/scripts/launch.sh" &
            success "Eww iniciado."
        fi
    else
        if pgrep -x eww > /dev/null; then
            eww kill 2>/dev/null || true
            pkill -x eww 2>/dev/null || true
            info "Eww cerrado (no configurado en '$target')."
        fi
    fi

    # Obtener configuración de cursor, tema e iconos del tema actual
    local cursor_theme="Bibata-Modern-Ice"
    local cursor_size="40"
    local color_scheme="prefer-dark"
    local icon_theme="WhiteSur"

    if [ -f "$target_dir/gtk-3.0/settings.ini" ]; then
        local ct="$(grep '^gtk-cursor-theme-name=' "$target_dir/gtk-3.0/settings.ini" | cut -d= -f2 | tr -d ' ' || true)"
        local cs="$(grep '^gtk-cursor-theme-size=' "$target_dir/gtk-3.0/settings.ini" | cut -d= -f2 | tr -d ' ' || true)"
        [ -n "$ct" ] && cursor_theme="$ct"
        [ -n "$cs" ] && cursor_size="$cs"

        if grep -q 'gtk-application-prefer-dark-theme=0' "$target_dir/gtk-3.0/settings.ini"; then
            color_scheme="prefer-light"
        fi
        icon_theme="$(grep '^gtk-icon-theme-name=' "$target_dir/gtk-3.0/settings.ini" | cut -d= -f2 | tr -d ' ' || echo 'WhiteSur')"
    fi

    # Recargar Hyprland y aplicar cursor
    if pgrep -x Hyprland > /dev/null; then
        hyprctl setcursor "$cursor_theme" "$cursor_size" >/dev/null 2>&1 || true
        hyprctl reload >/dev/null 2>&1 || true
        success "Hyprland recargado con cursor '$cursor_theme' ($cursor_size px)."
    fi

    # Sincronizar tema de cursor, GTK e iconos en GSettings / dconf
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface cursor-size "$cursor_size" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface color-scheme "$color_scheme" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" 2>/dev/null || true
    fi

    # Reiniciar portal GTK para aplicar estilos CSS actualizados
    if systemctl --user is-active --quiet xdg-desktop-portal-gtk 2>/dev/null; then
        systemctl --user restart xdg-desktop-portal-gtk 2>/dev/null || true
    fi

    # Recargar Kitty
    if pgrep -x kitty > /dev/null; then
        kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null || true
        success "Terminales Kitty recargadas."
    fi

    # Gestión de AGS
    if [ -d "$target_dir/ags" ]; then
        if pgrep -x ags > /dev/null; then
            ags quit 2>/dev/null || true
            sleep 0.3
        fi
        hyprctl dispatch 'hl.dsp.exec_cmd("env PATH=$HOME/.local/bin:$PATH ags run")' >/dev/null 2>&1 || true
        success "AGS iniciado/reiniciado con los nuevos componentes."
    else
        if pgrep -x ags > /dev/null; then
            ags quit 2>/dev/null || true
            sleep 0.2
            pkill -x ags 2>/dev/null || true
            info "AGS detenido (no configurado en '$target')."
        fi
    fi

    # Gestión de Quickshell Dock
    if [ -d "$target_dir/quickshell/dock" ]; then
        if pgrep -f "quickshell.*dock" > /dev/null; then
            pkill -f "quickshell.*dock" 2>/dev/null || true
            sleep 0.2
        fi
        quickshell -d -n -p "$HOME/.config/quickshell/dock"
        success "Quickshell Dock iniciado."
    else
        if pgrep -f "quickshell.*dock" > /dev/null; then
            pkill -f "quickshell.*dock" 2>/dev/null || true
            info "Quickshell Dock detenido (no configurado en '$target')."
        fi
    fi

    # Gestión de Quickshell Bar (Status Bar)
    if [ -d "$target_dir/quickshell/bar" ]; then
        if pgrep -f "quickshell.*bar" > /dev/null; then
            pkill -f "quickshell.*bar" 2>/dev/null || true
            sleep 0.2
        fi
        quickshell -d -n -p "$HOME/.config/quickshell/bar"
        success "Quickshell Bar iniciada."
    else
        if pgrep -f "quickshell.*bar" > /dev/null; then
            pkill -f "quickshell.*bar" 2>/dev/null || true
            info "Quickshell Bar detenida (no configurado en '$target')."
        fi
    fi

    # Gestión de Quickshell Launcher
    if [ -d "$target_dir/quickshell/launcher" ]; then
        if pgrep -f "quickshell.*launcher" > /dev/null; then
            pkill -f "quickshell.*launcher" 2>/dev/null || true
            sleep 0.2
        fi
        quickshell -d -n -p "$HOME/.config/quickshell/launcher"
        success "Quickshell Launcher iniciado."
    else
        if pgrep -f "quickshell.*launcher" > /dev/null; then
            pkill -f "quickshell.*launcher" 2>/dev/null || true
            info "Quickshell Launcher detenido (no configurado en '$target')."
        fi
    fi

    # Gestión de Quickshell Spotlight
    if [ -d "$target_dir/quickshell/spotlight" ]; then
        if pgrep -f "quickshell.*spotlight" > /dev/null; then
            pkill -f "quickshell.*spotlight" 2>/dev/null || true
            sleep 0.2
        fi
        quickshell -d -n -p "$HOME/.config/quickshell/spotlight"
        success "Quickshell Spotlight iniciado."
    else
        if pgrep -f "quickshell.*spotlight" > /dev/null; then
            pkill -f "quickshell.*spotlight" 2>/dev/null || true
            info "Quickshell Spotlight detenido (no configurado en '$target')."
        fi
    fi

    # Gestión de Quickshell Notifications
    if [ -d "$target_dir/quickshell/notifications" ]; then
        if pgrep -f "quickshell.*notifications" > /dev/null; then
            pkill -f "quickshell.*notifications" 2>/dev/null || true
            sleep 0.2
        fi
        quickshell -d -n -p "$HOME/.config/quickshell/notifications"
        success "Quickshell Notifications iniciado."
    else
        if pgrep -f "quickshell.*notifications" > /dev/null; then
            pkill -f "quickshell.*notifications" 2>/dev/null || true
            info "Quickshell Notifications detenido (no configurado en '$target')."
        fi
    fi

    # Gestión de Quickshell Widgets (Desktop Canvas)
    if [ -d "$target_dir/quickshell/widgets" ]; then
        if pgrep -f "quickshell.*widgets" > /dev/null; then
            pkill -f "quickshell.*widgets" 2>/dev/null || true
            sleep 0.2
        fi
        quickshell -d -n -p "$HOME/.config/quickshell/widgets"
        success "Quickshell Widgets de escritorio iniciados."
    else
        if pgrep -f "quickshell.*widgets" > /dev/null; then
            pkill -f "quickshell.*widgets" 2>/dev/null || true
            info "Quickshell Widgets detenidos (no configurado en '$target')."
        fi
    fi


    echo ""
    success "${BOLD}¡Tema '$target' aplicado exitosamente!${RESET}"
}

# ------------------------------------------------------------------------------
# Comando: CREATE (Scaffold para Tema 2 o nuevos temas)
# ------------------------------------------------------------------------------
cmd_create() {
    local new_theme="$1"

    if [ -z "$new_theme" ]; then
        error "Debes especificar el nombre para el nuevo tema. Ejemplo: lunita-theme create tema-2"
        exit 1
    fi

    local dest="$THEMES_DIR/$new_theme"
    if [ -d "$dest" ]; then
        error "El tema '$new_theme' ya existe en $dest"
        exit 1
    fi

    info "Creando estructura base para nuevo tema '${BOLD}$new_theme${RESET}'..."
    mkdir -p "$dest"/{ags,eww,hypr/modules,hypr/scripts,kitty,matugen/templates,matugen/hooks,wlogout,zsh}

    # Crear theme.json
    cat << JSON > "$dest/theme.json"
{
  "id": "$new_theme",
  "name": "${new_theme^}",
  "version": "1.0.0",
  "author": "$(whoami)",
  "description": "Nuevo tema personalizado para Lunita-Dots.",
  "components": {
    "bar": "custom",
    "launcher": "custom",
    "widgets": "custom",
    "color_engine": "matugen"
  },
  "features": [
    "Diseño personalizado"
  ]
}
JSON

    # Crear README.md
    cat << MD > "$dest/README.md"
# 🎨 Tema: ${new_theme^}

Tema personalizado creado a partir de la arquitectura modular de Lunita-Dots.

## Componentes
- **Barra**: Por definir (AGS, Waybar, etc.)
- **Widgets**: Por definir
- **Estilos**: Ver \`hypr/\`, \`matugen/\`, etc.
MD

    success "Tema creado en: $dest"
    echo ""
    echo -e "Puedes empezar a personalizar tu nuevo tema en: ${CYAN}$dest${RESET}"
    echo -e "Para activarlo una vez configurado, ejecuta: ${GREEN}lunita-theme apply $new_theme${RESET}"
}

# ------------------------------------------------------------------------------
# Comando: GUI (Lanzar selector gráfico)
# ------------------------------------------------------------------------------
cmd_gui() {
    if command -v lunita-theme-selector &>/dev/null; then
        lunita-theme-selector &
    elif [ -f "$DOTS_DIR/scripts/lunita-theme-selector" ]; then
        "$DOTS_DIR/scripts/lunita-theme-selector" &
    else
        error "No se encontró el ejecutable lunita-theme-selector"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Menú de Ayuda
# ------------------------------------------------------------------------------
cmd_help() {
    echo -e "${BOLD}${MAGENTA}🌙 Lunita Theme Manager${RESET} — Control de Temas para Lunita-Dots"
    echo ""
    echo -e "${BOLD}Uso:${RESET} lunita-theme [COMANDO] [ARGUMENTOS]"
    echo ""
    echo -e "${BOLD}Comandos:${RESET}"
    echo -e "  ${CYAN}gui${RESET}                       Abre el selector gráfico de temas (Theme Selector)."
    echo -e "  ${CYAN}list, ls${RESET}                  Lista todos los temas disponibles e indica el activo."
    echo -e "  ${CYAN}current${RESET}                   Muestra información y componentes del tema actual."
    echo -e "  ${CYAN}apply, set <tema>${RESET}         Aplica el tema indicado, enlazando configuraciones y recargando."
    echo -e "  ${CYAN}create <nombre>${RESET}           Genera el esqueleto y descriptor para un nuevo tema (ej. Tema 2)."
    echo -e "  ${CYAN}help, --help, -h${RESET}          Muestra este mensaje de ayuda."
    echo ""
    echo -e "${BOLD}Ejemplos:${RESET}"
    echo "  lunita-theme gui"
    echo "  lunita-theme list"
    echo "  lunita-theme apply lunita-default"
    echo "  lunita-theme create tema-2"
}

# ------------------------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------------------------
case "$1" in
    gui)
        cmd_gui
        ;;
    list|ls)
        cmd_list
        ;;
    current)
        cmd_current
        ;;
    apply|set)
        cmd_apply "$2"
        ;;
    create)
        cmd_create "$2"
        ;;
    help|--help|-h|"")
        cmd_help
        ;;
    *)
        error "Comando desconocido: '$1'"
        echo "Ejecuta 'lunita-theme help' para ver la lista de comandos disponibles."
        exit 1
        ;;
esac
