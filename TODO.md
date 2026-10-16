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
- **Archivos Afectados:** `themes/macos-theme/.config/quickshell/dock/shell.qml`, `themes/macos-theme/.config/quickshell/dock/DockState.qml`, `themes/macos-theme/.config/quickshell/dock/DockItem.qml`, `themes/macos-theme/.config/quickshell/dock/DockContextMenu.qml`, `themes/macos-theme/.config/quickshell/dock/DockAddAppModal.qml`
- **Descripción:** El estado interactivo del Dock (como la apertura de menús contextuales al hacer clic derecho o estados de hover/activación) se comparte globalmente entre todas las pantallas, provocando que el menú se despliegue simultáneamente en todos los monitores conectados. Se debe encapsular el estado de cada instancia del Dock localmente por monitor (`ShellScreen` / instancia de `PanelWindow`).
- **Criterios de Aceptación:**
  1. Hacer clic derecho sobre un icono del Dock abre el menú contextual únicamente en el monitor donde ocurrió la interacción.
  2. Las animaciones e indicadores de interacción operan de forma independiente en configuraciones multimonitor.
- **Dependencias:** Ninguna

### [ISSUE-023] Integración de System Tray Icons en la barra superior de macOS
- **Estado:** PENDIENTE
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_023_FEAT`
- **Módulo(s):** macOS-Theme / Bar (System Tray)
- **Archivos Afectados:** `themes/macOS-Theme/.config/quickshell/bar/` (Archivos QML)
- **Descripción:** Implementar el contenedor de iconos de bandeja del sistema (`Quickshell.Services.SystemTray`) para procesos en segundo plano dentro de la Status Bar superior. Debe ubicarse inmediatamente a la izquierda del primer icono de control (el botón de acomodar/editar widgets), desplegando cada nuevo icono en dirección hacia la izquierda de la barra.
- **Criterios de Aceptación:**
  1. Los procesos activos en segundo plano (Discord, clientes de red, etc.) renderizan sus iconos en la barra superior.
  2. La fila de iconos crece de derecha a izquierda partiendo desde el límite izquierdo del icono de gestión de widgets.
  3. Soporta interacciones nativas de clic izquierdo y menú contextual (clic derecho) sobre cada icono.
- **Dependencias:** Ninguna

### [ISSUE-024] Posicionamiento de System Tray Icons en barra de tareas de Windows 11
- **Estado:** PENDIENTE
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_024_FEAT`
- **Módulo(s):** Modern-Win11-Theme / Bar-Dock (System Tray)
- **Archivos Afectados:** `themes/Modern-Win11-Theme/.config/quickshell/dock/`, `themes/Modern-Win11-Theme/.config/quickshell/bar/` (Archivos QML)
- **Descripción:** Incorporar los iconos de bandeja del sistema (`SystemTray`) para aplicaciones en segundo plano dentro del área de estado de la barra (donde residen los indicadores de Internet, sonido y batería). Deben posicionarse partiendo inmediatamente a la izquierda del indicador de idioma (`ENG`), apilándose uno al lado del otro hacia la izquierda.
- **Criterios de Aceptación:**
  1. Los iconos del System Tray aparecen alineados horizontalmente a la izquierda del indicador `ENG`.
  2. El flujo visual se expande hacia la izquierda sin solapar ni desplazar erróneamente los módulos centrales.
- **Dependencias:** Ninguna

### [ISSUE-025] Diseño e implementación de Flyout interactivo de Red (Wi-Fi y Ethernet)
- **Estado:** PENDIENTE
- **Prioridad:** ALTA
- **Rama Sugerida:** `ISSUE_025_FEAT`
- **Módulo(s):** Modern-Win11-Theme / Flyouts (Network)
- **Archivos Afectados:** `themes/Modern-Win11-Theme/.config/quickshell/` (Archivos QML de barra/dock y scripts de red)
- **Descripción:** Reemplazar la invocación de GUIs externas básicas de red por un panel flotante (Flyout) nativo en QML con estética Fluent Design, homologado al diseño actual del panel de Sonido/Hora. Debe ser funcionalmente interactivo (integrado vía `nmcli` o backend equivalente) para escanear/conectar redes Wi-Fi y detectar/mostrar explícitamente el estado de la conexión física Ethernet si el equipo está conectado por cable.
- **Criterios de Aceptación:**
  1. Pulsar el icono de red abre el Flyout nativo con el mismo lenguaje visual que el módulo de Sonido/Hora.
  2. Muestra el estado activo de red cableada (Ethernet) cuando existe conexión física.
  3. Permite visualizar redes Wi-Fi disponibles, alternar la antena y conectarse de forma interactiva sin abrir aplicaciones externas.
- **Dependencias:** Ninguna

### [ISSUE-026] Creación de icono y Flyout interactivo de Bluetooth
- **Estado:** PENDIENTE
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_026_FEAT`
- **Módulo(s):** Modern-Win11-Theme / Flyouts (Bluetooth)
- **Archivos Afectados:** `themes/Modern-Win11-Theme/.config/quickshell/` (Archivos QML de barra/dock y scripts Bluetooth)
- **Descripción:** Diseñar e insertar un icono de estado de Bluetooth ubicado inmediatamente a la derecha del indicador `ENG` en la dock bar. Al hacer clic sobre él, debe desplegar un panel interactivo (Flyout) con la misma línea estética del panel de Sonido/Hora para gestionar dispositivos Bluetooth (`bluetoothctl`).
- **Criterios de Aceptación:**
  1. El icono de Bluetooth se renderiza a la derecha de la etiqueta `ENG`.
  2. Al pulsarlo, despliega el Flyout interactivo permitiendo encender/apagar el adaptador Bluetooth y conectar/desconectar dispositivos emparejados.
- **Dependencias:** Ninguna

### [ISSUE-027] Vincular botón "Widgets y Aplicaciones" con la edición de widgets de escritorio
- **Estado:** PENDIENTE
- **Prioridad:** MEDIA
- **Rama Sugerida:** `ISSUE_027_FEAT`
- **Módulo(s):** Modern-Win11-Theme / Dock / Widgets
- **Archivos Afectados:** `themes/Modern-Win11-Theme/.config/quickshell/dock/` (Archivos QML), `core/.local/bin/lunita-widgets-toggle`, `core/.local/bin/lunita-widgets-manager`
- **Descripción:** Conectar la acción del botón "Widgets y Aplicaciones" presente en la dock bar del tema Windows 11 para que invoque el modo de modificación/gestión de los widgets del escritorio.
- **Criterios de Aceptación:**
  1. Hacer clic en el botón "Widgets y Aplicaciones" activa la edición o el panel gestor de los widgets en pantalla de forma directa.
- **Dependencias:** Ninguna