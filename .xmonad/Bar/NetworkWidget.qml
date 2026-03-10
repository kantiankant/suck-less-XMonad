// NetworkWidget.qml — Wi-Fi status via iwd (iwctl)
// Left click: alacritty -e impala  |  Right click: iwctl scan
// Signal strength icons matching waybar format-icons ["󰤯","󰤟","󰤢","󰤥","󰤨"]

import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    implicitWidth: netIcon.implicitWidth + 16
    implicitHeight: 26

    property string icon: "󰤨"
    property bool connected: true

    Timer {
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    Process {
        id: netProc
        command: ["bash", "-c",
            "iwctl station wlan0 show 2>/dev/null | grep -i 'Connected network' | grep -q '.' && echo 'YES' || echo 'NO'"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line === "YES") {
                    root.connected = true
                    sigProc.running = true
                } else {
                    root.connected = false
                    root.icon = "󰤨"
                }
            }
        }
    }

    Process {
        id: sigProc
        command: ["bash", "-c",
            "iwctl station wlan0 show 2>/dev/null | grep -i 'signal' | grep -oP '-?\\d+' | head -1"]
        stdout: SplitParser {
            onRead: data => {
                const rssi = parseInt(data.trim())
                if (isNaN(rssi)) { root.icon = "󰤨"; return }
                if      (rssi >= -50) root.icon = "󰤨"
                else if (rssi >= -60) root.icon = "󰤥"
                else if (rssi >= -70) root.icon = "󰤢"
                else if (rssi >= -80) root.icon = "󰤟"
                else                  root.icon = "󰤯"
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: netHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            id: netIcon
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -1
            text: root.icon
            color: root.connected ? "#ffffff" : "#666666"
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }

    HoverHandler { id: netHover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (e) => {
            if (e.button === Qt.RightButton) iwctlScan.running  = true
            else                             impalaProc.running = true
        }
    }

    Process { id: impalaProc; command: ["alacritty", "--class", "floating", "-e", "impala"] }
    Process { id: iwctlScan;  command: ["bash", "-c", "iwctl station wlan0 scan"] }
}
