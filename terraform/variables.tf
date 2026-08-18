variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "boba-eks"
}

variable "creator" {
  description = "Resource creator name"
  type        = string
  default     = "Matteo.Ta"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "webserver"
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
  default     = "boba-eks-task"
}

