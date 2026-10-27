# 📋 Estado Inmediato de Tareas (TODO.md)

Este archivo refleja el estado de ejecución del ciclo de trabajo activo. Es mutado por el agente de forma continua a medida que avanza, valida y completa tareas.

---

## 🚀 Tareas del Ciclo Activo

### [ISSUE-000] Establecer la Tríada Documental de Gestión Asistida por IA
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Módulo(s):** Documentación / Gobernanza
- **Archivos Afectados:** `AGENTS.md`, `TODO.md`, `BACKLOG.md`
- **Descripción:** Definir formalmente las instrucciones estáticas para agentes de IA (`AGENTS.md`), el tablero de ejecución inmediata (`TODO.md`) y el repositorio estratégico de tareas futuras (`BACKLOG.md`), integrando las restricciones de privilegios, validaciones pre-commit y convenciones de commit en la rama `ISSUE_000_DOCS`.
- **Criterios de Aceptación:**
  1. `AGENTS.md` incluye prohibición de sudo/pacman, validación de sintaxis, reglas de commit y respeto a la sesión activa.
  2. `TODO.md` y `BACKLOG.md` estructurados y mutuamente excluyentes.
  3. Los archivos están presentes y verificados sintácticamente en la rama `ISSUE_000_DOCS`.
- **Dependencias:** Ninguna

---

### [ISSUE-001] Limpieza y Purgado de Artefactos de Caché y Residuos en Git
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Módulo(s):** Repositorio / Git / Temas
- **Archivos Afectados:** `.gitignore`, `themes/lunita-default/.config/eww/scripts/__pycache__/media.cpython-314.pyc`, `themes/lunita-default/.config/quickshell/bar/Battery.qml.orig`, `.lunita-theme`
- **Descripción:** Desvincular del tracking de Git los archivos compilados (`.pyc`), residuos de edición (`.orig`) y el estado mutable local (`.lunita-theme`), asegurando que `.gitignore` los descarte de forma estricta.
- **Criterios de Aceptación:**
  1. `git ls-files | grep -E '\.pyc$|\.orig$|\.lunita-theme$'` retorna vacío.
  2. El árbol de trabajo no trackea artefactos efímeros.
- **Dependencias:** [ISSUE-000]

---

### [ISSUE-002] Purgado Definitivo del Código Huérfano de AGS v2
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Módulo(s):** Temas / `lunita-default`
- **Archivos Afectados:** `themes/lunita-default/.config/ags/`, `themes/lunita-default/.stow-local-ignore`, `themes/lunita-default/README.md`
- **Descripción:** Eliminar completamente la carpeta legacy de AGS (`themes/lunita-default/.config/ags/`) para reducir el peso del repositorio, dado que Quickshell reemplazó esta funcionalidad y ya está excluido por Stow.
- **Criterios de Aceptación:**
  1. La carpeta `themes/lunita-default/.config/ags` es removida del repositorio.
  2. `lunita-theme` y Quickshell continúan operando sin referencias rotas.
- **Dependencias:** [ISSUE-000]

---

### [ISSUE-003] Dinamización de Marcadores de Usuario mediante XDG
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Módulo(s):** Temas / GTK / Qt / Stow
- **Archivos Afectados:** `core/.local/bin/lunita-theme`, `.gitignore`, `themes/*/.stow-local-ignore`, `themes/*/.config/gtk-3.0/bookmarks.template`, `themes/*/.local/share/user-places.xbel.template`
- **Descripción:** Reemplazar las rutas fijas (`/home/facuud2/...`) por generación dinámica basada en utilidades XDG (`xdg-user-dir`) durante la aplicación del tema o mediante plantillas dinámicas, evitando roturas en instalaciones de otros usuarios.
- **Criterios de Aceptación:**
  1. No existen referencias hardcodeadas a `/home/facuud2` en los archivos versionados de marcadores.
  2. Al ejecutar `lunita-theme apply`, los marcadores apuntan a las carpetas XDG reales del usuario activo.
- **Dependencias:** [ISSUE-001]

### [ISSUE-004] Persistencia y Autostart de Quickshell al iniciar sesión
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_004_QUICKSHELL_AUTOSTART`
- **Módulo(s):** Core / Autostart / Quickshell
- **Archivos Afectados:** `core/.config/hypr/modules/autostart.lua`, `core/.local/bin/lunita-quickshell`
- **Descripción:** Al iniciar el sistema, el entorno visual de Quickshell no arranca automáticamente, obligando al usuario a ejecutar `lunita-quickshell start` de forma manual. Se debe garantizar que el autostart de Hyprland lea el tema activo de la sesion previa y levante los demonios correspondientes sin intervención humana.
- **Criterios de Aceptación:**
  1. Reiniciar el sistema levanta automáticamente los componentes de Quickshell del tema actual.
  2. No existen condiciones de carrera (race conditions) entre la carga de variables XDG y el arranque de Quickshell.
- **Dependencias:** Ninguna

### [ISSUE-005] Testing de rendimiento e integración de Hyprquickpaper
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_005_TEST_HYPRQUICKPAPER`
- **Módulo(s):** Lunita-Theme / Wallpaper
- **Archivos Afectados:** `themes/lunita-default/.config/quickshell/hyprquickpaper/`, `core/.local/bin/hyprquickpaper`, `BACKLOG.md`
- **Descripción:** Realizar pruebas de rendimiento, renderizado 3D e interactividad del componente hyprquickpaper dentro de la suite de Lunita-Default. 
- **Criterios de Aceptación:**
  1. Componente ejecutado y testeado en el entorno local.
  2. Bugs resultantes documentados como nuevas tareas en el BACKLOG.md.
- **Dependencias:** Ninguna

### [ISSUE-006] Reparar disparador del menú Wlogout en Dynamic Island
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_006_FIX_WLOGOUT_TRIGGER`
- **Módulo(s):** Lunita-Theme / Bar (Dynamic Island)
- **Archivos Afectados:** `themes/lunita-default/.config/quickshell/bar/ExpandedPanel.qml`, `themes/lunita-default/theme.json`
- **Descripción:** El botón/módulo de energía ubicado en la Dynamic Island no está invocando correctamente el script o ejecutable de `wlogout` al hacer click, pues actualmente renderiza con pequeno menu propio de la dynamic island cosa que debe cambiar completamente.
- **Criterios de Aceptación:**
  1. Un click en la interfaz QML despliega el menú `wlogout` de pantalla completa de forma consistente.
- **Dependencias:** Ninguna

### [ISSUE-007] Rediseño y contraste del widget de Clima Dinámico
- **Estado:** COMPLETADO
- **Prioridad:** BAJA
- **Rama Sugerida:** `ISSUE_007_WEATHER_WIDGET_REDESIGN`
- **Módulo(s):** Lunita-Theme / Widgets
- **Archivos Afectados:** `themes/lunita-default/.config/quickshell/bar/WeatherWidget.qml`
- **Descripción:** La UI actual del clima carece de datos reales (siempre el icon de nublado con 11 grados Celsius). Se debe refactorizar la paleta del widget para utilizar colores más marcados/contrastantes siguiendo la tematica de NothingOS y actualizar la iconografía vectorial para armonizarla con el diseño actual de Lunita-Default.
- **Criterios de Aceptación:**
  1. Nueva iconografía y paleta de alto contraste implementadas.
- **Dependencias:** Ninguna

### [ISSUE-008] Auto-foco y escritura directa en el App Launcher (Type-to-Search)
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_008_LAUNCHER_AUTO_FOCUS`
- **Módulo(s):** Lunita-Theme / Launcher
- **Archivos Afectados:** `themes/lunita-default/.config/quickshell/launcher/shell.qml`, `themes/lunita-default/.config/quickshell/launcher/SearchMenuView.qml`
- **Descripción:** Actualmente el usuario debe hacer click o navegar hasta el icono de la lupa para buscar. El componente debe capturar el foco del teclado inmediatamente al volverse visible (`forceActiveFocus()`), permitiendo escribir nativamente sin pasos extra.
- **Criterios de Aceptación:**
  1. Presionar atajo de launcher y escribir inmediatamente rellena el campo de búsqueda expandiendo el app launcher en consecuencia.
- **Dependencias:** Ninguna

### [ISSUE-009] Optimización de refresco (240Hz) en animación del Launcher
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_009_LAUNCHER_240HZ_ANIMATION`
- **Módulo(s):** Lunita-Theme / Launcher
- **Archivos Afectados:** `themes/lunita-default/.config/quickshell/launcher/LauncherState.qml`, `themes/lunita-default/.config/quickshell/launcher/LauncherView.qml`
- **Descripción:** Las curvas de animación (`NumberAnimation` / `PropertyAnimation`) al expandir el launcher parecen estar limitadas o renderizando a 60Hz. Modificar las físicas o sincronizaciones de la ventana en Quickshell para aprovechar la fluidez en monitores de alta tasa de refresco (240Hz).
- **Criterios de Aceptación:**
  1. Animación de expansión fluida y sin "stuttering" a 240fps.
- **Dependencias:** Ninguna

### [ISSUE-010] Soporte para tecla Enter del Numpad en el App Launcher
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_010_LAUNCHER_NUMPAD_ENTER`
- **Módulo(s):** Lunita-Theme / Launcher
- **Archivos Afectados:** `themes/lunita-default/.config/quickshell/launcher/SearchMenuView.qml`, `themes/lunita-default/.config/quickshell/launcher/shell.qml`
- **Descripción:** El interceptor de teclado del buscador detecta la tecla "Enter" principal (`Qt.Key_Return`), pero ignora la tecla "Enter" del teclado numérico (`Qt.Key_Enter`). 
- **Criterios de Aceptación:**
  1. Ambas teclas Enter ejecutan la aplicación seleccionada.
- **Dependencias:** Ninguna

### [ISSUE-011] Cierre del Launchpad al perder el foco (Click externo)
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_011_LAUNCHPAD_OUTSIDE_CLICK_DISMISS`
- **Módulo(s):** macOS-Theme / Launcher
- **Archivos Afectados:** `themes/macOS-Theme/.config/quickshell/launcher/shell.qml`
- **Descripción:** El Launchpad permanece abierto al hacer click fuera de sus márgenes. Se debe implementar un cierre reactivo (vía `onActiveFocusChanged` de la ventana o integrando un `MouseArea` invisible de fondo) para emular el comportamiento nativo de macOS.
- **Criterios de Aceptación:**
  1. Un click fuera de los componentes principales oculta el launcher inmediatamente.
- **Dependencias:** Ninguna

### [ISSUE-012] Interpolación y curvas de animación en el Launchpad
- **Estado:** COMPLETADO
- **Prioridad:** BAJA
- **Rama Sugerida:** `ISSUE_012_LAUNCHPAD_ANIMATIONS`
- **Módulo(s):** macOS-Theme / Launcher
- **Archivos Afectados:** `themes/macOS-Theme/.config/quickshell/launcher/LauncherView.qml`, `themes/macOS-Theme/.config/quickshell/launcher/LauncherState.qml`, `themes/macOS-Theme/.config/quickshell/launcher/AppItem.qml`
- **Descripción:** La aparición del launcher es demasiado espontánea/brusca. Se deben inyectar curvas Bezier (`Easing.InOutQuad` o resortes) para opacidad y escalado, logrando que los iconos aparezcan con un efecto suave, cuidando la atención al detalle.
- **Criterios de Aceptación:**
  1. Animaciones de entrada y salida fluidas y consistentes con la estética de Cupertino.
- **Dependencias:** Ninguna

### [ISSUE-013] Limpieza de estado (Clear) del buscador al cerrar Launchpad
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_013_LAUNCHPAD_SEARCH_CLEAR`
- **Módulo(s):** macOS-Theme / Launcher
- **Archivos Afectados:** `themes/macOS-Theme/.config/quickshell/launcher/LauncherView.qml`
- **Descripción:** El estado del `TextField` persiste en memoria. Si el usuario escribe una búsqueda, cierra el launcher (SUPER+A) y vuelve a abrirlo, el texto anterior sigue allí. Se debe vaciar el string del input en el hook de cierre (`onVisibleChanged`).
- **Criterios de Aceptación:**
  1. Cada invocación del launcher muestra la barra de búsqueda vacía.
- **Dependencias:** Ninguna

