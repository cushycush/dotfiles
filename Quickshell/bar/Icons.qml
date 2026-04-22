pragma Singleton

import QtQuick

// Nerd Font codepoints (MDI range unless noted). Using fromCodePoint keeps
// this file pure-ASCII so the glyphs survive any transform along the way.
QtObject {
    readonly property string cpu:       String.fromCodePoint(0xF061A)  // mdi-chip
    readonly property string memory:    String.fromCodePoint(0xF035B)  // mdi-memory
    readonly property string thermo:    String.fromCodePoint(0xF050F)  // mdi-thermometer
    readonly property string clock:     String.fromCodePoint(0xF00F3)  // mdi-clock
    readonly property string weekday:   String.fromCodePoint(0xF00EE)  // mdi-calendar-today
    readonly property string calendar:  String.fromCodePoint(0xF00ED)  // mdi-calendar
    readonly property string disk:      String.fromCodePoint(0xF02CA)  // mdi-harddisk
    readonly property string battery:   String.fromCodePoint(0xF0079)  // mdi-battery
    readonly property string charging:  String.fromCodePoint(0xF0084)  // mdi-battery-charging
    readonly property string wifi:      String.fromCodePoint(0xF05A9)  // mdi-wifi
    readonly property string wifiOff:   String.fromCodePoint(0xF05AA)  // mdi-wifi-off
    readonly property string down:      String.fromCodePoint(0xF0045)  // mdi-arrow-down
    readonly property string up:        String.fromCodePoint(0xF005D)  // mdi-arrow-up
    readonly property string bluetooth: String.fromCodePoint(0xF00AF)  // mdi-bluetooth
    readonly property string volHigh:   String.fromCodePoint(0xF057E)  // mdi-volume-high
    readonly property string volMed:    String.fromCodePoint(0xF0580)  // mdi-volume-medium
    readonly property string volLow:    String.fromCodePoint(0xF057F)  // mdi-volume-low
    readonly property string volMute:   String.fromCodePoint(0xF075F)  // mdi-volume-mute
    readonly property string bell:      String.fromCodePoint(0xF009A)  // mdi-bell
    readonly property string github:    String.fromCodePoint(0xF02A4)  // mdi-github
    readonly property string rss:       String.fromCodePoint(0xF033B)  // mdi-rss
    readonly property string headphones: String.fromCodePoint(0xF02CB) // mdi-headphones
    readonly property string github_pr: String.fromCodePoint(0xF0A31)  // mdi-source-pull
    readonly property string bug:       String.fromCodePoint(0xF00E4)  // mdi-bug
    readonly property string fire:      String.fromCodePoint(0xF0238)  // mdi-fire — GPU temp
    readonly property string speedo:    String.fromCodePoint(0xF04C5)  // mdi-speedometer — GPU util
    readonly property string gpu:       String.fromCodePoint(0xF1BEB)  // mdi-expansion-card-variant
}
