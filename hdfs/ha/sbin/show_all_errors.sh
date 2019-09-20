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
    echo "${ERRORS[$COMMAND]}[wrong_arguments]"
    exit 1
fi

dir=$1
echo "show ${ERRORS[@]} in $dir"

echo ${ERRORS[$COMMAND]}:
generate_command_errors $dir
echo ""

echo ${ERRORS[$RECONFIG]}:
generate_reconfig_errors $dir
echo ""

echo ${ERRORS[$FATAL]}:
generate_fatal_errors $dir
echo ""

echo ${ERRORS[$SYSTEM]}:
generate_system_errors $dir
echo ""

