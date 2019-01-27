#!/bin/bash

grep -rn -v 'tty\|redundant\|SIGTERM' * | grep "ERROR\|WA^C\|Exception\|failed"
