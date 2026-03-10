// shell.qml — Quickshell pill bar for XMonad
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            implicitHeight: pill.height + 10
            margins.top: 10
            color: "transparent"
            exclusiveZone: 48

            mask: Region {
                x:      pill.x
                y:      0
                width:  pill.width
                height: pill.height
            }

            // ── THE pill ─────────────────────────────────────────────────────
            Rectangle {
                id: pill
                anchors.horizontalCenter: parent.horizontalCenter
                width:  pillRow.implicitWidth + 12
                height: 38
                radius: 20
                color:  "#141414"
                border.width: 0
                clip: true

                // Border as inner rect — avoids QTBUG-137166 transparent hole bug
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    z: 10
                }

                RowLayout {
                    id: pillRow
                    anchors.centerIn: parent
                    spacing: 0

                    PillButton {
                        icon: "\uF31F"
                        bgColor: "#2a2a2a"
                        bgHover: "#444444"
                        Layout.margins: 4
                        onLeftClick:  launcherProc.running  = true
                        onRightClick: alacrittyProc.running = true
                        onMidClick:   rofiRunProc.running   = true
                        Process { id: launcherProc;  command: ["rofi", "-show", "drun"] }
                        Process { id: rofiRunProc;   command: ["rofi", "-show", "run"]  }
                        Process { id: alacrittyProc; command: ["alacritty"] }
                    }

                    Text {
                        text: ""
                        color: Qt.rgba(1, 1, 1, 0.14)
                        font.pixelSize: 10
                        Layout.leftMargin: 2
                        Layout.rightMargin: 2
                    }

                    XWorkspaces    { Layout.leftMargin: 4;  Layout.rightMargin: 2 }
                    PillDot        {}
                    ClockWidget    { Layout.leftMargin: 4;  Layout.rightMargin: 4 }
                    BatteryWidget  { Layout.leftMargin: 1;  Layout.rightMargin: 1 }
                    TrayWidget     { Layout.leftMargin: 0;  Layout.rightMargin: 0 }
                    NetworkWidget  { Layout.leftMargin: 1;  Layout.rightMargin: 2 }
                    VolumeWidget   { Layout.leftMargin: 2;  Layout.rightMargin: 2 }
                    PillDot        {}

                    PillButton {
                        icon: "󰐥"
                        bgColor: Qt.rgba(1, 1, 1, 0.06)
                        bgHover: "#3a3a3a"
                        iconColor: "#888888"
                        iconHoverColor: "#ffffff"
                        Layout.margins: 4
                        onLeftClick: wlogoutProc.running = true
                        onMidClick:  suspendProc.running = true
                        Process { id: wlogoutProc; command: ["wlogout"] }
                        Process { id: suspendProc; command: ["systemctl", "suspend"] }
                    }
                }
            }
        }
    }
}
