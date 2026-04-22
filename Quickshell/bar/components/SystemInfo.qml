import QtQuick
import Quickshell.Io

// Centralised polling of system metrics so every module reads from a single
// source. Spawns short-lived shell processes on a timer to keep QML simple.
QtObject {
    id: sys

    // Published observable state ------------------------------------------
    property int    cpuPercent: 0
    property string memUsedHuman: "--"
    property int    memPercent: 0
    property int    cpuTempC: 0
    property int    gpuTempC: 0
    property int    gpuMemMiB: 0
    property int    gpuUtilPercent: 0
    property int    batteryPercent: 0
    property string batteryStatus: "Unknown"
    property string wifiSsid: ""
    property int    netDownKbps: 0
    property int    netUpKbps: 0
    property int    volumePercent: 0
    property bool   volumeMuted: false
    property string diskUsedPercent: "0%"

    // Internal CPU sampling state
    property int _lastCpuIdle: 0
    property int _lastCpuTotal: 0

    // Internal network sampling state (bytes, monotonic)
    property real _lastNetRx: 0
    property real _lastNetTx: 0
    property real _lastNetTime: 0

    // Processes -----------------------------------------------------------
    property Process cpuProc: Process {
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split(/\s+/);
                const idle = parseInt(p[4]) + parseInt(p[5]);
                const total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (sys._lastCpuTotal > 0) {
                    const dTotal = total - sys._lastCpuTotal;
                    const dIdle  = idle  - sys._lastCpuIdle;
                    sys.cpuPercent = dTotal > 0
                        ? Math.max(0, Math.min(100, Math.round(100 * (1 - dIdle / dTotal))))
                        : 0;
                }
                sys._lastCpuTotal = total;
                sys._lastCpuIdle  = idle;
            }
        }
    }

    property Process memProc: Process {
        command: ["sh", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%d %d\\n\", t, a}' /proc/meminfo"]
        stdout: SplitParser {
            onRead: data => {
                const [total, avail] = data.trim().split(/\s+/).map(Number);
                if (!total) return;
                const usedKb = total - avail;
                sys.memPercent = Math.round(100 * usedKb / total);
                const usedGiB = usedKb / 1024 / 1024;
                sys.memUsedHuman = usedGiB >= 1
                    ? usedGiB.toFixed(2) + " GiB"
                    : Math.round(usedKb / 1024) + " MiB";
            }
        }
    }

    property Process tempProc: Process {
        // First thermal zone; swap to a specific zone (x86_pkg_temp etc.) if desired.
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                const raw = parseInt(data.trim());
                sys.cpuTempC = raw > 0 ? Math.round(raw / 1000) : 0;
            }
        }
    }

    property Process gpuProc: Process {
        command: ["sh", "-c", "nvidia-smi --query-gpu=temperature.gpu,memory.used,utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(",").map(s => parseInt(s.trim()));
                if (parts.length >= 3 && !isNaN(parts[0])) {
                    sys.gpuTempC = parts[0];
                    sys.gpuMemMiB = parts[1];
                    sys.gpuUtilPercent = parts[2];
                }
            }
        }
    }

    property Process batProc: Process {
        command: ["sh", "-c", "for d in /sys/class/power_supply/BAT*; do [ -e \"$d\" ] && echo \"$(cat $d/capacity) $(cat $d/status)\" && break; done"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/);
                if (parts.length >= 2) {
                    sys.batteryPercent = parseInt(parts[0]) || 0;
                    sys.batteryStatus  = parts[1] || "Unknown";
                }
            }
        }
    }

    property Process wifiProc: Process {
        command: ["sh", "-c", "iwgetid -r 2>/dev/null | head -1"]
        stdout: SplitParser {
            onRead: data => { sys.wifiSsid = data.trim(); }
        }
    }

    property Process volProc: Process {
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\\d+%' | head -1; pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null"]
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split("\n").map(s => s.trim()).filter(Boolean);
                for (const l of lines) {
                    if (l.endsWith("%")) sys.volumePercent = parseInt(l);
                    else if (l.startsWith("Mute:")) sys.volumeMuted = l.endsWith("yes");
                }
            }
        }
    }

    property Process netProc: Process {
        command: ["sh", "-c", "awk 'NR>2 && $1 !~ /^(lo:|docker|veth|br-)/ {rx+=$2; tx+=$10} END{printf \"%d %d\\n\", rx, tx}' /proc/net/dev"]
        stdout: SplitParser {
            onRead: data => {
                const [rx, tx] = data.trim().split(/\s+/).map(Number);
                const now = Date.now() / 1000;
                if (sys._lastNetTime > 0) {
                    const dt = now - sys._lastNetTime;
                    if (dt > 0) {
                        sys.netDownKbps = Math.max(0, Math.round((rx - sys._lastNetRx) / dt / 1024));
                        sys.netUpKbps   = Math.max(0, Math.round((tx - sys._lastNetTx) / dt / 1024));
                    }
                }
                sys._lastNetRx = rx;
                sys._lastNetTx = tx;
                sys._lastNetTime = now;
            }
        }
    }

    property Process diskProc: Process {
        command: ["sh", "-c", "df -h / | awk 'NR==2 {print $5}'"]
        stdout: SplitParser {
            onRead: data => { sys.diskUsedPercent = data.trim() || "0%"; }
        }
    }

    // Tickers -------------------------------------------------------------
    property Timer fastTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            sys.cpuProc.running = true;
            sys.memProc.running = true;
            sys.netProc.running = true;
            sys.volProc.running = true;
            sys.gpuProc.running = true;
        }
    }
    property Timer slowTimer: Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            sys.tempProc.running = true;
            sys.batProc.running = true;
            sys.wifiProc.running = true;
            sys.diskProc.running = true;
        }
    }
}
