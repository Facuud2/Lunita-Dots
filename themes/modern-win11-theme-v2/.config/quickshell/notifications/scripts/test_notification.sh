#!/usr/bin/env bash
# ==============================================================================
# 🪟 Windows 11 Fluent Notifications Test Script for Lunita-Dots
# ==============================================================================

TYPE="${1:-whatsapp}"

case "$TYPE" in
    whatsapp)
        notify-send \
            -a "WhatsApp" \
            -u normal \
            "WhatsApp" \
            "You may have new messages" \
            -A "open=Abrir" \
            -A "dismiss=Descartar"
        ;;
    spotify)
        notify-send \
            -a "Spotify" \
            -u normal \
            "Reproduciendo ahora" \
            "Daft Punk - Instant Crush" \
            -A "pause=Pausar"
        ;;
    firefox)
        notify-send \
            -a "Firefox" \
            -u normal \
            "Descarga completada" \
            "Lunita-Dots-Release-v2.0.tar.gz se descargó con éxito." \
            -A "open=Abrir carpeta"
        ;;
    discord|telegram)
        notify-send \
            -a "Discord" \
            -u normal \
            "Dev Community" \
            "Alguien te mencionó en #general: 'Revisa el PR de Quickshell'" \
            -A "reply=Responder"
        ;;
    system|concentracion)
        notify-send \
            -a "Sistema" \
            -u critical \
            "Asistente de concentración" \
            "Tu sesión de concentración de 30 minutos ha finalizado."
        ;;
    *)
        notify-send \
            -a "Sistema" \
            -u normal \
            "Notificación" \
            "$TYPE"
        ;;
esac
