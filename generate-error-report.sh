#!/bin/bash

# Output file for the error report
ERROR_REPORT="network_drops_report.txt"

# Get all lines with DROP and calculate time differences
gawk '
    /\| DROP$/ {
        # Remove "| DROP " from the line
        line = substr($0, 1, length($0) - 7)
        current_time = mktime(gensub(/^([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2}).*/, "\\1 \\2 \\3 \\4 \\5 \\6", "g"))
        if (last_time != "") {
            time_diff = current_time - last_time
            minutes = int(time_diff / 60)
            seconds = time_diff % 60
            printf "%s | Time since last drop: %02d:%02d\n", line, minutes, seconds
        } else {
            print line " | First drop"
        }
        last_time = current_time
    }
' network_ping_log.txt > "$ERROR_REPORT"
