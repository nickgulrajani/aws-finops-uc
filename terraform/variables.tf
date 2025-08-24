variable "project" {
  type        = string
  default     = "finops-zero-cost"
  description = "Project tag"
}

variable "environment" {
  type        = string
  default     = "dryrun"
  description = "Environment name"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region (no API calls in dry run)"
}

variable "name_prefix" {
  type        = string
  default     = "finops"
  description = "Resource name prefix"
}

variable "org_target_id" {
  type        = string
  default     = "r-exampleroot"
  description = "Organizations root/OU ID for policy attachment (placeholder)"
}

