// XWorkspaces.qml — EWMH workspace switcher for XMonad
// Polls xprop for _NET_CURRENT_DESKTOP and _NET_NUMBER_OF_DESKTOPS
// Matches waybar hyprland/workspaces: persistent 1-5, active pill

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: wsRow.implicitWidth
    implicitHeight: wsRow.implicitHeight

    property int currentDesktop: 0
    property int totalDesktops: 9  // XMonad default — overridden by xprop on startup

    // ── One-shot: read total desktops on startup ──────────────────────────────
    Process {
        id: totalProc
        command: ["bash", "-c", "xprop -root _NET_NUMBER_OF_DESKTOPS | grep -oP '\\d+$'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const n = parseInt(data.trim())
                if (!isNaN(n)) root.totalDesktops = n
            }
        }
    }

    // ── xprop -spy: blocks and emits a line on EVERY property change ─────────
    // Far more responsive than polling — reacts the instant XMonad switches.
    Process {
        id: spyProc
        command: ["xprop", "-root", "-spy", "_NET_CURRENT_DESKTOP"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                // Output format: "_NET_CURRENT_DESKTOP(CARDINAL) = 2"
                const match = data.match(/=\s*(\d+)/)
                if (match) root.currentDesktop = parseInt(match[1])
            }
        }

        // If the spy process dies (shouldn't, but X11 is X11), restart it
        onRunningChanged: {
            if (!running) restartTimer.running = true
        }
    }

    Timer {
        id: restartTimer
        interval: 500
        repeat: false
        onTriggered: spyProc.running = true
    }

    // ── Workspace buttons ─────────────────────────────────────────────────────
    RowLayout {
        id: wsRow
        spacing: 4

        Repeater {
            model: root.totalDesktops

            delegate: Item {
                required property int index
                readonly property bool active: index === root.currentDesktop

                // Active pill expands; inactive collapses to compact button
                implicitWidth: active ? 38 : 28
                implicitHeight: 26

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }
                }

                // Background: filled primary for active, transparent for rest
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: height / 2
                    color: parent.active
                        ? "#484848"                          // active workspace
                        : wsHover.containsMouse
                            ? Qt.rgba(1, 1, 1, 0.08)
                            : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                // Workspace number — matches waybar format-icons "1"–"5"
                Text {
                    anchors.centerIn: parent
                    text: parent.index + 1
                    color: parent.active ? "#ffffff" : "#888888"
                    font.pixelSize: 11
                    font.bold: parent.active
                    font.family: "SF Pro Text"

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                HoverHandler { id: wsHover }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Use the delegate's own `index` property — not parent.index
                        switchProc.command = ["xdotool", "set_desktop", String(index)]
                        switchProc.running = true
                    }
                    // Scroll to switch workspaces
                    onWheel: (e) => {
                        const dir = e.angleDelta.y > 0 ? -1 : 1
                        const next = Math.max(0, Math.min(root.totalDesktops - 1, root.currentDesktop + dir))
                        switchProc.command = ["xdotool", "set_desktop", String(next)]
                        switchProc.running = true
                    }
                }
            }
        }
    }

    Process {
        id: switchProc
        command: []
    }
}
