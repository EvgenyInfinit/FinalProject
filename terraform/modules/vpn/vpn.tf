##################
#Create VPN server
##################

resource "aws_instance" "vpn" {
  # ami                   = "ami-0d10bccf2f1a6d60b"  -- us-west-2
  ami                   = "ami-04406fdec0f245050"
  /* count                 = 1 */
  instance_type         = "t2.micro"
  key_name              = var.server_public_key
  subnet_id             = var.subnet_id[0]
  vpc_security_group_ids            = [aws_security_group.vpn_sg.id]
  user_data = <<-EOF
              admin_user=${var.server_username}
              admin_pw=${var.server_password}
              EOF
  tags = {
    name = "FP Vpn Server"
    role = "vpn_server"
    port = "1194"
  }
}


#####################################
#Create security group for vpn server
#####################################

resource "aws_security_group" "vpn_sg" {
  name        = "vpn_sg"
  description = "Allow straffic via VPN  "
   vpc_id = var.vpc_id
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow https"
    cidr_blocks = ["10.0.0.0/16"]
    /* self        = true */
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh"
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "openvpn1"
  }

    ingress {
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "openvpn2"
  }

    
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "openvpn2"
  }

    ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "openvpn3"
  }
  
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node-exporter"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }
  tags = {
    "name" = "vpn_sg"
  }
}


