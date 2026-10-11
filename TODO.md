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