pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "."

// Toast-style desktop notifications + a slide-in notification center.
// Claims the fdo Notifications DBus name (org.freedesktop.Notifications);
// any other notification daemon on the same bus must be stopped first.
ShellRoot {
    id: root

    readonly property int defaultTimeoutMs: 5000
    readonly property int lowTimeoutMs:     3500
    readonly property int historyLimit:     80

    // Center visibility state — toggled via IPC from the bar bell.
    property bool centerOpen: false

    // In-memory history. Every arriving notification is snapshotted here
    // so it outlives its toast; the list is newest-first and capped.
    property var history: []

    function appendHistory(n) {
        const entry = {
            id:        n.id,
            appName:   n.appName     || "",
            summary:   n.summary     || "",
            body:      n.body        || "",
            urgency:   n.urgency,
            timestamp: Date.now(),
        };
        const next = [entry].concat(history);
        if (next.length > historyLimit) next.length = historyLimit;
        history = next;
    }

    function clearHistory() { history = []; }

    function formatTimeAgo(ts) {
        const secs = Math.floor((Date.now() - ts) / 1000);
        if (secs < 60)    return secs + "s ago";
        if (secs < 3600)  return Math.floor(secs / 60) + "m ago";
        if (secs < 86400) return Math.floor(secs / 3600) + "h ago";
        return Math.floor(secs / 86400) + "d ago";
    }

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: false
        actionIconsSupported: false
        imageSupported: false
        persistenceSupported: false

        onNotification: (n) => {
            n.tracked = true;
            root.appendHistory(n);
        }
    }

    // IPC surface for the bar bell. `quickshell ipc call notifications toggle`.
    IpcHandler {
        target: "notifications"
        function toggle() { root.centerOpen = !root.centerOpen; }
        function open()   { root.centerOpen = true; }
        function close()  { root.centerOpen = false; }
        function clear()  { root.clearHistory(); }
    }

    // ── Toast stack ─────────────────────────────────────────────────────
    PanelWindow {
        id: toastPanel
        color: "transparent"
        implicitWidth: 480
        implicitHeight: 900

        anchors { top: true; right: true }
        margins { top: 54; right: 14 }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "qs-notifications-toasts"

        ListView {
            id: toastList
            anchors { top: parent.top; right: parent.right }
            width: 420
            height: contentHeight
            spacing: 10
            interactive: false
            model: server.trackedNotifications

            add: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
                    NumberAnimation { property: "x"; from: 60; to: 0; duration: 260; easing.type: Easing.OutCubic }
                }
            }
            remove: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; to: 0; duration: 180; easing.type: Easing.InCubic }
                    NumberAnimation { property: "x"; to: 80; duration: 220; easing.type: Easing.InCubic }
                }
            }
            displaced: Transition {
                NumberAnimation { property: "y"; duration: 260; easing.type: Easing.OutCubic }
            }

            delegate: Rectangle {
                id: toast
                required property var modelData
                readonly property Notification notif: modelData

                width: ListView.view.width
                implicitHeight: toastContent.implicitHeight + 24

                color: Theme.pillSurface
                radius: 12
                border.color: isCritical ? Theme.alert : Theme.separator
                border.width: isCritical ? 2 : 1

                readonly property bool isCritical: notif.urgency === NotificationUrgency.Critical
                readonly property bool isLow:      notif.urgency === NotificationUrgency.Low

                readonly property int ttl: {
                    if (isCritical) return 0;
                    if (notif.expireTimeout > 0) return notif.expireTimeout;
                    return isLow ? root.lowTimeoutMs : root.defaultTimeoutMs;
                }

                scale: hoverArea.containsMouse ? 1.01 : 1.0
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                Timer {
                    running: toast.ttl > 0 && !hoverArea.containsMouse
                    interval: toast.ttl
                    repeat: false
                    onTriggered: toast.notif.expire()
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toast.notif.dismiss()
                }

                ColumnLayout {
                    id: toastContent
                    anchors {
                        fill: parent
                        leftMargin: 14; rightMargin: 14
                        topMargin: 12;  bottomMargin: 12
                    }
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: toast.notif.appName || "notification"
                            color: toast.isCritical ? Theme.alert : Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 3
                            font.bold: toast.isCritical
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "×"
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                    }

                    Text {
                        text: toast.notif.summary
                        color: Theme.textBold
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        visible: text.length > 0
                    }

                    Text {
                        text: toast.notif.body
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        textFormat: Text.StyledText
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        visible: text.length > 0
                        maximumLineCount: 6
                        elide: Text.ElideRight
                        onLinkActivated: (url) => Qt.openUrlExternally(url)
                    }
                }
            }
        }
    }

    // ── Notification center ─────────────────────────────────────────────
    // A standalone layer-shell surface that slides in from the right when
    // `centerOpen` flips true. Hosts the full history of notifications that
    // this session has seen.
    PanelWindow {
        id: centerPanel

        readonly property int panelWidth: 440

        color: "transparent"
        implicitWidth: panelWidth
        visible: root.centerOpen || slideAnim.running

        anchors { top: true; bottom: true; right: true }
        margins { top: 54; right: 14; bottom: 14 }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "qs-notification-center"

        // Sliding wrapper — the card translates in/out of frame; this item
        // keeps `visible: false` when fully off-screen so input doesn't leak.
        Item {
            id: slideIn
            anchors.fill: parent
            property real slide: root.centerOpen ? 0 : (centerPanel.panelWidth + 40)

            Behavior on slide {
                NumberAnimation {
                    id: slideAnim
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                id: card
                anchors.fill: parent
                x: slideIn.slide
                color: Theme.bg
                radius: 14
                border.color: Theme.separator
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: Icons.bell
                            color: Theme.icon
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.iconSize
                        }
                        Text {
                            text: "Notifications"
                            color: Theme.textBold
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 2
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        Text {
                            text: root.history.length === 0 ? "" : "Clear all"
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.clearHistory()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.separator
                    }

                    // Empty state
                    Text {
                        visible: root.history.length === 0
                        text: "No notifications"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        Layout.alignment: Qt.AlignCenter
                        Layout.topMargin: 24
                    }

                    // History list
                    ListView {
                        id: historyList
                        visible: root.history.length > 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 6
                        model: root.history

                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                            NumberAnimation { property: "x"; from: 40; to: 0; duration: 240; easing.type: Easing.OutCubic }
                        }
                        remove: Transition {
                            NumberAnimation { property: "opacity"; to: 0; duration: 160 }
                            NumberAnimation { property: "x"; to: 60; duration: 200; easing.type: Easing.InCubic }
                        }
                        displaced: Transition {
                            NumberAnimation { property: "y"; duration: 220; easing.type: Easing.OutCubic }
                        }

                        delegate: Rectangle {
                            id: entry
                            required property int index
                            required property var modelData

                            width: ListView.view.width
                            implicitHeight: entryContent.implicitHeight + 20

                            color: rowHover.containsMouse ? Qt.lighter(Theme.pillSurface, 1.1) : Theme.pillSurface
                            radius: 10
                            border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.alert : "transparent"
                            border.width: modelData.urgency === NotificationUrgency.Critical ? 1 : 0

                            Behavior on color { ColorAnimation { duration: 120 } }

                            MouseArea {
                                id: rowHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const next = root.history.slice();
                                    next.splice(entry.index, 1);
                                    root.history = next;
                                }
                            }

                            ColumnLayout {
                                id: entryContent
                                anchors {
                                    fill: parent
                                    leftMargin: 12; rightMargin: 12
                                    topMargin: 10;  bottomMargin: 10
                                }
                                spacing: 3

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    Text {
                                        text: entry.modelData.appName || "notification"
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 4
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: root.formatTimeAgo(entry.modelData.timestamp)
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 4
                                    }
                                }

                                Text {
                                    text: entry.modelData.summary
                                    color: Theme.textBold
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 1
                                    font.bold: true
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    visible: text.length > 0
                                }

                                Text {
                                    text: entry.modelData.body
                                    color: Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 3
                                    textFormat: Text.StyledText
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    visible: text.length > 0
                                    maximumLineCount: 4
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Refresh "Xs ago" labels every 30s while the center is open.
    Timer {
        running: root.centerOpen && root.history.length > 0
        interval: 30000
        repeat: true
        onTriggered: {
            // Force re-eval by reassigning the same reference.
            root.history = root.history.slice();
        }
    }
}
