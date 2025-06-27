variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "cidrip_range" {
  description = "The CIDR IP range for the VPC"
  type        = string
  default     = "198.168.0.0/24"
}

variable "cidr_subnet_range" {
  description = "The CIDR IP range for the subnet"
  type        = string
  default     = "198.168.0.0/25"
}

variable "aws_availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "us-west-2a"

}

variable "aws_destination_cidr_block" {
  description = "The destination CIDR block for the route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "security_group" {
  description = "The name of the security group"
  type        = string
  default     = "jenkins_security_group"
}

variable "aws_instance_type" {
  description = "The type of AWS instance to use for Jenkins"
  type        = string
  default     = "t2.medium"

}
variable "instance_ami" {
  description = "The AMI ID for the Jenkins instance"
  type        = string
  default     = "ami-05f991c49d264708f"
}

variable "instance_key_name" {
  description = "The admin password for Jenkins"
  type        = string
  default     = "jenkins_key_pair"
}
