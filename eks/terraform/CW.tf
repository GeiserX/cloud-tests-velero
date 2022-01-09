### Cloud Watch ###

# EKS Cluster
resource "aws_cloudwatch_log_group" "eks-cluster" {

  name = "/aws/eks/sergio-test/cluster"
  retention_in_days = 14

}
