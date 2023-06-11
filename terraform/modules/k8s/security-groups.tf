resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "eks-worker-management"
  vpc_id      =var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 8301
    to_port   = 8301
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
   egress {
    from_port = 8600
    to_port   = 8600
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 8302
    to_port   = 8302
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

   egress {
    from_port = 8300
    to_port   = 8300
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node-exporter"
  } 

   ingress {
    from_port   = 9153
    to_port     = 9153
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "k8s prometheus"
  } 

   ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "k8s prometheus"
  } 
  
     ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "k8s prometheus"
  } 

     ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "k8s prometheus"
  } 

   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }

  tags = {
    Name = "eks-sg-${var.project_name}"
    env = var.tag_enviroment
  }
}