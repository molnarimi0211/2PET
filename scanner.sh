#!/bin/bash

#Define the output file to store the list of old files
OUTPUT_FILE="filtered_files_$(date +%Y%m%d_%H%M%S).txt"

#Ask the user for the directory to scan, with a default
read -p "Enter the directory you want to scan (press Enter for your home directory - $HOME): " USER_INPUT_DIR

#Set SCAN_DIR based on user input or default to HOME
if [ -z "$USER_INPUT_DIR" ]; then
    SCAN_DIR="$HOME"
    echo "No directory entered, defaulting to your home directory: $SCAN_DIR"
else
    SCAN_DIR="$USER_INPUT_DIR"
fi

#Checking if the entered/defaulted directory exists
if [ ! -d "$SCAN_DIR" ]; then
    echo "Error: The directory '$SCAN_DIR' does not exist or is not a directory."
    exit 1
fi

#Ask for the number of days
DEFAULT_DAYS="90" # Approximately 3 months
read -p "Enter the number of days (files older than this will be considered, press Enter for $DEFAULT_DAYS days): " USER_INPUT_DAYS

#Set NUM_DAYS based on user input or default
if [ -z "$USER_INPUT_DAYS" ]; then
    NUM_DAYS="$DEFAULT_DAYS"
    echo "No number of days entered, defaulting to $NUM_DAYS days."
else
    #Validation for days
    if ! [[ "$USER_INPUT_DAYS" =~ ^[0-9]+$ ]] || [ "$USER_INPUT_DAYS" -le 0 ]; then
        echo "Error: Invalid number of days. Please enter a positive integer."
        exit 1
    fi
    NUM_DAYS="$USER_INPUT_DAYS"
fi


#Ask the user for the minimum file size
DEFAULT_SIZE="5M" # 5 Megabytes
read -p "Enter the minimum file size (e.g., 100k, 5M, 1G, press Enter for $DEFAULT_SIZE): " USER_INPUT_SIZE

#Set FILE_SIZE_CRITERIA based on user input or default
if [ -z "$USER_INPUT_SIZE" ]; then
    FILE_SIZE_CRITERIA="+$DEFAULT_SIZE" # + means "greater than"
    echo "No minimum file size entered, defaulting to files larger than $DEFAULT_SIZE."
else
#Prepending '+' to ensure 'greater than' behavior for find command
    if [[ "$USER_INPUT_SIZE" =~ ^[0-9]+[kKmMGT]$ ]]; then
        FILE_SIZE_CRITERIA="+$USER_INPUT_SIZE"
    else
        echo "Error: Invalid file size format. Use numbers followed by k, M, G, or T (e.g., 100k, 5M, 1G)."
        exit 1
    fi
fi

echo "..."
echo "Searching for files in: $SCAN_DIR"
echo "  - Older than: $NUM_DAYS days"
echo "  - Larger than: $(echo "$FILE_SIZE_CRITERIA" | sed 's/^+//') (after removing the '+' sign)"
echo "Results will be saved to: $OUTPUT_FILE"
echo "This might take a while depending on the size of the directory and your criteria."
echo "---"


find "$SCAN_DIR" -type f -mtime +$NUM_DAYS -size "$FILE_SIZE_CRITERIA" -print0 | while IFS= read -r -d $'\0' file; do
    echo "$file" >> "$OUTPUT_FILE"
done

echo "..."
echo "Scan complete. Filtered files list saved to: $OUTPUT_FILE"
echo "Number of filtered files found: $(wc -l < "$OUTPUT_FILE")"
