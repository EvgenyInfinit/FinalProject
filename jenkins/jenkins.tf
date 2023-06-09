terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  #version = "~> 2.0"
  region = "us-east-2"
}

locals {
  jenkins_default_name = "jenkins2"
  jenkins_home = "/home/ubuntu/jenkins_home"
  jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}
#"sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --env JAVA_OPTS='-Djenkins.install.runSetupWizard=false' jenkins/jenkins"

resource "aws_security_group" "jenkins" {
  name = local.jenkins_default_name
  vpc_id      = var.vpc_id
  description = "Allow Jenkins inbound traffic"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

 ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node-exporter"
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
 egress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node-exporter"
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port = 0
    to_port = 0
    // -1 means all
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = local.jenkins_default_name
  }
}

resource "aws_key_pair" "jenkins_ec2_key" {
  key_name = "jenkins_ec2_key"
  public_key = file("jenkins_ec2_key.pub")
} 
###########################################
# Create Jenkins server 
##########################################
resource "aws_instance" "jenkins_server" {
  #ami = "ami-07d0cf3af28718ef8"
  ami = lookup(var.ami, var.region)
  #count = 1
  instance_type = "t3.micro"
  key_name = aws_key_pair.jenkins_ec2_key.key_name
  #key_name = var.key_pair_names
  subnet_id = var.subnet_id
   tags =        {
                  Name = "Jenkins Server 2"
                  role = "jenkins_master"
                  port = "8080"
                }
  associate_public_ip_address       = false
  vpc_security_group_ids = var.vpn_sg #[aws_security_group.jenkins.id,  var.vpn_sg] #, var.consul_security_group]
  /* iam_instance_profile = [aws_iam_instance_profile.jenkins-role.name, var.consul_iam_instance_profile] */
  iam_instance_profile =  aws_iam_instance_profile.jenkins-role.name
  #user_data = file("scripts/jenkins_server.tpl") 
  # connection {
  #   host = aws_instance.jenkins_server.private_ip
  #   user = "ubuntu"
  #   private_key = file("jenkins_ec2_key")
  # }
  #   provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get update -y",
  #     "sudo apt install docker.io -y",
  #     "sudo systemctl start docker",
  #     "sudo systemctl enable docker",
  #     "sudo usermod -aG docker ubuntu",
  #     "mkdir -p ${local.jenkins_home}",
  #     "sudo chown -R 1000:1000 ${local.jenkins_home}"
  #   ]
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
  #   ]
  # }
}
 ################
 # ssh
 ################
# resource "tls_private_key" "server_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "local_sensitive_file" "server_key_private" {
#   content = tls_private_key.server_key.private_key_pem
#   filename = "${path.root}/keys/${var.key_pair_names}.pem"
#   file_permission = "0600"
# }

# resource "local_sensitive_file" "server_key_public" {
#   #count = length(var.key_pair_names)
#   content = tls_private_key.server_key.public_key_pem
#   filename = "${path.root}/keys/${var.key_pair_names}.pub"
#   file_permission = "0600"
# }

# resource "local_sensitive_file" "authorized_keys" {
#   #count = length(var.key_pair)
#   content = tls_private_key.server_key[count.index].public_key_openssh
#   filename = "${path.root}/keys/authorized_keys"
#   file_permission = "0600"
# }




#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update -y",
#       "sudo apt install docker.io -y",
#       "sudo systemctl start docker",
#       "sudo systemctl enable docker",
#       "sudo usermod -aG docker ubuntu",
#       "mkdir -p ${local.jenkins_home}",
#       "sudo chown -R 1000:1000 ${local.jenkins_home}"
#     ]
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
#     ]
#   }
# }