### [ISSUE-014] Sincronización de esquema Claro/Oscuro en Dolphin
- **Estado:** PENDIENTE
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_012_FIX`
- **Módulo(s):** macOS-Theme / GTK-Qt Sync
- **Archivos Afectados:** `themes/macOS-Theme/dolphin/`, `themes/macOS-Theme/.config/qt6ct/`, A investigar.
- **Descripción:** El gestor de archivos KDE Dolphin no reacciona al modo claro/oscuro soportado por este tema particular. Forzar la inyección y lectura de las variables de colores para aplicaciones Qt al conmutar la preferencia visual.
- **Criterios de Aceptación:**
  1. Cambiar la paleta del macOS-Theme a modo oscuro/claro impacta instantáneamente o en el próximo reinicio a la ventana de Dolphin.
- **Dependencias:** Ninguna

### [ISSUE-015] Reparar bucle de carga infinito en GUI al aplicar lunita-default
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_015_FIX`
- **Módulo(s):** GUI / Theme Selector
- **Archivos Afectados:** `core/.local/bin/lunita-theme-selector`
- **Descripción:** Al seleccionar `lunita-default` y pulsar en `Aplicar tema` desde la interfaz gráfica, el tema se aplica correctamente en el backend, pero la GUI queda en un bucle infinito de carga sin mostrar el mensaje "Tema cambiado con éxito" (a diferencia del resto de los temas). El agente DEBE modificar ÚNICAMENTE el hilo de ejecución/respuesta de la interfaz gráfica GTK/Python. TIENE ESTRICTAMENTE PROHIBIDO modificar, validar o alterar componentes visuales QML, scripts del tema o la lógica del CLI, ya que funcionan perfectamente en terminal.
- **Criterios de Aceptación:**
  1. Seleccionar `lunita-default` en la GUI finaliza la animación y notifica el éxito correctamente sin colgarse.
- **Dependencias:** Ninguna

### [ISSUE-016] Restaurar fondo de pantalla automático al reiniciar el sistema
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_016_FIX`
- **Módulo(s):** Core / Autostart / Wallpaper
- **Archivos Afectados:** `core/.config/hypr/modules/autostart.lua`, `core/.local/bin/lunita-dynamic-wallpaper`
- **Descripción:** Tras reiniciar el sistema operativo, el fondo de pantalla no se renderiza. Se sospecha que el daemon encargado (`awww` o script disparador) no está siendo invocado correctamente durante la secuencia de inicio de Hyprland. El agente debe diagnosticar la cadena de ejecución durante el boot y repararlo.
- **Criterios de Aceptación:**
  1. Al iniciar sesión en frío, el fondo de pantalla del tema activo se muestra sin requerir comandos manuales.
- **Dependencias:** Ninguna

### [ISSUE-017] Normalización de nombres de temas (Minúsculas en sistema, Mayúsculas en GUI)
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_017_REFACTOR`
- **Módulo(s):** Core / Temas / GUI
- **Archivos Afectados:** `themes/macos-theme/`, `themes/modern-win11-theme/`, `themes/macos-theme/theme.json`, `themes/modern-win11-theme/theme.json`, `core/.local/bin/lunita-theme`, `core/.local/bin/lunita-tokri`, `core/.local/bin/lunita-widgets-manager`, `core/.oh-my-zsh/custom/themes/lunita.zsh-theme`, `themes/macos-theme/.oh-my-zsh/custom/macos.zsh`, `themes/macos-theme/.config/quickshell/bar/scripts/resolve_all_tray.sh`, `themes/modern-win11-theme/.config/quickshell/bar/BarState.qml`
- **Descripción:** Para evitar errores de tipeo y consistencia en la CLI, todas las carpetas físicas de los temas y sus identificadores de sistema deben ser en minúsculas (ej. `lunita-theme`, `macos-theme`, `win11-theme`). Sin embargo, el archivo `theme.json` debe alojar un atributo `name` formateado ("Lunita Theme", "MacOS 27 Theme", "Modern Windows 11 Theme") para que la GUI gráfica lo consuma y lo muestre con su correcta capitalización.
- **Criterios de Aceptación:**
  1. Directorios, estado guardado y CLI utilizan strings 100% en minúsculas.
  2. La GUI de selección renderiza los nombres legibles y formateados provenientes del JSON.
- **Dependencias:** Ninguna

### [ISSUE-018] Centralización y deduplicación del selector Hyprquickpaper
- **Estado:** COMPLETADO
- **Prioridad:** BAJA
- **Rama Sugerida:** `ISSUE_018_REFACTOR`
- **Módulo(s):** Core / Quickshell
- **Archivos Afectados:** `core/.config/quickshell/hyprquickpaper/`, `core/.local/bin/hyprquickpaper`, `core/.local/bin/lunita-theme`, `themes/lunita-default/.config/quickshell/hyprquickpaper/`, `themes/macOS-Theme/.config/quickshell/hyprquickpaper/`, `themes/Modern-Win11-Theme/.config/quickshell/hyprquickpaper/`
- **Descripción:** El componente interactivo Hyprquickpaper está triplicado idénticamente en las carpetas de los tres temas. Se debe extraer este código a un directorio compartido en `core/` (u orquestar un enlace simbólico universal mediante Stow) para tener un único punto de mantenimiento (Single Source of Truth).
- **Criterios de Aceptación:**
  1. El código de Hyprquickpaper existe una única vez en el repositorio.
  2. Su funcionalidad permanece inalterada en los tres temas.
- **Dependencias:** Ninguna

### [ISSUE-019] Unificación de lógica y servicios de los Widgets QML
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_019_REFACTOR`
- **Módulo(s):** Core / Temas / Widgets
- **Archivos Afectados:** `core/.config/quickshell/widgets/scripts/`, `core/.local/bin/lunita-widgets-manager`, `themes/macOS-Theme/.config/quickshell/widgets/scripts/`
- **Descripción:** Refactorizar la arquitectura de los widgets de escritorio en Quickshell. Los scripts subyacentes, recolección de datos y servicios lógicos compartidos deben migrarse al directorio base `core/`, garantizando que dentro de la carpeta `themes/` únicamente resida la capa de presentación (la sintaxis visual QML específica de cada ecosistema).
- **Criterios de Aceptación:**
  1. Eliminación de lógica duplicada entre temas.
  2. Los widgets de todos los temas importan y consumen correctamente los scripts base del core.
- **Dependencias:** Ninguna

### [ISSUE-020] Desacople de plantillas Matugen y protección de paletas estáticas
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_020_REFACTOR`
- **Módulo(s):** Core / Motor de Color
- **Archivos Afectados:** `core/.local/bin/lunita-palette-sync`, `core/.local/bin/lunita-theme`, `themes/macOS-Theme/theme.json`, `themes/Modern-Win11-Theme/theme.json`, `themes/lunita-default/theme.json`, `themes/lunita-default/.config/eww/scripts/watch_wallpaper.sh`, `themes/lunita-default/.config/matugen/hooks/update-theme.sh`, `themes/lunita-default/.config/quickshell/hyprquickpaper/commands.sh`, `themes/macOS-Theme/.config/quickshell/hyprquickpaper/commands.sh`, `themes/Modern-Win11-Theme/.config/quickshell/hyprquickpaper/commands.sh`
- **Descripción:** Centralizar cómo interactúa Matugen con Quickshell y Hyprland. Sincronizar dinámicamente los bordes y paleta de Hyprland (`colors.lua`) mediante `lunita-palette-sync` a partir de los tokens de cada tema (`theme.json`), evitando el sangrado de colores de Matugen hacia temas estáticos (`macOS-Theme`, `Modern-Win11-Theme`).
- **Criterios de Aceptación:**
  1. Al transicionar de `lunita-default` (con colores reactivos al wallpaper) a otro tema, no ocurre ningún "bleed" o sangrado de colores en Hyprland ni componentes del entorno.
  2. macOS y Win11 mantienen sus colores temáticos fijos correctamente inyectados (bordes de ventana azul Cupertino `#007AFF` y Fluent `#0078D4`), sin interferencia del daemon de Matugen.
- **Dependencias:** Ninguna

### [ISSUE-021] Resolución contextual del Clipboard al pulsar SUPER+V en lunita-default
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_021_FIX`
- **Módulo(s):** Core / Lunita-Default / Clipboard
- **Archivos Afectados:** `core/.local/bin/lunita-clipboard`, `core/.config/hypr/modules/rules.lua`, `themes/lunita-default/.config/quickshell/clipboard/shell.qml`, `themes/lunita-default/.config/quickshell/clipboard/ClipboardState.qml`, `themes/lunita-default/.config/quickshell/clipboard/ClipboardView.qml`, `themes/lunita-default/.config/quickshell/clipboard/ClipboardItem.qml`, `themes/lunita-default/.config/quickshell/clipboard/scripts/clipboard_manager.py`, `themes/lunita-default/.config/quickshell/clipboard/fonts`
- **Descripción:** Al presionar el atajo `SUPER+V` estando activo el tema `lunita-default`, el wrapper invoca la interfaz del portapapeles perteneciente a `macOS-Theme` en lugar del componente nativo de `lunita-default`. El script disparador debe resolver dinámicamente el tema activo y levantar la interfaz QML correspondiente a `lunita-default`.
- **Criterios de Aceptación:**
  1. Presionar `SUPER+V` en `lunita-default` abre exclusivamente el portapapeles con el diseño e integración de `lunita-default`.
  2. El wrapper no tiene rutas ni fallbacks forzados hacia `macOS-Theme`.
- **Dependencias:** Ninguna

### [ISSUE-022] Aislamiento de estado por monitor en la Dockbar de macOS
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_022_FIX`
- **Módulo(s):** macOS-Theme / Dock
- **Archivos Afectados:** `themes/macos-theme/.config/quickshell/dock/shell.qml`, `themes/macos-theme/.config/quickshell/dock/DockPlatter.qml`, `themes/macos-theme/.config/quickshell/dock/DockState.qml`, `themes/macos-theme/.config/quickshell/dock/DockItem.qml`, `themes/macos-theme/.config/quickshell/dock/DockContextMenu.qml`, `themes/macos-theme/.config/quickshell/dock/DockAddAppModal.qml`, `themes/macos-theme/.config/quickshell/launcher/LauncherState.qml`
- **Descripción:** El estado interactivo del Dock (como la apertura de menús contextuales al hacer clic derecho o estados de hover/activación) se comparte globalmente entre todas las pantallas, provocando que el menú se despliegue simultáneamente en todos los monitores conectados. Se debe encapsular el estado de cada instancia del Dock localmente por monitor (`ShellScreen` / instancia de `PanelWindow`).
- **Criterios de Aceptación:**
  1. Hacer clic derecho sobre un icono del Dock abre el menú contextual únicamente en el monitor donde ocurrió la interacción.
  2. Las animaciones e indicadores de interacción operan de forma independiente en configuraciones multimonitor.
- **Dependencias:** Ninguna

### [ISSUE-023] Integración de System Tray Icons en la barra superior de macOS
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_023_FEAT`
- **Módulo(s):** macOS-Theme / Bar (System Tray)
- **Archivos Afectados:** `themes/macos-theme/.config/quickshell/bar/BarView.qml`, `themes/macos-theme/.config/quickshell/bar/BarState.qml`, `themes/macos-theme/.config/quickshell/bar/shell.qml`, `themes/macos-theme/.config/quickshell/bar/popups/TrayContextMenu.qml`, `themes/macos-theme/.config/quickshell/bar/scripts/tray_resolver.py`, `themes/macos-theme/.config/quickshell/bar/scripts/resolve_all_tray.sh`
- **Descripción:** Implementar el contenedor de iconos de bandeja del sistema (`Quickshell.Services.SystemTray`) para procesos en segundo plano dentro de la Status Bar superior. Debe ubicarse inmediatamente a la izquierda del primer icono de control (el botón de acomodar/editar widgets), desplegando cada nuevo icono en dirección hacia la izquierda de la barra.
- **Criterios de Aceptación:**
  1. Los procesos activos en segundo plano (Discord, clientes de red, etc.) renderizan sus iconos en la barra superior.
  2. La fila de iconos crece de derecha a izquierda partiendo desde el límite izquierdo del icono de gestión de widgets.
  3. Soporta interacciones nativas de clic izquierdo y menú contextual (clic derecho) sobre cada icono.
- **Dependencias:** Ninguna

### [ISSUE-024] Posicionamiento de System Tray Icons en barra de tareas de Windows 11
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_024_FEAT`
- **Módulo(s):** Modern-Win11-Theme / Bar-Dock (System Tray)
- **Archivos Afectados:** `core/.local/bin/lunita-icon-resolver`, `core/.local/bin/lunita-theme`, `core/.local/share/applications/lunita-theme-selector.desktop`, `core/.local/share/applications/lunita-widgets-manager.desktop`, `themes/modern-win11-theme/.config/quickshell/dock/TrayPlatter.qml`, `themes/modern-win11-theme/.config/quickshell/dock/DockState.qml`, `themes/modern-win11-theme/.config/quickshell/dock/DockItem.qml`, `themes/modern-win11-theme/.config/quickshell/dock/scripts/tray_resolver.py`, `themes/modern-win11-theme/.config/quickshell/launcher/scripts/app_scanner.py`, `themes/macos-theme/.config/quickshell/bar/scripts/tray_resolver.py`, `themes/lunita-default/.config/quickshell/bar/scripts/tray_resolver.py`
- **Descripción:** Incorporar los iconos de bandeja del sistema (`SystemTray`) para aplicaciones en segundo plano dentro del área de estado de la barra (donde residen los indicadores de Internet, sonido y batería). Deben posicionarse partiendo inmediatamente a la izquierda del indicador de idioma (`ENG`), apilándose uno al lado del otro hacia la izquierda.
- **Criterios de Aceptación:**
  1. Los iconos del System Tray aparecen alineados horizontalmente a la izquierda del indicador `ENG`.
  2. El flujo visual se expande hacia la izquierda sin solapar ni desplazar erróneamente los módulos centrales.
