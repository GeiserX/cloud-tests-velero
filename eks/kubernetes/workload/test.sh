#!/bin/bash
kubectl delete -k ./

velero restore create $RANDOM-my-backup-$RANDOM --from-backup my-test

until kubectl wait deploy/wordpress --timeout=300s --for=condition=available;
do
  sleep 1;
done;
