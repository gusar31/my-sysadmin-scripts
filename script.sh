set -euo pipefail

readonly N=10
readonly LOG_FILE="/home/ubuntu/resource-monitor/monitor.log"

while true; do
    {
        date '+--- %Y-%m-%d %H:%M:%S ---'
        free -h
        df -h
        uptime
        printf '\n'
    } >> "$LOG_FILE"

    sleep "$N"
done