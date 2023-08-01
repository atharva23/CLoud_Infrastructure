variable "region" {
  description = "AWS region"
  default     = "us-east-1"  
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name"
}


variable "bucket_name" {
  description = "S3 bucket name"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for the auto scaling group"
  default     = ["us-east-1a"]  # Set your desired default availability zones here
}
