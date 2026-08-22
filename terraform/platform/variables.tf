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

