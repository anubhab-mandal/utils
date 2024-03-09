#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 file1 file2"
    exit 1
fi
hexdump1=$(xxd -p "$1" | tr -d '\n')
hexdump2=$(xxd -p "$2" | tr -d '\n')
minLength=$(echo -e "${#hexdump1}\n${#hexdump2}" | sort -n | head -n1)
let "progressBarLength=50"
let "unitsPerTick=$minLength/$progressBarLength"
matchCount=0
echo -n "Progress: ["
for (( i=0; i<$minLength; i++ )); do
    if [ "${hexdump1:$i:1}" = "${hexdump2:$i:1}" ]; then
        ((matchCount++))
    fi
    if ! ((i % unitsPerTick)); then echo -n "#"; fi
done
echo "] Done."
if [ $minLength -eq 0 ]; then
    echo "At least one file is empty."
    exit 1
fi
matchPercentage=$(echo "scale=2; ($matchCount / $minLength) * 100" | bc)
echo "Matching Hex Data: $matchPercentage%"

