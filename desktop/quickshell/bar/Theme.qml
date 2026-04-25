pragma Singleton

import QtQuick

// Nordic palette, flat aesthetic — transparent bar, warm yellow icons,
// cream text. No pills; the Pill component now acts as a pure grouping box.
QtObject {
    // Bar surface — solid Nord Polar Night, matching the Ghostty nordic base.
    readonly property color bg:         "#242933"

    // Semantic text roles
    readonly property color text:       "#D8DEE9"   // nord4 — cream
    readonly property color textBold:   "#ECEFF4"   // nord6 — snow
    readonly property color textMuted:  "#6e6a86"   // dimmed cream

    // Icon roles
    readonly property color icon:       "#EBCB8B"   // nord13 — aurora yellow
    readonly property color iconBlue:   "#81A1C1"   // nord9
    readonly property color iconTeal:   "#88C0D0"   // nord8

    // Status colors
    readonly property color alert:      "#BF616A"   // nord11 — red
    readonly property color accent:     "#D08770"   // nord12 — orange
    readonly property color good:       "#A3BE8C"   // nord14 — green
    readonly property color focus:      "#BF616A"   // red accent for focused workspace

    // Typography
    readonly property string fontFamily: "MonoLisa Nerd Font"
    readonly property int    fontSize:   16
    readonly property int    iconSize:   20

    // Segmented pill surfaces
    readonly property color pillSurface: "#2E3440"   // nord0 — one shade above bar bg
    readonly property color separator:   "#434C5E"   // nord2 — thin in-pill divider

    // Spacing
    readonly property int barHeight:     38
    readonly property int barMargin:     18
    readonly property int groupPadX:     0
    readonly property int modGap:        20
    readonly property int iconTextGap:   8
    readonly property int pillHeight:    30
    readonly property int pillPadX:      14
    readonly property int segGap:        3          // visual slice between middle segments
    readonly property int superPillGap:  18         // around the ⋮ dot-separator
}
