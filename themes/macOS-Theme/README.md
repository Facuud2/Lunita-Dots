# 🍎 Tema: macOS Sonoma (Lunita-Dots)

Tema réplica inspirado en la interfaz y experiencia de usuario de **macOS Sonoma / Sequoia**, adaptado al ecosistema modular de Lunita-Dots en Hyprland y Wayland.

---

## 🎯 Objetivos de Diseño
- **Barra Superior**: Menú global con logo de manzana/luna, menús de aplicación y panel de control (Control Center).
- **Dock Inferior**: Dock flotante con efectos de amplificación (magnification) y accesos directos.
- **Ventanas y Efectos**: Animaciones Bezier ultra fluidas y desenfoque *frosted glass* característico de macOS.
- **Esquema de Colores**: Sincronización continua mediante Matugen conservando la calidez visual de Apple.

---

## 🧩 Estado de los Componentes
| Componente | Implementación Base | Estado |
| :--- | :--- | :--- |
| **Barra Superior** | AGS GTK4 | Base funcional Lunita, lista para adaptar a menú macOS |
| **Dock** | Planned (AGS / Quickshell) | En desarrollo |
| **Compositor** | Hyprland (Lua) | Curvas Bezier y reglas activas |
| **Lanzador** | AGS App Launcher / Spotlight | Funcional |
| **Terminal** | Kitty | Estilo macOS dark |
| **Gestor de Archivos** | Dolphin | Frosted glass y vista Finder |
