data "aws_canonical_user_id" "current_user" {}
# --------------------------------- S3 for Velero --------------------------------- #
resource "aws_s3_bucket" "velero_tests_backups" {
  bucket = "sergio-tests-velero-backups"
  versioning {
    enabled = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name = "S3 Bucket for velero EKS backups"
  }
  force_destroy = true
}