provider "aws" {
    # access_key = "ACCESS_KEY_HERE"
    # secret_key = "SECRET_KEY_HERE"
    region = "eu-west-1"
}

resource "aws_vpc" "web_srv_vpc" {
    
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
        Name = "web-srv-vpc"
    }
}

resource "aws_subnet" "web_srv_sn" {
    vpc_id     = aws_vpc.web_srv_vpc.id
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "web-srv-sn"
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

resource "aws_instance" "web_server" {
    ami                         = "ami-01b282b0f06ba5fd2"
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.web_srv_sn.id
    key_name                    = "home-key"
    associate_public_ip_address = "true"
    user_data                   = "${file("instance_bootstrap.sh")}"
    vpc_security_group_ids      = [aws_security_group.web_srv_sg.id]

    tags = {
        Name = "web-srv-inst"
    }
}