#!/bin/bash

trap 'echo " - Ctrl-C ignored" ' INT
trap 'echo " - Signal TERM cahched"; exit 0 ' TERM
while [ 1 ]; do
  sleep 1
done

exit 0
