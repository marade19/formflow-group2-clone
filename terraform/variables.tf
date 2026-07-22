variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "project_name" {
  description = "project name"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_1_cidr" {
  type = string
}

variable "public_subnet_2_cidr" {
  type = string
}

variable "availability_zone_1" {
  type = string
}

variable "availability_zone_2" {
  type = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "instance_type" {
  type = string
}

variable "github_repository" {
  description = "GitHub repository URL"
  type        = string
}