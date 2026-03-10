import Quickshell
import QtQuick

Item {
    implicitWidth: clockText.implicitWidth + 24
    implicitHeight: 26

    SystemClock {
        id: sysClock
        precision: SystemClock.Seconds
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: clockHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }

        Row {
            id: clockText
            anchors.centerIn: parent
            spacing: 0

            Text {
                id: dateText
                text: {
                    sysClock.now
                    return Qt.formatDate(new Date(), "ddd dd") + "  ·  "
                }
                color: Qt.rgba(1, 1, 1, 0.45)
                font.pixelSize: 12
                font.weight: Font.Normal
                font.family: "SF Pro Text"
                font.letterSpacing: 0.3
            }

            Text {
                id: timeText
                text: {
                    sysClock.now
                    return Qt.formatTime(new Date(), "h:mm AP")
                }
                color: "#ffffff"
                font.pixelSize: 13
                font.weight: Font.Medium
                font.family: "SF Pro Text"
                font.letterSpacing: 0.4
            }
        }
    }

    HoverHandler { id: clockHover }
}
