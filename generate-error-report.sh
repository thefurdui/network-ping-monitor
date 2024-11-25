#!/bin/bash

# Output file for the error report
ERROR_REPORT="network_drops_report.txt"

# Get all lines with DROP and calculate time differences
gawk '
    {
        # Store timestamp for all entries (both successful and drops)
        current_time = mktime(gensub(/^([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2}).*/, "\\1 \\2 \\3 \\4 \\5 \\6", "g"))
        
        if ($0 ~ /\| DROP$/) {
            # Remove "| DROP " from the line
            line = substr($0, 1, length($0) - 7)
            if (last_drop_time != "") {
                drop_diff = current_time - last_drop_time
                drop_minutes = int(drop_diff / 60)
                drop_seconds = drop_diff % 60
                
                outage_diff = current_time - last_success_time
                outage_minutes = int(outage_diff / 60)
                outage_seconds = outage_diff % 60
                
                printf "%s | Time since last drop: %02d:%02d | Outage duration: %02d:%02d\n", 
                       line, drop_minutes, drop_seconds, outage_minutes, outage_seconds
            } else {
                print line " | First drop"
            }
            last_drop_time = current_time
        } else {
            last_success_time = current_time
        }
    }
' network_ping_log.txt > "$ERROR_REPORT"
