terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "private-admin"
  region  = "us-east-1"
}


resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name          = "LearningAWS_VPC"
    "LearningAWS" = "vpc"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    "Name"        = "subnet_a_public"
    "LearningAWS" = "subnet_a"
  }

  depends_on = [
    aws_vpc.vpc,
  ]
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    "Name"        = "subnet_b_private"
    "LearningAWS" = "subnet_b"
  }

  depends_on = [
    aws_vpc.vpc,
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name"        = "LearningAWS_igw"
    "LearningAWS" = "igw"
  }

  depends_on = [
    aws_vpc.vpc,
  ]
}

data "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [
    aws_vpc.vpc,
  ]
}

resource "aws_route" "name" {
  route_table_id         = data.aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  depends_on = [
    aws_vpc.vpc,
  ]
}

resource "aws_instance" "some-ec2-instance" {
  ami           = "ami-022758574f5a26580"
  instance_type = "t2.micro"
  key_name      = "main_ssh_key"
  vpc_security_group_ids = [
    aws_security_group.sg_authorize_ssh_from_anywhere.id
  ]
  subnet_id = aws_subnet.subnet_a.id

  tags = {
    "LearningAWS" = "the-instance"
  }

  depends_on = [
    aws_security_group.sg_authorize_ssh_from_anywhere,
    aws_subnet.subnet_a,
  ]
}

resource "aws_key_pair" "my_ssh_key" {
  key_name   = "main_ssh_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqafZxB8pmwKOLhn2K+eozZ4YP1PFC0jQXhL8eR7HxhBdEcn364o4I6EV9BBIxczPZjQgBktKOmRWO2CZowK6ttDhMDIyeMgo0RMziT0Q7Hw1KLl16li5WiKDqLEcTQEuE3tYGS/W93NZOiCyK0+a0urejPZ9g+YhyyAzfFrJmk2mDQxxFgsFOsdyVMPxRlFcL0eUBqNKu95H7S2BF9oivIY2Iakd85ZzTbBxsDDTxLPVWsz1NgsEA5CBaLiYkweVHFlKk1BKM585C7dA6AgP4zOwjbTHyPSigVtXGdhYk5ZLSLTBs0VctKKVrbW82tLOIKx9xuop6IRTHf7QfKvTrttLWSK0axn4kBMRWCcLTZafIQ6yanrLM5sdz4roZ3v46ImNvIweuh55SnM72WM0mg5oy7sLt1YAVbSMC/CL8xYBzLhXZway+rHAh2Gw7v3DpgxOGKzYLdlcTA8TwhH4d1H8ipf5ueppwcwV1JGuEsnCJd4Dozj7aI/zqBCWqghHMRUgqIOdVEPWLmGZ0IIyOTKkGQinK9EAsyGfNMmwnsjyKZVLZfPCWaYQZ36KaywA6TVyKlAe+0+LF4wkAOz5lDERAnVq9F/FyEIwhEmKA7aKjIs5I+UIU3lc/Nrdtiey19xXz99jj3VRPhRfeKmt+H17xslT/IX4qo+29HfpsBw== shockn745@gmail.com"
  tags = {
    "LearningAWS" = "the ssh key"
  }
}

resource "aws_security_group" "sg_authorize_ssh_from_anywhere" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "SSH from Anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Instances can access Anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "sg_authorize_ssh_from_anywhere"
    "LearningAWS" = "security_group"
  }

  depends_on = [
    aws_vpc.vpc,
  ]
}

output "ip_of_ec2_instance" {
  value = aws_instance.some-ec2-instance.public_ip
}

output "dns_of_ec2_instance" {
  value = aws_instance.some-ec2-instance.public_dns
}
