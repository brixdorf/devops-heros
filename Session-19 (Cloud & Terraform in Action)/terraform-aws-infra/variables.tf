variable "aws_region" {
  description = "AWS region for every resource"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix for resource names and the Project tag"
  type        = string
}

variable "vpc_cidr" {
  description = "IP range of the whole VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "IP range of the public subnet, must sit inside vpc_cidr"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 size. t3.micro is Free Tier eligible in ap-south-1"
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidr" {
  description = "Who may open the website on port 80"
  type        = string
  default     = "0.0.0.0/0"
}
