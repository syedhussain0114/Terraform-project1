resource "aws_vpc" "hussain_vpc" {

    cidr_block = "${var.vpc_cidr}"
    tags = {
      Name = "${var.vpc_name}"
    }
}
resource "aws_subnet" "hussain_subnet_pub1" {
    vpc_id = aws_vpc.hussain_vpc.id
    cidr_block = "${var.subnet_cidr_pub1}"
    map_public_ip_on_launch = true
    availability_zone = "ap-south-1a"
    tags = {
      Name = "${var.subnet_name_pub1}"
    }
  
}
resource "aws_subnet" "hussain_subnet_pub2" {
    vpc_id = aws_vpc.hussain_vpc.id
    cidr_block = "${var.subnet_cidr_pub2}"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.subnet_name_pub2}"
    }
  
}
resource "aws_subnet" "hussain_subnet_pri1" {
    vpc_id = aws_vpc.hussain_vpc.id
    cidr_block = "${var.subnet_cidr_pri1}"
    availability_zone = "ap-south-1a"
    tags = {
      Name = "${var.subnet_name_pri1}"
    }
  
}
resource "aws_subnet" "hussain_subnet_pri2" {
    vpc_id = aws_vpc.hussain_vpc.id
    availability_zone = "ap-south-1b"
    cidr_block = "${var.subnet_cidr_pri2}"
    tags = {
      Name = "${var.subnet_name_pri2}"
    }
  
}
resource "aws_instance" "myinstance1" {
  subnet_id = aws_subnet.hussain_subnet_pub1.id
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  tags = {
    Name = "${var.instance_name}"
  }
}
resource "aws_instance" "myinstance2" {
  subnet_id = aws_subnet.hussain_subnet_pub2.id
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  tags = {
    Name = "${var.instance_name}"
  }
}
resource "aws_instance" "myinstance3" {
  subnet_id = aws_subnet.hussain_subnet_pub2.id
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  tags = {
    Name = "${var.instance_name}"
  }
}
resource "aws_internet_gateway" "hussain_IGW" {
  vpc_id = aws_vpc.hussain_vpc.id

  tags = {
    Name = "${var.igw_name}"
  }
}

resource "aws_route_table" "hussain_rt_pub" {
   vpc_id = aws_vpc.hussain_vpc.id
   route {
    cidr_block = "${var.rt_cidr_pub}"
    gateway_id = aws_internet_gateway.hussain_IGW.id
   }
   tags = {
     Name = "${var.RT_name_pub}"
   }
}
resource "aws_route_table" "hussain_rt_pri" {
  vpc_id = aws_vpc.hussain_vpc.id
  route {
    cidr_block = "${var.rt_cidr_pri}"
    nat_gateway_id = aws_nat_gateway.hussain_NAT_GW.id
  }
  tags = {
    Name = "${var.RT_name_pri}"
  }
}
resource "aws_route_table_association" "associate_pub1" {
    subnet_id = aws_subnet.hussain_subnet_pub1.id
    route_table_id = aws_route_table.hussain_rt_pub.id
  
}
resource "aws_route_table_association" "associate_pub2" {
    subnet_id = aws_subnet.hussain_subnet_pub2.id
    route_table_id = aws_route_table.hussain_rt_pub.id
  
}
resource "aws_route_table_association" "associate_pri1" {
    subnet_id = aws_subnet.hussain_subnet_pri1.id
    route_table_id = aws_route_table.hussain_rt_pri.id
  
}
resource "aws_route_table_association" "associate_pri2" {
    subnet_id = aws_subnet.hussain_subnet_pri2.id
    route_table_id = aws_route_table.hussain_rt_pri.id
  
}
resource "aws_eip" "hussainEIP" {
  tags = {
    Name = "${var.EIP_name}"
  }
}
resource "aws_nat_gateway" "hussain_NAT_GW" {
   
   allocation_id = aws_eip.hussainEIP.id
   subnet_id     = aws_subnet.hussain_subnet_pub1.id
   tags = {
    Name = "${var.Nat_gateway_name}"
}
} 

resource "aws_security_group" "hussain_sg" {
  name        = "hussain_sg"
  description = "Allow Traficc in-bound as well out-bound"
  vpc_id      = aws_vpc.hussain_vpc.id
  egress {
    description = "Allow All Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.sg_name}"
  }
}
resource "aws_vpc_security_group_ingress_rule" "in-bound-rule" {
  security_group_id = aws_security_group.hussain_sg.id
  description = "for an HTTP Protocol"
  cidr_ipv4   = "${var.inbound_cidr}"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}
resource "aws_vpc_security_group_ingress_rule" "in-bound-rule2" {
  security_group_id = aws_security_group.hussain_sg.id
  description = "for an SSH Protocol"
  cidr_ipv4   = "${var.inbound_cidr}"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}
resource "aws_vpc_security_group_ingress_rule" "in-bound-rule3" {
  security_group_id = aws_security_group.hussain_sg.id
  description = "for an SSH Protocol"
  cidr_ipv4   = "${var.inbound_cidr}"
  from_port   = 81
  ip_protocol = "tcp"
  to_port     = 81
}
resource "aws_alb" "my-ALB" {
  name = "${var.name_alb}"
  load_balancer_type = "application"
  internal = false
  security_groups = [aws_security_group.hussain_sg.id]
  subnets = [aws_subnet.hussain_subnet_pub1.id, aws_subnet.hussain_subnet_pub2.id]
  tags = {
    Name = "${var.name_alb}"
  }
}
resource "aws_alb_target_group" "hussainTG1" {
  name = "${var.name_tg1}"
  target_type = "instance"
  protocol = "HTTP"
  port = "80"
  vpc_id = aws_vpc.hussain_vpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}
resource "aws_alb_target_group" "hussainTG2" {
  name = "${var.name_tg2}"
  target_type = "instance"
  protocol = "HTTP"
  port = 80
  vpc_id = aws_vpc.hussain_vpc.id
  health_check {
    path = "/app2"
    port = "traffic-port"
  }
}
resource "aws_alb_target_group" "hussainTG3" {
  name = "${var.name_tg3}"
  target_type = "instance"
  protocol = "HTTP"
  port = 80
  vpc_id = aws_vpc.hussain_vpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}
resource "aws_alb_target_group_attachment" "attach" {
  target_group_arn = aws_alb_target_group.hussainTG1.arn
  target_id = aws_instance.myinstance1.id
  port = 80
}
resource "aws_alb_target_group_attachment" "attach2" {
  target_group_arn = aws_alb_target_group.hussainTG2.arn
  target_id = aws_instance.myinstance2.id
  port = 80
}
resource "aws_alb_target_group_attachment" "attach3" {
  target_group_arn = aws_alb_target_group.hussainTG3.arn
  target_id = aws_instance.myinstance3.id
  port = 80
}
resource "aws_alb_listener" "my-listner" {
  load_balancer_arn = aws_alb.my-ALB.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.hussainTG1.arn
    type = "forward"

  }
}
resource "aws_alb_listener" "my-listner2" {
  load_balancer_arn = aws_alb.my-ALB.arn
  port = 81
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.hussainTG3.arn
    type = "forward"
  }
}
resource "aws_alb_listener_rule" "my-rule" {
  listener_arn = aws_alb_listener.my-listner.arn
  priority = 1
  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.hussainTG2.arn
  }
  condition {
   path_pattern {
     values = ["/app2", "/app2/*"]
   }
  }
  tags = {
    Name = "${var.rule_name}"
  }
}
output "loadbalancer_dns_name" {
  value = aws_alb.my-ALB.dns_name
}
