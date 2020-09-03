variable "name" {
  description = "Lambda name"
}

variable "handler" {
  description = "Lambda handler name"
  default     = "handler"
}

variable "runtime" {
  description = "Lambda runtime"
  default     = "nodejs12.x"
}

variable "role" {
  description = "Lambda IAM role"
}
