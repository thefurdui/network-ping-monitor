#!/bin/bash

# Output file
OUTPUT_FILE="network_ping_log.txt"

# URL of a file to download for testing (choose a small file)
DOWNLOAD_URL="http://speedtest.tele2.net/1MB.zip"

# Infinite loop to continuously check internet speed
while true; do
    # Get current timestamp
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Measure download speed
    DOWNLOAD_SPEED=$(curl -s -w '%{speed_download}' -o /dev/null $DOWNLOAD_URL)
    DOWNLOAD_SPEED_Mbps=$(echo "scale=2; $DOWNLOAD_SPEED / 125000" | bc)

    # Check if speeds are valid numbers
    if ! [[ $DOWNLOAD_SPEED_Mbps =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "$TIMESTAMP | Download: $DOWNLOAD_SPEED_Mbps Mbps | DROP" >> $OUTPUT_FILE
    else
        echo "$TIMESTAMP | Download: $DOWNLOAD_SPEED_Mbps Mbps" >> $OUTPUT_FILE
    fi

    # Wait for 1 second before the next test
    sleep 1
done

