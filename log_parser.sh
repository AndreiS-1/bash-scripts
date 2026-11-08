#!/bin/bash

validate_file() {
    if [[ ! -f "$1" ]]; then
        echo "Error: File $1 does not exist."
        exit 1
    else
        echo "File $1 is valid."
    fi
}

start() {
    echo "Analyzed file: $(basename "$1")"
    echo "Analysis date: $(date +%Y-%m-%d)"
}

stats() {
    echo "ERROR: $(grep -c "ERROR" "$1")"
    echo "WARN: $(grep -c "WARN" "$1")"
    echo "INFO: $(grep -c "INFO" "$1")"
}

addresses() {
    local ips_found=$(grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$1" | sort -u)

    if [[ -z "$ips_found" ]]; then
        echo "No IP addresses found in the file."
    else
        echo "$ips_found"
    fi
}

lines_in_file() {
    echo "--- Total lines in file ---"
    wc -l < "$1"
}

main() {
    echo "---- File Validation ----"
    validate_file "$1"

    echo "=== LOG PARSER SUMMARY ==="
    start "$1"

    echo "--- Line Statistics ---"
    stats "$1"

    echo "--- IP Addresses Found ---"
    addresses "$1"

    lines_in_file "$1"
    echo "=== FINISHED ==="
}

mkdir -p "$HOME/logs"
main "$1" | tee "$HOME/logs/parsed_$(basename "$1")_$(date +%Y%m%d).txt"
