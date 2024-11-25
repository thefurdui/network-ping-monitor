#!/bin/bash

# Get all lines with DROP and calculate time differences
awk '
    /\| DROP$/ {
        current_time = mktime(gensub(/^([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2}).*/, "\\1 \\2 \\3 \\4 \\5 \\6", "g"))
        if (last_time != "") {
            time_diff = current_time - last_time
            print $0 " | Time since last drop: " time_diff " seconds"
        } else {
            print $0 " | First drop"
        }
        last_time = current_time
    }
' network_ping_log.txt
