import QtQuick
import QtQuick.Layouts
import ".."

// Icon + label row. Two-tone by default: warm-yellow icon + cream text.
// Callers can override either independently for semantic emphasis.
RowLayout {
    id: mod

    property string icon: ""
    property string label: ""
    property color iconColor: Theme.icon
    property color labelColor: Theme.text
    property int iconSize: Theme.iconSize
    property bool bold: false

    spacing: Theme.iconTextGap

    Text {
        text: mod.icon
        color: mod.iconColor
        visible: mod.icon.length > 0
        font.family: Theme.fontFamily
        font.pixelSize: mod.iconSize
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        text: mod.label
        color: mod.labelColor
        visible: mod.label.length > 0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: mod.bold
        verticalAlignment: Text.AlignVCenter
    }
}
