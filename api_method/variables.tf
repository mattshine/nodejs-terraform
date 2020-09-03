variable "rest_api_id" {
  description = "ID of the rest API"
}

variable "path" {
  description = "API resource path"
}

variable "lambda" {
  description = "The Lambda name"
}

variable "resource_id" {
  description = "API resource ID"
}

variable "method" {
  description = "The HTTP method"
  default     = "GET"
}

variable "region" {
  description = "AWS Region"
  default = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID"
}
