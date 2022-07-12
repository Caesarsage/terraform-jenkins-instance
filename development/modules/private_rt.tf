/**
* An elastic IP address to be used by the NAT Gateway defined below.  The NAT
* gateway acts as a gateway between our private subnets and the public
* internet, providing access out to the internet from with in those subnets,
* while denying access in to them from the public internet.  This IP address
* acts as the IP address from which all the outbound traffic from the private
* subnets will originate.
*/

resource "aws_eip" "eip_for_the_nat_gateway" {
  vpc = true

  tags = {
    Name = "jenkins-tutoral-eip_for_the_nat_gateway"
  }
}

/**
* A NAT Gateway that lives in our public subnet and provides an interface
* between our private subnets and the public internet.  It allows traffic to
* exit our private subnets, but prevents traffic from entering them.
*/

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_for_the_nat_gateway.id
  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)

  tags = {
    Name = "jenkins-tutorial-nat_gateway"
  }
}

/**
* A route from the private route table out to the internet through the NAT  
* Gateway.
*/

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "private_rt_jenkins"
  }
}

/**
* Associate the private route table with the private subnet.
*/

resource "aws_route_table_association" "private" {
  count          = var.private_subnets_count
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}