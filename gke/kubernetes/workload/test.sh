#!/bin/bash

kubectl delete -k ./ >/dev/null

until velero restore create $RANDOM-my-backup-$RANDOM --from-backup velero-wm-daily-20220115161706;
do
  sleep 1;
done;

until kubectl -n workload wait deploy/wordpress --timeout=300s --for=condition=available;
do
  sleep 1;
done;
