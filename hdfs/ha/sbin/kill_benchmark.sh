#!/bin/bash

ps aux | grep benchmark.sh | awk -F ' ' '{print $2}' | xargs kill -9
jps | awk -F ' ' '{print $1}' | xargs kill -9