- **Dependencias:** Ninguna

### [ISSUE-025] Diseño e implementación de Flyout interactivo de Red (Wi-Fi y Ethernet)
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_025_FEAT`
- **Módulo(s):** Modern-Win11-Theme / Flyouts (Network)
- **Archivos Afectados:** `themes/modern-win11-theme/.config/quickshell/dock/NetworkControlFlyout.qml`, `themes/modern-win11-theme/.config/quickshell/dock/scripts/network_manager.py`, `themes/modern-win11-theme/.config/quickshell/dock/DockState.qml`, `themes/modern-win11-theme/.config/quickshell/dock/TrayPlatter.qml`, `themes/modern-win11-theme/.config/quickshell/dock/shell.qml`, `themes/modern-win11-theme/.config/quickshell/dock/assets/ethernet.svg`, `themes/modern-win11-theme/.config/quickshell/dock/assets/tray-wifi-off.svg`, `themes/modern-win11-theme/.config/quickshell/dock/assets/wifi-off.svg`
- **Descripción:** Reemplazar la invocación de GUIs externas básicas de red por un panel flotante (Flyout) nativo en QML con estética Fluent Design, homologado al diseño actual del panel de Sonido/Hora. Debe ser funcionalmente interactivo (integrado vía `nmcli` o backend equivalente) para escanear/conectar redes Wi-Fi y detectar/mostrar explícitamente el estado de la conexión física Ethernet si el equipo está conectado por cable.
- **Criterios de Aceptación:**
  1. Pulsar el icono de red abre el Flyout nativo con el mismo lenguaje visual que el módulo de Sonido/Hora.
  2. Muestra el estado activo de red cableada (Ethernet) cuando existe conexión física.
  3. Permite visualizar redes Wi-Fi disponibles, alternar la antena y conectarse de forma interactiva sin abrir aplicaciones externas.
- **Dependencias:** Ninguna

### [ISSUE-026] Creación de icono y Flyout interactivo de Bluetooth
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_026_FEAT`
- **Módulo(s):** Modern-Win11-Theme / Flyouts (Bluetooth)
- **Archivos Afectados:** `themes/modern-win11-theme/.config/quickshell/dock/BluetoothControlFlyout.qml`, `themes/modern-win11-theme/.config/quickshell/dock/MediaControlFlyout.qml`, `themes/modern-win11-theme/.config/quickshell/dock/scripts/bluetooth_manager.py`, `themes/modern-win11-theme/.config/quickshell/dock/DockState.qml`, `themes/modern-win11-theme/.config/quickshell/dock/TrayPlatter.qml`, `themes/modern-win11-theme/.config/quickshell/dock/shell.qml`, `themes/modern-win11-theme/.config/quickshell/dock/assets/keyboard.svg`
- **Descripción:** Diseñar e insertar un icono de estado de Bluetooth ubicado inmediatamente a la derecha del indicador `ENG` en la dock bar. Al hacer clic sobre él, debe desplegar un panel interactivo (Flyout) con la misma línea estética del panel de Sonido/Hora para gestionar dispositivos Bluetooth (`bluetoothctl`).
- **Criterios de Aceptación:**
  1. El icono de Bluetooth se renderiza a la derecha de la etiqueta `ENG`.
  2. Al pulsarlo, despliega el Flyout interactivo permitiendo encender/apagar el adaptador Bluetooth y conectar/desconectar dispositivos emparejados.
- **Dependencias:** Ninguna

