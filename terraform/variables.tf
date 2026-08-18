variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for deployment"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Main CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for the public subnet"
}

variable "ssh_key_name" {
  type        = string
  default     = "my-aws-key" # CHANGE THIS: Exact name of your .pem key on AWS
  description = "Name of the existing AWS SSH key pair for instance access"
}
