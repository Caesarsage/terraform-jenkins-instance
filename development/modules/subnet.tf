

/**
* A public subnet with in our VPC that we can launch resources into that we
* want to be auto-assigned public ip addresses.  These resources will be
* exposed to the public internet, with public IPs, by default.  They don't need
* to go through, and aren't shielded by, the NAT Gateway.
*/

resource "aws_subnet" "public_subnets" {
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 2 + count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  count                   = var.public_subnets_count
  tags = {
    Name = "jenkins-instance-public-subnet"
  }
}

/** 
* A private subnet for pieces of the infrastructure that we don't want to be
* directly exposed to the public internet.  Infrastructure launched into this
* subnet will not have public IP addresses, and can access the public internet
* only through the route to the NAT Gateway.
*/


resource "aws_subnet" "private_subnets" {
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  count                   = var.private_subnets_count
  tags = {
    Name = "jenkins-instance-private-subnet"
  }
}