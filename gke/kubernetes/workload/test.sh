#!/bin/bash
kubectl delete -k ./ >/dev/null

echo "Deleted resources" >/dev/null

velero restore create $RANDOM-my-backup-$RANDOM --from-backup test-wp >/dev/null

echo "Velero backup restored" >/dev/null
#sleep 10 >/dev/null # No problem of waiting 10s... the kubernetes deployment still continues underneath

until kubectl wait deploy/wordpress --timeout=300s --for=condition=available; >/dev/null
do
  sleep 1;
done;