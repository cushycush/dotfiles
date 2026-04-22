pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "."

// Rofi-like application launcher. Standalone shell — spawned on keybind,
// exits after launching the chosen entry or on Esc / click-outside.
ShellRoot {
    id: root

    readonly property int maxResults: 200

    property string query: ""
    property int selectedIndex: 0

    readonly property var allApps: DesktopEntries.applications.values
        .filter(e => !e.noDisplay)
        .slice()
        .sort((a, b) => (a.name || "").localeCompare(b.name || ""))

    readonly property var filtered: {
        const q = query.trim().toLowerCase();
        if (!q) return allApps.slice(0, maxResults);
        const out = allApps.filter(e => {
            const n = (e.name || "").toLowerCase();
            const g = (e.genericName || "").toLowerCase();
            const c = (e.comment || "").toLowerCase();
            return n.includes(q) || g.includes(q) || c.includes(q);
        });
        return out.slice(0, maxResults);
    }

    function moveSelection(delta) {
        const n = filtered.length;
        if (n === 0) return;
        selectedIndex = Math.max(0, Math.min(n - 1, selectedIndex + delta));
    }

    function launch(entry) {
        if (!entry) return;
        entry.execute();
        Qt.quit();
    }

    PanelWindow {
        id: panel

        color: "#99000000"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "qs-launcher"

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: 680
            height: 560
            color: Theme.bg
            radius: 14
            border.color: Theme.separator
            border.width: 1

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onClicked: {}
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: Theme.pillSurface
                    radius: 24

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 12

                        Text {
                            text: Icons.search
                            color: Theme.icon
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.iconSize
                            verticalAlignment: Text.AlignVCenter
                        }

                        TextInput {
                            id: search
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 4
                            selectByMouse: true
                            clip: true
                            focus: true

                            Component.onCompleted: forceActiveFocus()

                            onTextChanged: {
                                root.query = text;
                                root.selectedIndex = 0;
                            }

                            Keys.priority: Keys.BeforeItem
                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Down) {
                                    root.moveSelection(1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up) {
                                    root.moveSelection(-1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_PageDown) {
                                    root.moveSelection(8);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_PageUp) {
                                    root.moveSelection(-8);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.launch(root.filtered[root.selectedIndex]);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    Qt.quit();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: resultList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: root.filtered
                    currentIndex: root.selectedIndex
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        id: row
                        required property int index
                        required property var modelData

                        width: ListView.view.width
                        height: 44
                        radius: 8
                        color: index === root.selectedIndex ? Theme.pillSurface : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 14

                            Text {
                                text: row.modelData.name || ""
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 2
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                text: row.modelData.genericName || ""
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                elide: Text.ElideRight
                                visible: text.length > 0
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selectedIndex = row.index
                            onClicked: root.launch(row.modelData)
                        }
                    }
                }
            }
        }
    }
}
