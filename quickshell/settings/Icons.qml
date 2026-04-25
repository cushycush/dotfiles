pragma Singleton

import QtQuick

QtObject {
    readonly property string bluetooth:          String.fromCodePoint(0xF00AF)  // mdi-bluetooth
    readonly property string bluetoothOff:       String.fromCodePoint(0xF00B2)
    readonly property string bluetoothConnected: String.fromCodePoint(0xF00B1)
    readonly property string wifi:               String.fromCodePoint(0xF05A9)
    readonly property string wifiOff:            String.fromCodePoint(0xF05AA)
    readonly property string wifiLock:           String.fromCodePoint(0xF099D)  // mdi-wifi-lock
    readonly property string volHigh:            String.fromCodePoint(0xF057E)
    readonly property string volMed:             String.fromCodePoint(0xF0580)
    readonly property string volLow:             String.fromCodePoint(0xF057F)
    readonly property string volMute:            String.fromCodePoint(0xF075F)
    readonly property string check:              String.fromCodePoint(0xF012C)  // mdi-check
    readonly property string chevron:            String.fromCodePoint(0xF0142)  // mdi-chevron-right
    readonly property string cog:                String.fromCodePoint(0xF0493)  // mdi-cog
    readonly property string refresh:            String.fromCodePoint(0xF0450)  // mdi-refresh
}
