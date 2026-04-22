import QtQuick
import QtQuick.Layouts
import ".."

// Grouping container — transparent, no radius. Exists so clusters of
// modules can be positioned as a unit (left/center/right alignment).
Item {
    id: group

    default property alias content: row.data
    property int gap: Theme.modGap
    property int padX: Theme.groupPadX

    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth + padX * 2

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: group.gap
    }
}
