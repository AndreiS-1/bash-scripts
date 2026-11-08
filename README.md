# DevOps & System Administration Scripts

This repository contains a collection of Bash scripts used for system monitoring, parsing log files, creating backups, and organizing directories on Linux systems.

These scripts are designed to be simple, readable, and easy to run, making them ideal for daily administrative tasks.

## Scripts at a glance

| Script | What it does | How to run |
|---|---|---|
| `log_parser.sh` | Extracts line counts, unique IPs and INFO/WARN/ERROR stats from a log file | `./log_parser.sh <path_to_log_file>` |
| `health_check.sh` | Checks connectivity, disk usage and critical services | `./health_check.sh` |
| `monitor.sh` | Logs memory usage, disk alerts (80%) and top 5 CPU processes | `./monitor.sh` |
| `organizer.sh` | Creates a standard set of subfolders in a target directory | `./organizer.sh </path/to/folder>` |
| `backups_devops.sh` | System checks and compressed backup of the home directory | `./backups_devops.sh -c`, `-b` or `-f` |

## Requirements

- Linux with Bash
- Some scripts are written for **Arch-based distributions**: `health_check.sh` lists recent packages with Pacman and checks services such as NetworkManager. On other distributions these parts may fail or need adapting.

## Installation

All scripts require executable permissions before they can be run.

```bash
git clone <your_repository_url>
cd <repository_folder>
chmod +x *.sh
```

## Script details

### 1. log_parser.sh

Parses log files to extract line counts, unique IP addresses, and standard message stats (INFO, WARN, ERROR).

- **Usage:** `./log_parser.sh <path_to_log_file>`
- **Output:** displays a summary in the terminal and saves it to `$HOME/logs/parsed_<filename>_<date>.txt`

### 2. health_check.sh

A quick diagnostic tool that checks internet connectivity, disk usage, and the status of critical services (like NetworkManager). It also lists recently installed Pacman packages.

- **Usage:** `./health_check.sh`
- **Output:** saves a full execution log to `$HOME/logs/health_<timestamp>.txt` and prints a summary to the console

### 3. monitor.sh

A monitoring script designed for cron jobs or periodic manual execution. It logs memory usage, alerts if disk partitions exceed an 80% threshold, verifies system services, and lists the top 5 CPU-intensive processes.

- **Usage:** `./monitor.sh`
- **Output:** appends execution data to `$HOME/logs/monitor_<date>.log`

### 4. organizer.sh

Automates directory structuring. It takes a target directory path and automatically creates a standard set of subfolders (`texts`, `logs`, `scripts`, and `others`) inside it.

- **Usage:** `./organizer.sh </path/to/folder>`

### 5. backups_devops.sh

An interactive CLI tool for both system validation and home directory backups. It excludes cache folders to save space when creating the compressed `.tar.gz` archive.

You can edit the script to change the target backup path, customize the list of monitored services, or specify custom IPs to ping.

- **Usage:**
  - `./backups_devops.sh -c` runs system checks only
  - `./backups_devops.sh -b` runs the backup only
  - `./backups_devops.sh -f` runs the full check and backup
- **Output:** system logs are saved to `/tmp/system_check.log` and backup archives to `/tmp/backups/`

> **Warning:** `/tmp` is usually cleared on reboot. Copy the archives somewhere permanent, or change the backup path in the script.

## Note on documentation

The core structure and text of this README were generated with the assistance of AI, then manually reviewed and adapted to accurately match the code behavior.
