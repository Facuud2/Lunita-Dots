# 🌙 Tema 1: Lunita Default

**Lunita Default** es el tema fundacional e insignia de **Lunita-Dots**. Combina una estética fluida inspirada en Material You y macOS con componentes reactivos que responden a la música, notificaciones y fondos de pantalla en tiempo real.

---

## 🧩 Componentes del Tema

| Componente | Framework / Herramienta | Función Principal |
|---|---|---|
| **Barra Superior** | Quickshell (Qt6/QML) | Dynamic Island interactiva de 36px con pastillas dinámicas |
| **Notificaciones** | Quickshell Notifications | Demonio D-Bus integrado con pastilla animada |
| **Lanzador & PowerMenu** | Quickshell Launcher | Búsqueda por teclado, monitor de recursos y menú de apagado |
| **Widget de Escritorio** | Eww + CAVA | Reproductor multimedia y espectro de audio fijado en el escritorio |
| **Motor de Temas** | Matugen | Extracción de paleta armónica desde el wallpaper activo |
| **Compositor** | Hyprland (Lua) | Animaciones Bezier macOS, blur frosted glass y reglas de ventana |
| **Selector de Fondos** | HyprQuickPaper (Quickshell) | Selector de wallpapers 3D interactivo por GPU |
| **Terminal & Shell** | Kitty & Zsh | Recarga en vivo por `SIGUSR1` y prompt de pastillas `pills` |
| **Cierre de Sesión** | Wlogout | Botones redondeados con desenfoque de fondo |

---

## 🎨 Paleta y Comportamiento Dinámico
Al cambiar el fondo con HyprQuickPaper (`SUPER + W`) o con `awww img`, Matugen genera automáticamente los tokens de color para:
- Bordes y sombras de Hyprland (`hypr/modules/colors.lua`)
- Estilos de la Dynamic Island y Launcher (`quickshell/colors.json`)
- Widget y carátula SVG de Eww (`eww/colors.scss`)
- Terminal Kitty (`kitty/colors-matugen.conf`)
- Highlights de Neovim (`nvim/lua/colors.lua`)
- Bloqueo Hyprlock (`hypr/hyprlock-colors.conf`)
- Transición Prelock (`core/prelock/palette.conf`)
- Prompt de Zsh (`oh-my-zsh/custom/zsh-colors.zsh`)
- Cliente Vesktop / Discord (`vesktop/themes/lunita.theme.css`)
