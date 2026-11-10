import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: root

    required property var barState
    signal navigateToPage(int pageIndex)

    spacing: 12
    implicitWidth: 830
    implicitHeight: 300

    // ── Row 1: Player + Weather + Toggles ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        PlayerCard {
            barState: root.barState
            Layout.preferredWidth: 340
            Layout.preferredHeight: 168
        }

        WeatherCard {
            barState: root.barState
            Layout.preferredWidth: 180
            Layout.preferredHeight: 168
        }

        TogglesGrid {
            barState: root.barState
            Layout.fillWidth: true
            Layout.preferredHeight: 168
        }
    }

    // ── Row 2: Sliders + System Stats ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        SlidersCard {
            barState: root.barState
            Layout.preferredWidth: 340
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
