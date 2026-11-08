#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Error: No argument provided."
    echo "Usage: ./organizer.sh /path/to/folder"
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "Error: '$1' is not a valid directory."
    exit 1
fi

echo "Valid directory: $1"

mkdir -p "$1"/{texts,logs,scripts,others}
echo "Subdirectories created successfully in '$1'."
