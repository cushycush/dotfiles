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
        implicitWidth: 480
        // Tall enough for a comfortable stack; transparent areas don't grab
        // input, so leaving extra vertical runway is cheap.
        implicitHeight: 900

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

        ListView {
            id: toastList
            anchors {
                top: parent.top
                right: parent.right
            }
            width: 420
            height: contentHeight
            spacing: 10
            interactive: false
            model: server.trackedNotifications

            // Slide in from the right and fade up.
            add: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        from: 0; to: 1
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "x"
                        from: 60; to: 0
                        duration: 260
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Slide out to the right and fade down.
            remove: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: 180
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "x"
                        to: 80
                        duration: 220
                        easing.type: Easing.InCubic
                    }
                }
            }

            // Remaining toasts ease up into the vacated slot.
            displaced: Transition {
                NumberAnimation {
                    property: "y"
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }

            delegate: Rectangle {
                id: toast
                required property var modelData
                readonly property Notification notif: modelData

                width: ListView.view.width
                implicitHeight: content.implicitHeight + 24

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

                // Soften hover so the toast subtly responds to the mouse.
                Behavior on color {
                    ColorAnimation { duration: 120 }
                }
                scale: hoverArea.containsMouse ? 1.01 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }

                Timer {
                    id: expireTimer
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
