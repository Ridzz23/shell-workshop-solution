#!/bin/bash

# ===============================
# Bulk File Renamer
# Features:
#   ✅ Bulk renaming with custom prefix
#   ✅ Backup original files
#   ✅ Optional dry-run mode
# ===============================

# --- Check if correct arguments are passed ---
if [ $# -lt 2 ]; then
    echo "Usage: ./bulk_rename.sh <directory> <new_base_name> [--dry-run]"
    exit 1
fi

directory=$1
base_name=$2
dry_run=false

# --- Check if dry-run flag was provided ---
if [ "$3" == "--dry-run" ]; then
    dry_run=true
fi

# --- Verify directory exists ---
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' does not exist."
    exit 1
fi

# --- Create a backup directory ---
if [ "$dry_run" = false ]; then
    backup_dir="$directory/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    echo "Created backup folder: $backup_dir"
fi

# --- Copy files to backup ---
cp "$directory"/* "$backup_dir"/
echo "All original files backed up."

count=1

# --- Rename loop ---
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        extension="${file##*.}"
        filename=$(basename "$file")
        printf -v padded "%03d" "$count"   # pad with zeros
        new_name="${base_name}_${padded}.${extension}"

        if [ "$dry_run" = true ]; then
            echo "[DRY RUN] Would rename: $filename → $new_name"
        else
            mv "$file" "$directory/$new_name"
            echo "Renamed: $filename → $new_name"
        fi

        ((count++))
    fi
done

if [ "$dry_run" = true ]; then
    echo "Dry run complete — no files were changed."
else
    echo "All files renamed successfully!"
fi
