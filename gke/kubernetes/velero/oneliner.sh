#!/bin/bash
TIMEFORMAT=%R;
for i in {1..50}
do
  sleep 1
  time timeout 300s ./test.sh
  sleep 1
done
