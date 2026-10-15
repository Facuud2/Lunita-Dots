#!/usr/bin/env bash
# ==============================================================================
# 🍎 macOS Notifications Test Script for Lunita-Dots
# Generates authentic macOS sample notifications matching Apple UI
# ==============================================================================

TYPE="${1:-brunch}"

case "$TYPE" in
    brunch|reminder)
        notify-send \
            -a "Reminders" \
            -u critical \
            "Brunch" \
            "Today, 9:45 AM" \
            -A "complete=Mark as Completed" \
            -A "hour=Remind Me in an Hour" \
            -A "afternoon=Remind Me This Afternoon" \
            -A "tomorrow=Remind Me Tomorrow"
        ;;
    facetime)
        notify-send \
            -a "FaceTime" \
            -u critical \
            "FaceTime Grandma" \
            "Today, 9:41 AM" \
            -A "complete=Mark as Completed" \
            -A "hour=Remind Me in an Hour" \
            -A "afternoon=Remind Me This Afternoon"
        ;;
    fitness)
        notify-send \
            -a "Fitness" \
            -u normal \
            "Move goal achieved" \
            "Joe, you closed your Move ring, and it's not even noon yet. Well done."
        ;;
    medication)
        notify-send \
            -a "Health" \
            -u critical \
            "Medications Reminder" \
            "Time to log your 9:30 AM medications" \
            -A "log=Log All as Taken" \
            -A "snooze=Remind in 30 Minutes"
        ;;
    messages|imessage)
        notify-send \
            -a "Messages" \
            -u normal \
            "Sarah Jenkins" \
            "Hey! Are we still meeting for lunch at 1:00 PM?" \
            -A "reply=Reply" \
            -A "read=Mark as Read"
        ;;
    mail)
        notify-send \
            -a "Mail" \
            -u normal \
            "GitHub Notifications" \
            "[Lunita-Dots] Pull Request #42 approved by reviewer" \
            -A "view=View on GitHub" \
            -A "archive=Archive"
        ;;
    *)
        notify-send \
            -a "System" \
            -u normal \
            "Notification" \
            "$TYPE"
        ;;
esac