### [ISSUE-027] Vincular botón "Widgets y Aplicaciones" con la edición de widgets de escritorio
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_027_FEAT`
- **Módulo(s):** Modern-Win11-Theme / Dock / Widgets
- **Archivos Afectados:** `themes/modern-win11-theme/.config/quickshell/dock/TrayPlatter.qml`, `themes/modern-win11-theme/.config/quickshell/dock/DockState.qml`, `core/.local/bin/lunita-widgets-toggle`, `core/.local/bin/lunita-widgets-manager`
- **Descripción:** Conectar la acción del botón "Widgets y Aplicaciones" presente en la dock bar del tema Windows 11 para que invoque el modo de modificación/gestión de los widgets del escritorio.
- **Criterios de Aceptación:**
  1. Hacer clic en el botón "Widgets y Aplicaciones" activa la edición o el panel gestor de los widgets en pantalla de forma directa.
- **Dependencias:** Ninguna

### [ISSUE-028] Auditoría General de Código, Errores de Sintaxis, Rutas y Refinamiento Multitema
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `AUDITORY_FIXES`
- **Módulo(s):** Core / Temas (`lunita-default`, `macos-theme`, `modern-win11-theme`) / Quickshell / Scripts
- **Archivos Afectados:**
  - `core/.config/hypr/hyprlock-colors.conf`
  - `core/.config/hypr/modules/autostart.lua`
  - `core/.config/hypr/modules/keybinds.lua`
  - `core/.config/quickshell/hyprquickpaper/commands.sh`
  - `core/.config/quickshell/widgets/scripts/git_activity_provider.py`
  - `core/.local/bin/hyprquickpaper`
  - `core/.local/bin/lunita-clipboard`
  - `core/.local/bin/lunita-launcher`
  - `core/.local/bin/lunita-osd`
  - `core/.local/bin/lunita-theme`
  - `core/.local/bin/lunita-theme-selector`
  - `core/.local/bin/lunita-widgets-manager`
  - `core/.oh-my-zsh/custom/themes/lunita.zsh-theme`
  - `themes/lunita-default/.config/gtk-3.0/bookmarks.template`
  - `themes/lunita-default/.config/qt6ct/qt6ct.conf`
  - `themes/lunita-default/.config/quickshell/bar/AppLauncher.qml`
  - `themes/lunita-default/.config/quickshell/bar/AudioPanel.qml`
  - `themes/lunita-default/.config/quickshell/bar/ConnPanel.qml`
  - `themes/lunita-default/.config/quickshell/bar/Exec.qml`
  - `themes/lunita-default/.config/quickshell/bar/ExpandedPanel.qml`
  - `themes/lunita-default/.config/quickshell/bar/QuickActions.qml`
  - `themes/lunita-default/.config/quickshell/bar/Recorder.qml`
  - `themes/lunita-default/.config/quickshell/bar/Weather.qml`
  - `themes/lunita-default/.config/quickshell/osd/OSDState.qml`
  - `themes/lunita-default/.local/share/user-places.xbel.template`
  - `themes/lunita-default/README.md`
  - `themes/macos-theme/.config/gtk-3.0/bookmarks.template`
  - `themes/macos-theme/.config/qt6ct/qt6ct.conf`
  - `themes/macos-theme/.config/quickshell/bar/popups/AppMenuDropdown.qml`
  - `themes/macos-theme/.config/quickshell/bar/popups/AppleMenu.qml`
  - `themes/macos-theme/.config/quickshell/dock/DockState.qml`
  - `themes/macos-theme/.config/quickshell/lockscreen/LockView.qml`
  - `themes/macos-theme/.config/quickshell/osd/OSDState.qml`
  - `themes/macos-theme/.config/quickshell/spotlight/scripts/spotlight_search.py`
  - `themes/macos-theme/.config/quickshell/widgets/scripts/*` (13 scripts purgados y centralizados en core)
  - `themes/macos-theme/.oh-my-zsh/custom/macos.zsh`
  - `themes/modern-win11-theme/.config/gtk-3.0/bookmarks.template`
  - `themes/modern-win11-theme/.config/qt6ct/qt6ct.conf`
  - `themes/modern-win11-theme/.config/quickshell/dock/DockState.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/LauncherState.qml`
  - `themes/modern-win11-theme/.local/share/user-places.xbel.template`
  - `themes/modern-win11-theme/theme.json`
- **Descripción:** Corrección exhaustiva de errores de sintaxis en QML detectados por `qmlformat` (operadores opcionales `?.`, `??` y firmas TypeScript no soportadas), dinamización de todas las rutas hardcodeadas de desarrollo y usuario (`/mnt/Desarrollo`, `/mnt/Disco2`, `/home/facuud2`), purgado de 13 scripts duplicados y archivos huérfanos, soporte e integración de OSD de brillo y autostart del wallpaper, estandarización de despachadores de Hyprland (`hyprctl dispatch`) reemplazando llamadas a `hl.dsp.*` en CLI/QML, e incorporación de fallback automático para el historial de portapapeles (`lunita-clipboard`) en `modern-win11-theme`.
- **Criterios de Aceptación:**
  1. Los 159 archivos QML del proyecto compilan y formatean con 0 errores bajo `qmlformat`.
  2. No existen rutas estáticas de desarrollo en plantillas ni ejecutables.
  3. `lunita-osd` soporta brillo y volumen fluidamente.
  4. Los tres temas (`lunita-default`, `macos-theme` y `modern-win11-theme`) operan con comandos válidos de Hyprland sin excepciones en stderr.
  5. Ningún cambio fue pusheado al repositorio remoto.
- **Dependencias:** Ninguna

### [ISSUE-029] Erradicación de Bucle Infinito de Recarga de Plugins y Componentes en lunita-default
- **Estado:** COMPLETADO
- **Prioridad:** CRÍTICA
- **Rama Sugerida:** `AUDITORY_FIXES`
- **Módulo(s):** Core / Autostart / Hyprland / Matugen / Eww
- **Archivos Afectados:**
  - `core/.config/hypr/modules/autostart.lua`
  - `core/.local/bin/lunita-dynamic-wallpaper`
  - `core/.local/bin/lunita-quickshell`
  - `core/.local/bin/lunita-theme`
  - `themes/lunita-default/.config/eww/scripts/launch.sh`
  - `themes/lunita-default/.config/eww/scripts/watch_wallpaper.sh`
  - `themes/lunita-default/.config/matugen/hooks/update-theme.sh`
- **Descripción:** Al cambiar a `lunita-default`, el sistema entraba en un bucle infinito donde se recargaban continuamente todos los componentes, plugins de Hyprland (`hyprpm reload -n`) y Quickshell. El origen radicaba en una cascada de retroalimentación circular: `autostart.lua` se re-ejecutaba en cada `hyprctl reload` (invocando `lunita-dynamic-wallpaper init` con `force=true`, `lunita-quickshell start` y `hyprpm reload`), lo que provocaba que `awww` emitiera eventos de cambio de fondo que `watch_wallpaper.sh` detectaba, disparando `matugen image`, cuyo hook `update-theme.sh` volvía a forzar `hyprctl reload`, `lunita-quickshell restart` y `lunita-palette-sync sync`, repitiendo el ciclo perpetuamente.
- **Criterios de Aceptación:**
  1. `autostart.lua` cuenta con Session Guard (`_G.__LUNITA_AUTOSTART_DONE` y lockfile de instancia) emulando `exec-once` estricto y no se ejecuta durante `hyprctl reload`.
  2. `update-theme.sh` de Matugen no relanza destructivamente Quickshell ni llama circularmente a `lunita-palette-sync sync`.
  3. `watch_wallpaper.sh` cuenta con PID singleton lock y compara rutas canónicas (`realpath`) evitando falsos positivos de cambio de wallpaper.
  4. `lunita-dynamic-wallpaper init` no fuerza recarga si el wallpaper ya está activo en pantalla.
  5. `lunita-quickshell` limpia procesos huérfanos de listeners (`osd_listener.py`).
- **Dependencias:** [ISSUE-028]

### [ISSUE-030] Orquestador de Wallpaper Bajo Demanda y Erradicación de Demoras de 90s en Shutdown
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `AUDITORY_FIXES`
- **Módulo(s):** Core / Wallpaper / Systemd / Eww
- **Archivos Afectados:**
  - `core/.config/hypr/modules/autostart.lua`
  - `core/.config/systemd/user.conf.d/timeout.conf`
  - `core/.config/systemd/user/lunita-wallpaper.service`
  - `core/.config/systemd/user/lunita-wallpaper.timer`
  - `core/.local/bin/lunita-wallpaper`
  - `core/.local/bin/lunita-dynamic-wallpaper`
  - `themes/lunita-default/.config/eww/eww.yuck`
  - `themes/lunita-default/.config/eww/scripts/launch.sh`
  - `themes/lunita-default/.config/eww/scripts/watch_wallpaper.sh`
- **Descripción:** Al reiniciar o apagar el equipo, systemd quedaba bloqueado durante 90 segundos esperando el watchdog de `user@1000.service` debido a demonios huérfanos ejecutados con `setsid ... sleep 60` (`lunita-dynamic-wallpaper daemon`) y scripts de observación continua (`watch_wallpaper.sh`) que no procesaban `SIGTERM` mientras dormían en `sleep`. Se desarrolló desde cero un orquestador 100% libre de demonios en bucle (`lunita-wallpaper`) con ejecución atómica bajo demanda (One-Shot: restaura o aplica en <0.2s y termina con `exit 0`), rotación horaria delegada a temporizadores nativos de systemd (`lunita-wallpaper.timer`), timeout de seguridad de 5s en `user.conf.d/timeout.conf`, y eliminación de bucles persistentes en Eww.
- **Criterios de Aceptación:**
  1. `lunita-wallpaper` restaura y aplica fondos en modo One-Shot sin dejar procesos en segundo plano.
  2. `lunita-dynamic-wallpaper` actúa como wrapper compatible y seguro sin bucles infinitos.
  3. `core/.config/systemd/user.conf.d/timeout.conf` limita a 5s el timeout máximo de cierre del User Manager.
  4. Los temporizadores de systemd gestionan la rotación horaria nativa (06:00, 13:00, 20:00).
  5. Cero procesos huérfanos al apagar o reiniciar el equipo, garantizando un shutdown instantáneo.
- **Dependencias:** [ISSUE-029]

---

### [ISSUE-031] Rediseño Integral de Menús, Popups y Flyouts con Anti-Slop Taste Skill
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `AUDITORY_FIXES`
- **Módulo(s):** Temas (`lunita-default`, `macos-theme`, `modern-win11-theme`) / Quickshell / UI-UX
- **Archivos Afectados:**
  - `themes/lunita-default/.config/quickshell/bar/ExpandedPanel.qml`
  - `themes/lunita-default/.config/quickshell/bar/AudioPanel.qml`
  - `themes/lunita-default/.config/quickshell/bar/ConnPanel.qml`
  - `themes/lunita-default/.config/quickshell/bar/CalendarPanel.qml`
  - `themes/lunita-default/.config/quickshell/bar/NotifPanel.qml`
  - `themes/lunita-default/.config/quickshell/launcher/SearchMenuView.qml`
  - `themes/macos-theme/.config/quickshell/bar/popups/AppleMenu.qml`
  - `themes/macos-theme/.config/quickshell/bar/popups/AppMenuDropdown.qml`
  - `themes/macos-theme/.config/quickshell/bar/popups/BluetoothMenu.qml`
  - `themes/macos-theme/.config/quickshell/bar/popups/CalendarMenu.qml`
  - `themes/macos-theme/.config/quickshell/bar/popups/NetworkMenu.qml`
  - `themes/macos-theme/.config/quickshell/bar/popups/SoundMenu.qml`
  - `themes/macos-theme/.config/quickshell/bar/popups/TrayContextMenu.qml`
  - `themes/macos-theme/.config/quickshell/dock/DockContextMenu.qml`
  - `themes/macos-theme/.config/quickshell/launcher/AppItem.qml`
  - `themes/macos-theme/.config/quickshell/launcher/CategoryDetailView.qml`
  - `themes/macos-theme/.config/quickshell/launcher/CategorySection.qml`
  - `themes/macos-theme/.config/quickshell/launcher/HeaderBar.qml`
  - `themes/macos-theme/.config/quickshell/launcher/LauncherState.qml`
  - `themes/macos-theme/.config/quickshell/launcher/LauncherView.qml`
  - `themes/macos-theme/.config/quickshell/launcher/shell.qml`
  - `themes/macos-theme/.config/quickshell/spotlight/SpotlightItem.qml`
  - `themes/macos-theme/.config/quickshell/spotlight/SpotlightPreview.qml`
  - `themes/macos-theme/.config/quickshell/spotlight/SpotlightState.qml`
  - `themes/macos-theme/.config/quickshell/spotlight/SpotlightView.qml`
  - `themes/macos-theme/.config/quickshell/spotlight/shell.qml`
  - `themes/modern-win11-theme/.config/quickshell/bar/panels/LeftSoundFlyout.qml`
  - `themes/modern-win11-theme/.config/quickshell/bar/panels/RightBrightnessFlyout.qml`
  - `themes/modern-win11-theme/.config/quickshell/dock/BluetoothControlFlyout.qml`
  - `themes/modern-win11-theme/.config/quickshell/dock/CalendarNotificationFlyout.qml`
  - `themes/modern-win11-theme/.config/quickshell/dock/DockContextMenu.qml`
  - `themes/modern-win11-theme/.config/quickshell/dock/MediaControlFlyout.qml`
  - `themes/modern-win11-theme/.config/quickshell/dock/NetworkControlFlyout.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/AppItem.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/CategoryDetailView.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/CategoryFolderCard.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/CategorySection.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/HeaderBar.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/LauncherState.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/LauncherView.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/PowerFlyout.qml`
  - `themes/modern-win11-theme/.config/quickshell/launcher/shell.qml`
  - `themes/macos-theme/.config/quickshell/launcher/assets/icons/search.svg`
  - `themes/modern-win11-theme/.config/quickshell/launcher/assets/icons/lock.svg`
  - `themes/modern-win11-theme/.config/quickshell/launcher/assets/icons/logout.svg`
  - `themes/modern-win11-theme/.config/quickshell/launcher/assets/icons/moon.svg`
  - `themes/modern-win11-theme/.config/quickshell/launcher/assets/icons/reload.svg`
  - `core/.config/hypr/modules/rules.lua`
  - `core/.local/bin/lunita-theme-selector`
  - `core/.local/bin/lunita-widgets-manager`
  - `themes/lunita-default/.config/wlogout/style.css`
- **Descripción:** Rediseño estético y funcional exhaustivo de todos los 22 menús, popups y flyouts interactivos de los 3 ecosistemas de escritorio en Quickshell, así como las interfaces gráficas y menús independientes del sistema (`lunita-theme-selector`, `lunita-widgets-manager` y `wlogout`), aplicando los principios de la `design-taste-frontend` skill (jerarquía tipográfica estricta, superficies tonales intencionadas, erradicación de brillos y bordes plásticos `RectangularGlow` o `#47ffffff`, y sustitución de emojis crudos por iconografía vectorial auténtica):
  1. **`lunita-default`:** Enfatizada la identidad Nothing OS brutalista/monocromática de alto contraste. Se perfeccionó la isla `ExpandedPanel`, se rediseñó el buscador `SearchMenuView` eliminando cajas genéricas cuadradas y dotándolo de cápsulas y píldoras Nothing con atajos visuales nítidos, y se añadieron bordes de 1px a tarjetas y controles de `AudioPanel`, `ConnPanel`, `CalendarPanel` y `NotifPanel`. Se armonizó el menú de apagado `wlogout` con el rojo oficial `#D71921` y superficie `#161618`.
  2. **`macos-theme`:** Depuración de la estética Cupertino. Se erradicó el `RectangularGlow` artificial de 16px con `#99000000` en `DockContextMenu`, implementando elevación de capa ambiental limpia con borde de 1px y 12px de radio, selección en `#007AFF`, tipografía SF Pro Text/Display e interacción suave.
  3. **`modern-win11-theme`:** Implementación pura de Fluent Design. Se refactorizó completamente `PowerFlyout` erradicando emojis desalineados (`🔒`, `🌙`, `🔄`, etc.) y fuentes sustitutas, reemplazándolos por iconos vectoriales SVG oficiales, Segoe UI Variable, acento suave al hover y bordes de radio 8px/6px. Se optimizó el dimensionamiento y sizing reactivo de `DockContextMenu` y flyouts de control.
  4. **Interfaces Gráficas y Herramientas Independientes (Anti-Slop & Opacidad Sólida):** Refinamiento integral de `lunita-theme-selector` y `lunita-widgets-manager`. Se configuró la regla de ventana `lunita-gui-tools` en `core/.config/hypr/modules/rules.lua` (`opacity = "1.0 override 1.0 override"`, flotante y centrada) erradicando la semitransparencia del 82% que volvía ilegibles los textos sobre ventanas o videos de fondo. En `lunita-theme-selector`, se incorporaron superficies sólidas `#121316` / `#16171B`, encabezados sutiles `#94A3B8`, chips informativos con glifos Nerd Font (`󱂬`, `󱂫`, `󰍉`, etc.) y micro-bordes de acento dinámicos. En `lunita-widgets-manager`, se erradicaron los botones genéricos azules en el chrome ("Color goes on data, not chrome"), se estilizaron los paneles de control de widgets (`Adw.PreferencesGroup`, `boxed-list`, `switch:checked`) y se dotó de botones de acción secundarios con elevación sutil y proporciones limpias.
  5. **Auditoría Visual y Corrección de Iconos en Vivo:** Mediante capturas en tiempo real bajo Wayland y simulación de uso real, se detectaron y subsanaron: glifos literales de texto (`search` y `arrow_back`) en `SearchMenuView` de `lunita-default` corregidos con `SymbolsNerdFont` y `Feather`; textura ausente (checkerboard) en `HeaderBar` de macOS corregida con un SVG nativo `search.svg`; sustitución de fuentes residuales `Adwaita Sans` por `Segoe UI Variable Text` en Windows 11; e independización de iconos vectoriales en `PowerFlyout` eliminando rutas relativas frágiles.
- **Criterios de Aceptación:**
  1. Todos los archivos QML pasan `qmlformat` con 0 errores de sintaxis y formateo limpio.
  2. Ningún menú contiene emojis, texturas faltantes o brillos plásticos artificiales.
  3. Cada tema mantiene una coherencia visual y táctil inmaculada con su respectivo lenguaje de diseño.
  4. `lunita-theme-selector` adapta sus acentos dinámicamente según la paleta del tema seleccionado.
  5. Ningún cambio fue pusheado al repositorio remoto.
- **Dependencias:** [ISSUE-028], [ISSUE-030]

### [ISSUE-032] Cierre automático de Spotlight/Finder al hacer clic fuera de la ventana
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_032_FIX`
- **Módulo(s):** Core / Temas / Spotlight
- **Archivos Afectados:** `themes/macos-theme/.config/quickshell/spotlight/shell.qml`, `themes/macos-theme/.config/quickshell/spotlight/SpotlightView.qml`
- **Descripción:** Actualmente el modal de Spotlight/Finder (`SUPER+SPACE`) permanece abierto aunque el usuario haga clic fuera de su superficie. Se debe capturar la pérdida de foco o implementar un contenedor subyacente (`MouseArea` de pantalla completa transparente detrás del cuadro de búsqueda o manejo de foco en `PanelWindow`) para que cualquier clic fuera de la interfaz dibujada por Quickshell cierre el componente inmediatamente.
- **Criterios de Aceptación:**
  1. Hacer clic en cualquier punto externo a la ventana de Spotlight cierra el modal de forma instantánea.
  2. La interacción interna (escritura, selección de resultados y clic dentro del modal) no dispara el cierre accidental.
- **Dependencias:** Ninguna

### [ISSUE-035] Adaptación estética dinámica de widgets por tema con persistencia de layout
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_035_FEAT`
- **Módulo(s):** Core / Temas / Widgets
- **Archivos Afectados:** `core/.config/quickshell/widgets/`, `themes/macos-theme/.config/quickshell/widgets/`, `core/.local/bin/lunita-palette-sync`, `core/.local/bin/lunita-quickshell`, `themes/lunita-default/theme.json`, `themes/modern-win11-theme/theme.json`
- **Descripción:** Los widgets de escritorio deben adaptar su diseño visual (bordes, desenfoque, tipografía y paleta de colores) dinámicamente según el tema activo (`lunita-default`, `macOS-Theme`, `Modern-Win11-Theme`), pero manteniendo una única configuración persistente de estado: qué widgets están activos, sus dimensiones y sus coordenadas en pantalla deben conservarse intactos al cambiar de un tema a otro.
- **Criterios de Aceptación:**
  1. Cambiar de tema transforma la estética de los widgets en pantalla para coincidir con el lenguaje visual del nuevo tema.
  2. La posición, tamaño y visibilidad de los widgets activos se mantienen sin reiniciarse ni desacomodarse entre cambios de tema.
- **Dependencias:** [ISSUE-019]

### [ISSUE-036] Estandarización de clic izquierdo (edición) y clic derecho (menú) en botón de widgets
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_036_FEAT`
- **Módulo(s):** Temas / Bar-Dock / Widgets
- **Archivos Afectados:** `themes/macos-theme/.config/quickshell/bar/BarView.qml`, `themes/modern-win11-theme/.config/quickshell/dock/TrayPlatter.qml`, `themes/modern-win11-theme/.config/quickshell/dock/DockState.qml`, `themes/lunita-default/.config/quickshell/bar/CompactPill.qml`, `core/.local/bin/lunita-widgets-toggle`
- **Descripción:** Unificar el comportamiento del botón de control de widgets en los 3 temas mediante el manejo de botones en `MouseArea` (`acceptedButtons: Qt.LeftButton | Qt.RightButton`):
  - **Clic izquierdo:** Activa/desactiva directamente el modo de edición en pantalla (`lunita-widgets-toggle`) para arrastrar, reposicionar y redimensionar los widgets.
  - **Clic derecho:** Abre exclusivamente la interfaz gráfica de configuración (`lunita-widgets-manager`).
- **Criterios de Aceptación:**
  1. En los 3 temas, el clic izquierdo sobre el icono de widgets habilita el arrastre y redimensionamiento en el escritorio.
  2. En los 3 temas, el clic derecho abre la ventana del menú de configuración de widgets.
- **Dependencias:** Ninguna

### [ISSUE-038] Reparación crítica de carga de datos y renderizado en widgets de escritorio
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_038_FIX`
- **Módulo(s):** Core / Widgets (Backend & QML)
- **Archivos Afectados:** `core/.config/quickshell/widgets/scripts/sys_provider.py`, `core/.config/quickshell/widgets/scripts/net_provider.py`, `core/.config/quickshell/widgets/NetworkWidget.qml`, `core/.config/quickshell/widgets/DesktopGridCanvas.qml`, `core/.config/quickshell/widgets/PhotoWidget.qml`
- **Descripción:** Todos los widgets de escritorio (a excepción del reloj/hora) se encuentran rotos y se renderizan vacíos sin cargar información. El agente debe auditar el flujo de datos (procesos `Process` en QML, lectura de JSON locales, permisos de ejecución en scripts de Python/Bash y rutas tras últimas refactorizaciones) y restaurar la ingesta y visualización de datos en cada widget.
- **Criterios de Aceptación:**
  1. Todos los widgets activos cargan, parsean y muestran su información correspondiente en tiempo real sin quedar en blanco.
  2. No se registran errores de lectura o rutas inexistentes en los logs de `lunita-quickshell`.
- **Dependencias:** Ninguna

### [ISSUE-033] Integración de paleta dinámica Matugen en el Clipboard de lunita-default
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_033_FEAT`
- **Módulo(s):** Lunita-Default / Clipboard / Matugen
- **Archivos Afectados:** `themes/lunita-default/.config/quickshell/clipboard/ClipboardState.qml`, `themes/lunita-default/.config/quickshell/launcher/LauncherState.qml`, `themes/lunita-default/.config/quickshell/bar/Theme.qml`, `themes/lunita-default/.config/quickshell/bar/CompactPill.qml`, `core/.config/quickshell/hyprquickpaper/commands.sh`, `core/.config/quickshell/widgets/WidgetsState.qml`
- **Descripción:** El portapapeles de `lunita-default` utiliza actualmente una paleta estática inspirada en NothingOS con acentos rojizos fijos. Se debe vincular el componente QML del portapapeles con los tokens de color generados por Matugen para que adopte dinámicamente la paleta extraída del fondo de pantalla activo, manteniendo coherencia visual con el resto del tema.
- **Criterios de Aceptación:**
  1. El portapapeles de `lunita-default` elimina los colores rojizos hardcodeados y consume las variables dinámicas de Matugen.
  2. Al cambiar de wallpaper en `lunita-default`, el portapapeles actualiza sus colores de fondo, bordes y acentos automáticamente.
- **Dependencias:** [ISSUE-021]

### [ISSUE-034] Eliminación definitiva de Eww y sus widgets en lunita-default
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_034_CHORE`
- **Módulo(s):** Lunita-Default / Core
- **Archivos Afectados:** `themes/lunita-default/.config/eww/`, `themes/lunita-default/theme.json`, `themes/lunita-default/.config/matugen/config.toml`, `themes/lunita-default/.config/matugen/templates/eww-colors.scss`, `themes/lunita-default/.config/matugen/hooks/update-theme.sh`, `core/.local/bin/lunita-theme`, `themes/lunita-default/README.md`, `.gitignore`
- **Descripción:** Purgar por completo la carpeta `.config/eww` dentro de `lunita-default`, así como cualquier plantilla de Matugen, referencia en `theme.json` o llamada al demonio `eww` en los scripts de inicio y cambio de tema, dado que serán reemplazados por el ecosistema de widgets nativos en Quickshell.
- **Criterios de Aceptación:**
  1. El directorio `.config/eww` ya no existe en `themes/lunita-default/`.
  2. `lunita-theme` y `matugen` no intentan invocar ni generar plantillas para Eww.
- **Dependencias:** Ninguna

### [ISSUE-037] Incorporación de widgets de escritorio y botón de control en Dynamic Island de lunita-default
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_037_FEAT`
- **Módulo(s):** Lunita-Default / Bar (Dynamic Island) / Widgets
- **Archivos Afectados:** `themes/lunita-default/.config/quickshell/bar/CompactPill.qml`, `themes/lunita-default/.config/quickshell/bar/QuickActions.qml`, `themes/lunita-default/theme.json`
- **Descripción:** Habilitar el lienzo de widgets de escritorio (`widgets`) dentro del ciclo de vida de `lunita-default` y añadir un botón dedicado en la Dynamic Island para gestionar dichos widgets, respetando la convención de clic izquierdo (modo arrastre/redimensionado) y clic derecho (abrir menú gestor).
- **Criterios de Aceptación:**
  1. Los widgets de escritorio se inician y se muestran de forma nativa al aplicar `lunita-default`.
  2. La Dynamic Island incluye el botón de widgets con soporte para clic izquierdo (edición) y clic derecho (menú).
- **Dependencias:** [ISSUE-035], [ISSUE-036]

### [ISSUE-039] Rediseño de Calendario en el menú de widgets con eventos por día e indicadores geométricos
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_039_FEAT`
- **Módulo(s):** GUI / Widgets Manager / Calendario
- **Archivos Afectados:** `core/.local/bin/lunita-widgets-manager`, `core/.config/quickshell/widgets/CalendarWidget.qml`, `core/.config/quickshell/widgets/WidgetsState.qml`, `core/.config/quickshell/widgets/scripts/calendar_provider.py`
- **Descripción:** Rediseñar la sección de Calendario dentro de `lunita-widgets-manager` para que la cuadrícula mensual ocupe toda el área de la ventana. Al hacer clic sobre la celda de un día específico, debe desplegarse un diálogo/panel para agregar o editar eventos y notas asociados a esa fecha. Se deben conservar los colores de categorización actuales e incorporar la elección de un marcador geométrico sutil por evento: estrella, círculo, triángulo o cuadrado.
- **Criterios de Aceptación:**
  1. El calendario se expande ocupando la totalidad de la vista en el gestor de widgets.
  2. Hacer clic en cualquier día permite crear/editar notas y eventos para esa fecha, asignándoles color y forma geométrica (estrella, círculo, triángulo o cuadrado).
  3. Los marcadores geométricos y eventos se guardan y se reflejan visualmente tanto en el gestor como en el widget de escritorio.
- **Dependencias:** [ISSUE-038]

### [ISSUE-040] Rediseño del widget de Notas/Agenda estilo iOS/iPadOS y purga de referencias a UNaB
- **Estado:** COMPLETADO
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_040_FEAT`
- **Módulo(s):** GUI / Widgets Manager / Widgets QML
- **Archivos Afectados:** `core/.local/bin/lunita-widgets-manager`, `core/.config/quickshell/widgets/TimetableWidget.qml`, `core/.config/quickshell/widgets/WidgetsState.qml`, `core/.config/quickshell/widgets/scripts/timetable_provider.py`, `core/.config/quickshell/hyprquickpaper/shell-coverflow-clear.qml`, `core/.config/quickshell/hyprquickpaper/shell-coverflow-minimal.qml`, `core/.config/quickshell/hyprquickpaper/shell-coverflow.qml`, `core/.config/quickshell/hyprquickpaper/shell-hexcomb.qml`, `themes/lunita-default/wallpaper/wallpaper2.jpg`
- **Descripción:** 
  1. Rediseñar el widget de escritorio de Notas y Agenda adoptando el paradigma visual de iOS/iPadOS: una tarjeta limpia que exhibe el título y el contenido de la nota activa, permitiendo alternar suavemente entre distintas tarjetas/notas al hacer scroll vertical (hacia arriba o hacia abajo con `WheelHandler`).
  2. Eliminar absolutamente todo rastro, pestaña, plantilla de horario o referencia a "UNaB" tanto en el código de `lunita-widgets-manager` como en los widgets QML y archivos de configuración por defecto.
- **Criterios de Aceptación:**
  1. El widget de Notas muestra título y cuerpo en formato tarjeta y cambia de nota dinámicamente mediante scroll vertical.
  2. `grep -ri "unab" core/ themes/` no arroja ningún resultado en el repositorio.
- **Dependencias:** [ISSUE-038]

### [ISSUE-041] Restricción de instancia única (Singleton) en el menú gestor de widgets
- **Estado:** COMPLETADO
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_041_FIX`
- **Módulo(s):** GUI / Widgets Manager
- **Archivos Afectados:** `core/.local/bin/lunita-widgets-manager`
- **Descripción:** Actualmente es posible abrir múltiples ventanas simultáneas de `lunita-widgets-manager`. Se debe garantizar el comportamiento de instancia única (Singleton) utilizando el registro nativo de `Adw.Application` / `Gtk.Application` mediante un `application_id` único (ej. `org.lunita.WidgetsManager`) o un bloqueo por archivo en `$XDG_RUNTIME_DIR`. Si el usuario invoca el menú cuando ya está abierto, debe enfocar y traer al frente (`present()`) la ventana existente en lugar de crear un proceso duplicado.
- **Criterios de Aceptación:**
  1. Ejecutar `lunita-widgets-manager` múltiples veces desde terminal o mediante clic derecho en las barras nunca abre más de una ventana.
  2. Si la ventana ya existe en segundo plano, una nueva invocación le devuelve el foco en el escritorio actual.
- **Dependencias:** Ninguna

### [ISSUE-042] Re-refactorización total del Widget de Calendario (Basado en Imagen)
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_042_REFACTOR`
- **Módulo(s):** Temas / Widgets / Calendario
- **Archivos Afectados:** `core/.config/quickshell/widgets/CalendarWidget.qml`, `core/.local/bin/lunita-widgets-manager`
- **Descripción:** Reestructurar desde cero el widget de Calendario replicando con precisión milimétrica la imagen de referencia adjunta en el prompt de ejecución. Debe operar como una tarea 100% aislada e independiente del resto de los widgets.
- **Directrices de Diseño (UX/UI Pro & Anti AI-Slop):**
  1. Seguir estrictamente la composición, proporciones, paddings y jerarquía tipográfica de la imagen proporcionada.
  2. Aplicar el flujo de diseño **UX/UI Pro** bajo estética **iOS-Like** pura (bordes continuos tipo *squircle*, desenfoque translúcido sutil, contraste limpio y ausencia total de sobrecarga visual o "AI Slop").
- **Criterios de Aceptación:**
  1. El trabajo se realiza y confirma exclusivamente dentro de la rama `ISSUE_042_REFACTOR`.
  2. La interfaz QML resultante es fiel a la imagen adjunta en el prompt y respeta las guías iOS-Like.
  3. El widget funciona de manera autónoma sin romper ni depender de otros widgets del lienzo.
- **Dependencias:** Ninguna (Ejecución independiente)

### [ISSUE-043] Re-refactorización total del Widget de Dispositivos Conectados (Basado en Imagen)
- **Estado:** PENDIENTE
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_043_REFACTOR`
- **Módulo(s):** Temas / Widgets / Dispositivos y Batería
- **Archivos Afectados:** `themes/*/.config/quickshell/widgets/` (Componente QML de Dispositivos/Batería y scripts recolectores UPower/Bluetooth)
- **Descripción:** Rediseñar por completo el widget de Dispositivos Conectados y niveles de batería guiándose estrictamente por la imagen de referencia adjunta al momento de ejecutar esta tarea.
- **Directrices de Diseño (UX/UI Pro & Anti AI-Slop):**
  1. Replicar exactamente la disposición de anillos/barras de batería, iconografía de periféricos y distribución espacial de la captura adjunta.
  2. Aplicar los estándares de **UX/UI Pro** y **Anti AI-Slop**, priorizando legibilidad inmediata, micro-interacciones suaves y acabado nativo **iOS-Like**.
- **Criterios de Aceptación:**
  1. El desarrollo se encapsula en la rama `ISSUE_043_REFACTOR`.
  2. El resultado visual coincide exactamente con la imagen adjunta en el prompt.
  3. Muestra el estado real del equipo y periféricos conectados sin acoplarse a otras tareas.
- **Dependencias:** Ninguna (Ejecución independiente)

### [ISSUE-044] Re-refactorización total del Widget de Notas (Basado en Imagen)
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_044_REFACTOR`
- **Módulo(s):** Temas / Widgets / Notas
- **Archivos Afectados:** `core/.config/quickshell/widgets/TimetableWidget.qml`, `core/.config/quickshell/widgets/scripts/timetable_provider.py`, `core/.config/quickshell/widgets/WidgetsState.qml`, `core/.local/bin/lunita-widgets-manager`
- **Descripción:** Reestructurar íntegramente el widget de Notas basándose de forma estricta en la imagen de referencia suministrada en el prompt. Debe mantener navegación fluida por scroll entre notas y sincronización con el gestor.
- **Directrices de Diseño (UX/UI Pro & Anti AI-Slop):**
  1. Obedecer fielmente el diseño de cabecera, líneas divisoras, márgenes internos y estilo de tarjeta de la imagen adjunta.
  2. Ejecutar bajo el estándar **UX/UI Pro** + **Anti AI-Slop**, logrando la estética nativa de Apple Notes en **iOS/iPadOS**.
