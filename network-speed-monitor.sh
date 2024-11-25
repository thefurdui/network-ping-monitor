#!/bin/bash

# Output file
OUTPUT_FILE="network_speed_log.txt"

# Check if speedtest or speedtest-cli is installed
if command -v speedtest &> /dev/null; then
    SPEEDTEST_CMD="speedtest"
elif command -v speedtest-cli &> /dev/null; then
    SPEEDTEST_CMD="speedtest-cli"
else
    echo "Neither 'speedtest' nor 'speedtest-cli' is installed. Please install one of them before running the script."
    exit 1
fi

# Infinite loop to continuously check internet speed
while true; do
    # Get current timestamp
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ "$SPEEDTEST_CMD" = "speedtest" ]; then
        # Run speedtest without advanced arguments
        SPEEDTEST_OUTPUT=$($SPEEDTEST_CMD 2>&1)

        # Check if the output contains an error
        if echo "$SPEEDTEST_OUTPUT" | grep -qi 'error'; then
            echo "$TIMESTAMP | Error running speedtest" >> $OUTPUT_FILE
        else
            # Parse download and upload speeds from the output
            DOWNLOAD=$(echo "$SPEEDTEST_OUTPUT" | grep 'Download' | awk '{print $2}')
            UPLOAD=$(echo "$SPEEDTEST_OUTPUT" | grep 'Upload' | awk '{print $2}')
            DOWNLOAD_UNIT=$(echo "$SPEEDTEST_OUTPUT" | grep 'Download' | awk '{print $3}')
            UPLOAD_UNIT=$(echo "$SPEEDTEST_OUTPUT" | grep 'Upload' | awk '{print $3}')

            # Write the results to the output file
            echo "$TIMESTAMP | Download: $DOWNLOAD $DOWNLOAD_UNIT | Upload: $UPLOAD $UPLOAD_UNIT" >> $OUTPUT_FILE
        fi
    else
        # Run speedtest-cli
        SPEEDTEST_OUTPUT=$($SPEEDTEST_CMD --simple 2>&1)

        # Check for errors
        if echo "$SPEEDTEST_OUTPUT" | grep -qi 'Cannot\|Error'; then
            echo "$TIMESTAMP | Error running speedtest" >> $OUTPUT_FILE
        else
            # Extract Ping, Download, Upload speeds
            PING=$(echo "$SPEEDTEST_OUTPUT" | grep 'Ping' | awk '{print $2}')
            PING_UNIT=$(echo "$SPEEDTEST_OUTPUT" | grep 'Ping' | awk '{print $3}')
            DOWNLOAD=$(echo "$SPEEDTEST_OUTPUT" | grep 'Download' | awk '{print $2}')
            DOWNLOAD_UNIT=$(echo "$SPEEDTEST_OUTPUT" | grep 'Download' | awk '{print $3}')
            UPLOAD=$(echo "$SPEEDTEST_OUTPUT" | grep 'Upload' | awk '{print $2}')
            UPLOAD_UNIT=$(echo "$SPEEDTEST_OUTPUT" | grep 'Upload' | awk '{print $3}')

            # Write the results to the output file
            echo "$TIMESTAMP | Download: $DOWNLOAD $DOWNLOAD_UNIT | Upload: $UPLOAD $UPLOAD_UNIT" >> $OUTPUT_FILE
        fi
    fi

    # Wait for 60 seconds before the next test
    sleep 60
done
