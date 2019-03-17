ps aux | grep benchmark.sh | awk -F ' ' '{print $2}' | xargs kill -9
