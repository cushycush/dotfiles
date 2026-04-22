import QtQuick
import QtQuick.Layouts
import ".."

// Triple-dot separator drawn as three explicit rectangles instead of the
// U+22EE glyph — avoids baseline offset issues so the dots sit on the
// bar's true vertical midline.
Column {
    id: root
    property int dotSize: 4
    property int dotGap: 4
    Layout.alignment: Qt.AlignVCenter
    spacing: dotGap
    Repeater {
        model: 3
        delegate: Rectangle {
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: Theme.separator
        }
    }
}
