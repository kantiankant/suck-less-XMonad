// PillButton.qml — reusable pill button for launcher and power button
// Properties: icon, bgColor, bgHover, iconColor, iconHoverColor
// Signals: onLeftClick, onRightClick, onMidClick

import QtQuick

Item {
    id: root
    implicitWidth: label.implicitWidth + 28
    implicitHeight: 30

    property string icon: ""
    property color bgColor: "#2a2a2a"
    property color bgHover: "#444444"
    property color iconColor: "#ffffff"
    property color iconHoverColor: "#ffffff"

    signal leftClick()
    signal rightClick()
    signal midClick()

    Behavior on implicitWidth {
        NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: btnHover.containsMouse ? root.bgHover : root.bgColor
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.icon
        color: btnHover.containsMouse ? root.iconHoverColor : root.iconColor
        font.pixelSize: 15
        // "monospace" won't resolve Nerd Font glyphs
        font.family: "JetBrainsMono Nerd Font"
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    HoverHandler { id: btnHover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: (e) => {
            if      (e.button === Qt.RightButton)  root.rightClick()
            else if (e.button === Qt.MiddleButton) root.midClick()
            else                                   root.leftClick()
        }
    }
}
