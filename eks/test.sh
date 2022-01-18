# Destroy cluster
#k delets svc -n workload wordpress
#terraform -chdir=terraform/eks-cluster/ destroy -auto-approve
# delete cluster:
#kubectl config unset sergio-test

# Create cluster, cloud resources and velero dependencies
terraform -chdir=terraform/eks-cluster/ apply -auto-approve # We could add variables here to select where to deploy the cluster on demand
aws eks --region eu-west-3 update-kubeconfig --name sergio-test
#terraform -chdir=terraform/platform-services/ apply -auto-approve

# Install velero and recover backup
helmfile -f kubernetes/velero/helmfile.yaml apply
until velero restore create my-backup --from-backup velero-my-schedule-20220116171514
do
  sleep 1;
done;
until kubectl -n workload wait deploy/wordpress --timeout=300s --for=condition=available;
do
  sleep 1;
done;
