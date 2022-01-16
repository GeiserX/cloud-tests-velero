#resource "aws_security_group" "EC2" {
#  name = "EC2 Instances"
#  description = "Logical EC2 Instance Grouping"
#  vpc_id = aws_vpc.default.id
#  tags = {
#    Name = "EC2 Instances"
#  }
#}
#
#resource "aws_security_group" "ALB" {
#  name = "ALB-SG"
#  vpc_id = aws_vpc.default.id
#  ingress {
#    protocol = "tcp"
#    from_port = 443
#    to_port = 443
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  egress {
#    protocol = "all"
#    from_port = 0
#    to_port = 0
#    security_groups = [aws_security_group.EC2.id ]
#    ### Claranet Access
#  }
#  egress {
#    protocol = "tcp"
#    from_port = 443
#    to_port = 443
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = {
#    Name = "ALB-SG"
#  }
#}