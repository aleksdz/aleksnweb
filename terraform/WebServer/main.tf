provider "aws" {
    # access_key = "ACCESS_KEY_HERE"
    # secret_key = "SECRET_KEY_HERE"
    region = "eu-west-1"
}

resource "aws_s3_bucket" "av_bucket" {
  bucket        = "anw-appveyor"
  acl           = "private"
  region        = "eu-west-1"

  tags = {
    Name        = "aleksnweb AppVeyor artifacts bucket"
  }
}

resource "aws_vpc" "web_srv_vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
        Name = "web-srv-vpc"
    }
}

resource "aws_subnet" "web_srv_sn_1a" {
    vpc_id              = aws_vpc.web_srv_vpc.id
    cidr_block          = "10.0.0.0/18"
    availability_zone   = "eu-west-1a"

    tags = {
        Name = "web-srv-sn-a"
    }
}

resource "aws_subnet" "web_srv_sn_1b" {
    vpc_id              = aws_vpc.web_srv_vpc.id
    cidr_block          = "10.0.64.0/18"
    availability_zone   = "eu-west-1b"

    tags = {
        Name = "web-srv-sn-b"
    }
}

resource "aws_internet_gateway" "web_srv_gw" {
    vpc_id = aws_vpc.web_srv_vpc.id

    tags = {
        Name = "web-srv-gw"
    }
}

resource "aws_route_table" "web_srv_rtb" {
    vpc_id = aws_vpc.web_srv_vpc.id

    tags = {
        Name = "web-srv-rtb"
    }
}

resource "aws_route" "web_srv_public" {
    route_table_id         = aws_route_table.web_srv_rtb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.web_srv_gw.id
}

resource "aws_main_route_table_association" "web_srv_rtb_asc" {
    vpc_id         = aws_vpc.web_srv_vpc.id
    route_table_id = aws_route_table.web_srv_rtb.id
}

resource "aws_security_group" "web_srv_sg" {
    name        = "web-srv-sg"
    description = "Web Server Security Group"
    vpc_id      = aws_vpc.web_srv_vpc.id

    tags = {
        Name = "web-srv-sg"
    }
}

resource "aws_security_group_rule" "web_srv_inbound_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_srv_sg.id
}

resource "aws_security_group_rule" "web_srv_inbound_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_srv_sg.id
}

resource "aws_security_group_rule" "web_srv_inbound_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_srv_sg.id
}

resource "aws_security_group_rule" "web_srv_outbound" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.web_srv_sg.id
}

resource "aws_key_pair" "home_key" {
    key_name   = "home-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhDZIk0ZGOtC6SOBo9W7OrNK6ASdxEZ0iEkcyF+Wa7SY40Bv+FDQcl6dxLmH8q3CiAPFCY+bTSvM/5LrmaiOO/dVbKOCKEGBrrnGC7CmJv3lgpfOMr9M5OfcvoXFMKjU2dE6Dl733sP+JXrwR9Np2lOU2gJYGdT0JMOVb/mg0XvFdqeqSX9dZvdXi8YvsiZfwBi5ZfRWGjakG0eteImAVDwph/pRA4E78Wc/NkYEIXOL5N1kMIrzO7Tq8ZdK5NpULQTq7PzCkgUiDvuN7aiOOkE+ZRzP4zkokhoAihUnqqDbCBr1hmSJ0xP55ULxS8Aya7/AzQn1fwxZFSGlrsGo3j zaers@soulkeeper"
}

resource "aws_iam_instance_profile" "ec_inst_prf" {
    name = "ec2-instance-profile"
    role = "${aws_iam_role.ec_iam_role.name}"
}

resource "aws_iam_role" "ec_iam_role" {
    name = "ec-iam-role"
    assume_role_policy = "${file("ec_iam_plc.json")}"
}

resource "aws_iam_role_policy" "ec_role_plc" {
  name = "ec-role-plc"
  role = "${aws_iam_role.ec_iam_role.id}"

  policy = "${file("ec_role_plc.json")}"
}

resource "aws_iam_policy" "av_role_plc" {
  name = "av-s3-plc"
  
  policy = "${file("av_role_plc.json")}"
}

resource "aws_instance" "web_server" {
    ami                         = "ami-01b282b0f06ba5fd2"
    instance_type               = "t2.micro"
    key_name                    = "aws-key-mac"
    user_data                   = "${file("instance_bootstrap.sh")}"
    iam_instance_profile        = aws_iam_instance_profile.ec_inst_prf.id
    availability_zone           = "eu-west-1a"

    network_interface {
        device_index            = 0
        network_interface_id    = "${aws_network_interface.web_server_subnet_interface.id}"
    }

    tags = {
        Name = "web-srv-inst"
    }
}

resource "aws_network_interface" "web_server_subnet_interface" {
    subnet_id   = "${aws_subnet.web_srv_sn_1a.id}"
    security_groups = ["${aws_security_group.web_srv_sg.id}"]
    private_ips = ["10.0.0.10"]
}


resource "aws_eip" "web_server_ip" {
  network_interface         = "${aws_network_interface.web_server_subnet_interface.id}"
  associate_with_private_ip = "10.0.0.10"
  vpc                       = true
}

resource "aws_alb" "web_server_lb" {
    name                = "web-server-lb"
    subnets             = ["${aws_subnet.web_srv_sn_1a.id}","${aws_subnet.web_srv_sn_1b.id}"]
    security_groups    = ["${aws_security_group.web_srv_sg.id}"]
    load_balancer_type  = "application"
}

resource "aws_alb_target_group" "web_srv_tg" {
    name            = "web-srv-lb-tg"
    port            = 80
    protocol        = "HTTP"
    vpc_id          = "${aws_vpc.web_srv_vpc.id}"
}

resource "aws_alb_target_group_attachment" "web_srv_tg_target" {
  target_group_arn = "${aws_alb_target_group.web_srv_tg.arn}"
  target_id        = "${aws_instance.web_server.id}"
  port             = 80
}

resource "aws_alb_listener" "web_srv_lb_listener" {
    load_balancer_arn   = "${aws_alb.web_server_lb.arn}"
    port                = 443
    protocol            = "HTTPS"
    ssl_policy          = "ELBSecurityPolicy-2016-08"
    certificate_arn     = "arn:aws:acm:eu-west-1:651390807906:certificate/b9776e07-05f3-47e3-a98c-5a701468ea29"

    default_action {
        type                = "forward"
        target_group_arn    = "${aws_alb_target_group.web_srv_tg.arn}"
    }
}

output "web_server_lb_name" {
  value = "${aws_alb.web_server_lb.name}"
}

