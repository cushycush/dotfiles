import QtQuick
import QtQuick.Layouts
import ".."

// A single capsule segment. Configurable rounded/flat on left and right edges
// so segments can be "stitched" into a super-pill or stand alone.
Rectangle {
    id: pill
    default property alias content: row.data
    property bool roundLeft: true
    property bool roundRight: true

    color: Theme.pillSurface
    implicitHeight: Theme.pillHeight
    implicitWidth: row.implicitWidth + Theme.pillPadX * 2

    // Per-corner radius (Qt 6.7+). radius:0 as the base so only the flagged
    // corners round up.
    radius: 0
    topLeftRadius:     roundLeft  ? Theme.pillHeight / 2 : 0
    bottomLeftRadius:  roundLeft  ? Theme.pillHeight / 2 : 0
    topRightRadius:    roundRight ? Theme.pillHeight / 2 : 0
    bottomRightRadius: roundRight ? Theme.pillHeight / 2 : 0

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.modGap
    }
}
