#!/bin/bash
testname=$RANDOM >/dev/null 2>&1
velero create backup $testname --from-schedule velero-my-schedule >/dev/null 2>&1
until [ $(kubectl get backup $testname -o=jsonpath='{.status.progress.itemsBackedUp}') = 22 ] >/dev/null 2>&1
do
  echo "waiting" >/dev/null 2>&1
done

# dd if=/dev/zero of=testfile bs=1024 count=1024000