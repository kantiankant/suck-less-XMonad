// ControlButton.qml — compact media control button for MusicDropdown

import QtQuick

Item {
    id: root
    property string icon: ""
    property int    size: 16
    signal clicked()

    implicitWidth:  size + 16
    implicitHeight: size + 12

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: btnHover.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: root.icon
            font.pixelSize: root.size
            // "monospace" won't resolve Nerd Font glyphs
            font.family: "JetBrainsMono Nerd Font"
            color: btnHover.containsMouse ? "#ffffff" : "#aaaaaa"
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    HoverHandler { id: btnHover }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
