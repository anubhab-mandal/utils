#!/bin/bash

read -p "Enter the characters you want to replace (to input white space, enter \ \ ): " chars
read -p "Enter the character or string you want to replace them with: " replacement
pattern=$(echo "$chars" | sed -E 's/(.)/\1|/g; s/\|$//')

echo "This will replace any of these characters: $chars, with '$replacement' in filenames."

read -p "Are you sure you want to proceed? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    directory="."

    # Use a for loop with a glob to process only files in the current directory
    for file in "$directory"/*; do
        if [ -f "$file" ]; then  # Ensure it's a file
            dir=$(dirname "$file")
            filename=$(basename -- "$file")
            if echo "$filename" | grep -qE "[$pattern]"; then
                newFilename=$(echo "$filename" | sed -E "s/[$pattern]/$replacement/g")
                newPath="$dir/$newFilename"
                if [ ! -e "$newPath" ]; then
                    mv -- "$file" "$newPath"
                    echo "Renamed '$file' to '$newPath'"
                else
                    echo "Target filename '$newPath' already exists. Skipping '$file'."
                fi
            fi
        fi
    done
else
    echo "Operation cancelled."
fi

