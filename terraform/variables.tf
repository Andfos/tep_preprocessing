variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "The availablity zone to deploy the resources"
  type        = string
  default     = "us-east-1a"
}

variable "state_bucket" {
  description = "The S3 bucket to store the Terraform state file"
  type        = string
  default     = "renovaro-general-purpose"
}

