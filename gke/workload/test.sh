#!/bin/bash
kubectl delete -k ./

echo "Deleted resources"

velero restore create my-backup-$RANDOM --from-backup test-wp

echo "Velero backup restored"
sleep 10

kubectl wait deploy/wordpress --for=condition=available
