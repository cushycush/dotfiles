pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../bar" as Bar

// Rofi-like application launcher. Standalone shell — spawned on keybind,
// exits after launching the chosen entry or on Esc / click-outside.
ShellRoot {
    id: root

    readonly property int maxResults: 200

    property string query: ""
    property int selectedIndex: 0

    // Snapshot visible entries once at startup (sorted). Filtering is derived.
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

    function launch(entry) {
        if (!entry) return;
        entry.execute();
        Qt.quit();
    }

    PanelWindow {
        id: panel

        // Dim-out scrim across the whole screen.
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

        // Click outside the card dismisses.
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: 640
            height: 520
            color: Bar.Theme.bg
            radius: 14
            border.color: Bar.Theme.separator
            border.width: 1

            // Swallow clicks on the card so they don't bubble to the scrim.
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onClicked: {}
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // ── Search field
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Bar.Theme.pillSurface
                    radius: 20

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        spacing: 10

                        Text {
                            text: Bar.Icons.search
                            color: Bar.Theme.icon
                            font.family: Bar.Theme.fontFamily
                            font.pixelSize: Bar.Theme.iconSize - 2
                            verticalAlignment: Text.AlignVCenter
                        }

                        TextInput {
                            id: search
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            color: Bar.Theme.text
                            font.family: Bar.Theme.fontFamily
                            font.pixelSize: Bar.Theme.fontSize
                            focus: true
                            selectByMouse: true
                            clip: true
                            onTextChanged: {
                                root.query = text;
                                root.selectedIndex = 0;
                            }
                            Keys.onDownPressed: if (root.selectedIndex < root.filtered.length - 1) root.selectedIndex++;
                            Keys.onUpPressed:   if (root.selectedIndex > 0) root.selectedIndex--;
                            Keys.onReturnPressed: root.launch(root.filtered[root.selectedIndex])
                            Keys.onEnterPressed:  root.launch(root.filtered[root.selectedIndex])
                            Keys.onEscapePressed: Qt.quit()
                        }
                    }
                }

                // ── Result list
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
                        height: 40
                        radius: 8
                        color: index === root.selectedIndex ? Bar.Theme.pillSurface : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            Text {
                                text: row.modelData.name || ""
                                color: Bar.Theme.text
                                font.family: Bar.Theme.fontFamily
                                font.pixelSize: Bar.Theme.fontSize
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: row.modelData.genericName || ""
                                color: Bar.Theme.textMuted
                                font.family: Bar.Theme.fontFamily
                                font.pixelSize: Bar.Theme.fontSize - 2
                                elide: Text.ElideRight
                                visible: text.length > 0
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
