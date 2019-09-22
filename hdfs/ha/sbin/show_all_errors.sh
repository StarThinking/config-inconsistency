#!/bin/bash
set -u

if [ -z "$TEST_HOME" ]; then
    echo "TEST_HOME not set."
    exit 3
fi

. $TEST_HOME/sbin/global_var.sh
. $TEST_HOME/sbin/util/error_helper.sh
. $TEST_HOME/sbin/util/system_error_subsetof.sh

if [ $# -lt 1 ]; then
    echo "${ERRORS[$COMMAND_ERROR]}[wrong_arguments]"
    exit 1
fi

dir=$1
echo "show ${ERRORS[@]} in $dir"

echo ${ERRORS[$COMMAND_ERROR]}:
generate_command_errors $dir
echo ""

echo ${ERRORS[$RECONFIG_ERROR]}:
generate_reconfig_errors $dir
echo ""

echo ${ERRORS[$FATAL_ERROR]}:
generate_fatal_errors $dir
echo ""

echo ${ERRORS[$SYSTEM_ERROR]}:
generate_system_errors $dir
echo ""

