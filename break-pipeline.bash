#!/bin/bash


critical_threshold=$LW_CRITICAL_THRESHOLD
high_threshold=$LW_HIGH_THRESHOLD
medium_threshold=$LW_MEDIUM_THRESHOLD

echo " "
echo " "
echo "                            Container Vulnerability Assessment Results"
echo "                         ==================================================="
echo " "
critical=$(cat lw-verbose.txt| grep 'Registry' | grep 'Critical')
arr_critical=($critical)
high=$(cat lw-verbose.txt| grep 'Repository' | grep 'High') 
arr_high=($high)
medium=$(cat lw-verbose.txt| grep 'Size' | grep 'Medium')
arr_medium=($medium)

if  [ -z "$arr_critical" ] && [ -z "$arr_high" ] && [ -z "$arr_medium" ]; then
    echo "Good news! This image has no vulnerabilities."
    
else
    cat lw-verbose.txt| grep 'CONTAINER IMAGE DETAILS' | awk '{print $1, $2, $3}'
    cat lw-verbose.txt | grep 'ID' | grep 'SEVERITY' | grep 'COUNT' | awk '{print $1, $2}'
    cat lw-verbose.txt | grep 'Digest' | awk '{print $1, $2}'
    echo "The number of CRITICAL vulns is ${arr_critical[3]}"
    echo "The number of HIGH vulns is ${arr_high[3]}"
    echo "The number of MEDIUM vulns is ${arr_medium[4]}"	
    echo " "

    if ((${arr_critical[3]} < $critical_threshold)) && ((${arr_high[3]} < $high_threshold)) && ((${arr_medium[4]} < $medium_threshold)); then
        echo "The test was passed - continuing with pipeline"
    else
        echo "One or more of the SEVERITY exceeds the allowable threshold"
        echo "===================================="
        echo "          |Critical | High | Medium    "
        echo "------------------------------------"
        echo "vulns     | ${arr_critical[3]}       | ${arr_high[3]}    | ${arr_medium[4]}"
        echo "------------------------------------"
        echo "threshold | $critical_threshold      | $high_threshold    | $medium_threshold "
        echo " "

        echo "Exiting the pipeline with RC=99" >&2
        exit 99
    fi
fi
