import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: root

    required property var barState
    signal navigateToPage(int pageIndex)

    spacing: 12
    implicitWidth: 846
    implicitHeight: 298

    // ── Row 1: Player (388px) + Weather (188px) + Toggles (Fill) ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        PlayerCard {
            barState: root.barState
            Layout.preferredWidth: 388
            Layout.preferredHeight: 166
        }

        WeatherCard {
            barState: root.barState
            Layout.preferredWidth: 188
            Layout.preferredHeight: 166
        }

        TogglesGrid {
            barState: root.barState
            Layout.fillWidth: true
            Layout.preferredHeight: 166
        }
    }

    // ── Row 2: Sliders (388px) + System Stats Sparklines (Fill) ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        SlidersCard {
            barState: root.barState
            Layout.preferredWidth: 388
            Layout.preferredHeight: 120
        }

        StatsRow {
            barState: root.barState
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            onNavigateToPage: page => root.navigateToPage(page)
        }
    }
}
