#!/bin/bash

grep -rn -v 'tty\|redundant\|SIGTERM' * | grep "ERROR\|failed"
