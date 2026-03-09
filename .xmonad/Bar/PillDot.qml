// PillDot.qml — dot separator matching waybar custom/separator-dot "·"
// color: alpha(@outline_variant, 0.4), font-size:7px

import QtQuick

Text {
    text: "·"
    color: Qt.rgba(1, 1, 1, 0.3)
    font.pixelSize: 7
    font.weight: Font.Black
    leftPadding: 5
    rightPadding: 5
}
