#!/bin/bash
kubectl delete -k ./

echo "Deleted resources"

velero restore create my-backup-$RANDOM --from-backup velero-wm-daily-20220109143912

echo "Velero backup restored"
#sleep 20 >/dev/null # No problem of waiting 10s... the kubernetes deployment still continues underneath

until  kubectl wait deploy/wordpress --timeout=300s --for=condition=available;
do
  sleep 1;
done;
