import QtQuick
import Quickshell.Io

// Polls GitHub via `gh` for the current user's open PRs and assigned
// issues across all repos. Slow cadence (3 min) — way under the
// authenticated search API's 30-req/min ceiling. If `gh` is missing
// or unauthenticated both counts stay at -1, which the bar renders
// as a dash.
QtObject {
    id: gh

    property int prCount: -1
    property int issueCount: -1

    property Process proc: Process {
        command: ["sh", "-c",
            "PR=$(gh api --method GET /search/issues -f 'q=is:open is:pr author:@me' --jq '.total_count' 2>/dev/null || echo -1); " +
            "IS=$(gh api --method GET /search/issues -f 'q=is:open is:issue assignee:@me' --jq '.total_count' 2>/dev/null || echo -1); " +
            "echo \"$PR $IS\""]
        stdout: SplitParser {
            onRead: data => {
                const [pr, is] = data.trim().split(/\s+/).map(Number);
                if (!Number.isNaN(pr)) gh.prCount    = pr;
                if (!Number.isNaN(is)) gh.issueCount = is;
            }
        }
    }

    property Timer ticker: Timer {
        interval: 180000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: gh.proc.running = true
    }
}
