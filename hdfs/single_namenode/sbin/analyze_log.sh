#!/bin/bash

#grep -rn -v 'tty\|redundant\|SIGTERM' * | grep "ERROR\|failed"
grep -rn -v 'tty\|redundant\|SIGTERM\|retry.RetryInvocationHandler\|ConnectException' * | grep "ERROR\|failed\|Exception\|exception"
