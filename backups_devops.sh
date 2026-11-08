#!/bin/bash

DISK_TARGET=80
LOG_FILE="/tmp/system_check.log"

usage() {
    echo "Usage: $0 [options]"
    echo "-c | --check   to verify the system"
    echo "-b | --backup  to backup the home directory"
    echo "-f | --full    for everything mentioned above"
}

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

check_disk() {
    log "INFO" "---- Checking the disk -----"
    while read -r mount_point percent; do
        if [[ "$percent" -gt "$DISK_TARGET" ]]; then
            log "WARN" "$mount_point reached $percent%"
        else
            log "INFO" "$mount_point is OK ($percent%)"
        fi
    done < <(df --output=target,pcent | tail -n +2 | tr -d '%')
}

check_memory() {
    log "INFO" "---- Checking the memory ----"
    local total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local free=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    log "INFO" "Total memory: $((total/1024)) MB, Free: $((free/1024)) MB"
}

check_services() {
    log "INFO" "---- Checking the services ----"
    local services=(sshd NetworkManager docker bluetooth cronie)

    for s in "${services[@]}"; do
        if systemctl is-active --quiet "$s" 2>/dev/null; then
            log "INFO" "Service $s: ACTIVE"
        else
            log "WARN" "Service $s: INACTIVE / NOT INSTALLED"
        fi
    done
}

check_network() {
    local hosts=("1.1.1.1" "8.8.8.8" "google.com")
    log "INFO" "---- Checking the network ----"
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
            log "INFO" "Host $host: OK"
        else
            log "WARN" "Host $host: UNREACHABLE / OFFLINE"
        fi
    done
}

backup_needed() {
    log "INFO" "---- Starting Backup for $HOME/reincalzire ----"
    local backup_dir="/tmp/backups"
    local timestamp=$(date "+%Y%m%d_%H%M%S")
    local dest="$backup_dir/home_backup_${timestamp}.tar.gz"

    mkdir -p "$backup_dir"

    if tar --exclude="$HOME/.cache" -czf "$dest" "$HOME/reincalzire" 2>/dev/null; then
        log "INFO" "Backup successfully created at: $dest"
    else
        log "WARN" "Backup finished with warnings."
    fi
}

full_all() {
    check_disk
    check_memory
    check_services
    check_network
    backup_needed
}

do_check=false
do_backup=false
do_full=false

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help) usage; exit 0 ;;
            -c | --check) do_check=true ;;
            -b | --backup) do_backup=true ;;
            -f | --full) do_full=true ;;
            *) echo "Unknown argument: $1"; exit 1 ;;
        esac
        shift
    done

    if [[ "$do_check" == true ]]; then
        check_disk
        check_memory
        check_services
        check_network
    fi

    if [[ "$do_backup" == true ]]; then
        backup_needed
    fi

    if [[ "$do_full" == true ]]; then
        full_all
    fi
}

main "$@"
