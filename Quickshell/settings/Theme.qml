pragma Singleton

import QtQuick

// Matches the bar / notifications palette. Kept as its own copy per
// shell since qmldir singletons are scoped.
QtObject {
    readonly property color bg:         "#242933"
    readonly property color bgElev:     "#2B313D"   // one step above bg for cards
    readonly property color text:       "#D8DEE9"
    readonly property color textBold:   "#ECEFF4"
    readonly property color textMuted:  "#6e6a86"

    readonly property color icon:       "#EBCB8B"
    readonly property color iconBlue:   "#81A1C1"
    readonly property color iconTeal:   "#88C0D0"

    readonly property color alert:      "#BF616A"
    readonly property color accent:     "#D08770"
    readonly property color good:       "#A3BE8C"

    readonly property color pillSurface: "#2E3440"
    readonly property color separator:   "#434C5E"

    readonly property string fontFamily: "MonoLisa Nerd Font"
    readonly property int    fontSize:   16
    readonly property int    iconSize:   20
}
