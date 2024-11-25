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
    echo "You can install 'speedtest' using Homebrew: brew install speedtest-cli"
    echo "Or install 'speedtest-cli' using pip: pip install speedtest-cli"
    exit 1
fi

# Infinite loop to continuously check internet speed
while true; do
    # Get current timestamp
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [ "$SPEEDTEST_CMD" = "speedtest" ]; then
        # Run speedtest using the official Ookla CLI
        SPEEDTEST_OUTPUT=$($SPEEDTEST_CMD --accept-license --accept-gdpr -f csv)

        # Check if the output is valid
        if [ -z "$SPEEDTEST_OUTPUT" ]; then
            echo "$TIMESTAMP | Error running speedtest" >> $OUTPUT_FILE
        else
            # Parse the CSV output
            IFS=',' read -r SERVER_ID SPONSOR SERVER_NAME STAMP DISTANCE PING JITTER DOWNLOAD UPLOAD PACKET_LOSS ISP EXTERNAL_IP <<< "$SPEEDTEST_OUTPUT"

            # Convert speeds from bits to Mbit/s
            DOWNLOAD_Mbps=$(echo "scale=2; $DOWNLOAD/1000000" | bc)
            UPLOAD_Mbps=$(echo "scale=2; $UPLOAD/1000000" | bc)

            # Write the results to the output file
            echo "$TIMESTAMP | Download: $DOWNLOAD_Mbps Mbps | Upload: $UPLOAD_Mbps Mbps" >> $OUTPUT_FILE
        fi
    else
        # Run speedtest-cli
        SPEEDTEST_OUTPUT=$($SPEEDTEST_CMD --simple 2>&1)

        # Check for errors
        if echo "$SPEEDTEST_OUTPUT" | grep -q 'Cannot\|Error'; then
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

