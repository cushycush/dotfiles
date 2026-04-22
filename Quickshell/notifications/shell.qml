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

    property bool centerOpen: false

    // Current wall-clock time used to recompute relative timestamps in the
    // center. Ticks every 30s only while the center is visible.
    property double now: Date.now()

    // Persistence paths. Following XDG base-dir spec: state that should
    // survive reboots but isn't config goes in $XDG_STATE_HOME.
    readonly property string stateDir: {
        const xdg = Quickshell.env("XDG_STATE_HOME");
        const home = Quickshell.env("HOME");
        return (xdg && xdg.length > 0) ? (xdg + "/quickshell")
                                       : (home + "/.local/state/quickshell");
    }
    readonly property string historyPath: stateDir + "/notifications.json"

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
            history.insert(0, {
                appName:   n.appName || "",
                summary:   n.summary || "",
                body:      n.body    || "",
                urgency:   n.urgency,
                timestamp: Date.now(),
            });
            while (history.count > root.historyLimit) history.remove(history.count - 1);
            root.schedulePersist();
        }
    }

    // Incremental model so ListView's remove/displaced transitions fire
    // when individual entries are dismissed (a JS-array model resets
    // wholesale on every change and skips animations).
    ListModel { id: history }

    // Clearing one-at-a-time with a short stagger cascades the remove
    // animation instead of wiping the list in a single frame.
    Timer {
        id: clearTimer
        interval: 40
        repeat: true
        onTriggered: {
            if (history.count === 0) { stop(); return; }
            history.remove(0);
            root.schedulePersist();
        }
    }
    function clearHistory() { clearTimer.restart(); }

    // ── Persistence ─────────────────────────────────────────────────────
    Process {
        id: mkdirProc
        command: ["mkdir", "-p", root.stateDir]
    }

    FileView {
        id: historyFile
        path: root.historyPath
        preload: true
        // First-run miss isn't an error we want logged.
        printErrors: false
        onLoaded: root.loadHistoryFromDisk()
        onLoadFailed: function(_err) { /* no saved history yet */ }
    }

    // Debounce writes: notification bursts (e.g. dismissing many at once)
    // collapse to a single file write.
    Timer {
        id: persistTimer
        interval: 300
        repeat: false
        onTriggered: root.persistHistory()
    }

    function schedulePersist() { persistTimer.restart(); }

    function loadHistoryFromDisk() {
        try {
            const raw = historyFile.text();
            if (!raw) return;
            const arr = JSON.parse(raw);
            if (!Array.isArray(arr)) return;
            history.clear();
            const n = Math.min(arr.length, root.historyLimit);
            for (let i = 0; i < n; i++) {
                const e = arr[i] || {};
                history.append({
                    appName:   String(e.appName || ""),
                    summary:   String(e.summary || ""),
                    body:      String(e.body    || ""),
                    urgency:   e.urgency | 0,
                    timestamp: Number(e.timestamp) || Date.now(),
                });
            }
        } catch (err) {
            console.warn("notifications: failed to load history:", err);
        }
    }

    function persistHistory() {
        try {
            const arr = [];
            for (let i = 0; i < history.count; i++) {
                const e = history.get(i);
                arr.push({
                    appName:   e.appName,
                    summary:   e.summary,
                    body:      e.body,
                    urgency:   e.urgency,
                    timestamp: e.timestamp,
                });
            }
            historyFile.setText(JSON.stringify(arr));
        } catch (err) {
            console.warn("notifications: failed to persist history:", err);
        }
    }

    Component.onCompleted: mkdirProc.running = true;

    function formatTimeAgo(ts) {
        const secs = Math.floor((now - ts) / 1000);
        if (secs < 60)    return secs + "s ago";
        if (secs < 3600)  return Math.floor(secs / 60) + "m ago";
        if (secs < 86400) return Math.floor(secs / 3600) + "h ago";
        return Math.floor(secs / 86400) + "d ago";
    }

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
    PanelWindow {
        id: centerPanel
        readonly property int panelWidth: 440

        color: "transparent"
        implicitWidth: panelWidth
        visible: root.centerOpen || slideAnim.running

        anchors { top: true; bottom: true; right: true }
        margins { top: 0; right: 14; bottom: 14 }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "qs-notification-center"

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
                anchors.topMargin: 14
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
                            text: "Clear all"
                            color: clearHover.containsMouse ? Theme.text : Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            visible: history.count > 0
                            MouseArea {
                                id: clearHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.clearHistory()
                            }
                        }
                        Rectangle {
                            implicitWidth: 26
                            implicitHeight: 26
                            radius: 13
                            color: closeHover.containsMouse ? Theme.pillSurface : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 4
                            }
                            MouseArea {
                                id: closeHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.centerOpen = false
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.separator
                    }

                    // Single layout slot for list + empty state so the panel
                    // doesn't collapse or jump when clearing everything.
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            anchors.centerIn: parent
                            visible: history.count === 0
                            text: "No notifications"
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        ListView {
                            id: historyList
                            visible: history.count > 0
                            anchors.fill: parent
                            clip: true
                            spacing: 6
                            model: history

                            add: Transition {
                                ParallelAnimation {
                                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
                                    NumberAnimation { property: "x"; from: 40; to: 0; duration: 260; easing.type: Easing.OutCubic }
                                }
                            }
                            remove: Transition {
                                ParallelAnimation {
                                    NumberAnimation { property: "opacity"; to: 0; duration: 180; easing.type: Easing.InCubic }
                                    NumberAnimation { property: "x"; to: 80; duration: 220; easing.type: Easing.InCubic }
                                }
                            }
                            displaced: Transition {
                                NumberAnimation { property: "y"; duration: 240; easing.type: Easing.OutCubic }
                            }

                            delegate: Rectangle {
                                id: entry
                                required property int index
                                required property string appName
                                required property string summary
                                required property string body
                                required property int urgency
                                required property double timestamp

                                width: ListView.view.width
                                implicitHeight: entryContent.implicitHeight + 20

                                color: rowHover.containsMouse ? Qt.lighter(Theme.pillSurface, 1.12) : Theme.pillSurface
                                radius: 10
                                border.color: urgency === NotificationUrgency.Critical ? Theme.alert : "transparent"
                                border.width: urgency === NotificationUrgency.Critical ? 1 : 0

                                Behavior on color { ColorAnimation { duration: 120 } }

                                MouseArea {
                                    id: rowHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        history.remove(entry.index);
                                        root.schedulePersist();
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
                                            text: entry.appName || "notification"
                                            color: Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 4
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: root.formatTimeAgo(entry.timestamp)
                                            color: Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 4
                                        }
                                    }

                                    Text {
                                        text: entry.summary
                                        color: Theme.textBold
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 1
                                        font.bold: true
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        visible: text.length > 0
                                    }

                                    Text {
                                        text: entry.body
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
    }

    // Keep "Xs ago" fresh while the center is visible.
    Timer {
        running: root.centerOpen && history.count > 0
        interval: 30000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = Date.now()
    }
}
