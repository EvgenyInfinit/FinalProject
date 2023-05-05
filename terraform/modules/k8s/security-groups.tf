
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      =  var.vpc_id #module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

# resource "aws_security_group" "all_worker_mgmt" {
#   name_prefix = "eks-worker-management"
#   vpc_id      = data.aws_vpc.vpc.id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "eks-sg-${var.project_name}"
#     env = var.tag_enviroment
#   }
# }