- **Criterios de Aceptación:**
  1. Todo cambio queda registrado únicamente en la rama `ISSUE_044_REFACTOR`.
  2. La apariencia final calca la referencia visual provista y elimina cualquier elemento genérico no solicitado.
- **Dependencias:** Ninguna (Ejecución independiente)

### [ISSUE-045] Re-refactorización total del Widget de Clima (Basado en Imagen)
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_045_REFACTOR`
- **Módulo(s):** Temas / Widgets / Clima
- **Archivos Afectados:** `core/.config/quickshell/widgets/WeatherWidget.qml`, `core/.config/quickshell/widgets/WidgetFrame.qml`, `core/.config/quickshell/widgets/DesktopGridCanvas.qml`, `core/.config/quickshell/widgets/WidgetsState.qml`, `core/.config/quickshell/widgets/scripts/weather_provider.py`, `core/.local/bin/lunita-widgets-manager`
- **Descripción:** Reconstruir el widget de Clima siguiendo al pie de la letra la imagen de referencia adjuntada en la sesión del prompt.
- **Directrices de Diseño (UX/UI Pro & Anti AI-Slop):**
  1. Respetar la ubicación exacta de la temperatura principal, pronóstico por horas/días, iconos climáticos y gradientes de fondo mostrados en la imagen.
  2. Aplicar directrices **UX/UI Pro** y **Anti AI-Slop** para lograr un acabado **iOS Weather-Like** limpio, con pesos tipográficos precisos y sin sombras ni bordes artificiales.
- **Criterios de Aceptación:**
  1. Desarrollo aislado en la rama `ISSUE_045_REFACTOR`.
  2. Coincidencia visual estricta con la imagen de referencia adjunta y carga correcta de datos climáticos.
- **Dependencias:** Ninguna (Ejecución independiente)

### [ISSUE-046] Creación del nuevo Widget de Archivos (Basado en Imagen)
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_046_FEAT`
- **Módulo(s):** Temas / Widgets / Archivos (Nuevo Componente)
- **Archivos Afectados:** `core/.config/quickshell/widgets/FilesWidget.qml`, `core/.config/quickshell/widgets/WidgetFrame.qml`, `core/.config/quickshell/widgets/DesktopGridCanvas.qml`, `core/.config/quickshell/widgets/WidgetsState.qml`, `core/.config/quickshell/widgets/scripts/files_provider.py`, `core/.local/bin/lunita-widgets-manager`
- **Descripción:** Desarrollar desde cero un nuevo widget de Archivos recientes/anclados para el escritorio, tomando como especificación visual absoluta la imagen adjunta en el prompt al iniciar la tarea.
- **Directrices de Diseño (UX/UI Pro & Anti AI-Slop):**
  1. Construir la grilla o lista de archivos, previsualizaciones de iconos, truncado de nombres y espaciados exactamente como dicta la imagen de referencia.
  2. Implementar con el flujo **UX/UI Pro** y **Anti AI-Slop**, emulando la estética del widget de *Files* de **iOS/iPadOS** y abriendo los elementos con `xdg-open` o Dolphin al interactuar.
