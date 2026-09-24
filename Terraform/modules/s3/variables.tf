variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "bucket_prefix" {
  type = string
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "eks_node_role_name" {
  type = string
}
