pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "."

// System settings slide-in panel: bluetooth, wi-fi, sound.
// Toggled via IPC (`settings toggle`); no bar entry of its own yet.
ShellRoot {
    id: root

    property bool panelOpen: false

    SettingsState { id: state }

    IpcHandler {
        target: "settings"
        function toggle() { root.panelOpen = !root.panelOpen; }
        function open()   { root.panelOpen = true; }
        function close()  { root.panelOpen = false; }
    }

    // When the panel opens, force a fresh poll so the user sees current
    // state rather than whatever was cached 4 seconds ago.
    onPanelOpenChanged: if (panelOpen) state.refreshAll();

    // ── Inline components ────────────────────────────────────────────────
    component ToggleSwitch: Rectangle {
        id: sw
        property bool on: false
        signal toggled

        implicitWidth:  38
        implicitHeight: 22
        radius: height / 2
        color: on ? Theme.good : Theme.separator
        Behavior on color { ColorAnimation { duration: 140 } }

        Rectangle {
            width: sw.height - 4
            height: width
            radius: height / 2
            color: Theme.textBold
            y: 2
            x: sw.on ? (sw.width - width - 2) : 2
            Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: sw.toggled()
        }
    }

    component SectionCard: Rectangle {
        id: card
        default property alias content: inner.data
        color: Theme.bgElev
        radius: 12
        border.color: Theme.separator
        border.width: 1
        implicitHeight: inner.implicitHeight + 24
        Layout.fillWidth: true

        ColumnLayout {
            id: inner
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 8
        }
    }

    // A single row inside a list (paired device, network, sink). Hover
    // highlight + rounded corners.
    component ListRow: Rectangle {
        id: row
        property bool hovered: rowHover.hovered
        signal clicked

        implicitHeight: 36
        Layout.fillWidth: true
        color: row.hovered ? Qt.lighter(Theme.pillSurface, 1.15) : "transparent"
        radius: 8
        Behavior on color { ColorAnimation { duration: 120 } }

        HoverHandler { id: rowHover }
        TapHandler { onTapped: row.clicked() }
    }

    component VolumeSlider: Item {
        id: slider
        property int value: 0
        property bool muted: false
        signal changed(int v)

        implicitHeight: 22
        Layout.fillWidth: true

        readonly property int trackHeight: 4
        readonly property int knobSize: 14

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            height: slider.trackHeight
            radius: height / 2
            color: Theme.separator

            Rectangle {
                height: parent.height
                radius: parent.radius
                width: parent.width * (slider.value / 100)
                color: slider.muted ? Theme.textMuted : Theme.good
            }
        }

        Rectangle {
            id: knob
            width: slider.knobSize
            height: width
            radius: width / 2
            color: Theme.textBold
            border.color: Theme.bg
            border.width: 2
            y: (slider.height - height) / 2
            x: Math.round((slider.width - width) * (slider.value / 100))
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: (m) => setFromX(m.x)
            onPositionChanged: (m) => { if (pressed) setFromX(m.x); }
            onReleased: (m) => slider.changed(slider.value)

            function setFromX(x) {
                const usable = slider.width - slider.knobSize;
                const clamped = Math.max(0, Math.min(usable, x - slider.knobSize / 2));
                slider.value = Math.round((clamped / usable) * 100);
            }
        }
    }

    // ── Panel ────────────────────────────────────────────────────────────
    PanelWindow {
        id: panel
        readonly property int panelWidth: 440

        color: "transparent"
        implicitWidth: panelWidth
        visible: root.panelOpen || slideAnim.running

        anchors { top: true; bottom: true; right: true }
        margins { top: 0; right: 14; bottom: 14 }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "qs-settings-panel"

        Item {
            id: slide
            anchors.fill: parent
            property real offset: root.panelOpen ? 0 : (panel.panelWidth + 40)

            Behavior on offset {
                NumberAnimation {
                    id: slideAnim
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                id: card
                anchors.fill: parent
                anchors.topMargin: 14
                x: slide.offset
                color: Theme.bg
                radius: 14
                border.color: Theme.separator
                border.width: 1

                ColumnLayout {
                    id: panelContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // ── Header ───────────────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: Icons.cog
                            color: Theme.icon
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.iconSize
                        }
                        Text {
                            text: "Settings"
                            color: Theme.textBold
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 2
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            implicitWidth: 26; implicitHeight: 26
                            radius: 13
                            color: closeHover.hovered ? Theme.pillSurface : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 4
                            }
                            HoverHandler { id: closeHover }
                            TapHandler { onTapped: root.panelOpen = false }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.separator
                    }

                    // Scrollable content so the panel copes with many
                    // wifi networks / sinks without overflowing.
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: cards.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: cards
                            width: parent.width
                            spacing: 12

                            // ── Bluetooth ────────────────────────────────
                            SectionCard {
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text: state.btPowered
                                              ? (state.btDevices.some(d => d.connected)
                                                 ? Icons.bluetoothConnected
                                                 : Icons.bluetooth)
                                              : Icons.bluetoothOff
                                        color: state.btPowered ? Theme.icon : Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.iconSize
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text {
                                            text: "Bluetooth"
                                            color: Theme.textBold
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.bold: true
                                        }
                                        Text {
                                            text: !state.btAvailable ? "No adapter"
                                                : state.btPowered    ? (connectedNames() || "On")
                                                :                      "Off"
                                            color: Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 3
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true

                                            function connectedNames() {
                                                return state.btDevices
                                                    .filter(d => d.connected)
                                                    .map(d => d.name)
                                                    .join(", ");
                                            }
                                        }
                                    }
                                    ToggleSwitch {
                                        on: state.btPowered
                                        enabled: state.btAvailable
                                        opacity: enabled ? 1.0 : 0.4
                                        onToggled: state.btTogglePower()
                                    }
                                }

                                // Paired devices list
                                Repeater {
                                    model: state.btPowered ? state.btDevices : []
                                    delegate: ListRow {
                                        required property var modelData
                                        onClicked: modelData.connected
                                                   ? state.btDisconnect(modelData.mac)
                                                   : state.btConnect(modelData.mac)
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10; anchors.rightMargin: 10
                                            spacing: 8

                                            Text {
                                                text: modelData.connected ? Icons.bluetoothConnected : Icons.bluetooth
                                                color: modelData.connected ? Theme.good : Theme.textMuted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.iconSize - 2
                                            }
                                            Text {
                                                text: modelData.name
                                                color: Theme.text
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 2
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                            Text {
                                                text: modelData.connected ? "connected" : "paired"
                                                color: Theme.textMuted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 4
                                            }
                                        }
                                    }
                                }
                                Text {
                                    visible: state.btPowered && state.btDevices.length === 0
                                    text: "No paired devices"
                                    color: Theme.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 3
                                    Layout.leftMargin: 10
                                }
                            }

                            // ── Wi-Fi ────────────────────────────────────
                            SectionCard {
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text: state.wifiEnabled ? Icons.wifi : Icons.wifiOff
                                        color: state.wifiEnabled ? Theme.icon : Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.iconSize
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text {
                                            text: "Wi-Fi"
                                            color: Theme.textBold
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.bold: true
                                        }
                                        Text {
                                            text: !state.wifiAvailable        ? "NetworkManager not available"
                                                : !state.wifiEnabled           ? "Off"
                                                : state.wifiActiveSsid.length  ? ("Connected: " + state.wifiActiveSsid)
                                                :                                "Not connected"
                                            color: Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 3
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }
                                    // Refresh / rescan
                                    Text {
                                        text: Icons.refresh
                                        color: refreshHover.hovered ? Theme.icon : Theme.textMuted
                                        visible: state.wifiAvailable && state.wifiEnabled
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.iconSize - 2
                                        HoverHandler { id: refreshHover }
                                        TapHandler { onTapped: state.wifiRescan() }
                                    }
                                    ToggleSwitch {
                                        on: state.wifiEnabled
                                        enabled: state.wifiAvailable
                                        opacity: enabled ? 1.0 : 0.4
                                        onToggled: state.wifiToggle()
                                    }
                                }

                                Repeater {
                                    model: (state.wifiEnabled ? state.wifiNetworks : []).slice(0, 8)
                                    delegate: ListRow {
                                        required property var modelData
                                        onClicked: state.wifiOpenEditor(modelData.ssid)
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10; anchors.rightMargin: 10
                                            spacing: 8

                                            Text {
                                                text: modelData.security && modelData.security.length > 0
                                                      ? Icons.wifiLock : Icons.wifi
                                                color: modelData.active ? Theme.good : Theme.textMuted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.iconSize - 2
                                            }
                                            Text {
                                                text: modelData.ssid
                                                color: Theme.text
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 2
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                            Text {
                                                text: modelData.signal + "%"
                                                color: Theme.textMuted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 4
                                            }
                                        }
                                    }
                                }
                                Text {
                                    visible: state.wifiEnabled && state.wifiNetworks.length === 0
                                    text: "No networks in range"
                                    color: Theme.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 3
                                    Layout.leftMargin: 10
                                }
                            }

                            // ── Sound ────────────────────────────────────
                            SectionCard {
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text: state.muted                  ? Icons.volMute
                                            : state.volumePercent >= 66    ? Icons.volHigh
                                            : state.volumePercent >= 33    ? Icons.volMed
                                            :                                Icons.volLow
                                        color: state.muted ? Theme.textMuted : Theme.icon
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.iconSize
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1
                                        Text {
                                            text: "Output"
                                            color: Theme.textBold
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.bold: true
                                        }
                                        Text {
                                            text: {
                                                const s = state.sinks.find(x => x.active);
                                                return s ? s.description : "No sink";
                                            }
                                            color: Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 3
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }
                                    ToggleSwitch {
                                        on: !state.muted
                                        onToggled: state.muteToggle()
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    Text {
                                        text: state.volumePercent + "%"
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 2
                                        Layout.preferredWidth: 44
                                    }
                                    VolumeSlider {
                                        value: state.volumePercent
                                        muted: state.muted
                                        onChanged: (v) => state.volSet(v)
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 1
                                    color: Theme.separator
                                    visible: state.sinks.length > 1
                                }

                                Repeater {
                                    model: state.sinks.length > 1 ? state.sinks : []
                                    delegate: ListRow {
                                        required property var modelData
                                        onClicked: state.sinkSelect(modelData.name)
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10; anchors.rightMargin: 10
                                            spacing: 8

                                            Text {
                                                text: modelData.active ? Icons.check : " "
                                                color: Theme.good
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.iconSize - 2
                                                Layout.preferredWidth: Theme.iconSize
                                            }
                                            Text {
                                                text: modelData.description
                                                color: modelData.active ? Theme.textBold : Theme.text
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 2
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
