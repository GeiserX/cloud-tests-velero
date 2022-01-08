### EKS Cluster ###

# Default
resource "aws_eks_cluster" "default" {

  version = "1.21"
  name = "inform-klm-dev"
  role_arn = aws_iam_role.eks-cluster.arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    endpoint_public_access = true
    endpoint_private_access = true
    subnet_ids = [aws_subnet.private["eu-west-1a"].id, aws_subnet.private["eu-west-1b"].id]
    public_access_cidrs = ["212.82.224.202/32", "212.82.224.205/32"]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "10.160.85.0/24"
  }

  depends_on = [
    #aws_iam_role_policy_attachment.eks-cluster,
    #aws_iam_role_policy_attachment.eks-cluster_vpc,
    aws_cloudwatch_log_group.eks-cluster
  ]

}

output "endpoint" {
  value = aws_eks_cluster.default.endpoint
}

/*
output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.default.certificate_authority[0].data
}
*/


### EKS Node Group (Workers) ###

resource "aws_eks_node_group" "private" {

  cluster_name = aws_eks_cluster.default.name
  node_role_arn = aws_iam_role.eks-worker.arn
  subnet_ids = [aws_subnet.private["eu-west-1a"].id, aws_subnet.private["eu-west-1b"].id]

  node_group_name = "inform-klm-dev-private"
  #instance_types = ["t3.medium"]
  instance_types = ["r5.xlarge"]
  capacity_type = "ON_DEMAND"
  disk_size = 20

  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 2
  }

  version = "1.21"

  /*
  remote_access {
    ec2_ssh_key = aws_key_pair.ssh.id
    source_security_group_ids = [aws_security_group.bastion-host.id]
  }
  */

}


### EKS Identity Provider ###

# EKS cluster OpenID identity provider association
resource "aws_eks_identity_provider_config" "inform-klm-dev" {
  cluster_name = aws_eks_cluster.default.name

  oidc {
    client_id = "sts.amazonaws.com"
    identity_provider_config_name = "inform-klm-dev"
    issuer_url = aws_eks_cluster.default.identity.0.oidc.0.issuer
  }
}

# OpenID Provider
resource "aws_iam_openid_connect_provider" "inform-klm-dev" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url = aws_eks_cluster.default.identity.0.oidc.0.issuer
}