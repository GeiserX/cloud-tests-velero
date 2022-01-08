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
resource "aws_iam_role" "rc-instances" {
  name = "rc-instances"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "ep-instances" {
  name = "ep-instances"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role" "jumphost-instances" {
name = "jumphost-instances"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jumphost-instances" {
  name = "jumphost-instances"
  role = aws_iam_role.jumphost-instances.name
}

resource "aws_iam_instance_profile" "rc-instances" {
  name = "rc-instances"
  role = aws_iam_role.rc-instances.name
}

resource "aws_iam_instance_profile" "ep-instances" {
  name = "ep-instances"
  role = aws_iam_role.ep-instances.name
}

resource "aws_iam_role_policy" "rc-instances-to-repo" {
  name = "rc-s3-access"
  role = aws_iam_role.rc-instances.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:GetObject",
                      "s3:ListBucket"],
            "Resource": [
                "arn:aws:s3:::${var.project_name}-poc-docker-files/*", 
                "arn:aws:s3:::${var.project_name}-poc-docker-files"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ep-instances-to-repo" {
  name = "ep-s3-access"
  role = aws_iam_role.ep-instances.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:GetObject",
                      "s3:ListBucket"],
            "Resource": [
                "arn:aws:s3:::${var.project_name}-poc-docker-files/*", 
                "arn:aws:s3:::${var.project_name}-poc-docker-files"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "rc-CloudwatchLogs" {
  role = aws_iam_role.rc-instances.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ep-CloudwatchLogs" {
  role = aws_iam_role.ep-instances.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_user" "inform" {
  name = "Inform"
}
resource "aws_iam_access_key" "inform" {
  user = aws_iam_user.inform.name
}

/*
output "inform-access-key" {
  value = aws_iam_access_key.inform.id
}

output "inform-secret-key" {
  value = nonsensitive(aws_iam_access_key.inform.secret)
}
*/

resource "aws_iam_user_policy" "inform-s3-access" {
  user = aws_iam_user.inform.name
  name = "Inform-S3-Access"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                        "s3:GetBucketLocation",
                        "s3:ListAllMyBuckets"
                      ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": ["s3:*"],
            "Resource": [
                "arn:aws:s3:::${var.project_name}-poc-docker-files/*", 
                "arn:aws:s3:::${var.project_name}-poc-docker-files",
                "arn:aws:s3:::${var.project_name}-poc-clients/*", 
                "arn:aws:s3:::${var.project_name}-poc-clients"

            ]
        }
    ]
}
EOF
}


resource "aws_iam_user_policy_attachment" "CloudwatchReadOnly" {
  user = aws_iam_user.inform.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
resource "aws_iam_user_policy_attachment" "EC2ReadOnly" {
  user = aws_iam_user.inform.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}


### Monitoring-User
resource "aws_iam_user" "nagios" {
  name = "nagios"
}
resource "aws_iam_access_key" "nagios" {
  user = aws_iam_user.nagios.name
}
resource "aws_iam_user_policy_attachment" "Cloudwatch-for-Nagios" {
  user       = aws_iam_user.nagios.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
resource "aws_iam_user_policy_attachment" "RDS-for-Nagios" {
  user       = aws_iam_user.nagios.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

/*
output "nagios-access-key" {
  alue = aws_iam_access_key.nagios.id
}

output "nagios-secret-key" {
  value = nonsensitive(aws_iam_access_key.nagios.secret)
}
*/


### EKS ###

# cluster control plane
resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster"

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
  role = aws_iam_role.eks-cluster.name
}

/*
resource "aws_iam_role_policy_attachment" "eks-cluster_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.eks-cluster.name
}
*/

# worker nodes
resource "aws_iam_role" "eks-worker" {
  name = "eks-worker"

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
  role = aws_iam_role.eks-worker.name
}

resource "aws_iam_role_policy_attachment" "eks-worker_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks-worker.name
}

resource "aws_iam_role_policy_attachment" "eks-worker_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks-worker.name
}
resource "aws_iam_role_policy_attachment" "eks-worker_cloudwatchlogs" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role = aws_iam_role.eks-worker.name
}

# external dns
resource "aws_iam_policy" "external-dns" {
  name = "external-dns"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "external-dns" {
  name = "external-dns"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.inform-klm-dev.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${trimprefix(aws_eks_cluster.default.identity.0.oidc.0.issuer, "https://")}:sub": "system:serviceaccount:external-dns:external-dns"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "external-dns" {
  role       = aws_iam_role.external-dns.name
  policy_arn = aws_iam_policy.external-dns.arn
}





resource "aws_iam_role" "efs-controller" {
  name = "efs-controller"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.inform-klm-dev.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity"
      }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "efs-controller" {
  role       = aws_iam_role.efs-controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}


# cert-manager
resource "aws_iam_policy" "cert-manager" {
  name = "cert-manager"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "cert-manager" {
  name = "cert-manager"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.inform-klm-dev.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${trimprefix(aws_eks_cluster.default.identity.0.oidc.0.issuer, "https://")}:sub": "system:serviceaccount:platform-services:cert-manager"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cert-manager" {
  role       = aws_iam_role.cert-manager.name
  policy_arn = aws_iam_policy.cert-manager.arn
}


# fluentbit (logging)
resource "aws_iam_policy" "fluentbit" {
  name = "fluentbit"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutRetentionPolicy",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "fluentbit" {
  name = "fluentbit"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.inform-klm-dev.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${trimprefix(aws_eks_cluster.default.identity.0.oidc.0.issuer, "https://")}:sub": "system:serviceaccount:platform-services:fluent-bit-aws-for-fluent-bit"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "fluentbit" {
  role = aws_iam_role.fluentbit.name
  policy_arn = aws_iam_policy.fluentbit.arn
}















# ------------- Velero ------------- #
resource "aws_iam_policy" "velero" {
  name = "velero"
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
      "Resource": "arn:aws:s3:::inform-klm-dev-velero-backups/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::inform-klm-dev-velero-backups"
    }
  ]
}
EOF
}

resource "aws_iam_role" "velero" {
  name = "velero"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.inform-klm-dev.arn}"
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
  role       = aws_iam_role.velero.name
  policy_arn = aws_iam_policy.velero.arn
}