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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "public_subnets" {
  description = "Public subnet configuration"
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    public-a = {
      cidr = "10.0.0.0/20"
      az   = "eu-west-2a"
    }

    public-b = {
      cidr = "10.0.16.0/20"
      az   = "eu-west-2b"
    }
  }
}

variable "private_subnets" {
  description = "Private subnet configuration"
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    private-a = {
      cidr = "10.0.128.0/20"
      az   = "eu-west-2a"
    }

    private-b = {
      cidr = "10.0.144.0/20"
      az   = "eu-west-2b"
    }
  }
}