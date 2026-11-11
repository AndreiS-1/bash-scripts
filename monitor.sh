#!/bin/bash

DISK_THRESHOLD=80
mkdir -p "$HOME/logs"
LOG_FILE="$HOME/logs/monitor_$(date +%Y%m%d).log"

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

check_disk() {
    while read -r mount_point percent; do
        if [[ "$percent" -gt "$DISK_THRESHOLD" ]]; then
            log "WARN" "$mount_point reached $percent%"
        else
            log "INFO" "$mount_point is OK ($percent%)"
        fi
    done < <(df --output=target,pcent | tail -n +2 | tr -d '% ')
}

check_memory() {
    local total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local free=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    log "INFO" "Total memory: $((total/1024)) MB, Free: $((free/1024)) MB"
}

check_processes() {
    log "INFO" "Top 5 processes by CPU usage:"
    ps aux --sort=-%cpu | head -n 6 | while read -r line; do
        log "INFO" "$line"
    done
}

check_load() {
    # Extrage valoarea "load average" pe ultimul minut
    local load=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | tr -d ' ')
    log "INFO" "CPU Load average (1 min): $load"
}

check_services() {
    SERVICES=("sshd" "cronie" "NetworkManager")

    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log "INFO" "$service is active"
        else
            log "WARN" "$service is not active"
        fi
    done
}

log "INFO" "Monitor started"
check_disk
check_memory
check_load
check_processes
check_services
log "INFO" "Monitor stopped"
