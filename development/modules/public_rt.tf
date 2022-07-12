
/**
* Provides a connection between the VPC and the public internet, allowing
* traffic to flow in and out of the VPC and translating IP addresses to public
* addresses.
*/
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "igw_jenkins"
  }
}

/**
* A route from the public route table out to the internet through the internet
* gateway.
*/

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt_jenkins"
  }
}

/**
* Associate the public route table with the public subnets.
*/

resource "aws_route_table_association" "public" {
  count     = var.public_subnets_count
  subnet_id = element(aws_subnet.public_subnets.*.id, count.index)

  route_table_id = aws_route_table.public_rt.id
}