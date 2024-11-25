#!/bin/bash

# Output file
OUTPUT_FILE="network_ping_log.txt"

# URL of a file to download for testing (choose a small file)
DOWNLOAD_URL="http://speedtest.tele2.net/1MB.zip"

# URL of a server to upload data for testing (must accept PUT requests)
UPLOAD_URL="http://your-upload-test-server/upload"

# Size of data to upload (in bytes)
UPLOAD_SIZE=1048576  # 1 MB

# Create a temporary file for upload test
UPLOAD_FILE="upload_test_file.bin"
dd if=/dev/zero of=$UPLOAD_FILE bs=1 count=$UPLOAD_SIZE &> /dev/null

# Infinite loop to continuously check internet speed
while true; do
    # Get current timestamp
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Measure download speed
    DOWNLOAD_SPEED=$(curl -s -w '%{speed_download}' -o /dev/null $DOWNLOAD_URL)
    DOWNLOAD_SPEED_Mbps=$(echo "scale=2; $DOWNLOAD_SPEED / 125000" | bc)

    # Check if speeds are valid numbers
    if ! [[ $DOWNLOAD_SPEED_Mbps =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "$TIMESTAMP | Download: $DOWNLOAD_SPEED_Mbps Mbps | ERROR"
        DOWNLOAD_SPEED_Mbps="0.00"
    fi

    # Write the results to the output file
    if [ "$DOWNLOAD_SPEED_Mbps" = "0.00" ]; then
        echo "$TIMESTAMP | Download: $DOWNLOAD_SPEED_Mbps Mbps | DROP" >> $OUTPUT_FILE
    else
        echo "$TIMESTAMP | Download: $DOWNLOAD_SPEED_Mbps Mbps" >> $OUTPUT_FILE
    fi

    # Wait for 2 seconds before the next test
    sleep 2 
done

# Clean up
rm $UPLOAD_FILE
