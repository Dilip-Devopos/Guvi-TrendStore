############################################################################################################################################################################################
# This terraform file to craet a aws  resources like vpc, subnets, security groups, ec2 instance, with jenkins installed on it.
############################################################################################################################################################################################
provider "aws" {
  alias  = "aws"
  region = var.aws_region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidrip_range
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_subnet_range
  availability_zone       = var.aws_availability_zone
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gatway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.routetable.id
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.routetable.id
  destination_cidr_block = var.aws_destination_cidr_block
  gateway_id             = aws_internet_gateway.gatway.id
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins_instance" {
  ami                         = var.instance_ami
  instance_type               = var.aws_instance_type
  subnet_id                   = aws_subnet.subnet.id
  security_groups             = [aws_security_group.security_group.id]
  key_name                    = var.instance_key_name
  associate_public_ip_address = true
  tags = {
    Name = "JenkinsInstance"
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y wget gnupg2 software-properties-common

    # Install Java 17
    wget -qO - https://repos.azul.com/azul-repo.key | gpg --dearmor | sudo tee /usr/share/keyrings/azul.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/azul.gpg] http://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list > /dev/null
    sudo apt update -y
    sudo apt install -y zulu17-jdk

    # Install Jenkins
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update -y
    sudo apt install -y jenkins

    # Start Jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
  EOF
}
