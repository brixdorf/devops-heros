variable "aws_region" {
  description = "AWS region to create the bucket in"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Used as the bucket name prefix and as a tag"
  type        = string
}

variable "owner" {
  description = "Owner tag added to every resource"
  type        = string
}

variable "environment" {
  description = "Environment name, part of the bucket name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "enable_versioning" {
  description = "Keep old versions of objects when they are overwritten or deleted"
  type        = bool
  default     = true
}
