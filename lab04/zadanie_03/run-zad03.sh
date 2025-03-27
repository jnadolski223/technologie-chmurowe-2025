#!/bin/bash

total_space=$(df --output=size / | tail -1)
total_space_bytes=$((total_space * 1024))

docker system df -v | awk '/Local Volumes space usage:/,/Build cache usage:/' | awk 'NR>3 && NF>=2 {print $1, $NF}' | head -n -1 > volumes.txt

echo "=== Zużycie przestrzeni dyskowej przez wolumeny Docker ==="

while read -r volume_name volume_size; do

    case "$volume_size" in
        *kB) bytes_size=$(echo "$volume_size" | sed 's/kB//') 
             bytes_size=$(echo "$bytes_size * 1024" | bc | awk '{printf "%.0f", $1}') ;;
        *MB) bytes_size=$(echo "$volume_size" | sed 's/MB//') 
             bytes_size=$(echo "$bytes_size * 1024 * 1024" | bc | awk '{printf "%.0f", $1}') ;;
        *GB) bytes_size=$(echo "$volume_size" | sed 's/GB//') 
             bytes_size=$(echo "$bytes_size * 1024 * 1024 * 1024" | bc | awk '{printf "%.0f", $1}') ;;
        *B)  bytes_size=$(echo "$volume_size" | sed 's/B//') ;;
        *)   bytes_size=0 ;;
    esac

    if [[ "$bytes_size" -gt 0 ]]; then
        usage_percent=$(echo "($bytes_size / $total_space_bytes) * 100" | bc)
        echo "$volume_name: $usage_percent%"
    else
        echo "$volume_name: 0%"
    fi
done < volumes.txt

rm volumes.txt
