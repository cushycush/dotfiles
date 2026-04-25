import QtQuick
import Quickshell.Io

// Polling + actions for the system-settings panel. Kept as a plain
// QtObject (instantiated by shell.qml) so consumers can bind to the
// published properties like any other model.
QtObject {
    id: state

    // ── Bluetooth ────────────────────────────────────────────────────────
    property bool btAvailable: false
    property bool btPowered:   false
    // [{ mac: "AA:BB:...", name: "My Headphones", connected: bool }]
    property var  btDevices: []

    // ── Wi-Fi (NetworkManager) ───────────────────────────────────────────
    property bool wifiAvailable: false
    property bool wifiEnabled:   false
    property string wifiActiveSsid: ""
    // [{ ssid, signal, security, active }]
    property var wifiNetworks: []

    // ── Sound (PipeWire/PulseAudio via pactl) ────────────────────────────
    property int  volumePercent: 0
    property bool muted:         false
    property string defaultSinkName: ""
    // [{ name, description, active }]
    property var  sinks: []

    // ── Polling ──────────────────────────────────────────────────────────
    property Process btProc: Process {
        // Lines: "POWERED yes|no", then one "DEV mac|name|yes|no" per paired device.
        command: ["sh", "-c",
            "if ! command -v bluetoothctl >/dev/null 2>&1; then echo 'UNAVAIL'; exit; fi; " +
            "show=$(bluetoothctl show 2>/dev/null); " +
            "if [ -z \"$show\" ]; then echo 'UNAVAIL'; exit; fi; " +
            "pw=$(printf '%s\\n' \"$show\" | awk '/Powered:/ {print $2; exit}'); " +
            "echo \"POWERED ${pw:-no}\"; " +
            "connected=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}'); " +
            "bluetoothctl devices Paired 2>/dev/null | while read _ mac rest; do " +
            "  conn=no; for c in $connected; do [ \"$c\" = \"$mac\" ] && conn=yes; done; " +
            "  printf 'DEV %s|%s|%s\\n' \"$mac\" \"$rest\" \"$conn\"; " +
            "done"]
        stdout: StdioCollector {
            onStreamFinished: state.parseBluetooth(this.text)
        }
    }

    property Process wifiProc: Process {
        // Lines: "AVAIL yes|no", "ENABLED yes|no", "ACTIVE <ssid>", "NET ssid|signal|security|active".
        command: ["sh", "-c",
            "if ! command -v nmcli >/dev/null 2>&1; then echo 'AVAIL no'; exit; fi; " +
            "echo 'AVAIL yes'; " +
            "en=$(nmcli -t -f WIFI radio 2>/dev/null); " +
            "echo \"ENABLED ${en:-disabled}\"; " +
            "act=$(nmcli -t -f ACTIVE,SSID d wifi 2>/dev/null | awk -F: '$1==\"yes\"{print $2; exit}'); " +
            "echo \"ACTIVE ${act}\"; " +
            "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY d wifi list --rescan no 2>/dev/null | " +
            "  awk -F: 'NF>=4 && $2!=\"\" {u=$1; ssid=$2; sig=$3; sec=$4; " +
            "    for (i=5;i<=NF;i++) sec=sec\":\"$i; " +
            "    printf \"NET %s|%s|%s|%s\\n\", ssid, sig, sec, (u==\"*\")?\"yes\":\"no\"}'"]
        stdout: StdioCollector {
            onStreamFinished: state.parseWifi(this.text)
        }
    }

    property Process soundProc: Process {
        // Lines: "VOL <pct>", "MUTE yes|no", "DEFAULT <name>", "SINK name|description|active".
        command: ["sh", "-c",
            "vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\\d+%' | head -1 | tr -d '%'); " +
            "echo \"VOL ${vol:-0}\"; " +
            "mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}'); " +
            "echo \"MUTE ${mute:-no}\"; " +
            "def=$(pactl get-default-sink 2>/dev/null); " +
            "echo \"DEFAULT ${def}\"; " +
            "pactl -f json list sinks 2>/dev/null | " +
            "  jq -r --arg def \"$def\" '.[] | \"SINK \\(.name)|\\(.description)|\" + (if .name == $def then \"yes\" else \"no\" end)' 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: state.parseSound(this.text)
        }
    }

    // Action processes -- refresh the affected card after they exit so the
    // UI reflects reality without waiting for the next poll tick.
    property Process btActionProc: Process {
        onExited: state.btProc.running = true
    }
    property Process wifiActionProc: Process {
        onExited: state.wifiProc.running = true
    }
    property Process soundActionProc: Process {
        onExited: state.soundProc.running = true
    }
    property Process wifiEditorProc: Process { }

    // ── Actions ──────────────────────────────────────────────────────────
    function btTogglePower() {
        btActionProc.command = ["sh", "-c",
            "pw=$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2; exit}'); " +
            "if [ \"$pw\" = \"yes\" ]; then bluetoothctl power off; " +
            "else bluetoothctl power on; fi"];
        btActionProc.running = true;
    }

    function btConnect(mac)    { btActionProc.command = ["bluetoothctl", "connect",    mac]; btActionProc.running = true; }
    function btDisconnect(mac) { btActionProc.command = ["bluetoothctl", "disconnect", mac]; btActionProc.running = true; }

    function wifiToggle() {
        wifiActionProc.command = ["sh", "-c",
            "en=$(nmcli -t -f WIFI radio 2>/dev/null); " +
            "if [ \"$en\" = \"enabled\" ]; then nmcli radio wifi off; " +
            "else nmcli radio wifi on; fi"];
        wifiActionProc.running = true;
    }

    function wifiRescan() {
        wifiActionProc.command = ["sh", "-c", "nmcli d wifi rescan 2>/dev/null; sleep 2"];
        wifiActionProc.running = true;
    }

    function wifiOpenEditor(ssid) {
        // Launch detached so the editor outlives our shell process.
        wifiEditorProc.command = ["sh", "-c",
            ssid && ssid.length > 0
                ? `nm-connection-editor --edit="${ssid}" >/dev/null 2>&1 &`
                : "nm-connection-editor >/dev/null 2>&1 &"];
        wifiEditorProc.running = true;
    }

    function volSet(percent) {
        const pct = Math.max(0, Math.min(100, Math.round(percent)));
        soundActionProc.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", pct + "%"];
        soundActionProc.running = true;
    }
    function muteToggle() {
        soundActionProc.command = ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"];
        soundActionProc.running = true;
    }
    function sinkSelect(name) {
        soundActionProc.command = ["pactl", "set-default-sink", name];
        soundActionProc.running = true;
    }

    function refreshAll() {
        btProc.running    = true;
        wifiProc.running  = true;
        soundProc.running = true;
    }

    // ── Parsers ──────────────────────────────────────────────────────────
    function parseBluetooth(text) {
        const lines = (text || "").split("\n").map(s => s.trim()).filter(Boolean);
        if (lines.length === 0 || lines[0] === "UNAVAIL") {
            state.btAvailable = false;
            state.btPowered   = false;
            state.btDevices   = [];
            return;
        }
        state.btAvailable = true;
        const devs = [];
        for (const l of lines) {
            if (l.startsWith("POWERED ")) {
                state.btPowered = l.substring(8) === "yes";
            } else if (l.startsWith("DEV ")) {
                const rest = l.substring(4);
                const parts = rest.split("|");
                if (parts.length >= 3) {
                    devs.push({
                        mac: parts[0],
                        name: parts[1],
                        connected: parts[2] === "yes",
                    });
                }
            }
        }
        state.btDevices = devs;
    }

    function parseWifi(text) {
        const lines = (text || "").split("\n").map(s => s.trim()).filter(Boolean);
        state.wifiAvailable  = false;
        state.wifiEnabled    = false;
        state.wifiActiveSsid = "";
        const nets = [];
        for (const l of lines) {
            if (l === "AVAIL yes")       state.wifiAvailable = true;
            else if (l === "AVAIL no")   state.wifiAvailable = false;
            else if (l.startsWith("ENABLED ")) state.wifiEnabled = l.substring(8) === "enabled";
            else if (l.startsWith("ACTIVE "))  state.wifiActiveSsid = l.substring(7);
            else if (l.startsWith("NET ")) {
                const parts = l.substring(4).split("|");
                if (parts.length >= 4) {
                    nets.push({
                        ssid: parts[0],
                        signal: parseInt(parts[1]) | 0,
                        security: parts[2],
                        active: parts[3] === "yes",
                    });
                }
            }
        }
        // Same SSID can appear per-BSSID; keep the strongest-signal row but
        // OR `active` across all (the "*" marker may sit on a weaker BSSID).
        const byName = {};
        for (const n of nets) {
            const ex = byName[n.ssid];
            if (!ex) { byName[n.ssid] = n; continue; }
            byName[n.ssid] = {
                ssid:     n.ssid,
                signal:   Math.max(ex.signal, n.signal),
                security: (ex.signal >= n.signal) ? ex.security : n.security,
                active:   ex.active || n.active,
            };
        }
        const uniq = Object.values(byName).sort((a, b) => {
            if (a.active !== b.active) return a.active ? -1 : 1;
            return b.signal - a.signal;
        });
        state.wifiNetworks = uniq;
    }

    function parseSound(text) {
        const lines = (text || "").split("\n").map(s => s.trim()).filter(Boolean);
        const sinkArr = [];
        for (const l of lines) {
            if (l.startsWith("VOL "))          state.volumePercent = parseInt(l.substring(4)) | 0;
            else if (l.startsWith("MUTE "))    state.muted = l.substring(5) === "yes";
            else if (l.startsWith("DEFAULT ")) state.defaultSinkName = l.substring(8);
            else if (l.startsWith("SINK ")) {
                const parts = l.substring(5).split("|");
                if (parts.length >= 3) {
                    sinkArr.push({
                        name: parts[0],
                        description: parts[1] === "(null)" ? parts[0] : parts[1],
                        active: parts[2] === "yes",
                    });
                }
            }
        }
        state.sinks = sinkArr;
    }

    // ── Tickers ──────────────────────────────────────────────────────────
    property Timer poll: Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: state.refreshAll()
    }
}
