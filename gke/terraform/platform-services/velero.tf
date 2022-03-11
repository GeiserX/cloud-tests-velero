# ======================
# Create custom role for disk/snapshots
# =====================
resource "google_project_iam_custom_role" "velero-role" {
  role_id     = "velero"
  title       = "Velero Role"
  description = "A Role to get disks and create/delete Snaphosts"
  permissions = [
    "compute.disks.get",
    "compute.disks.create",
    "compute.disks.createSnapshot",
    "compute.snapshots.get",
    "compute.snapshots.create",
    "compute.snapshots.useReadOnly",
    "compute.snapshots.delete",
    "compute.zones.get",
  ]
}

# ======================
# The bucket where to save k8s backups
# =====================
resource "google_storage_bucket" "velero-backups-bucket" {
  name          = "velero-backups-sergio-test"
  location      = var.gcp_default_region
  storage_class = "REGIONAL"
}

# ======================
# The Service Account
# =====================
module "velero-service-account" {
  source = "git::https://git.eu.clara.net/de-tf-modules/gcp/service-account.git?ref=0.7.0"

  id                = "velero-backups"
  display_name      = "Velero Backups"
  dump_iam_json_key = true
  roles             = ["projects/claranet-playground/roles/velero"]
}

# ======================
# Bind SA to the bucket
# =====================
resource "google_storage_bucket_iam_member" "velero-backups" {
  bucket = google_storage_bucket.velero-backups-bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.velero-service-account.email}"
}

