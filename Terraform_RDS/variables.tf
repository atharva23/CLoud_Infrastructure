variable "rds_instance_class" {
  description = "The instance class for the RDS database."
  type        = string
}

variable "rds_allocated_storage" {
  description = "The allocated storage for the RDS database."
  type        = number
}

variable "rds_root_password" {
  description = "The root password for the RDS database."
  type        = string
}

variable "rds_superuser_name" {
  description = "The superuser name for the RDS database."
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs where RDS will be deployed."
  type        = list(string)
  default     = []
}