- **Criterios de Aceptación:**
  1. Rama exclusiva `ISSUE_046_FEAT` creada y utilizada para el feature.
  2. El nuevo widget se registra en el lienzo y su diseño replica la imagen adjunta sin desviaciones.
- **Dependencias:** Ninguna (Ejecución independiente)

### [ISSUE-047] Re-refactorización total del Widget de Imágenes (Basado en Imagen)
- **Estado:** COMPLETADO [x]
- **Prioridad:** MEDIA
- **Rama Requerida:** `ISSUE_047_REFACTOR`
- **Módulo(s):** Temas / Widgets / Imágenes y Fotos
- **Archivos Afectados:** `core/.config/quickshell/widgets/PhotoWidget.qml`, `core/.config/quickshell/widgets/scripts/photo_provider.py`
- **Descripción:** Reestructurar por completo el widget de Imágenes/Galería ajustándolo estrictamente al diseño de la imagen de referencia proporcionada en el prompt.
- **Directrices de Diseño (UX/UI Pro & Anti AI-Slop):**
  1. Recortar las imágenes con el radio de curvatura (`radius` / `OpacityMask` / `MultiEffect`) exacto de la referencia, respetando superposiciones de texto o controles si la imagen los incluye.
  2. Aplicar **UX/UI Pro** y **Anti AI-Slop** para conseguir una presentación fotográfica limpia al estilo **iOS Photos Widget**, con transiciones suaves (`CrossFade`) y escalado `PreserveAspectCrop`.
- **Criterios de Aceptación:**
  1. Trabajo confinado en la rama `ISSUE_047_REFACTOR`.
  2. Fidelidad visual absoluta respecto a la imagen suministrada en el prompt.
- **Dependencias:** Ninguna (Ejecución independiente)

### [ISSUE-048] Rediseño autónomo del Widget de Fitness con Anillos de Actividad (Sin Imagen)
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_048_FEAT`
- **Módulo(s):** Temas / Widgets / Fitness & Hábitos
- **Archivos Afectados:** `core/.config/quickshell/widgets/HabitTrackerWidget.qml`
- **Descripción:** Rediseñar el widget de Fitness e integrar un sistema de **Anillos de Actividad concéntricos** que se llenen dinámicamente a medida que el usuario registre su progreso diario desde el gestor de widgets o mediante interacción directa. **Nota para el agente:** Esta es la única tarea de la serie que NO incluye imagen de referencia adjunta; el agente es responsable de diseñar la interfaz de forma autónoma.
- **Directrices de Diseño (UX/UI Pro & Anti AI-Slop):**
  1. Aplicar rigurosamente el flujo **UX/UI Pro** y **Anti AI-Slop** siguiendo el estándar visual de **Apple Fitness (iOS/watchOS)**: fondo oscuro profundo de alto contraste, tres anillos concéntricos con bordes redondeados (`lineCap: "round"`), pistas de fondo translúcidas y métricas tipográficas limpias al costado.
  2. Incluir animaciones fluidas de llenado radial cuando cambien los valores registrados por el usuario.
- **Criterios de Aceptación:**
  1. Implementado íntegramente en la rama `ISSUE_048_FEAT`.
  2. Renderiza los anillos concéntricos con estética nativa iOS-Like sin caer en diseños genéricos ("AI Slop").
  3. Los anillos reflejan en tiempo real el porcentaje de progreso que el usuario decida registrar.
- **Dependencias:** Ninguna (Ejecución independiente)

### [ISSUE-049] Reparar Autoinicio del Servicio de Widgets de Quickshell al Iniciar Sesión
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_049_FIX`
- **Módulo(s):** Core / Widgets / Autostart / Quickshell
- **Archivos Afectados:** `core/.config/quickshell/widgets/WeatherWidget.qml`, `core/.config/quickshell/widgets/HabitTrackerWidget.qml`, `core/.config/quickshell/widgets/FilesWidget.qml`, `core/.local/bin/lunita-quickshell`, `core/.config/hypr/modules/autostart.lua`
- **Descripción:** El servicio y demonio de widgets en Quickshell (`quickshell -p ~/.config/quickshell/widgets`) no arrancaba con el inicio del sistema durante la invocación de `lunita-quickshell start` desde `autostart.lua`. La investigación del log reveló errores fatales de parseo en QML: asignaciones no enteras a `font.pixelSize` (`13.5`, `12.5`, `10.5` en `WeatherWidget.qml`, `HabitTrackerWidget.qml` y `FilesWidget.qml`) y asignaciones inválidas de `horizontalAlignment` sobre componentes `Column`, lo que provocaba el cierre prematuro inmediato del proceso con código de error 255. Adicionalmente, `lunita-quickshell` carecía de los comandos explícitos `start-component` y `stop-component` requeridos por utilidades como `lunita-widgets-toggle`.
- **Criterios de Aceptación:**
  1. `quickshell -p ~/.config/quickshell/widgets` carga sin fallos de parseo de propiedades ni excepciones en la consola.
  2. `lunita-quickshell status` reporta el proceso de widgets en estado Activo con PID asignado.
  3. Soporte para `start-component` y `stop-component` en `lunita-quickshell`.
  4. Los archivos modificados pasan las validaciones obligatorias `bash -n` y `luac -p`.
- **Dependencias:** Ninguna (Ejecución independiente)

