variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "runtime" {
  description = "Lambda runtime environment"
  default = "nodejs12.x"
}

variable "environment" {
  description = "The environment to deploy to"
  default = "demo"
}

variable "method" {
  description = "HTTP method"
  default = "GET"
}

variable "dbusername" {}
variable "dbpassword" {}
