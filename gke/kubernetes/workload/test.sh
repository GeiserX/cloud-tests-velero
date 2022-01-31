#!/bin/bash

kubectl delete -k ./

until velero restore create $RANDOM-my-backup-$RANDOM --from-backup test;
do
  sleep 1;
done;

until kubectl -n workload wait deploy/wordpress --timeout=300s --for=condition=available;
do
  sleep 1;
done;
