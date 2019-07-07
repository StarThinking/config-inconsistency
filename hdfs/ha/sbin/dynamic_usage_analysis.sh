#!/bin/bash

dir=$1

grep -r msx $1 | awk -F " " '{ if ($9 ~ /dfs./) print $9}' | awk -F " " '{if ($1 !~ /\.hdfs\./) print $1}' | sort -u
