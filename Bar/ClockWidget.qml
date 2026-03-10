import QtQuick

Item {
    id: root
    implicitWidth: clockText.implicitWidth + 24
    implicitHeight: 26

    property var now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
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
                    const d = root.now
                    const days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                    return days[d.getDay()] + " " + String(d.getDate()).padStart(2,"0") + "  ·  "
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
                    const d = root.now
                    let h = d.getHours()
                    const ampm = h >= 12 ? "PM" : "AM"
                    h = h % 12 || 12
                    const m = String(d.getMinutes()).padStart(2,"0")
                    return h + ":" + m + " " + ampm
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
