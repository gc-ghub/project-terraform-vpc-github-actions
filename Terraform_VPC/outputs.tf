output "tags" {
  value = local.tags
}

output "vpc_id" {
    value = module.vpc
  
}

output "sg" {
  value = module.sg
}

output "ec2" {
  value = module.ec2.ec2_id
}


output "alb" {
    value = module.alb
  
}