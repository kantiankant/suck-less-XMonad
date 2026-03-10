// BatteryWidget.qml — Battery status via /sys/class/power_supply
// Hover to reveal percentage

import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    implicitWidth: batIcon.implicitWidth + 16
    implicitHeight: 26

    property int capacity: 100
    property bool charging: false
    property string icon: "󰁹"

    function updateIcon() {
        if (root.charging) {
            root.icon = "󰂄"
        } else {
            if      (root.capacity >= 100) root.icon = "󰁹"
            else if (root.capacity >= 90)  root.icon = "󰂂"
            else if (root.capacity >= 80)  root.icon = "󰂁"
            else if (root.capacity >= 70)  root.icon = "󰂀"
            else if (root.capacity >= 60)  root.icon = "󰁿"
            else if (root.capacity >= 50)  root.icon = "󰁾"
            else if (root.capacity >= 40)  root.icon = "󰁽"
            else if (root.capacity >= 30)  root.icon = "󰁼"
            else if (root.capacity >= 20)  root.icon = "󰁻"
            else                           root.icon = "󰁺"
        }
    }

    Timer {
        interval: 250 
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batCapProc.running    = true
            batStatusProc.running = true
        }
    }

    Process {
        id: batCapProc
        command: ["bash", "-c",
            "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null"]
        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim())
                if (!isNaN(val)) {
                    root.capacity = val
                    root.updateIcon()
                }
            }
        }
    }

    Process {
        id: batStatusProc
        command: ["bash", "-c",
            "cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null"]
        stdout: SplitParser {
            onRead: data => {
                root.charging = data.trim() === "Charging"
                root.updateIcon()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: batHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }

        Row {
            anchors.centerIn: parent
            spacing: -10 

            Text {
                id: batIcon
                text: root.icon
                color: {
                    if (root.capacity <= 15 && !root.charging) return "#ff5555"
                    if (root.charging) return "#50fa7b"
                    return "#ffffff"
                }
                font.pixelSize: 15
                font.family: "JetBrainsMono Nerd Font"
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                text: root.capacity + "%"
                color: Qt.rgba(1, 1, 1, 0.6)
                font.pixelSize: 11
                font.family: "SF Pro Text"
                font.letterSpacing: 0.3
                opacity: batHover.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }
    }

    HoverHandler { id: batHover }
}
