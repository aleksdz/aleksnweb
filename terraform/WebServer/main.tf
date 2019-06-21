provider "aws" {
    # access_key = "ACCESS_KEY_HERE"
    # secret_key = "SECRET_KEY_HERE"
    region = "eu-west-1"
}

resource "aws_vpc" "web_srv_vpc" {
    cidr_block           = "10.0.0.0/28"
    enable_dns_hostnames = "true"

    tags = {
        Name = "web-srv-vpc"
    }
}

resource "aws_subnet" "web_srv_sn" {
    vpc_id     = aws_vpc.web_srv_vpc.id
    cidr_block = "10.0.0.0/28"

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
}

resource "aws_security_group_rule" "web_srv_inbound_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.web_srv_sg.id
}

resource "aws_security_group_rule" "web_srv_inbound_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["10.0.0.0/16"]
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


resource "aws_instance" "web_server" {
    ami                         = "ami-01b282b0f06ba5fd2"
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.web_srv_sn.id
    associate_public_ip_address = "true"
    user_data                   = "${file("instance_bootstrap.sh")}"

    tags = {
        Name = "web-srv-inst"
    }
}