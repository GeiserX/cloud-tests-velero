data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "docker-repo" {
  bucket = "${var.project_name}-poc-docker-files"

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
  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  grant {
    type        = "Group"
    permissions = ["READ_ACP", "READ"]
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
  }

  tags = {
    Name = "S3 Bucket for yum repo"
  }
  force_destroy = true
}

resource "aws_s3_bucket" "clients" {
bucket = "${var.project_name}-poc-clients"

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
    Name = "S3 Bucket for GUI clients"
  }
  force_destroy = true
}



resource "aws_s3_bucket" "eks_artifacts" {
bucket = "${var.project_name}-${var.environment}-artifacts"

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
    Name = "S3 Bucket for EKS Artifacts"
  }
  force_destroy = true
}


resource "aws_s3_bucket_policy" "eks_artifacts" {
  bucket = aws_s3_bucket.eks_artifacts.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {   
        "Sid": "AllowAccessFromAccount",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${var.project_account_id}:root"
        },
        "Action": "s3:*",
        "Resource": [
            "arn:aws:s3:::${var.project_name}-${var.environment}-artifacts",
            "arn:aws:s3:::${var.project_name}-${var.environment}-artifacts/*"
        ]
    },
    {
            "Sid": "AllowAccessFromVPC",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
            "arn:aws:s3:::${var.project_name}-${var.environment}-artifacts",
            "arn:aws:s3:::${var.project_name}-${var.environment}-artifacts/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:sourceVpc": "${aws_vpc.default.id}"
                }
            }
        }
  ]
}
POLICY
}


# --------------------------------- S3 for Velero --------------------------------- #

resource "aws_s3_bucket" "velero_dev_backups" {
  bucket = "${var.project_name}-${var.environment}-velero-backups"

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

/* resource "aws_s3_bucket_policy" "velero_dev_backups" {
  bucket = aws_s3_bucket.velero_dev_backups.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {   
        "Sid": "AllowAccessFromAccount",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${var.project_account_id}:root"
        },
        "Action": "s3:*",
        "Resource": [
            "arn:aws:s3:::${var.project_name}-${var.environment}-velero-backups",
            "arn:aws:s3:::${var.project_name}-${var.environment}-velero-backups/*"
        ]
    },
    {
            "Sid": "AllowAccessFromVPC",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
            "arn:aws:s3:::${var.project_name}-${var.environment}-velero-backups",
            "arn:aws:s3:::${var.project_name}-${var.environment}-velero-backups/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:sourceVpc": "${aws_vpc.default.id}"
                }
            }
        }
  ]
}
POLICY
} */