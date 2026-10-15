# 🔮 Visión Estratégica y Backlog Técnico (BACKLOG.md)

Este documento contiene el inventario de requerimientos futuros, refactorizaciones, optimizaciones y deuda técnica de **Lunita-Dots**.

**Nota de Gobernanza:** Este archivo es gestionado y priorizado por el operador humano (gestor del proyecto). El agente no debe promover tareas a `TODO.md` de manera autónoma sin autorización explícita.

---

## 🏗️ 1. Infraestructura y Automatización

### [BACKLOG-INFRA-01] Servidor MCP Local de Lunita-Dots
- **Objetivo:** Construir un servidor Model Context Protocol en Python para proveer herramientas de introspección, verificación de enlaces Stow y consulta de manifiestos temáticos a los agentes de IA.
- **Alcance:**
  - Herramientas de solo lectura (`lunita_theme_list`, `lunita_theme_info`, `lunita_check_syntax`).
  - Operaciones controladas bajo confirmación humana.
- **Complejidad:** Media.

### [BACKLOG-INFRA-02] Pipeline Local de Validación y Linters (Sanity Check Hook)
- **Objetivo:** Crear un script unificado `sanity-check.sh` o hook pre-commit que verifique simultáneamente:
  - `bash -n` y `shellcheck` en todos los ejecutables de `core/.local/bin/`.
  - `luac -p` en módulos de `core/.config/hypr/modules/`.
  - `python3 -m py_compile` y `ruff` en scripts Python.
  - Validación de esquemas en todos los `theme.json`.
- **Complejidad:** Baja.

---

## 🎨 2. Tematización y Ecosistema Quickshell

### [BACKLOG-THEME-01] Desacople Completo de Plantillas y Hooks Matugen
- **Objetivo:** Centralizar y estandarizar cómo Matugen interactúa con Quickshell en `lunita-default` frente a temas que no usan Matugen (`macOS-Theme`, `Modern-Win11-Theme`).
- **Complejidad:** Media.

### [BACKLOG-THEME-02] Unificación de Widgets QML entre Temas
- **Objetivo:** Refactorizar los widgets de Quickshell (`widgets/scripts/`) para que compartan servicios subyacentes comunes en `core/` y solo varíe la capa estética QML en cada tema.
- **Complejidad:** Alta.

### [BACKLOG-THEME-03] Centralización y Deduplicación del Selector Hyprquickpaper
- **Objetivo:** Hyprquickpaper se encuentra actualmente triplicado de forma idéntica en `themes/lunita-default/`, `themes/macOS-Theme/` y `themes/Modern-Win11-Theme/` ocupando espacio redundante. Extraerlo como paquete compartido en `core/` o enlazarlo simbióticamente mediante Stow para evitar dispersión de mantenimiento.
- **Complejidad:** Baja.

### [BACKLOG-THEME-04] Optimización de Caché Asíncrona y Miniaturas de Video en Hyprquickpaper
- **Objetivo:** En `cache.sh`, la generación masiva de thumbnails de vídeo con `ffmpeg` puede saturar I/O si hay carpetas con múltiples clips. Implementar throttle y límite de concurrencia de workers en segundo plano y fallback visual mientras `magick`/`ffmpeg` completan el thumbnail.
- **Complejidad:** Media.

### [BACKLOG-THEME-05] Disparadores e Integración de Widgets en Escritorio para Lunita-Default y Modern-Win11
- **Objetivo:** Proveer controles visuales directos (botones dedicados o menú contextual de configuración) para invocar el gestor de widgets (`lunita-widgets-manager`) y alternar los widgets de escritorio (`lunita-widgets-toggle`) tanto en `lunita-default` como en `modern-win11-theme`, emulando la paridad funcional existente en `macOS-Theme`.
- **Alcance y Características Técnicas:**
  - **Lunita-Default (Dynamic Island / Barra Superior):** Integrar un botón dedicado de Widgets en la barra superior o dentro del menú expandido de la Dynamic Island con soporte para click izquierdo (conmutar visibilidad de widgets en el escritorio vía `lunita-widgets-toggle`) y click derecho (abrir el configurador interactivo `lunita-widgets-manager`).
  - **Modern-Win11-Theme (Dock / Bandeja del Sistema):** Adaptar el botón de widgets existente en la bandeja de tareas (`TrayPlatter.qml` / `dock`) o añadir acceso rápido en la barra/dock para que el click izquierdo active o muestre los widgets del escritorio y el click secundario (o botón de configuración de widgets) dispare `lunita-widgets-manager` en lugar de únicamente abrir el app launcher.
  - **Capa de Widgets de Escritorio en Ambos Temas:** Asegurar que los componentes de presentación QML de widgets puedan desplegarse anclados al layer `Background` o `Bottom` del escritorio en `lunita-default` y `modern-win11-theme`, consumiendo los servicios unificados de `core/`.
- **Complejidad:** Media.

---

## ⚙️ 3. Subproyectos Nativos y C++

### [BACKLOG-NATIVE-01] Automatización de Compilación Segura para Prelock y Tokri
- **Objetivo:** Añadir tareas de verificación de dependencias de build (`raylib`, `qt6-base`, `cmake`) que detecten si los binarios están presentes en `~/.local/bin` o deben compilarse.
- **Complejidad:** Media.

---

## 🔒 4. Seguridad y Robustez

### [BACKLOG-SEC-01] Manejo Estricto de Errores en Scripts Críticos Bash
- **Objetivo:** Auditar todos los scripts de `core/.local/bin/` y añadir banderas `set -euo pipefail` asegurando que ningún fallo intermedio quede enmascarado.
- **Complejidad:** Media.
