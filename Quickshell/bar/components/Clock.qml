import QtQuick

// Ticking clock state — exposes .time and .date strings updated each second.
QtObject {
    id: clock
    property string time: ""
    property string date: ""
    property string dayName: ""

    property Timer timer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date();
            clock.time = Qt.formatDateTime(now, "h:mm AP");
            clock.date = Qt.formatDateTime(now, "d MMMM");
            clock.dayName = Qt.formatDateTime(now, "dddd");
        }
    }
}
