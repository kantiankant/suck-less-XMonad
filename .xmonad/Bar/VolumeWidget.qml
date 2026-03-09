// VolumeWidget.qml — Volume status via pactl
// Matches waybar pulseaudio module: icon-only, scroll to adjust
// format-icons: ["󰕿","󰖀","󰕾"], muted: "󰝟", bluetooth: "󰂰"
// Left click: pavucontrol, right: mute toggle, scroll: ±2%

import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    implicitWidth: volIcon.implicitWidth + 16
    implicitHeight: 26

    property bool muted: false
    property int volume: 50
    property bool isBluetooth: false

    readonly property string icon: {
        if (muted)       return "󰝟"
        if (isBluetooth) return "󰂰"
        if (volume <= 0) return "󰕿"
        if (volume < 50) return "󰖀"
        return "󰕾"
    }

    function refresh() {
        statusProc.running = true
    }

    Timer {
        interval: 2000  // 2s is plenty — pamixer actions trigger immediate refresh
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Single process for both volume and mute — avoids out-of-order race condition
    Process {
        id: statusProc
        command: ["bash", "-c",
            "echo \"VOL:$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1)\"; echo \"MUTE:$(pactl get-sink-mute @DEFAULT_SINK@ | grep -c 'yes')\""]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line.startsWith("VOL:")) {
                    const n = parseInt(line.slice(4))
                    if (!isNaN(n)) root.volume = n
                } else if (line.startsWith("MUTE:")) {
                    root.muted = line.slice(5) === "1"
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: volHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            id: volIcon
            anchors.centerIn: parent
            text: root.icon
            color: root.muted ? "#666666" : "#ffffff"
            font.pixelSize: 15
            // "monospace" won't resolve Nerd Font glyphs — use the installed NF family
            font.family: "JetBrainsMono Nerd Font"

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    HoverHandler { id: volHover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: (e) => {
            if (e.button === Qt.RightButton)       muteProc.running    = true
            else if (e.button === Qt.MiddleButton) micMuteProc.running = true
            else                                   pavuProc.running    = true
        }
        onWheel: (e) => {
            if (e.angleDelta.y > 0) volUpProc.running   = true
            else                    volDownProc.running  = true
        }
    }

    Process { id: pavuProc;    command: ["pavucontrol"] }
    Process {
        id: muteProc
        command: ["pamixer", "-t"]
        onRunningChanged: if (!running) root.refresh()
    }
    Process {
        id: micMuteProc
        command: ["pamixer", "--default-source", "-t"]
    }
    Process {
        id: volUpProc
        command: ["pamixer", "-i", "2"]
        onRunningChanged: if (!running) root.refresh()
    }
    Process {
        id: volDownProc
        command: ["pamixer", "-d", "2"]
        onRunningChanged: if (!running) root.refresh()
    }
}
