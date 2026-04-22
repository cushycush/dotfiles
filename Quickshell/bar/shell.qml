pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "." as Bar
import "components" as C

// ─────────────────────────────────────────────────────────────────────────
// Top + bottom flat bars — transparent base, warm-yellow icons, cream text.
// Nordic palette; no pill containers, clusters separated by stretchers.
// ─────────────────────────────────────────────────────────────────────────
ShellRoot {
    id: root

    C.SystemInfo { id: sys }
    C.Clock      { id: clock }
    C.GitHub     { id: gh }

    // Notification shell writes its DND flag and unread count to this
    // file; we watch for changes instead of polling via IPC.
    readonly property string notifStatePath: {
        const xdg = Quickshell.env("XDG_STATE_HOME");
        const home = Quickshell.env("HOME");
        const base = (xdg && xdg.length > 0) ? xdg : (home + "/.local/state");
        return base + "/quickshell/notif-state.json";
    }

    property bool notifDnd: false
    property int  notifUnread: 0

    FileView {
        id: notifStateFile
        path: root.notifStatePath
        watchChanges: true
        preload: true
        printErrors: false
        onLoaded: root.readNotifState()
        onFileChanged: reload()
        onLoadFailed: function(_err) { /* file doesn't exist yet */ }
    }

    // One-shot process wrapper for IPC calls fired from bar widgets.
    Process {
        id: openSettingsProc
        command: ["/bin/sh", "-c",
            "quickshell -p ~/dotfiles/Quickshell/settings/shell.qml ipc --any-display call settings toggle"]
    }

    function readNotifState() {
        try {
            const raw = notifStateFile.text();
            if (!raw) return;
            const obj = JSON.parse(raw);
            if (obj && typeof obj === "object") {
                root.notifDnd    = !!obj.dnd;
                root.notifUnread = Number(obj.unread) | 0;
            }
        } catch (_) { /* ignore */ }
    }

    // ── Top bar (one per screen) ─────────────────────────────────────────
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: topBar
            required property var modelData
            screen: modelData
            color: Bar.Theme.bg
            implicitHeight: Bar.Theme.barHeight
            exclusiveZone: Bar.Theme.barHeight
            anchors { top: true; left: true; right: true }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Bar.Theme.barMargin
                anchors.rightMargin: Bar.Theme.barMargin
                spacing: 0

                // ── Left: [CPU)  (RAM]  ⋮  temp
                RowLayout {
                    spacing: 0
                    RowLayout {
                        spacing: Bar.Theme.segGap
                        C.SegmentPill {
                            roundLeft: true;  roundRight: false
                            C.Module { icon: Bar.Icons.cpu; label: sys.cpuPercent + "%" }
                        }
                        C.SegmentPill {
                            roundLeft: false; roundRight: true
                            C.Module { icon: Bar.Icons.memory; label: sys.memUsedHuman }
                        }
                    }
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    C.DotSep {}
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    C.Module {
                        icon: Bar.Icons.thermo
                        label: sys.cpuTempC + "°C"
                        iconColor: sys.cpuTempC >= 80 ? Bar.Theme.alert
                                 : sys.cpuTempC >= 65 ? Bar.Theme.accent
                                 : Bar.Theme.icon
                    }
                }

                Item { Layout.fillWidth: true }

                // ── Center segmented super-pill: [time)  (day)  (date]
                RowLayout {
                    spacing: Bar.Theme.segGap
                    C.SegmentPill {
                        roundLeft: true;  roundRight: false
                        C.Module { icon: Bar.Icons.clock; label: clock.time; iconSize: Bar.Theme.iconSize - 2 }
                    }
                    C.SegmentPill {
                        roundLeft: false; roundRight: false
                        C.Module { icon: Bar.Icons.weekday; label: clock.dayName }
                    }
                    C.SegmentPill {
                        roundLeft: false; roundRight: true
                        C.Module { icon: Bar.Icons.calendar; label: clock.date }
                    }
                }

                Item { Layout.fillWidth: true }

                // ── Right (GPU mirror of CPU left): 🔥gpu_temp   ⋮   [VRAM)  (util%]
                RowLayout {
                    spacing: 0
                    C.Module {
                        icon: Bar.Icons.fire
                        label: sys.gpuTempC + "°C"
                        iconColor: sys.gpuTempC >= 85 ? Bar.Theme.alert
                                 : sys.gpuTempC >= 75 ? Bar.Theme.accent
                                 : Bar.Theme.icon
                    }
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    C.DotSep {}
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    RowLayout {
                        spacing: Bar.Theme.segGap
                        C.SegmentPill {
                            roundLeft: true;  roundRight: false
                            C.Module { icon: Bar.Icons.memory; label: sys.gpuMemMiB + " MiB" }
                        }
                        C.SegmentPill {
                            roundLeft: false; roundRight: true
                            C.Module {
                                icon: Bar.Icons.speedo
                                label: sys.gpuUtilPercent + "%"
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Bottom bar (one per screen) ──────────────────────────────────────
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bottomBar
            required property var modelData
            screen: modelData
            color: Bar.Theme.bg
            implicitHeight: Bar.Theme.barHeight
            exclusiveZone: Bar.Theme.barHeight
            anchors { bottom: true; left: true; right: true }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Bar.Theme.barMargin
                anchors.rightMargin: Bar.Theme.barMargin
                spacing: 0

                // ── Left super-pill: [ wifi | ↓ | ↑ ]   ⋮   [ rss | bug ]
                RowLayout {
                    spacing: 0
                    C.SegmentPill {
                        C.Module {
                            icon: sys.wifiSsid.length > 0 ? Bar.Icons.wifi : Bar.Icons.wifiOff
                            label: sys.wifiSsid.length > 0 ? sys.wifiSsid : "offline"
                            iconColor: sys.wifiSsid.length > 0 ? Bar.Theme.icon : Bar.Theme.textMuted
                            labelColor: sys.wifiSsid.length > 0 ? Bar.Theme.text : Bar.Theme.textMuted
                        }
                        C.VSep {}
                        C.Module { icon: Bar.Icons.down; label: sys.netDownKbps + " KB/s" }
                        C.VSep {}
                        C.Module { icon: Bar.Icons.up;   label: sys.netUpKbps   + " KB/s" }
                    }
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    C.DotSep {}
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    C.SegmentPill {
                        // Placeholder cluster — wire these to real data later.
                        C.Module { icon: Bar.Icons.rss; label: "0" }
                        C.VSep {}
                        C.Module { icon: Bar.Icons.bug; label: "0" }
                    }
                }

                Item { Layout.fillWidth: true }

                // ── Middle: workspaces pill — only occupied + focused
                C.SegmentPill {
                    Repeater {
                        model: 10
                        delegate: Text {
                            required property int index
                            readonly property int wsId: index + 1
                            readonly property var ws: Hyprland.workspaces.values.find(w => w.id === wsId)
                            readonly property bool focused: Hyprland.focusedWorkspace
                                && Hyprland.focusedWorkspace.id === wsId
                            readonly property bool occupied: ws !== undefined

                            visible: focused || occupied
                            text: wsId.toString()
                            color: focused ? Bar.Theme.icon : Bar.Theme.text
                            font.family: Bar.Theme.fontFamily
                            font.pixelSize: Bar.Theme.fontSize
                            font.bold: focused
                            verticalAlignment: Text.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + parent.wsId)
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // ── Right super-pill: [ bt | 󰕾 | 󰁹 | bell ]   ⋮   [ github | pr ]
                RowLayout {
                    spacing: 0
                    C.SegmentPill {
                        C.Module {
                            icon: !sys.btAvailable        ? Bar.Icons.bluetoothOff
                                : !sys.btPowered          ? Bar.Icons.bluetoothOff
                                : sys.btDevice.length > 0 ? Bar.Icons.bluetoothConnected
                                :                           Bar.Icons.bluetooth
                            iconColor: !sys.btAvailable        ? Bar.Theme.textMuted
                                     : !sys.btPowered          ? Bar.Theme.textMuted
                                     : sys.btDevice.length > 0 ? Bar.Theme.accent
                                     :                           Bar.Theme.icon
                            label: sys.btDevice
                            TapHandler {
                                enabled: sys.btAvailable
                                onTapped: sys.toggleBluetooth()
                            }
                            TapHandler {
                                acceptedButtons: Qt.RightButton
                                onTapped: openSettingsProc.running = true
                            }
                        }
                        C.VSep {}
                        C.Module {
                            icon: sys.volumeMuted         ? Bar.Icons.volMute
                                : sys.volumePercent >= 66 ? Bar.Icons.volHigh
                                : sys.volumePercent >= 33 ? Bar.Icons.volMed
                                : Bar.Icons.volLow
                            label: sys.volumeMuted ? "muted" : sys.volumePercent + "%"
                            iconColor: sys.volumeMuted ? Bar.Theme.textMuted : Bar.Theme.icon
                            labelColor: sys.volumeMuted ? Bar.Theme.textMuted : Bar.Theme.text
                        }
                        C.VSep {}
                        C.Module {
                            icon: sys.batteryStatus === "Charging" ? Bar.Icons.charging : Bar.Icons.battery
                            label: sys.batteryPercent + "%"
                            iconColor: sys.batteryPercent <= 15 && sys.batteryStatus !== "Charging"
                                     ? Bar.Theme.alert : Bar.Theme.icon
                        }
                        C.VSep {}

                        // Non-rotating cell owns hit testing; the inner Text
                        // rotates purely visually. Keeps hover/tap events
                        // stable regardless of where the glyph has tilted.
                        Item {
                            id: bellCell
                            implicitWidth: bellIcon.implicitWidth
                            implicitHeight: bellIcon.implicitHeight

                            // ringing: animation has exclusive rotation control.
                            // suppressHover: post-click latch; bell stays level
                            // even while the cursor is still on it, and only
                            // re-engages the tilt when the cursor leaves and
                            // returns.
                            property bool ringing: false
                            property bool suppressHover: false

                            Process {
                                id: toggleNotifProc
                                // --any-display so the lookup finds the
                                // notifications instance even when it was
                                // launched with no attached Wayland display
                                // (e.g. via `setsid -f` during dev reload).
                                command: ["/bin/sh", "-c", "quickshell -p ~/dotfiles/Quickshell/notifications/shell.qml ipc --any-display call notifications toggle"]
                            }
                            Process {
                                id: dndToggleProc
                                command: ["/bin/sh", "-c", "quickshell -p ~/dotfiles/Quickshell/notifications/shell.qml ipc --any-display call notifications dndToggle"]
                            }

                            Text {
                                id: bellIcon
                                anchors.centerIn: parent
                                text: root.notifDnd ? Bar.Icons.bellOff : Bar.Icons.bell
                                color: root.notifDnd ? Bar.Theme.textMuted : Bar.Theme.icon
                                font.family: Bar.Theme.fontFamily
                                font.pixelSize: Bar.Theme.iconSize
                                transformOrigin: Item.Center

                                Binding on rotation {
                                    when: !bellCell.ringing
                                    value: (bellHover.hovered && !bellCell.suppressHover) ? -45 : 0
                                }

                                Behavior on rotation {
                                    enabled: !bellCell.ringing
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }

                            // Unread dot — sibling of bellIcon so it stays
                            // pinned to the cell's top-right while the bell
                            // tilts or rings underneath it.
                            Rectangle {
                                visible: root.notifUnread > 0 && !root.notifDnd
                                width: 7; height: 7; radius: 3.5
                                color: Bar.Theme.alert
                                border.color: Bar.Theme.bg
                                border.width: 1
                                x: bellIcon.x + bellIcon.implicitWidth  - width + 1
                                y: bellIcon.y - 1
                            }

                            HoverHandler {
                                id: bellHover
                                onHoveredChanged: {
                                    if (!hovered) bellCell.suppressHover = false;
                                }
                            }
                            TapHandler {
                                onTapped: {
                                    bellRingAnim.restart();
                                    toggleNotifProc.running = true;
                                }
                            }
                            TapHandler {
                                acceptedButtons: Qt.RightButton
                                onTapped: dndToggleProc.running = true
                            }

                            SequentialAnimation {
                                id: bellRingAnim
                                ScriptAction { script: bellCell.ringing = true }
                                NumberAnimation { target: bellIcon; property: "rotation"; to: -28; duration: 70 }
                                NumberAnimation { target: bellIcon; property: "rotation"; to:  28; duration: 110 }
                                NumberAnimation { target: bellIcon; property: "rotation"; to: -20; duration: 100 }
                                NumberAnimation { target: bellIcon; property: "rotation"; to:  20; duration: 90 }
                                NumberAnimation { target: bellIcon; property: "rotation"; to: -12; duration: 80 }
                                NumberAnimation { target: bellIcon; property: "rotation"; to:  12; duration: 70 }
                                NumberAnimation { target: bellIcon; property: "rotation"; to:   0; duration: 60 }
                                ScriptAction {
                                    script: {
                                        bellCell.ringing = false;
                                        // Stay level after the ring unless the
                                        // user leaves and re-enters the bell.
                                        if (bellHover.hovered) bellCell.suppressHover = true;
                                    }
                                }
                            }
                        }
                    }
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    C.DotSep {}
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    C.SegmentPill {
                        C.Module {
                            icon: Bar.Icons.github
                            label: gh.issueCount < 0 ? "–" : gh.issueCount.toString()
                            labelColor: gh.issueCount > 0 ? Bar.Theme.text : Bar.Theme.textMuted
                        }
                        C.VSep {}
                        C.Module {
                            icon: Bar.Icons.github_pr
                            label: gh.prCount < 0 ? "–" : gh.prCount.toString()
                            labelColor: gh.prCount > 0 ? Bar.Theme.text : Bar.Theme.textMuted
                        }
                    }
                }
            }
        }
    }
}
