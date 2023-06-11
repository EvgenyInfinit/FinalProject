data "aws_availability_zones" "available" {}

###########################
#VPC
##########################

resource "aws_vpc" "evgy_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Evgy FinalProject VPC"
  }
}

#######################################
#public subnets
#####################################

resource "aws_subnet" "public" {
  count      = 2
  vpc_id     = aws_vpc.evgy_vpc.id
  cidr_block = var.public_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "FP Public Subnet_${count.index}"
  }
}

####################################
#private subnets
###################################

resource "aws_subnet" "private" {
  count      = 2
  vpc_id     = aws_vpc.evgy_vpc.id
  cidr_block = var.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "FP Private Subnet_${count.index}"
  }
}

###################
#internet gateway
# - is a horizontally scaled, redundant, and highly available VPC component that allows communication between your VPC and the internet
###################

resource "aws_internet_gateway" "ing" {
   vpc_id     = aws_vpc.evgy_vpc.id
   tags = {
    Name = "FP Public Subnet"
  }
}

##########################
#Elastic IP for NAT Gateway
# - Elastic IP address is a static public address associated with your AWS account
# - NAT gateway in a public subnet and must associate an elastic IP address with the NAT gateway at creation.
##########################
resource "aws_eip" "nat_eip" {
   #vpc = true
   domain = "vpc"
   count = 2
   depends_on = [aws_internet_gateway.ing]
   tags = {
    Name = "FP NAT gateway EIP"
    }
}

###################################
#NAT gateway
# - Network Address Translation (NAT) service. 
# - You can use a NAT gateway so that instances in a private subnet can connect to services outside your VPC 
# - but external services cannot initiate a connection with those instances.
###################################

resource "aws_nat_gateway" "nat_gw" {
  count = 2
  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]
  tags = {
    Name = "FP gw_NAT_${count.index}"
  }
  depends_on = [aws_internet_gateway.ing]
}

#####################################
#create routing attributes
#####################################

resource "aws_route_table" "public" {
#  count = 1
  vpc_id = aws_vpc.evgy_vpc.id
  route {
     cidr_block = "0.0.0.0/0" 
     gateway_id = aws_internet_gateway.ing.id
     }
  tags = {
    "Name" = "FP public route table"
  }
}
resource "aws_route_table_association" "public" {
  count = 2 
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  count = 2
  vpc_id = aws_vpc.evgy_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.nat_gw.*.id[count.index]
     }
  tags = {
    "Name" = "FP private route table"
  }
}
resource "aws_route_table_association" "private" {
  count = 2
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}


#####################################
## Application Load Balancer - alb ##
#####################################
resource "aws_alb" "alb1" {
  name = "alb1"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb1_sg.id]
  subnets = [for subnet in aws_subnet.public.*.id : subnet]
  tags = {
    Name = "application load balancer"
  }
}

resource "aws_alb_listener" "consul" {
  #depends_on = [time_sleep.wait_for_certificate_verification] 
  load_balancer_arn = aws_alb.alb1.arn
   certificate_arn = aws_acm_certificate.cert.arn 
  port              = "8500"
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = var.consul_target_group_arn
  }
}  

resource "aws_alb_listener" "jenkins" {
   # depends_on = [time_sleep.wait_for_certificate_verification]  
  load_balancer_arn = aws_alb.alb1.arn
  certificate_arn = aws_acm_certificate.cert.arn 
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = var.jenkins_target_group_arn
  }
}


resource "aws_alb_listener" "elastic" {
   # depends_on = [time_sleep.wait_for_certificate_verification]  
  load_balancer_arn = aws_alb.alb1.arn
  certificate_arn = aws_acm_certificate.cert.arn 
  port              = "5601"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = var.elastic_target_group_arn
  }
}

###########################
 ## APB security group
###########################
resource "aws_security_group" "alb1_sg" {
  name ="alb1-security-group"
  vpc_id = aws_vpc.evgy_vpc.id
  ingress {
    from_port = 8500
    to_port =  8500
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow consul UI access"
  }
  ingress {
    from_port = 443
    to_port =  443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow jenkins UI secure access"
  }
   ingress {
    from_port = 5601
    to_port =  5601
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow elastic UI secure access"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "app balancer security group"
  }
}

resource "aws_route53_record" "jenkins_record" {
  zone_id = data.aws_route53_zone.primary_domain.zone_id
  name    = "jenkins"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb1.dns_name]
}

resource "aws_route53_record" "consul_record" {
  zone_id = data.aws_route53_zone.primary_domain.zone_id
  name    = "consul"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb1.dns_name]
}  

resource "aws_route53_record" "kandula_record" {
  zone_id = data.aws_route53_zone.primary_domain.zone_id
  name    = "kandula"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb1.dns_name]
}  

resource "aws_route53_record" "grafana_record" {
  zone_id = data.aws_route53_zone.primary_domain.zone_id
  name    = "grafana"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb1.dns_name]
}

resource "aws_route53_record" "elasticsearch_record" {
  zone_id = data.aws_route53_zone.primary_domain.zone_id
  name    = "elasticsearch"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb1.dns_name]
}


resource "aws_route53_record" "prometheus_record" {
  zone_id = data.aws_route53_zone.primary_domain.zone_id
  name    = "prometheus"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb1.dns_name]
}
#######################################
#create instance profile
# !!! !!!
#####################################
# resource "aws_iam_instance_profile" "web_profile" {
#   name = "web_profile"
#   role = "opsScool_role"
# }
###########################
# Create Certificate 
###########################
resource "aws_acm_certificate" "cert" {
  domain_name       = "*.evgy.net"
  validation_method = "EMAIL"
  tags = {
    Name = "certificate-opps"
  }
}
data "aws_route53_zone" "primary_domain" {
  name         = "evgy.net"
  private_zone = false
}
# resource "aws_route53_zone" "primary_domain" {
#   name         = "ops.evgy.com"
#   #private_zone = false
# }
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
}