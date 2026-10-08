import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell

FocusScope {
    id: lockViewRoot
    anchors.fill: parent
    focus: true

    required property var lockState

    // ── 1. Wallpaper Background with subtle dark overlay ──
    Image {
        id: bgWallpaper
        anchors.fill: parent
        source: lockState.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.04, 0.08, 0.38)
    }

    // ── 2. Top Right Status Bar (Network, Bluetooth, Battery) ──
    RowLayout {
        anchors.top: parent.top
        anchors.topMargin: 24
        anchors.right: parent.right
        anchors.rightMargin: 28
        spacing: 8
        z: 40

        Rectangle {
            implicitHeight: 32
            implicitWidth: 38
            radius: 16
            color: Qt.rgba(0.08, 0.12, 0.20, 0.55)
            border.color: Qt.rgba(1, 1, 1, 0.18)
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: lockState.netIcon
                font.family: "JetBrainsMono Nerd Font Propo, SF Mono, sans-serif"
                font.pixelSize: 15
                color: "#ffffff"
            }
        }

        Rectangle {
            implicitHeight: 32
            implicitWidth: 38
            radius: 16
            color: Qt.rgba(0.08, 0.12, 0.20, 0.55)
            border.color: Qt.rgba(1, 1, 1, 0.18)
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: lockState.btIcon
                font.family: "JetBrainsMono Nerd Font Propo, SF Mono, sans-serif"
                font.pixelSize: 15
                color: lockState.btIcon === "󰂯" ? "#007aff" : "#ffffff"
            }
        }

        Rectangle {
            visible: lockState.isLaptopBattery
            implicitHeight: 32
            implicitWidth: batRow.implicitWidth + 20
            radius: 16
            color: Qt.rgba(0.08, 0.12, 0.20, 0.55)
            border.color: Qt.rgba(1, 1, 1, 0.18)
            border.width: 1

            RowLayout {
                id: batRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: lockState.batIcon
                    font.family: "JetBrainsMono Nerd Font Propo, sans-serif"
                    font.pixelSize: 14
                    color: lockState.isCharging ? "#34c759" : (lockState.batPercent <= 20 ? "#ff3b30" : "#ffffff")
                }

                Text {
                    text: lockState.batPercent + "%"
                    font.family: "SF Pro Display, Space Grotesk, sans-serif"
                    font.weight: Font.Medium
                    font.pixelSize: 12
                    color: "#ffffff"
                }
            }
        }
    }

    // ── 3. Central Cohesive Column (Clock -> Media Card -> Password Prompt) ──
    ColumnLayout {
        id: centralStack
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -20
        spacing: 24
        z: 20

        // ── A. Clock & Date ──
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            Text {
                id: dateText
                Layout.alignment: Qt.AlignHCenter
                text: {
                    let d = new Date();
                    let days = ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"];
                    let months = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];
                    return days[d.getDay()] + " " + d.getDate() + " " + months[d.getMonth()];
                }
                font.family: "SF Pro Display, Space Grotesk, sans-serif"
                font.weight: Font.Medium
                font.pixelSize: 22
                color: Qt.rgba(0.96, 0.97, 1.0, 0.88)

                Timer {
                    interval: 30000
                    running: true
                    repeat: true
                    onTriggered: dateText.text = {
                        let d = new Date();
                        let days = ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"];
                        let months = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];
                        return days[d.getDay()] + " " + d.getDate() + " " + months[d.getMonth()];
                    }
                }
            }

            Text {
                id: timeText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatTime(new Date(), "hh:mm")
                font.family: "SF Pro Display, Space Grotesk, sans-serif"
                font.weight: Font.Bold
                font.pixelSize: 96
                color: "#ffffff"

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
                }
            }
        }

        // ── B. Floating Media Card (Video / Audio Widget) ──
        Rectangle {
            id: mediaCard
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 390
            implicitHeight: 102
            radius: 22
            color: Qt.rgba(0.07, 0.10, 0.16, 0.68)
            border.color: Qt.rgba(1, 1, 1, 0.18)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                // Album Art thumbnail
                Rectangle {
                    Layout.preferredWidth: 74
                    Layout.preferredHeight: 74
                    radius: 12
                    color: Qt.rgba(0.14, 0.18, 0.26, 0.70)
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    border.width: 1
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: lockState.artUrl !== "" ? lockState.artUrl : (lockState.home !== "" ? "file://" + lockState.home + "/.config/hypr/assets/default_cover.png" : "")
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                    }
                }

                // Song Info & Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        text: lockState.trackTitle
                        font.family: "SF Pro Display, Space Grotesk, sans-serif"
                        font.weight: Font.Bold
                        font.pixelSize: 13
                        color: "#ffffff"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: lockState.trackArtist
                        font.family: "SF Pro Display, Space Grotesk, sans-serif"
                        font.weight: Font.Normal
                        font.pixelSize: 11
                        color: Qt.rgba(1, 1, 1, 0.65)
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        spacing: 8

                        // Previous Button
                        Rectangle {
                            implicitWidth: 28
                            implicitHeight: 28
                            radius: 8
                            color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.10)

                            Text {
                                anchors.centerIn: parent
                                text: "󰒮"
                                font.family: "JetBrainsMono Nerd Font Propo, sans-serif"
                                font.pixelSize: 13
                                color: "#ffffff"
                            }

                            MouseArea {
                                id: prevMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: lockState.previousTrack()
                            }
                        }

                        // Play / Pause Button
                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 10
                            color: playMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.28) : Qt.rgba(1, 1, 1, 0.15)

                            Text {
                                anchors.centerIn: parent
                                text: lockState.isPlaying ? "󰏤" : "󰐊"
                                font.family: "JetBrainsMono Nerd Font Propo, sans-serif"
                                font.pixelSize: 15
                                color: lockState.isPlaying ? "#34c759" : "#ffffff"
                            }

                            MouseArea {
                                id: playMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: lockState.togglePlay()
                            }
                        }

                        // Next Button
                        Rectangle {
                            implicitWidth: 28
                            implicitHeight: 28
                            radius: 8
                            color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.10)

                            Text {
                                anchors.centerIn: parent
                                text: "󰒭"
                                font.family: "JetBrainsMono Nerd Font Propo, sans-serif"
                                font.pixelSize: 13
                                color: "#ffffff"
                            }

                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: lockState.nextTrack()
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: lockState.timeProgress
                            font.family: "JetBrainsMono Nerd Font Propo, monospace"
                            font.pixelSize: 10
                            color: Qt.rgba(1, 1, 1, 0.50)
                            visible: lockState.timeProgress !== ""
                        }
                    }
                }
            }
        }

        // ── C. Password Prompt & Input Field ──
        ColumnLayout {
            id: passwordSection
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: lockState.authFailed ? lockState.statusText : "Touch ID or Enter Password"
                font.family: "SF Pro Display, Space Grotesk, sans-serif"
                font.pixelSize: 12
                color: lockState.authFailed ? "#ff453a" : Qt.rgba(1, 1, 1, 0.60)
            }

            Rectangle {
                id: inputPill
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 260
                implicitHeight: 42
                radius: 21
                color: Qt.rgba(0.08, 0.11, 0.18, 0.60)
                border.color: lockState.authFailed ? "#ff453a" : (pwdInput.activeFocus ? "#007aff" : Qt.rgba(1, 1, 1, 0.22))
                border.width: 1

                // Shake Animation on PAM fail
                SequentialAnimation {
                    id: shakeAnim
                    running: lockState.authFailed
                    loops: 1

                    NumberAnimation { target: inputPill; property: "x"; to: inputPill.x - 12; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: inputPill; property: "x"; to: inputPill.x + 12; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: inputPill; property: "x"; to: inputPill.x - 8; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: inputPill; property: "x"; to: inputPill.x + 8; duration: 50; easing.type: Easing.OutQuad }
                    NumberAnimation { target: inputPill; property: "x"; to: inputPill.x; duration: 50; easing.type: Easing.OutQuad }
                }

                TextInput {
                    id: pwdInput
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    echoMode: TextInput.Password
                    font.family: "SF Pro Display, Space Grotesk, sans-serif"
                    font.pixelSize: 14
                    color: "#ffffff"
                    focus: true

                    onAccepted: {
                        if (text.length > 0) {
                            lockState.submitPassword(text);
                            text = "";
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Enter Password"
                        font.family: "SF Pro Display, Space Grotesk, sans-serif"
                        font.pixelSize: 13
                        font.italic: true
                        color: Qt.rgba(1, 1, 1, 0.40)
                        visible: pwdInput.text.length === 0
                    }
                }
            }
        }
    }

    // ── 4. Bottom macOS Style Power Bar ──
    Rectangle {
        id: bottomPowerBar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter
        implicitHeight: 40
        implicitWidth: powerRow.implicitWidth + 28
        radius: 20
        color: Qt.rgba(0.08, 0.12, 0.20, 0.55)
        border.color: Qt.rgba(1, 1, 1, 0.18)
        border.width: 1
        z: 30

        RowLayout {
            id: powerRow
            anchors.centerIn: parent
            spacing: 16

            // Sleep / Suspender
            Rectangle {
                implicitHeight: 28
                implicitWidth: suspRow.implicitWidth + 16
                radius: 14
                color: suspMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                RowLayout {
                    id: suspRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰤄"
                        font.family: "JetBrainsMono Nerd Font Propo, sans-serif"
                        font.pixelSize: 14
                        color: "#f5f5f7"
                    }

                    Text {
                        text: "Suspender"
                        font.family: "SF Pro Display, Space Grotesk, sans-serif"
                        font.pixelSize: 12
                        color: "#f5f5f7"
                    }
                }

                MouseArea {
                    id: suspMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: lockState.suspend()
                }
            }

            // Reboot / Reiniciar
            Rectangle {
                implicitHeight: 28
                implicitWidth: rebootRow.implicitWidth + 16
                radius: 14
                color: rebootMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                RowLayout {
                    id: rebootRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰑓"
                        font.family: "JetBrainsMono Nerd Font Propo, sans-serif"
                        font.pixelSize: 14
                        color: "#f5f5f7"
                    }

                    Text {
                        text: "Reiniciar"
                        font.family: "SF Pro Display, Space Grotesk, sans-serif"
                        font.pixelSize: 12
                        color: "#f5f5f7"
                    }
                }

                MouseArea {
                    id: rebootMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: lockState.reboot()
                }
            }

            // Power Off / Apagar
            Rectangle {
                implicitHeight: 28
                implicitWidth: offRow.implicitWidth + 16
                radius: 14
                color: offMouse.containsMouse ? Qt.rgba(1, 0.23, 0.19, 0.25) : "transparent"

                RowLayout {
                    id: offRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰐥"
                        font.family: "JetBrainsMono Nerd Font Propo, sans-serif"
                        font.pixelSize: 14
                        color: "#ff453a"
                    }

                    Text {
                        text: "Apagar"
                        font.family: "SF Pro Display, Space Grotesk, sans-serif"
                        font.pixelSize: 12
                        color: "#ff453a"
                    }
                }

                MouseArea {
                    id: offMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: lockState.poweroff()
                }
            }
        }
    }

    Component.onCompleted: {
        pwdInput.forceActiveFocus();
    }
}
