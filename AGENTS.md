# 🌙 Protocolo Operativo y Reglas para Agentes de IA (AGENTS.md)

Este documento define las reglas de conducta, convenciones arquitectónicas, restricciones operativas y procedimientos de validación que rigen a cualquier agente de inteligencia artificial (o desarrollador automatizado) que opere sobre el repositorio **Lunita-Dots**.

---

## 1. Identidad y Arquitectura del Sistema

**Lunita-Dots** es un ecosistema avanzado de dotfiles y entorno de escritorio Wayland orquestado para Arch Linux con Hyprland.

### Principios Fundamentales de la Estructura
- **Estructura GNU Stow:**
  - `core/`: Paquete transversal e inmutable del sistema (Hyprland en Lua, orquestadores CLI en `.local/bin`, SDDM, Prelock, Tokri).
  - `themes/<nombre-tema>/`: Paquetes visuales intercambiables (Quickshell, Kitty, Wlogout, GTK, wallpapers).
- **Fuente de Verdad Temática:**
  - Cada tema cuenta con un manifiesto estricto `theme.json` que declara sus componentes, paleta y tokens de diseño.
  - La barra, menús, dock, OSD y notificaciones están basados en **Quickshell (Qt6/QML)**.
- **Reglas de exclusión:**
  - Cada paquete cuenta con `.stow-local-ignore`. Todo archivo auxiliar, documentación o activo que no deba enlazarse en `$HOME` debe registrarse en dicho archivo.

---

## 2. Restricciones Críticas y Límites de Autonomía (Guardrails)

### ⛔ Prohibición Estricta de Escalada de Privilegios
- **NUNCA** ejecutar comandos con `sudo`, `su` ni privilegios de administrador.
- **NUNCA** invocar gestores de paquetes del sistema (`pacman`, `yay`, `paru`, `apt`, etc.).
- **Protocolo de dependencias:** Si una tarea requiere una herramienta, biblioteca o paquete del sistema que no esté instalado, el agente **debe detenerse inmediatamente**, documentar la necesidad y solicitar la instalación manual al operador humano.

### ⛔ Respeto al Estado Activo del Sistema
- **NUNCA** ejecutar `lunita-theme apply` ni forzar recargas del compositor (`hyprctl reload`) de forma no solicitada en segundo plano.
- Esto previene congelamientos de pantalla, parpadeos de interfaz o interrupción del trabajo del usuario en la sesión gráfica.
- Las recargas solo están permitidas cuando la tarea explícitamente demande una prueba visual y haya sido autorizada.

### ⛔ Prohibición de Rutas Hardcodeadas
- **NUNCA** codificar rutas absolutas de usuario (ej. `/home/facuud2/...`).
- Utilizar siempre variables dinámicas de entorno:
  - En Bash: `$HOME` o variables XDG (`xdg-user-dir`).
  - En Python: `pathlib.Path.home()` o `os.getenv("HOME")`.
  - En Lua: `os.getenv("HOME")`.
  - Marcadores de usuario (GTK bookmarks, `user-places.xbel`): Deben generarse dinámicamente mediante `xdg-user-dir`.

### ⛔ Higiene del Repositorio y Git
- **NUNCA** hacer commit de archivos temporales, cachés o backups (`.pyc`, `__pycache__`, `.bak`, `.orig`, `*~`, `.tmp`).
- Respetar `.gitignore` y `.stow-local-ignore` en todo momento.

---

## 3. Estándares y Convenciones de Código

### Bash (`core/.local/bin/`, scripts de `hypr/`)
- Encabezado estándar: `#!/usr/bin/env bash`.
- Modo estricto obligatorio en scripts nuevos o refactorizados: `set -euo pipefail`.
- Indentación de 4 espacios.
- Funciones modulares con nombres en minúsculas y guiones bajos (`snake_case`).

### Python (`lunita-widgets-manager`, `lunita-palette-sync`, etc.)
- Python 3.10+.
- Uso estricto de `pathlib.Path` para manipulación de rutas.
- Manejo controlado de excepciones con mensajes limpios.
- Evitar dependencias externas no declaradas; priorizar la biblioteca estándar o `gi` (PyGObject).

### Lua (`core/.config/hypr/`)
- Hyprland se configura mediante la API nativa de Lua (`hl.*`).
- Mantener modularidad dentro de `core/.config/hypr/modules/`.
- No alterar configuraciones de hardware (`monitors.lua` específico del usuario).

### QML / Quickshell
- Componentes declarativos limpios.
- Consistencia con los tokens extraídos de `theme.json`.

---

## 4. Validación Pre-Commit Obligatoria

Antes de ejecutar cualquier `git commit`, el agente **DEBE** validar la sintaxis de cada archivo modificado según su lenguaje:

| Tipo de Archivo | Comando de Validación Obligatorio |
| :--- | :--- |
| **Bash** (`.sh` o scripts sin extensión) | `bash -n <ruta-del-archivo>` |
| **Lua** (`.lua`) | `luac -p <ruta-del-archivo>` |
| **Python** (`.py` o scripts sin extensión) | `python3 -m py_compile <ruta-del-archivo>` |
| **JSON** (`.json`) | `python3 -m json.tool <ruta-del-archivo> > /dev/null` |

> [!CAUTION]
> Si cualquiera de las validaciones falla, el agente tiene **estrictamente prohibido** ejecutar el commit. Debe subsanar el error de sintaxis primero.

---

## 5. Convención de Mensajes de Commit

Para preservar la trazabilidad e inmaculada estructura de Git, todo commit debe seguir estrictamente este formato:

```text
{TIPO}: [ISSUE-{$}] Descripción breve del cambio en imperativo
```

### Tipos Permitidos
- `feat`: Nueva funcionalidad o componente.
- `fix`: Corrección de un fallo o error en scripts/configs.
- `refactor`: Reestructuración de código sin alterar comportamiento.
- `docs`: Documentación o guías.
- `chore`: Tareas de mantenimiento, limpieza de archivos o configuración de entorno.
- `style`: Ajustes estéticos, formato o estilos sin cambios lógicos.

### Ejemplos Válidos
- `docs: [ISSUE-000] implementar AGENTS.md, TODO.md y BACKLOG.md`
- `fix: [ISSUE-002] reemplazar rutas estáticas en bookmarks por xdg-user-dir`
- `chore: [ISSUE-001] purgar artefactos cpython y Battery.qml.orig de git`

---

## 6. Dinámica de los Archivos de Gestión: `TODO.md` vs `BACKLOG.md`

- **`AGENTS.md`**: Reglas estáticas y manual de operaciones (este archivo).
- **`TODO.md`**: **Estado inmediato de ejecución.** Mutado autónomamente por la máquina durante el ciclo de trabajo activo. Contiene únicamente las tareas seleccionadas para el sprint en curso.
- **`BACKLOG.md`**: **Visión estratégica a mediano y largo plazo.** Gestionado y priorizado por el operador humano. El agente solo extrae tareas de aquí cuando el operador lo instruye o autoriza.