### [ISSUE-050] Interactividad completa, vistas de detalle, edición y gestos en el Widget de Notas
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_049_FEAT`
- **Módulo(s):** Temas / Widgets / Notas
- **Archivos Afectados:** `core/.config/quickshell/widgets/TimetableWidget.qml`, `core/.config/quickshell/widgets/WidgetsState.qml`, `core/.config/quickshell/widgets/shell.qml`, `core/.config/quickshell/widgets/DesktopGridCanvas.qml`, `core/.config/quickshell/widgets/WidgetFrame.qml`, `core/.config/quickshell/widgets/scripts/timetable_provider.py`, `core/.config/quickshell/widgets/scripts/widget_ipc_listener.py`, `core/.local/bin/lunita-widgets-manager`, `core/.local/bin/lunita-widgets-toggle`, `core/.local/bin/lunita-quickshell`
- **Descripción:** Dotar de interactividad completa al widget de Notas en el escritorio:
  1. **Vista de detalle y navegación:** Al hacer clic sobre el título de una nota en el listado, el widget transiciona hacia una vista completa mostrando el contenido íntegro de la nota seleccionada, con botón de retroceso ("Atrás") para volver al listado general.
  2. **Creación directa:** Botón de acción rápida (`+`) en el encabezado del widget para redactar y guardar notas directamente sin abrir el gestor externo.
  3. **Edición interactiva en vivo:** Al abrir cualquier nota en la vista de detalle, sus campos de título y contenido son editables (`TextInput` / `TextEdit`) con guardado automático persistente al presionar "Listo" o retroceder.
  4. **Efecto Smart Stack vertical en modo compacto:** En tamaño pequeño, la transición entre notas existentes se produce con una animación vertical fluida (hacia arriba o abajo) estilo pila inteligente de iOS mediante `DragHandler` y `WheelHandler`.
- **Criterios de Aceptación:**
  1. Hacer clic en una nota despliega su detalle completo editable y permite persistir modificaciones o regresar al listado.
  2. El botón `+` permite crear nuevas notas con título y cuerpo persistidos en el almacenamiento JSON.
  3. En tamaño compacto, la navegación vertical cicla exclusivamente entre las notas existentes con efecto de pila inteligente tridimensional y microindicador de página.
- **Dependencias:** [ISSUE-044]

### [ISSUE-051] Simplificación del Widget de Reloj y bloqueo en tamaño pequeño
- **Estado:** COMPLETADO [x]
- **Prioridad:** MEDIA
- **Rama Requerida:** `ISSUE_050_REFACTOR`
- **Módulo(s):** Temas / Widgets / Reloj y Lienzo (`DesktopGridCanvas`)
- **Archivos Afectados:** `core/.config/quickshell/widgets/ClockWidget.qml`, `core/.config/quickshell/widgets/WidgetFrame.qml`, `core/.config/quickshell/widgets/WidgetsState.qml`
- **Descripción:** 
  1. Eliminar toda lógica, consulta e interfaz relacionada con el clima dentro del widget de Reloj, dejando exclusivamente la visualización horaria.
  2. Restringir las dimensiones del widget de Reloj para que sea el único widget del ecosistema bloqueado permanentemente en su variante de tamaño pequeño, deshabilitando los controles o tiradores de expansión/redimensionamiento para este componente específico.
- **Criterios de Aceptación:**
  1. El widget de Reloj no muestra datos ni iconos meteorológicos ni realiza llamadas a servicios de clima.
  2. En el modo de edición de widgets (`lunita-widgets-toggle`), el reloj permite ser reposicionado pero bloquea cualquier intento de expandirlo a tamaños medianos o grandes.
- **Dependencias:** Ninguna

### [ISSUE-052] Animación vertical estilo Smart Stack (iOS) en el Widget de Imágenes
- **Estado:** COMPLETADO [x]
- **Prioridad:** MEDIA
- **Rama Requerida:** `ISSUE_052_FEAT`
- **Módulo(s):** Temas / Widgets / Imágenes
- **Archivos Afectados:** `core/.config/quickshell/widgets/PhotoWidget.qml`, `core/.config/quickshell/widgets/WidgetsState.qml`, `core/.config/quickshell/widgets/scripts/photo_provider.py`
- **Descripción:** Reemplazar el cambio estático de fotografías por una animación vertical de subida y bajada idéntica al comportamiento de la "Pila Inteligente" (*Smart Stack*) de iOS. Al deslizar/arrastrar verticalmente o rotar automáticamente el carrusel, las imágenes deben desplazarse en el eje Y con físicas de resorte (`SpringAnimation` / curvas Bezier iOS-Like), escala sutil de profundidad e indicadores laterales temporales de posición.
- **Criterios de Aceptación:**
  1. Las imágenes transicionan desplazándose verticalmente hacia arriba o hacia abajo con efecto de pila tridimensional estilo iOS.
  2. El usuario puede cambiar de foto manualmente deslizando hacia arriba/abajo con el cursor o rueda del ratón, además de la rotación automática.
- **Dependencias:** [ISSUE-047]

### [ISSUE-053] Registro manual en vivo e integración con Strava en el Widget de Salud/Fitness
- **Estado:** PENDIENTE
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_052_FEAT`
- **Módulo(s):** Temas / Widgets / Fitness & Backend de Sincronización
- **Archivos Afectados:** `themes/*/.config/quickshell/widgets/` (Componente QML de Fitness y scripts de sincronización), `core/.local/bin/lunita-widgets-manager`
- **Descripción:** Reemplazar los botones genéricos de incremento de pasos y movimiento en el widget de Salud por un sistema dual de ingesta de datos accesible desde el propio widget:
  1. **Modo Manual Interactivo:** Permitir ingresar o ajustar directamente desde la interfaz del widget las métricas del día (pasos, calorías/movimiento, minutos de ejercicio) actualizando los anillos de actividad en tiempo real.
  2. **Modo Dinámico (Strava API):** Implementar un flujo de conexión y sincronización con la API de Strava para extraer automáticamente las actividades físicas del usuario, traduciendo distancia, tiempo y gasto calórico al progreso de los anillos sin intervención manual.
- **Criterios de Aceptación:**
  1. Se eliminan los botones genéricos de prueba y se incorpora una vista/control limpio en el widget para alternar entre entrada manual y sincronización con Strava.
  2. En modo manual, el usuario puede introducir valores concretos desde el widget y persistirlos en el almacenamiento local.
  3. Al vincular una cuenta de Strava, el widget obtiene periódicamente las métricas recientes y actualiza los anillos de actividad de forma automática.
- **Dependencias:** [ISSUE-048]

---

### [ISSUE-054] Rediseño Estético Exclusivo de Widgets de Escritorio al Estilo NothingOS
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_054_STYLE`
- **Módulo(s):** Temas / Widgets / Quickshell / `lunita-default`
- **Archivos Afectados:** `core/.config/quickshell/widgets/WidgetSkin.qml`, `core/.config/quickshell/widgets/WidgetsState.qml`, `core/.config/quickshell/widgets/NdDotRing.qml`, `core/.config/quickshell/widgets/NdDotBar.qml`, `core/.config/quickshell/widgets/NdDotGrid.qml`, `core/.config/quickshell/widgets/ClockWidget.qml`, `core/.config/quickshell/widgets/WeatherWidget.qml`, `core/.config/quickshell/widgets/BatteryWidget.qml`, `core/.config/quickshell/widgets/NetworkWidget.qml`, `core/.config/quickshell/widgets/SystemResourcesWidget.qml`, `core/.config/quickshell/widgets/GitActivityWidget.qml`, `core/.config/quickshell/widgets/HabitTrackerWidget.qml`, `core/.config/quickshell/widgets/TimetableWidget.qml`, `core/.config/quickshell/widgets/MediaWidget.qml`, `core/.config/quickshell/widgets/CalendarWidget.qml`, `core/.config/quickshell/widgets/FilesWidget.qml`, `core/.config/quickshell/widgets/PhotoWidget.qml`
- **Descripción:** Rediseñar la capa visual de los 12 widgets de escritorio en Quickshell adoptando la identidad NothingOS (Nothing Phone / Nothing OS 2.5/3.0) para el tema `lunita-default`, preservando íntegramente las funcionalidades, interactividad, gestos y APIs subyacentes:
  1. **Arquitectura desacoplada de Skin:** Implementación de `WidgetSkin.qml` y primitivas dot-matrix (`NdDotRing`, `NdDotBar`, `NdDotGrid`), garantizando que la lógica de backend sea compartida y otros temas puedan mantener o definir sus propios skins (Apple en macOS, Fluent en Modern-Win11).
  2. **Lenguaje Visual NothingOS:**
     - Paleta monocromática estricta (negro `#111111`, gris `#1C1C1C`, blanco `#F5F5F5`, gris medio `#8F8F8F`) con acento de señal único rojo Nothing (`#D71921`) para estados activos/"en vivo".
     - Tipografía dual: cifras y datos principales en matriz de puntos LED (*NDOT 47* / *Doto*), textos de interfaz y cuerpo en *Space Grotesk*.
     - Tarjetas planas sin degradados, sombras ni blur; radio consistente de 24px.
  3. **Adaptación de los 12 widgets:** Reloj apilado digital, Clima monocromo plano, Anillos de progreso por puntos en Recursos/Salud/Batería, Heatmap de puntos en GitHub Activity, papel de puntos en Notas y carátula vinilo en Media.
- **Criterios de Aceptación:**
  1. Todos los widgets muestran la estética NothingOS en `lunita-default`.
  2. Ninguna funcionalidad previa (interacción de notas, smart stack, providers, IPC) se degrada ni altera.
  3. El tema `macos-theme` mantiene su diseño previo sin regresiones.
  4. Quickshell carga limpiamente sin errores de sintaxis QML.
- **Dependencias:** [ISSUE-050], [ISSUE-051]

---

### [ISSUE-055] Desktop Grid a Pantalla Completa, Red Visual Dinámica y Auto-Reflow
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_055_FEAT`
- **Módulo(s):** Temas / Widgets / Quickshell / Desktop Grid
- **Archivos Afectados:** `core/.config/quickshell/widgets/DesktopGridCanvas.qml`, `core/.config/quickshell/widgets/DesktopGridGuide.qml`, `core/.config/quickshell/widgets/WidgetFrame.qml`
- **Descripción:** Transformar el lienzo del escritorio en una cuadrícula completa modular matemática adaptativa inspirada en iOS / iPadOS / macOS y Ryoku:
  1. **Red Visual Dinámica (`DesktopGridGuide.qml`):** Guía de celdas y retícula visible en modo edición que se activa al arrastrar widgets con proyección en vivo del área de destino (*Ghost Slot / Drop Target*).
  2. **Motor de Colisión y Auto-Reflow:** Detección de solapamiento en coordenadas de celda y desplazamiento reactivo suave (*Push / Swap*) de los widgets en conflicto para evitar superposiciones no deseadas.
  3. **Suavizado Ergonómico del Jiggle:** Reducción de amplitud a ±0.45° a 360ms y congelamiento automático del temblor al posicionar el cursor sobre el control de redimensión o durante la redimensión activa para garantizar estabilidad y precisión.
- **Criterios de Aceptación:**
  1. El lienzo calcula dinámicamente columnas y filas según la resolución de la pantalla.
  2. Al mover un widget sobre otro, el widget en conflicto se desliza suavemente a una celda libre contigua.
  3. La red visual proyecta la silueta de destino del widget arrastrado con sus dimensiones reales (1x1, 2x1 o 2x2).
  4. El temblor jiggle es suave y se detiene automáticamente sobre el handle de resize.
- **Dependencias:** [ISSUE-052], [ISSUE-054]

---

### [ISSUE-056] Pulido y Estandarización de Transiciones y Micro-interacciones de Widgets (transitions-polish & transitions-dev)
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_052_FEAT`
- **Módulo(s):** Temas / Widgets / Quickshell / Animaciones & Micro-interacciones
- **Archivos Afectados:** `core/.config/quickshell/widgets/WidgetFrame.qml`, `core/.config/quickshell/widgets/DesktopGridGuide.qml`, `core/.config/quickshell/widgets/BatteryWidget.qml`, `core/.config/quickshell/widgets/CalendarWidget.qml`, `core/.config/quickshell/widgets/ClockWidget.qml`, `core/.config/quickshell/widgets/FilesWidget.qml`, `core/.config/quickshell/widgets/GitActivityWidget.qml`, `core/.config/quickshell/widgets/HabitTrackerWidget.qml`, `core/.config/quickshell/widgets/MediaWidget.qml`, `core/.config/quickshell/widgets/NdDotBar.qml`, `core/.config/quickshell/widgets/NdDotRing.qml`, `core/.config/quickshell/widgets/NetworkWidget.qml`, `core/.config/quickshell/widgets/PhotoWidget.qml`, `core/.config/quickshell/widgets/SystemResourcesWidget.qml`, `core/.config/quickshell/widgets/TimetableWidget.qml`, `core/.config/quickshell/widgets/WeatherWidget.qml`
- **Descripción:** Auditar y refactorizar exhaustivamente todos los widgets y componentes de Quickshell aplicando las reglas canónicas de las skills `transitions-polish` y `transitions-dev`:
  1. **Estandarización de Duraciones y Curvas Canónicas:**
     - Armonización de micro-interacciones a escala canónica: `--duration-quick` (150ms) para retroalimentación táctil y hover, `--duration-fast` (250ms) para deslizamientos de tarjetas y reposicionamientos del grid, `--duration-medium` (350ms) para medidores y barras de progreso.
     - Reemplazo de easings genéricos o faltantes por curvas canónicas: `Easing.OutCubic` (`--ease-smooth-out`) y `Easing.InOutSine` (`--ease-in-out`).
  2. **Micro-interacciones y Respuesta Háptica Visual (Transitions-dev):**
     - Incorporación de escala táctil al pulsar (`scale: pressed ? 0.985 : 1.0` en tarjetas; `scale: pressed ? 0.88-0.92 : (containsMouse ? 1.05-1.12 : 1.0)` en botones y controles interactivos) con `Behavior on scale` y `ColorAnimation`.
     - Interpolación reactiva con `animPct` / `animValue` en medidores radiales (`NdDotRing`, `BatteryWidget`), barras de puntos (`NdDotBar`) y barras de progreso del sistema para eliminar saltos bruscos ante cambios en tiempo real.
- **Criterios de Aceptación:**
  1. Todos los widgets disponen de respuesta táctil al click y hover suave.
  2. Todas las animaciones respetan estrictamente la escala de tokens de duración y easing canónico.
  3. Quickshell compila y carga sin errores ni advertencias de sintaxis QML.
