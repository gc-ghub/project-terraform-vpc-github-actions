variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "my-project"
}

variable "environment" {
  description = "Name of the environment."
  type        = string
  default     = "dev"
}


 variable "resource_tags" {
   description = "Tags to set for all resources"
   type        = map(string)
   default     = { }
}


variable "sg_id" {
    type = string
  
}

variable "subnet_id" {
    type = list(string)
  
}

variable "vpc_id" {
    type = string
  
}

variable "instace_id" {
    type = list(string)
  
}