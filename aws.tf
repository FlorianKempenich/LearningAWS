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
  region  = "eu-west-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "sandbox-remove"
  tags = {
    "LearningAWS" = "the-bucket"
  }
}

resource "aws_instance" "some-ec2-instance" {
  ami           = "ami-09b9e380df60300c8"
  instance_type = "t2.micro"
  key_name      = "main_ssh_key"
  vpc_security_group_ids = [
    aws_security_group.sg_authorize_ssh_from_anywhere.id
  ]

  tags = {
    "LearningAWS" = "the-instance"
  }

  depends_on = [
    aws_security_group.sg_authorize_ssh_from_anywhere,
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
  vpc_id = "vpc-6a24ea13"

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
}

output "ip_of_ec2_instance" {
  value = aws_instance.some-ec2-instance.public_ip
}
