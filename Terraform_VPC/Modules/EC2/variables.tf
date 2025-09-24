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


variable "instance_type" {
    type = string
    default = "t3.micro"
  
}

variable "sg_id" {
    type = string
  
}

variable "subnet_id" {
    type = list(string)
  
}

variable "ec2_names" {
    description = "EC2 names"
    type = list(string)
    default = ["WebServer1", "WebServer2"]
}