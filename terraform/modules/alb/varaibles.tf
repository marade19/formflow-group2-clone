variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_1_id" {
  description = "Public Subnet 1 ID"
  type        = string
}

variable "public_subnet_2_id" {
  description = "Public Subnet 2 ID"
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID"
  type        = string
}

variable "instance_id" {
  description = "EC2 Instance ID"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}