# 🌙 Tema 1: Lunita Default

**Lunita Default** es el tema fundacional e insignia de **Lunita-Dots**. Combina una estética fluida inspirada en Material You y macOS con componentes reactivos que responden a la música, notificaciones y fondos de pantalla en tiempo real.

---

## 🧩 Componentes del Tema

| Componente | Framework / Herramienta | Función Principal |
|---|---|---|
| **Barra Superior** | [AGS v2 (Astal + GTK4)](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/ags) | Dynamic Island interactiva de 36px con pastillas dinámicas |
| **Notificaciones** | [AGS Dynamic Island](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/ags/widget/island/NotificationService.ts) | Demonio D-Bus integrado con pastilla animada |
| **Lanzador & PowerMenu** | [AGS AppLauncher & PowerMenu](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/ags/widget) | Búsqueda por teclado, monitor de recursos y menú de apagado |
| **Widget de Escritorio** | [Eww + CAVA](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/eww) | Reproductor multimedia y espectro de audio fijado en el escritorio |
| **Motor de Temas** | [Matugen](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/matugen) | Extracción de paleta armónica desde el wallpaper activo |
| **Compositor** | [Hyprland (Lua)](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/hypr) | Animaciones Bezier macOS, blur frosted glass y reglas de ventana |
| **Selector de Fondos** | [HyprQuickPaper (Quickshell)](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/quickshell) | Selector de wallpapers 3D interactivo por GPU |
| **Terminal & Shell** | [Kitty](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/kitty) & [Zsh](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/zsh) | Recarga en vivo por `SIGUSR1` y prompt de pastillas `pills` |
| **Cierre de Sesión** | [Wlogout](file:///mnt/Desarrollo/Lunita-Dots/themes/lunita-default/wlogout) | Botones redondeados con desenfoque de fondo |

---

## 🎨 Paleta y Comportamiento Dinámico
Al cambiar el fondo con HyprQuickPaper (`SUPER + W`) o con `awww img`, Matugen genera automáticamente los tokens de color para:
- Bordes y sombras de Hyprland (`hypr/modules/colors.lua`)
- Estilos de la Dynamic Island y Launcher (`ags/colors.scss`)
- Widget y carátula SVG de Eww (`eww/colors.scss`)
- Terminal Kitty (`kitty/colors-matugen.conf`)
- Highlights de Neovim (`nvim/lua/colors.lua`)
- Bloqueo Hyprlock (`hypr/hyprlock-colors.conf`)
- Transición Prelock (`core/prelock/palette.conf`)
- Prompt de Zsh (`oh-my-zsh/custom/zsh-colors.zsh`)
- Cliente Vesktop / Discord (`vesktop/themes/lunita.theme.css`)
