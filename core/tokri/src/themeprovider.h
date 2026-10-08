#ifndef THEMEPROVIDER_H
#define THEMEPROVIDER_H

#include <QGuiApplication>
#include <QPalette>
#include <QStyleHints>
#include <QFile>
#include <QDir>

class ThemeProvider
{
public:
    ThemeProvider();

    static QPalette light(){
        QPalette pal;

        // Apple Cupertino Light (Frosted Acrylic)
        pal.setColor(QPalette::Window,          QColor("#F2F2F7"));
        pal.setColor(QPalette::Base,            QColor("#FFFFFF"));
        pal.setColor(QPalette::AlternateBase,   QColor("#E5E5EA"));
        pal.setColor(QPalette::Button,          QColor("#E5E5EA"));

        // Text
        pal.setColor(QPalette::WindowText,      QColor("#1D1D1F"));
        pal.setColor(QPalette::Text,            QColor("#1D1D1F"));
        pal.setColor(QPalette::ButtonText,      QColor("#1D1D1F"));
        pal.setColor(QPalette::PlaceholderText, QColor("#86868B"));
        pal.setColor(QPalette::BrightText,      QColor("#FFFFFF"));

        // Borders
        pal.setColor(QPalette::Light,           QColor(0, 0, 0, 15));
        pal.setColor(QPalette::Midlight,        QColor(0, 0, 0, 25));
        pal.setColor(QPalette::Mid,             QColor(0, 0, 0, 35));
        pal.setColor(QPalette::Dark,            QColor(0, 0, 0, 60));
        pal.setColor(QPalette::Shadow,          QColor(0, 0, 0, 80));

        // Selection (Apple Cupertino Blue)
        pal.setColor(QPalette::Highlight,       QColor("#007AFF"));
        pal.setColor(QPalette::HighlightedText, QColor("#FFFFFF"));
        pal.setColor(QPalette::Accent,          QColor("#007AFF"));

        // Links
        pal.setColor(QPalette::Link,            QColor("#007AFF"));
        pal.setColor(QPalette::LinkVisited,     QColor("#5856D6"));

        return pal;
    }

    static QPalette dark(){
        QPalette pal;

        // Apple Cupertino Dark (Liquid Glass)
        pal.setColor(QPalette::Window,          QColor("#1E1C22"));
        pal.setColor(QPalette::Base,            QColor("#141318"));
        pal.setColor(QPalette::AlternateBase,   QColor("#2C2A32"));
        pal.setColor(QPalette::Button,          QColor("#3A3742"));

        // Text
        pal.setColor(QPalette::WindowText,      QColor("#F5F5F7"));
        pal.setColor(QPalette::Text,            QColor("#F5F5F7"));
        pal.setColor(QPalette::ButtonText,      QColor("#F5F5F7"));
        pal.setColor(QPalette::PlaceholderText, QColor("#8E8E93"));
        pal.setColor(QPalette::BrightText,      QColor("#FFFFFF"));

        // Borders
        pal.setColor(QPalette::Light,           QColor(255, 255, 255, 30));
        pal.setColor(QPalette::Midlight,        QColor(255, 255, 255, 20));
        pal.setColor(QPalette::Mid,             QColor(255, 255, 255, 15));
        pal.setColor(QPalette::Dark,            QColor(0, 0, 0, 100));
        pal.setColor(QPalette::Shadow,          QColor(0, 0, 0, 120));

        // Selection (Apple Cupertino Blue)
        pal.setColor(QPalette::Highlight,       QColor("#0A84FF"));
        pal.setColor(QPalette::HighlightedText, QColor("#FFFFFF"));
        pal.setColor(QPalette::Accent,          QColor("#0A84FF"));

        // Links
        pal.setColor(QPalette::Link,            QColor("#0A84FF"));
        pal.setColor(QPalette::LinkVisited,     QColor("#AF52DE"));

        return pal;
    }

    static bool isDark()
    {
        QFile file(QDir::homePath() + "/.config/lunita/color_scheme");
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QString content = QString::fromUtf8(file.readAll()).trimmed().toLower();
            if (content.contains("light"))
                return false;
            if (content.contains("dark"))
                return true;
        }

        if (QGuiApplication::styleHints()) {
            return QGuiApplication::styleHints()->colorScheme() == Qt::ColorScheme::Dark;
        }
        return true;
    }

    static QString currentThemeName()
    {
        QFile file(QDir::homePath() + "/.config/lunita/current_theme");
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QString name = QString::fromUtf8(file.readAll()).trimmed();
            if (!name.isEmpty()) return name;
        }
        return QString();
    }

    static bool isWin11()
    {
        QString th = currentThemeName().toLower();
        return th.contains("win11") || th.contains("windows");
    }

    static QColor accentColor()
    {
        if (isWin11()) {
            return isDark() ? QColor("#4CC2FF") : QColor("#0078D4");
        }
        return isDark() ? QColor("#0A84FF") : QColor("#007AFF");
    }

    static QColor accentHoverColor()
    {
        if (isWin11()) {
            return isDark() ? QColor("#60CDFF") : QColor("#106EBE");
        }
        return isDark() ? QColor("#409CFF") : QColor("#0062CC");
    }

    static int windowCornerRadius()
    {
        return isWin11() ? 10 : 20;
    }

    static QColor windowBgColor()
    {
        if (isWin11()) {
            // Windows 11 Fluent Mica / Dark Acrylic: #1C2028
            return isDark() ? QColor(28, 32, 40, 242) : QColor(243, 243, 243, 244);
        }
        return isDark() ? QColor(36, 33, 40, 235) : QColor(246, 246, 248, 240);
    }

    static QColor windowBorderColor()
    {
        if (isWin11()) {
            return isDark() ? QColor(255, 255, 255, 24) : QColor(0, 0, 0, 22);
        }
        return isDark() ? QColor(255, 255, 255, 38) : QColor(0, 0, 0, 30);
    }

    static QPalette theme()
    {
        return isDark() ? ThemeProvider::dark() : ThemeProvider::light();
    }
};

#endif // THEMEPROVIDER_H
