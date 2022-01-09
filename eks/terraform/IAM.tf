resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 60
  password_reuse_prevention      = 5
}

#resource "aws_iam_user" "sergio" {
#  name = "Inform"
#}
#resource "aws_iam_access_key" "sergio" {
#  user = aws_iam_user.sergio.name
#}
#
#resource "aws_iam_user_policy_attachment" "CloudwatchReadOnly" {
#  user = aws_iam_user.sergio.name
#  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
#}
#
#resource "aws_iam_user_policy_attachment" "EC2ReadOnly" {
#  user = aws_iam_user.sergio.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
#}
/*
output "nagios-access-key" {
  alue = aws_iam_access_key.sergio.id
}

output "nagios-secret-key" {
  value = nonsensitive(aws_iam_access_key.sergio.secret)
}
*/

### EKS ###
# cluster control plane
resource "aws_iam_role" "eks-cluster-role" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster_vpc" { # MAYBE DELETE?
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.eks-cluster-role.name
}

# worker nodes
resource "aws_iam_role" "eks-worker-role" {
  name = "eks-worker-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks-worker-role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks-worker-role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks-worker-role.name
}
resource "aws_iam_role_policy_attachment" "eks-worker_cloudwatchlogs" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role = aws_iam_role.eks-worker-role.name
}


# ------------- Velero ------------- #
resource "aws_iam_policy" "velero-policy" {
  name = "velero-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
      ],
      "Resource": "arn:aws:s3:::sergio-tests-velero-backups/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::sergio-tests-velero-backups"
    }
  ]
}
EOF
}

resource "aws_iam_role" "velero-role" {
  name = "velero-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.sergio-test.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${trimprefix(aws_eks_cluster.default.identity.0.oidc.0.issuer, "https://")}:sub": "system:serviceaccount:velero:velero"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "velero" {
  role       = aws_iam_role.velero-role.name
  policy_arn = aws_iam_policy.velero-policy.arn
}