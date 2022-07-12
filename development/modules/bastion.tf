
/**
* A security group to allow SSH access into our bastion instance.
*/
resource "aws_security_group" "bastion" {
  name   = "bastion-security-group"
  vpc_id = var.vpc_id
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "aws_security_group.bastion_jenkins"
  }
}

/**
* The public key for the key pair we'll use to ssh into our bastion instance.
*/
resource "aws_key_pair" "bastion" {
  key_name   = "bastion-key-jenkins"
  public_key = var.public_key
}

/**
* This parameter contains the AMI ID for the most recent Amazon Linux 2 ami,
* managed by AWS.
*/

data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}
/**
* Launch a bastion instance we can use to gain access to the private subnets of
* this availabilty zone.
*/
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.bastion.id
  key_name                    = aws_key_pair.bastion.key_name
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.public_subnets, 0).id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  tags = {
    Name = "jenkins-bastion"
  }
}

output "bastion" {
  value = aws_instance.bastion.public_ip
}