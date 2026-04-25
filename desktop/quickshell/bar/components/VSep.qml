import QtQuick
import QtQuick.Layouts
import ".."

// Thin vertical line used *inside* a SegmentPill to divide sibling modules.
Rectangle {
    implicitWidth: 1
    implicitHeight: Theme.pillHeight * 0.55
    color: Theme.separator
    Layout.alignment: Qt.AlignVCenter
}
