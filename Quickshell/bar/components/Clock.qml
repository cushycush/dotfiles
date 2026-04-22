import QtQuick

// Ticking clock state — exposes .time and .date strings updated each second.
QtObject {
    id: clock
    property string time: ""
    property string date: ""

    property Timer timer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date();
            clock.time = Qt.formatDateTime(now, "HH:mm");
            clock.date = Qt.formatDateTime(now, "d MMMM");
        }
    }
}
