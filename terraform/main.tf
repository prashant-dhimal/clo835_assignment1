provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "clo_835_week1" {
  name = "assignment1_repo"
}
resource "aws_ecr_repository" "clo_835" {
  name = "assignment1_repo_db"
}
# Adding SSH key to Amazon EC2
resource "aws_key_pair" "my_key" {
  key_name   = "assignment_key"
  public_key = file("assignment_key.pub")
}
resource "aws_vpc" "clo835_vpc" {
  cidr_block = "10.0.0.0/16"
}

#data "aws_availability_zones" "available" {
# state = "available"
#}
# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}
variable "subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

resource "aws_subnet" "clo835_subnet" {
  count = length(var.subnet_cidr_blocks)

  vpc_id            = aws_vpc.clo835_vpc.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

}

resource "aws_security_group" "clo_835_sg" {
  name = "SG_EC2"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "assignment_instance" {
  ami                         = "ami-0ff8a91507f77f867"
  instance_type               = "t2.micro"
  iam_instance_profile        = "ECR_Access"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.alb_sg.id]
  subnet_id                   = aws_subnet.clo835_subnet[0].id
  key_name                    = aws_key_pair.my_key.key_name
  user_data                   = <<EOF
  #!/bin/bash

  sudo yum update -y
  sudo yum install -y docker
  sudo usermod -aG docker ec2-user
  sudo service docker restart
  EOF 
  tags = {
    Name = "Assignment_1_Instance"
  }
}
resource "aws_internet_gateway" "ig_gw" {
  vpc_id = aws_vpc.clo835_vpc.id

}
# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.clo835_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig_gw.id
  }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.clo835_subnet[*].id)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.clo835_subnet[count.index].id
}