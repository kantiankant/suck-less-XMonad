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
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    Process {
        id: netProc
        // Skip the header line from iwctl output with NR>1
        command: ["bash", "-c",
            "iwctl station list 2>/dev/null | awk 'NR>1 && /connected|disconnected/{print; exit}'"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (!line || line.includes("disconnected")) {
                    root.connected = false
                    root.icon = "󰤭"
                    return
                }
                root.connected = true
                sigProc.running = true
            }
        }
    }

    Process {
        id: sigProc
        command: ["bash", "-c",
            // NR>1 skips header; station name is first non-whitespace token
            "STATION=$(iwctl station list 2>/dev/null | awk 'NR>1 && /connected/{print $1; exit}'); " +
            "[ -n \"$STATION\" ] && iwctl station \"$STATION\" show 2>/dev/null | grep -i 'signal' | grep -oP '-?\\d+' | head -1"]
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
            anchors.horizontalCenterOffset: -2
            text: root.icon
            color: root.connected ? "#ffffff" : "#666666"
            font.pixelSize: 15
            // "monospace" won't resolve Nerd Font glyphs
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

    // Left click: alacritty -e impala (iwd TUI)
    Process { id: impalaProc; command: ["alacritty", "--class", "floating", "-e", "impala"] }
    // Right click: trigger a rescan
    Process { id: iwctlScan;  command: ["bash", "-c",
        "iwctl station $(iwctl station list 2>/dev/null | awk '/connected|disconnected/{print $1}' | head -1) scan"] }
}

