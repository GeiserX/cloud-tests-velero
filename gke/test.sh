# Destroy cluster
#terraform -chdir=terraform/gke-cluster/ destroy -auto-approve
#kubectl config unset gke_claranet-playground_europe-west1-b_sergio-test

# Create cluster, cloud resources and velero dependencies
terraform -chdir=terraform/gke-cluster/ apply -auto-approve # We could add variables here to select where to deploy the cluster on demand
gcloud container clusters get-credentials sergio-test --zone europe-west1-b --project claranet-playground
terraform -chdir=terraform/platform-services/ apply -auto-approve

# Install velero and recover backup
helmfile -f kubernetes/velero/helmfile.yaml apply
until velero restore create my-backup --from-backup velero-wm-daily-20220114211018
do
  sleep 1;
done;
until kubectl -n workload wait deploy/wordpress --timeout=300s --for=condition=available;
do
  sleep 1;
done;
