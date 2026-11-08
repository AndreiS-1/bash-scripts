#!/bin/bash

DISK_THRESHOLD=80
STATUS_INTERNET="OK"
STATUS_DISK="OK"
STATUS_NM="OK"

mkdir -p "$HOME/logs"
LOG_FILE="$HOME/logs/health_$(date +%Y%m%d_%H%M).txt"

internet_connectivity() {
    ping_result=$(ping -c 1 -W 2 8.8.8.8 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo "Warning! Network unreachable or packet loss."
        STATUS_INTERNET="WARNING"
    else
        loss=$(echo "$ping_result" | grep "packet loss" | awk -F'%' '{print $1}' | awk '{print $NF}')
        if [[ "$loss" -ne 0 ]]; then
            echo "Warning! Packet loss: $loss%."
            STATUS_INTERNET="WARNING"
        else
            echo "--Everything is OK, 0% loss--"
        fi
    fi
}

check_disk() {
    while read -r mount_point percent; do
        if [[ "$percent" -gt "$DISK_THRESHOLD" ]]; then
            echo "WARNING: $mount_point reached $percent%"
            STATUS_DISK="WARNING"
        else
            echo "INFO: $mount_point is OK ($percent%)"
        fi
    done < <(df --output=target,pcent | tail -n +2 | tr -d '%')
}

check_if_active() {
    variable="NetworkManager"
    is_active=$(systemctl is-active "$variable")
    if [[ "$is_active" != "active" ]]; then
        echo "WARNING: $variable is not active"
        STATUS_NM="WARNING"
    else
        echo "INFO: $variable is active"
    fi
}

last_installed() {
    packages=5
    echo "Last $packages installed packages:"
    grep "\[ALPM\] installed" /var/log/pacman.log | tail -n "$packages"
}

main() {
    echo "START"
    echo -e "\nInternet connectivity test: "
    internet_connectivity
    echo -e "\nDisk check: "
    check_disk
    echo -e "\nService status check: "
    check_if_active
    echo -e "\n"
    last_installed
    echo "END"
}

main > "$LOG_FILE"

echo "=== SUMMARY ==="
echo "Internet:       $STATUS_INTERNET"
echo "Disk:           $STATUS_DISK"
echo "NetworkManager: $STATUS_NM"
echo "Full log:       $LOG_FILE"