- **Dependencias:** [ISSUE-054], [ISSUE-055]

---

### [ISSUE-057] Sincronización de Celda por Centro, Supresión de Retícula y Dwell Timer estilo iOS en Desktop Grid
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_052_FEAT`
- **Módulo(s):** Temas / Widgets / Quickshell / Desktop Grid
- **Archivos Afectados:** `core/.config/quickshell/widgets/DesktopGridCanvas.qml`, `core/.config/quickshell/widgets/DesktopGridGuide.qml`
- **Descripción:** Corregir fallos de sincronización, origen flotante del aura y superposición múltiple de widgets al reordenar el escritorio:
  1. **Cálculo de Celda por Centro Geométrico:** Refactorización de `xToCol` y `yToRow` para calcular la posición destino basada en el centro exacto del widget (`centerX = px + width / 2.0`), eliminando saltos prematuros o asimétricos al cruzar columnas en widgets medianos (2x1, 2x2).
  2. **Supresión de Retícula y Refinado del Ghost Slot:** Eliminación de la matriz estática de 50 celdas que saturaba la pantalla. Rediseño del `ghostSlot` estilo drop placeholder sutil de iOS / Nothing (sin bordes rojos ni cruces invasivas) y supresión del salto flotante desde `(-1, -1)` al iniciar el arrastre mediante guardas en `Behavior on x/y`.
  3. **Dwell Timer estilo iOS / macOS:** Incorporación de un temporizador de permanencia (`dwellTimer` de 340ms) que evita el desplazamiento errático de widgets situados al pasar de paso sobre ellos; el reflow sólo se dispara si el usuario sostiene deliberadamente el widget sobre una posición ocupada.
  4. **Motor de Reflow Libre de Colisiones con Matriz de Ocupación:** Sustitución de la lógica previa por una matriz virtual de ocupación bidimensional `occ[r][c]`. Implementa el intercambio (*swap*) directo si cabe en el hueco de origen, o reubica ordenadamente cada widget colisionado en celdas contiguas según distancia Manhattan mínima garantizando cero solapamientos o widgets duplicados en la misma celda.
- **Criterios de Aceptación:**
  1. El aura / ghostSlot nace en la posición inicial del widget sin volar desde la esquina de la pantalla.
  2. El aura se reposiciona sincronizadamente con el centro del widget sin saltos prematuros.
  3. La retícula repetitiva de fondo ya no cubre la pantalla innecesariamente.
  4. Los widgets situados no se mueven si el widget arrastrado solo pasa por encima rápidamente; se apartan tras 340ms de permanencia sobre ellos.
  5. Dos o más widgets arrastrados a una misma posición no se superponen ni se montan entre sí.
  6. Quickshell carga limpiamente sin errores sintácticos.
- **Dependencias:** [ISSUE-055], [ISSUE-056]

---

### [ISSUE-058] Corrección de Timeout en Theme Selector y Persistencia del Servicio de Widgets al Cambiar de Tema
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_052_FEAT`
- **Módulo(s):** Temas / Orquestador CLI / Quickshell / Theme Selector
- **Archivos Afectados:** `core/.local/bin/lunita-theme`, `core/.local/bin/lunita-theme-selector`, `core/.local/bin/lunita-quickshell`, `core/.config/quickshell/widgets/WidgetSkin.qml`
- **Descripción:** Corregir el bloqueo/timeout al cambiar de tema por primera vez en `lunita-theme-selector` y garantizar que el servicio de widgets se mantenga en ejecución continua:
  1. **Prevención de Deadlock en Pipes de Subprocess:** Se reemplazó la espera ciega con `proc.poll()` en `lunita-theme-selector` por hilos lectores de streaming concurrente para `stdout` y `stderr`. Esto evita que el buffer del pipe de 64KB del kernel se sature y congele a `lunita-theme apply`, eliminando el falso timeout de 20s. Se amplió además el umbral de seguridad a 35s.
  2. **Optimización de Escaneo de Directorios (400x más rápido en frío):** En `clean_legacy_links` de `lunita-theme`, se limitó el escaneo de `.local/share` exclusivamente a las carpetas donde Lunita-Dots instala activos (`fonts`, `icons`, `applications`, `themes`, `user-places.xbel`), evitando recorrer cientos de miles de archivos de Steam, Wine o Flatpaks en frío.
  3. **Blindaje de Concurrencia (Flock):** Se incorporó un archivo de bloqueo `/tmp/lunita_theme_apply.lock` en `cmd_apply` para evitar que dos procesos de cambio de tema compitan entre sí y maten las instancias de Quickshell en segundo plano.
  4. **Persistencia y Resiliencia del Servicio de Widgets:**
     - Se eliminó la carpeta residual vacía `themes/macos-theme/.config/quickshell/widgets/` que provocaba que GNU Stow creara un enlace a un directorio sin `shell.qml`.
     - Se reforzó `start_component` en `lunita-quickshell` para validar la existencia física de `shell.qml` antes de invocar el daemon, con fallback automático a `core/.config/quickshell/widgets/shell.qml`.
     - Se aseguró en `cmd_restart` la verificación activa y levantamiento garantizado del daemon de `widgets`.
     - En `WidgetSkin.qml` se condicionó la carga de la fuente NDOT 47 exclusivamente a temas NothingOS, eliminando advertencias en otros temas.
- **Criterios de Aceptación:**
  1. `lunita-theme-selector` aplica temas de forma ágil sin lanzar el error "El proceso tardó demasiado en aplicar el tema".
  2. El servicio de widgets permanece activo (`lunita-quickshell status` reporta `widgets: Activo`) tras alternar entre temas.
  3. No existen condiciones de carrera entre llamadas concurrentes a `lunita-theme apply`.
  4. La sintaxis de Bash, Python y QML pasa todas las validaciones sin errores.
- **Dependencias:** [ISSUE-057]

### [ISSUE-059] Rediseño integral y autónomo de los Widgets de Escritorio en Modern-Win11-Theme
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_059_REFACTOR`
- **Módulo(s):** Modern-Win11-Theme / Widgets (Todos los componentes QML)
- **Archivos Afectados:** `core/.config/quickshell/widgets/WidgetSkin.qml`, `core/.config/quickshell/widgets/ClockWidget.qml`, `core/.config/quickshell/widgets/BatteryWidget.qml`, `core/.config/quickshell/widgets/WeatherWidget.qml`, `core/.config/quickshell/widgets/TimetableWidget.qml`, `core/.config/quickshell/widgets/CalendarWidget.qml`, `core/.config/quickshell/widgets/FilesWidget.qml`, `core/.config/quickshell/widgets/PhotoWidget.qml`, `core/.config/quickshell/widgets/HabitTrackerWidget.qml`, `core/.config/quickshell/widgets/SystemResourcesWidget.qml`, `core/.config/quickshell/widgets/NetworkWidget.qml`, `core/.config/quickshell/widgets/MediaWidget.qml`, `core/.config/quickshell/widgets/GitActivityWidget.qml`, `themes/modern-win11-theme/theme.json`, `core/.local/bin/lunita-palette-sync`, `TODO.md`
- **Descripción:** Rediseño integral de todos los widgets de escritorio existentes para el tema `Modern-Win11-Theme`. Se aplicó una dirección visual cohesiva de Fluent Design moderno (Windows 11) con superficies Mica/Acrylic translúcidas calibradas, radios estandarizados (10px en tarjeta exterior, 6px en controles internos), tipografía Segoe UI Variable y paleta cromática semántica Fluent (azul `#0078D4`, teal `#00B7C3`, púrpura `#8764B8`, naranja `#F7630C`, verde `#107C41`, amarillo Sticky Notes `#FCE100` y acento de error `#E81123`).
- **Directrices de Diseño y Adaptación de Skills (CSS ➔ QML):**
  1. **`/anti-slop-frontend`:** Eliminación de gradientes planos saturados o fondos genéricos. Bordes sutiles de 1px con refracción sutil, jerarquía estricta y superficies Mica/Acrylic de alta fidelidad.
  2. **`/ui-ux-pro-max`:** Jerarquía clara, métricas prominentes con Segoe UI Variable Display / Bold, etiquetas de metadatos atenuadas, paddings proporcionales y layouts Bento en reloj y batería.
  3. **`/design-taste-frontend`:** Composición Bento en widgets compactos, medianos y grandes. Selector de dispositivos Bluetooth/periféricos en batería con indicadores de color, sticky notes con franja de color superior, monitor de recursos con barras calibradas y reproductor multimedia con acento Fluent.
  4. **`/transitions-dev`:** Micro-interacciones de 150ms-250ms con curvas `Easing.OutCubic` en `Behavior on scale` para mouse presses, `Behavior on width` en progress bars, y transiciones de color en botones e interruptores interactivos.
- **Criterios de Aceptación:**
  1. El trabajo se desarrolla y confirma en la rama `ISSUE_059_REFACTOR`.
  2. Todos los widgets del tema `Modern-Win11-Theme` presentan un lenguaje visual cohesivo, original y de nivel de producción, libre de estética genérica ("AI Slop").
  3. Las propiedades visuales y animaciones están implementadas en QML puro y válido sin romper la ingesta de datos ni la persistencia de posiciones del lienzo (`DesktopGridCanvas`).
- **Dependencias:** Ninguna

---

### [ISSUE-060] Corrección de Autostart de Widgets y Resolución de Bloqueo Concurrente (Flock Leak) en Cambio de Tema
- **Estado:** COMPLETADO [x]
- **Prioridad:** ALTA
- **Rama Requerida:** `ISSUE_059_REFACTOR`
- **Módulo(s):** Core / Widgets / Quickshell / Theme Selector / Lunita-Theme
- **Archivos Afectados:** `core/.config/quickshell/widgets/ClockWidget.qml`, `core/.config/quickshell/widgets/PhotoWidget.qml`, `core/.config/quickshell/widgets/BatteryWidget.qml`, `core/.local/bin/lunita-quickshell`, `core/.local/bin/lunita-theme`, `core/.local/bin/lunita-theme-selector`, `core/.local/bin/lunita-widgets-manager`
- **Descripción:** Corrección de los dos fallos reportados en el inicio de widgets y el cambio continuo de temas:
  1. **Autostart y Carga de Widgets:** La adición reciente de componentes Fluent introdujo el uso de `RowLayout` y `ColumnLayout` en `ClockWidget.qml` y `PhotoWidget.qml` sin importar `QtQuick.Layouts`, provocando que Quickshell fallara silenciosamente al inicializar la configuración de widgets en el arranque (`autostart.lua`). Se incorporó el `import QtQuick.Layouts` faltante, se resolvieron las referencias de ámbito en `BatteryWidget.qml`, y se agregó un mecanismo de verificación y reintento en `lunita-quickshell cmd_start`.
  2. **Bloqueo Concurrente y Fuga de File Descriptor (Flock Leak):** En `lunita-theme apply`, el bloqueo `flock` sobre el descriptor de archivo 200 era heredado por los procesos hijos y daemons en segundo plano (incluidas las instancias de Quickshell). Al finalizar `lunita-theme`, los daemons retenían el descriptor abierto impidiendo que el kernel liberara el bloqueo sobre `/tmp/lunita_theme_apply.lock`, lo que provocaba que cualquier cambio subsecuente de tema se bloqueara indefinidamente ("Ya hay una aplicación de tema en curso"). Se implementó el cierre forzado del descriptor (`200>&-`) en todas las llamadas a procesos en segundo plano y subshells, timeout de 10s con `flock -w 10`, registro de PID, trap de limpieza (`cleanup_theme_lock`) y liberación explícita antes de salir.
  3. **Robustez en la GUI de Selección de Temas:** En `lunita-theme-selector`, se corrigió la evaluación de timeout y errores, garantizando que procesos colgados sean terminados limpiamente y que los fallos reales se reporten de forma fidedigna. En `lunita-widgets-manager`, se delegó el reinicio de widgets a `lunita-quickshell` asegurando la correcta inicialización del entorno Wayland.
- **Criterios de Aceptación:**
  1. El daemon de widgets arranca sin errores de QML y se muestra activo al reiniciar o iniciar sesión.
  2. Es posible cambiar de tema múltiples veces consecutivas tanto desde la terminal como desde `lunita-theme-selector` sin bloqueos ni tiempos muertos.
  3. No se filtran descriptores de archivo de bloqueo a los demonios de Quickshell.
  4. Todas las validaciones de sintaxis (Bash, Python, QML) pasan con 0 errores.
- **Dependencias:** [ISSUE-059]