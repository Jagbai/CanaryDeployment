resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags       = {
        Name = "Terraform VPC"
    }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

resource "aws_route_table" "my_vpc_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }

    tags = {
        Name = "Public Subnet Route Table."
    }
}

resource "aws_route_table_association" "my_route_table_associtation" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.my_vpc_route_table.id
}


resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.0.0/24"

    tags = {
        Name = "Public Subnet"
    }
}

resource "aws_security_group" "ecs_sg" {
    vpc_id      = aws_vpc.vpc.id
    # http
        ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
      "Name" = "allow_http_sg"
    }
}


resource "aws_lb_target_group" "GreenTargetGroup" {
  name        = "RubyGreenTargetGroup"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  health_check {
    interval = 5
    path = "/"
    port = "80"
    protocol = "HTTP"
    timeout = 2
    healthy_threshold = 2
    unhealthy_threshold = 5
    matcher = "200"
  }
}

resource "aws_lb_target_group" "BlueTargetGroup" {
  name        = "RubyBlueTargetGroup"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  health_check {
    interval = 5
    path = "/"
    port = "80"
    protocol = "HTTP"
    timeout = 2
    healthy_threshold = 2
    unhealthy_threshold = 5
    matcher = "200"
  }
}

resource "aws_lb" "rslb" {
  name               = "rs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "rslistener" {
  load_balancer_arn = aws_lb.rslb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    order = 1

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "404"
    }

    
  }


}


