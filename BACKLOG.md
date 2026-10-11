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
