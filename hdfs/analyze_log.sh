#!/bin/bash

grep -rn -v 'tty\|redundant' * | grep "ERROR\|WA^C\|Exception\|failed"
