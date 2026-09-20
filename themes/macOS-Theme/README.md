# 🍏 Tema 2: macOS Theme (Golden Gate Edition)

Ecosistema visual inspirado en el diseño y fluidez de **macOS 27 Golden Gate**, diseñado para **Lunita-Dots** en Hyprland.

---

## 💎 Componentes Principales

### 1. Dock Flotante de Cristal (AGS v2 / Astal / TypeScript)
- **Platter**: Bandeja flotante de cristal *frosted glass* (`rgba(26, 26, 32, 0.48)`), con borde hairline de 1px (`rgba(255, 255, 255, 0.16)`), reflejo superior sutil y sombra estructural difusa.
- **Radios Concéntricos**: `border-radius: 24px` para el Platter base y `border-radius: 14px` para las celdas squircle de las aplicaciones.
- **Status Indicator**: Pequeño punto indicador luminoso (blanco con resplandor) centrado debajo de cada aplicación que cuenta con ventanas abiertas en Hyprland.
- **Divider**: Separador vertical sutil que divide las aplicaciones ancladas de las aplicaciones activas no ancladas y la papelera.
- **Running Unpinned Apps**: Sección dinámica reactiva que muestra las aplicaciones abiertas que no forman parte de la barra fija.
- **Papelera (Trash)**: Icono reactivo en el extremo derecho con conteo de elementos y enlace a `trash:///`.
- **Reglas Wayland / Hyprland**: Ventana flotante (`exclusivity: IGNORE`, `layer: TOP`, `anchor: BOTTOM`, margen inferior de 10px) con desenfoque profundo mediante `layerrule = blur, macos-dock`.

---

## 🛠️ Activación del Tema

Para aplicar este tema dentro del ecosistema Lunita-Dots:

```bash
lunita-theme apply macOS-Theme
```
