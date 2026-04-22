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

                // ── Center segmented super-pill: [time)  (alarm)  (date]
                RowLayout {
                    spacing: Bar.Theme.segGap
                    C.SegmentPill {
                        roundLeft: true;  roundRight: false
                        C.Module { icon: Bar.Icons.clock; label: clock.time }
                    }
                    C.SegmentPill {
                        roundLeft: false; roundRight: false
                        C.Module { icon: Bar.Icons.alarm; label: "14:00 2h" }
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
                        C.Module { icon: Bar.Icons.bluetooth }
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
                        C.Module { icon: Bar.Icons.bell }
                    }
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    C.DotSep {}
                    Item { implicitWidth: Bar.Theme.superPillGap }
                    C.SegmentPill {
                        C.Module { icon: Bar.Icons.github;    label: "0" }
                        C.VSep {}
                        C.Module { icon: Bar.Icons.github_pr; label: "0" }
                    }
                }
            }
        }
    }
}
