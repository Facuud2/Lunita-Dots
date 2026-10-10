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
- **Estado:** PENDIENTE
- **Prioridad:** ALTA
- **Módulo(s):** Repositorio / Git / Temas
- **Archivos Afectados:** `.gitignore`, `themes/lunita-default/.config/eww/scripts/__pycache__/`, `themes/lunita-default/.config/quickshell/bar/Battery.qml.orig`, `.lunita-theme`
- **Descripción:** Desvincular del tracking de Git los archivos compilados (`.pyc`), residuos de edición (`.orig`) y el estado mutable local (`.lunita-theme`), asegurando que `.gitignore` los descarte de forma estricta.
- **Criterios de Aceptación:**
  1. `git ls-files | grep -E '\.pyc$|\.orig$|\.lunita-theme$'` retorna vacío.
  2. El árbol de trabajo no trackea artefactos efímeros.
- **Dependencias:** [ISSUE-000]

---

### [ISSUE-002] Purgado Definitivo del Código Huérfano de AGS v2
- **Estado:** PENDIENTE
- **Prioridad:** MEDIA
- **Módulo(s):** Temas / `lunita-default`
- **Archivos Afectados:** `themes/lunita-default/.config/ags/`
- **Descripción:** Eliminar completamente la carpeta legacy de AGS (`themes/lunita-default/.config/ags/`) para reducir el peso del repositorio, dado que Quickshell reemplazó esta funcionalidad y ya está excluido por Stow.
- **Criterios de Aceptación:**
  1. La carpeta `themes/lunita-default/.config/ags` es removida del repositorio.
  2. `lunita-theme` y Quickshell continúan operando sin referencias rotas.
- **Dependencias:** [ISSUE-000]

---

### [ISSUE-003] Dinamización de Marcadores de Usuario mediante XDG
- **Estado:** PENDIENTE
- **Prioridad:** ALTA
- **Módulo(s):** Temas / GTK / Qt / Stow
- **Archivos Afectados:** `themes/macOS-Theme/.config/gtk-3.0/bookmarks`, `themes/Modern-Win11-Theme/.config/gtk-3.0/bookmarks`, `themes/*/user-places.xbel`, `core/.local/bin/lunita-theme`
- **Descripción:** Reemplazar las rutas fijas (`/home/facuud2/...`) por generación dinámica basada en utilidades XDG (`xdg-user-dir`) durante la aplicación del tema o mediante plantillas dinámicas, evitando roturas en instalaciones de otros usuarios.
- **Criterios de Aceptación:**
  1. No existen referencias hardcodeadas a `/home/facuud2` en los archivos versionados de marcadores.
  2. Al ejecutar `lunita-theme apply`, los marcadores apuntan a las carpetas XDG reales del usuario activo.
- **Dependencias:** [ISSUE-001]
