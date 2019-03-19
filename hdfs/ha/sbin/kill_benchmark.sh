#!/bin/bash

ps aux | grep benchmark.sh | awk -F ' ' '{print $2}' | xargs kill -9
ps aux | grep FsShell | awk -F ' ' '{print $2}' | xargs kill -9
