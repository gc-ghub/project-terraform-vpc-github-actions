variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Name of the environment."
  type        = string
}


 variable "resource_tags" {
   description = "Tags to set for all resources"
   type        = map(string)
   default     = { }
}



variable "vpc_cidr" {
    description = "CIDR block for custom vpc"
    type = string 
}


variable "subnet_cidr_block" {
    description = "CIDR block for subnets"
    type = list(string)
  
}


variable "instance_type" {
    type = string
    
  
}