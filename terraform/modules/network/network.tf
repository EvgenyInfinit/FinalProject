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
    Name = "Public Subnet"
  }
}

##########################
#Elastic IP for NAT Gateway
# - Elastic IP address is a static public address associated with your AWS account
# - NAT gateway in a public subnet and must associate an elastic IP address with the NAT gateway at creation.
##########################
resource "aws_eip" "nat_eip" {
   vpc = true
   count = 2
   depends_on = [aws_internet_gateway.ing]
   tags = {
    Name = "NAT gateway EIP"
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
    Name = "gw_NAT_${count.index}"
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
    "Name" = "public route table"
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
    "Name" = "private route table"
  }
}
resource "aws_route_table_association" "private" {
  count = 2
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}

#######################################
#create instance profile
#####################################

#####################################
## Application Load Balancer - alb ##
#####################################

###########################
 ## APB security group
###########################

###########################
# Create Certificate 
###########################