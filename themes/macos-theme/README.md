# 🍎 Tema: macOS 27 (Lunita-Dots)

Tema réplica ultra-fiel inspirado en el sistema de diseño **macOS 27 (Liquid Glass & Apple Cupertino)**, adaptado para el ecosistema modular de Lunita-Dots en Hyprland y Wayland.

---

## 🎯 Objetivos de Diseño
- **Barra Superior Adaptable**: Soporte nativo para Tema Claro (*Light Theme*) y Tema Oscuro (*Dark Theme*) con Liquid Glass dinámico, tintado vectorial de íconos en tiempo real y menú global.
- **Centro de Control**: Control Center interactivo completo con sliders de brillo/volumen estilo Apple y botón de alternancia rápida Claro / Oscuro.
- **Dock Flotante**: Dock estilo macOS con magnificación fluida y esquinas redondeadas de 24px.
- **Ventanas y Efectos**: Físicas Core Animation / SwiftUI con curvas Bezier elásticas, bordes redondeados a 16px, desenfoque Kawase profundo de 3 pasadas y sombras ambientales difusas (35px).
- **Esquema de Colores Cupertino**: 100% nativo y libre de Matugen, utilizando la paleta oficial de Apple (Cupertino Blue, System Gray, Frosted Glass, Vibrant Light/Dark).

---

## 🧩 Estado de los Componentes
| Componente | Implementación Base | Estado |
| :--- | :--- | :--- |
| **Barra Superior** | Quickshell (QML) | Frosted Glass adaptativo Claro/Oscuro con tintado SVG |
| **Centro de Control** | Quickshell (QML) | Controles interactivos con toggle Dark Mode |
| **Notificaciones** | Quickshell (QML) | Banners macOS Glass con botón "Options ▾", dropdown interactivo y auto-dismiss |
| **Dock** | Quickshell (QML) | Dock con magnificación fluida |
| **Spotlight** | Quickshell (QML) | Búsqueda global, calculadora y lanzador rápido |
| **Compositor** | Hyprland (Lua) | Físicas Apple SwiftUI, bordes 16px, sombras difusas |
| **Terminal** | Kitty | Paleta Cupertino macOS con soporte claro/oscuro |
| **Pantalla de Bloqueo** | Hyprlock / Prelock | Acabado Apple Glass con tipografía SF Pro |
