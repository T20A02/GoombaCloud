#!/bin/bash

# Define source folder and target directory
source_folder="/path/to/source/folder"
target_directory="remote:target/directory"

# Define the maximum age for files in days
max_age_days=30

# Function to backup the source folder
backup() {
    # Check if source folder exists
    if [ ! -d "$source_folder" ]; then
        echo "Error: Source folder not found."
        exit 1
    fi

    # Check if target directory exists
    if ! rclone lsf "$target_directory" &> /dev/null; then
        echo "Error: Target directory not found."
        exit 1
    fi

    # Generate current date
    current_date=$(date +"%Y%m%d")

    # Create a copy with date prefix
    copy_with_date="${current_date}_$(basename "$source_folder")"

    # Copy the folder to the target directory
    rclone copy "$source_folder" "$target_directory/$copy_with_date"

    echo "Backup completed successfully."
}

# Function to retrieve files based on date
retrieve() {
    retrieve_date=$1
    retrieve_folder="$target_directory/${retrieve_date}_$(basename "$source_folder")"

    # Check if retrieve folder exists
    if ! rclone lsf "$retrieve_folder" &> /dev/null; then
        echo "Error: Retrieve folder not found for date $retrieve_date."
        exit 1
    fi

    # Copy files back to the source folder
    rclone copy "$retrieve_folder" "$source_folder"

    echo "Files retrieved successfully for date $retrieve_date."
}

# Function to prune files older than max_age_days
prune() {
    # Prune files older than max_age_days
    rclone cleanup "$target_directory" --min-age "$max_age_days"d

    echo "Pruning completed successfully."
}

# If no arguments are provided, run the backup and prune
if [ $# -eq 0 ]; then
    backup
    prune
fi

# Process argument
case "$1" in
    "retrieve")
        if [ -z "$2" ]; then
            echo "Error: Date argument missing for retrieve."
            exit 1
        fi
        retrieve "$2"
        ;;
    "prune")
        prune
        ;;
    *)
        echo "Usage: $0 [backup|retrieve <date>|prune]"
        exit 1
        ;;
esac
