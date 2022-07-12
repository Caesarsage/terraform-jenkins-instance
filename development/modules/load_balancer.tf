/**
* A security group to allow SSH access into our load balancer
*/

resource "aws_security_group" "lb" {
  name   = "ecs-alb-security-group"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = "jenkins-lb-sg"
  }
}

/**
*Load Balancer to be attached to the ECS cluster to distribute the load among instances
*/

resource "aws_elb" "jenkins_elb" {
  subnets                   = [for subnet in aws_subnet.public_subnets : subnet.id]
  cross_zone_load_balancing = true
  security_groups           = [aws_security_group.lb.id]
  instances                 = [aws_instance.jenkins_master.id]
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 5
  }

  tags = {
    Name = "jenkins_elb"
  }
}


output "load-balancer-ip" {
  value = aws_elb.jenkins_elb.dns_name
}