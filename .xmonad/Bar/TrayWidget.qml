// TrayWidget.qml — StatusNotifier system tray
// Uses Quickshell's built-in SystemTray service
// Matches waybar tray: icon-size:15, spacing:10, show-passive-items:true

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: trayRow.implicitWidth
    implicitHeight: 26

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property SystemTrayItem modelData
                implicitWidth: 20
                implicitHeight: 20

                // Passive items dimmed — matches waybar .passive { -gtk-icon-effect: dim }
                opacity: modelData.status === SystemTrayItem.Passive ? 0.45 : 1.0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Image {
                    anchors.fill: parent
                    source: modelData.icon
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                HoverHandler { id: itemHover }

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.08)
                    visible: itemHover.hovered
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: (e) => {
                        if (e.button === Qt.MiddleButton)
                            modelData.secondaryActivate(0, 0)
                        else if (e.button === Qt.RightButton)
                            modelData.showContextMenu(0, 0)
                        else
                            modelData.activate(0, 0)
                    }
                }
            }
        }
    }
}
