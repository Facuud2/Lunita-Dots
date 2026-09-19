# Qylock Orbital - Custom SDDM Theme (Qt6)

Tema personalizado para el gestor de pantalla **SDDM** (Qt6) basado en la estética minimalista y elegante del showcase de Qylock (minuto 1:59 a 2:07).

## Características

- **Video animado en bucle:** Trae por defecto el video original de Vertin (*Reverse: 1999*) en el balcón con el viento meciendo su cabello.
- **Reloj Orbital (Superior Derecha):**
  - Hora y minuto en tipografía romana estilizada (`Cinzel-Bold`).
  - Anillo orbital en 360° con satélite (`traveler`) rotando en tiempo real.
  - Día de la semana en acentos dorados (`#c9a063`) y fecha con divisor fino.
- **Identidad & Entrada de Contraseña (Inferior Derecha):**
  - Nombre de usuario en mayúsculas serif con menú desplegable para cambiar de usuario.
  - Caracteres de contraseña estilo destello (`✦ ✦ ✦ ✦ ✦`).
  - Cursor parpadeante y botón de acceso romboidal.
  - Micro-animación de escala ("pulse") al tipear.
- **Sesión y Energía (Inferior Izquierda):**
  - Selector de entorno de escritorio (Hyprland, Wayland, etc.).
  - Botones de REBOOT y SHUTDOWN con transiciones suaves.
- **Compatibilidad:** 100% nativo para **Qt6** y **SDDM 0.21+** en Wayland / X11.

---

## Cómo Probar el Tema (Sin reiniciar)

Para ver el tema en una ventana de prueba directamente en tu escritorio actual:

```bash
cd ~/sddm-themes/qylock-orbital
./preview.sh
```

---

## Cómo Cambiar el Fondo (por ejemplo, a un personaje de Genshin Impact)

El tema soporta tanto videos (`.mp4`, `.webm`, `.mkv`) como imágenes estáticas (`.png`, `.jpg`):

1. Copia tu video o imagen en esta carpeta (por ejemplo, `genshin_furina.mp4`).
2. Abre `theme.conf`:
   ```ini
   [General]
   background="genshin_furina.mp4"
   accentColor="#c9a063"
   accentDim="#8c6d45"
   textColor="#fdfaf2"
   ```
3. Ejecuta `./preview.sh` para verificar los cambios.

---

## Cómo Instalarlo en el Sistema (SDDM)

Para que se convierta en la pantalla de inicio de sesión de tu PC:

```bash
cd ~/sddm-themes/qylock-orbital
./install.sh
```

El script copiará los archivos a `/usr/share/sddm/themes/qylock-orbital` y activará el tema en `/etc/sddm.conf.d/theme.conf`.
