pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "."

// Toast-style desktop notifications, rendered as a stacked column in the
// top-right of the primary output. Claims the fdo Notifications DBus name
// (org.freedesktop.Notifications) — any other notification daemon on the
// same bus must be stopped first.
ShellRoot {
    id: root

    // Default dismissal for notifications that don't set an expireTimeout
    // (the spec encodes "server's choice" as -1). Low urgency fades faster;
    // critical urgency sticks around until dismissed manually.
    readonly property int defaultTimeoutMs: 5000
    readonly property int lowTimeoutMs:     3500

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
        }
    }

    PanelWindow {
        id: panel
        color: "transparent"
        implicitWidth: 420
        implicitHeight: Math.max(1, stack.implicitHeight + 24)

        anchors {
            top: true
            right: true
        }
        margins {
            top: 54
            right: 14
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "qs-notifications"

        ColumnLayout {
            id: stack
            anchors.right: parent.right
            anchors.top: parent.top
            width: 400
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: toast
                    required property var modelData
                    readonly property Notification notif: modelData

                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: 400
                    implicitHeight: content.implicitHeight + 24

                    color: Theme.pillSurface
                    radius: 12
                    border.color: isCritical ? Theme.alert : Theme.separator
                    border.width: isCritical ? 2 : 1

                    readonly property bool isCritical: notif.urgency === NotificationUrgency.Critical
                    readonly property bool isLow:      notif.urgency === NotificationUrgency.Low

                    // Resolve the time-to-live: critical never auto-dismisses;
                    // explicit expireTimeout wins; otherwise pick a default by urgency.
                    readonly property int ttl: {
                        if (isCritical) return 0;
                        if (notif.expireTimeout > 0) return notif.expireTimeout;
                        return isLow ? root.lowTimeoutMs : root.defaultTimeoutMs;
                    }

                    Timer {
                        running: toast.ttl > 0
                        interval: toast.ttl
                        repeat: false
                        onTriggered: toast.notif.expire()
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: toast.notif.dismiss()
                    }

                    ColumnLayout {
                        id: content
                        anchors {
                            fill: parent
                            leftMargin: 14
                            rightMargin: 14
                            topMargin: 12
                            bottomMargin: 12
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
    }
}
