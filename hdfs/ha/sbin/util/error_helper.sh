#!/bin/bash

. $TEST_HOME/sbin/global_var.sh

function generate_command_errors {
    if [ $# -lt 1 ]; then
        echo "${ERRORS[$COMMAND_ERROR]}[wrong_arguments]"
        exit 1
    fi
    dir=$1
    grep -rn "${ERRORS[$COMMAND_ERROR]}" $dir | awk -F "[\]\[]" '{print $2}' 2>/dev/null
}

function generate_reconfig_errors {
    if [ $# -lt 1 ]; then
        echo "${ERRORS[$COMMAND_ERROR]}[wrong_arguments]"
        exit 1
    fi
    dir=$1
    grep -rn "${ERRORS[$RECONFIG_ERROR]}" $dir | awk -F "[\]\[]" '{print $2}' 2>/dev/null
}


function generate_fatal_errors {
    if [ $# -lt 1 ]; then
        echo "${ERRORS[$COMMAND_ERROR]}[wrong_arguments]"
        exit 1
    fi
    dir=$1
    grep -rn "${ERRORS[$FATAL_ERROR]}" $dir | awk -F "[\]\[]" '{print $2}' 2>/dev/null
}

function generate_system_errors {
    if [ $# -lt 1 ]; then
        echo "${ERRORS[$COMMAND_ERROR]}[wrong_arguments]"
        exit 1
    fi
    dir=$1
    grep -rn "WARN\|ERROR\|FATAL" $dir | awk -F " " '{ if ($3 == "WARN" || $3 == "ERROR" || $3 == "FATAL") print $5}' | sort -u 2>/dev/null
}

